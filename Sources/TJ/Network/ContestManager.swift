import Foundation
import Combine
import SwiftUI

public struct ApiContestItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let hashtag: String
    public let participantLimit: Int
    public let voteCount: Int
    public let entryCount: Int
    public let hostName: String?
    public let codes: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case hashtag
        case participantLimit = "participant_limit"
        case voteCount = "vote_count"
        case entryCount = "entry_count"
        case hostName = "host_name"
        case codes
    }

    public init(
        id: String = "",
        title: String = "",
        description: String = "",
        hashtag: String = "",
        participantLimit: Int = 20,
        voteCount: Int = 0,
        entryCount: Int = 0,
        hostName: String? = nil,
        codes: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.hashtag = hashtag
        self.participantLimit = participantLimit
        self.voteCount = voteCount
        self.entryCount = entryCount
        self.hostName = hostName
        self.codes = codes
    }
}

public struct ApiLeaderboardEntryItem: Identifiable, Codable, Hashable, Sendable {
    public var id: String { postId }
    public let postId: String
    public let authorName: String
    public let avatarUrl: String?
    public var votes: Int

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case authorName = "author_name"
        case avatarUrl = "avatar_url"
        case votes
    }
}

struct ContestListResponseDTO: Codable {
    let contests: [ApiContestItem]?
}

struct ContestDetailResponseDTO: Codable {
    let contest: ApiContestItem?
    let leaderboard: [ApiLeaderboardEntryItem]?
}

struct CastVoteResponseDTO: Codable {
    let votes: Int
    let points: Int
}

@MainActor
public final class ContestManager: ObservableObject {
    public static let shared = ContestManager()

    @Published public var contests: [ApiContestItem] = []
    @Published public var activeFeedPosts: [FeedPost] = []
    @Published public var activeContest: ApiContestItem? = nil
    @Published public var leaderboard: [ApiLeaderboardEntryItem] = []
    @Published public var userPoints: Int = 20
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    private init() {}

    public func fetchContests(query: String = "", sort: String = "new") async {
        isLoading = true
        errorMessage = nil
        var components = URLComponents(string: "\(NetworkClient.shared.baseURL)/contests")!
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "sort", value: sort)]
        if !query.isEmpty { queryItems.append(URLQueryItem(name: "q", value: query)) }
        components.queryItems = queryItems

        guard let url = components.url else { isLoading = false; return }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ContestListResponseDTO.self, from: data)
                self.contests = decoded.contests ?? []
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func fetchContestFeed(hashtag: String) async {
        isLoading = true
        let clean = hashtag.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/contests/\(clean)") else {
            isLoading = false
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ContestDetailResponseDTO.self, from: data)
                self.activeContest = decoded.contest
                self.leaderboard = decoded.leaderboard ?? []
            }
        } catch {}

        // Fetch posts for this contest hashtag
        if let postsData = try? await API.data("posts", query: ["hashtag": clean, "page": "1"]) {
            let fetched = LiveJSON.posts(from: postsData)
            var postMap = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })

            // Include leaderboard entries as fallback posts if not returned in posts list
            for entry in self.leaderboard where !entry.postId.isEmpty && postMap[entry.postId] == nil {
                let fallback = FeedPost(
                    id: entry.postId,
                    authorName: entry.authorName.isEmpty ? "Contestant" : entry.authorName,
                    authorAvatar: entry.avatarUrl,
                    content: "Contest entry for #\(clean)",
                    likes: entry.votes,
                    isContest: true
                )
                postMap[entry.postId] = fallback
            }

            self.activeFeedPosts = Array(postMap.values).map { var p = $0; p.isContest = true; return p }
        }
        isLoading = false
    }

    public func createContest(title: String, description: String, hashtag: String, limit: Int = 20) async -> ApiContestItem? {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/contests") else { return nil }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body: [String: Any] = [
                "title": title,
                "description": description,
                "hashtag": hashtag.replacingOccurrences(of: "#", with: ""),
                "participant_limit": limit
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201 {
                let contest = try JSONDecoder().decode(ApiContestItem.self, from: data)
                await fetchContests()
                return contest
            }
        } catch {}
        return nil
    }

    public func redeemCode(hashtag: String, code: String) async -> Bool {
        let clean = hashtag.replacingOccurrences(of: "#", with: "")
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/contests/\(clean)/redeem") else { return false }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try? JSONEncoder().encode(["code": code])
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    public func castVote(postId: String, votes: Int = 1) async -> Bool {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/contests/votes") else { return false }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body: [String: Any] = ["post_id": postId, "votes": votes]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(CastVoteResponseDTO.self, from: data)
                self.userPoints = decoded.points
                if let idx = activeFeedPosts.firstIndex(where: { $0.id == postId }) {
                    activeFeedPosts[idx].likes = decoded.votes
                }
                return true
            }
        } catch {}
        return false
    }
}
