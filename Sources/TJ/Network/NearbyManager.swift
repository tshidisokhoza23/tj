import Foundation
import Combine
import SwiftUI

public struct NearbyPostItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let userId: String
    public let authorName: String
    public let authorAvatarUrl: String?
    public let content: String
    public let areaName: String
    public let latitude: Double
    public let longitude: Double
    public var likeCount: Int
    public var replyCount: Int
    public var isLiked: Bool
    public let createdAt: String?
    public let distanceKm: Double
    public var isResolved: Bool
    public let imageUrls: [String]
    public var replies: [NearbyReplyItem]

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case authorName = "author_name"
        case authorAvatarUrl = "author_avatar_url"
        case content
        case areaName = "area_name"
        case latitude
        case longitude
        case likeCount = "like_count"
        case replyCount = "reply_count"
        case isLiked = "is_liked"
        case createdAt = "created_at"
        case distanceKm = "distance_km"
        case isResolved = "is_resolved"
        case imageUrls = "image_urls"
        case replies
    }

    public init(
        id: String,
        userId: String = "",
        authorName: String = "Neighbor",
        authorAvatarUrl: String? = nil,
        content: String = "",
        areaName: String = "Nearby",
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        likeCount: Int = 0,
        replyCount: Int = 0,
        isLiked: Bool = false,
        createdAt: String? = nil,
        distanceKm: Double = 1.0,
        isResolved: Bool = false,
        imageUrls: [String] = [],
        replies: [NearbyReplyItem] = []
    ) {
        self.id = id
        self.userId = userId
        self.authorName = authorName
        self.authorAvatarUrl = authorAvatarUrl
        self.content = content
        self.areaName = areaName
        self.latitude = latitude
        self.longitude = longitude
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.isLiked = isLiked
        self.createdAt = createdAt
        self.distanceKm = distanceKm
        self.isResolved = isResolved
        self.imageUrls = imageUrls
        self.replies = replies
    }
}

public struct NearbyReplyItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let postId: String
    public let userId: String
    public let authorName: String
    public let authorAvatarUrl: String?
    public let content: String
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case authorName = "author_name"
        case authorAvatarUrl = "author_avatar_url"
        case content
        case createdAt = "created_at"
    }
}

public struct NearbyChatRequestItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let senderId: String
    public let senderName: String
    public let senderAvatarUrl: String?
    public let recipientId: String
    public let recipientName: String
    public let postId: String
    public let postSnippet: String
    public let message: String
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case senderName = "sender_name"
        case senderAvatarUrl = "sender_avatar_url"
        case recipientId = "recipient_id"
        case recipientName = "recipient_name"
        case postId = "post_id"
        case postSnippet = "post_reference_snippet"
        case message = "inquiry_message"
        case createdAt = "created_at"
    }
}

struct NearbyPostsResponseDTO: Codable {
    let posts: [NearbyPostItem]
}

struct NearbyRepliesResponseDTO: Codable {
    let replies: [NearbyReplyItem]
}

struct ToggleLikeResponseDTO: Codable {
    let is_liked: Bool
    let like_count: Int
}

struct ChatRequestsResponseDTO: Codable {
    let requests: [NearbyChatRequestItem]
}

@MainActor
public final class NearbyManager: ObservableObject {
    public static let shared = NearbyManager()

    @Published public var posts: [NearbyPostItem] = []
    @Published public var myPosts: [NearbyPostItem] = []
    @Published public var chatRequests: [NearbyChatRequestItem] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var currentRadiusKm: Int = 10
    @Published public var selectedAreaName: String = "Nearby"

    private init() {}

    public func fetchNearbyPosts(lat: Double = -26.19, lng: Double = 28.03, radiusKm: Int = 10, area: String? = nil) async {
        isLoading = true
        errorMessage = nil
        self.currentRadiusKm = radiusKm
        var components = URLComponents(string: "\(NetworkClient.shared.baseURL)/nearby/posts")!
        var queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lng", value: "\(lng)"),
            URLQueryItem(name: "radius", value: "\(radiusKm)")
        ]
        if let area, !area.isEmpty, area != "Nearby" {
            queryItems.append(URLQueryItem(name: "area", value: area))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
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
                let decoded = try JSONDecoder().decode(NearbyPostsResponseDTO.self, from: data)
                self.posts = decoded.posts
            } else {
                self.errorMessage = "Could not load nearby posts"
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func fetchMyPosts() async {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/posts/mine") else { return }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(NearbyPostsResponseDTO.self, from: data)
                self.myPosts = decoded.posts
            }
        } catch {}
    }

    public func createNearbyPost(content: String, areaName: String, latitude: Double, longitude: Double, imageUrls: [String] = []) async -> Bool {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/posts") else { return false }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body: [String: Any] = [
                "content": content,
                "area_name": areaName,
                "latitude": latitude,
                "longitude": longitude,
                "image_urls": imageUrls
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201 {
                await fetchNearbyPosts(lat: latitude, lng: longitude, radiusKm: currentRadiusKm, area: areaName)
                return true
            }
        } catch {}
        return false
    }

    public func toggleLike(postId: String) async {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likeCount += posts[index].isLiked ? 1 : -1

        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/posts/\(postId)/like") else { return }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ToggleLikeResponseDTO.self, from: data)
                posts[index].isLiked = decoded.is_liked
                posts[index].likeCount = decoded.like_count
            }
        } catch {}
    }

    public func fetchReplies(postId: String) async -> [NearbyReplyItem] {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/posts/\(postId)/replies") else { return [] }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(NearbyRepliesResponseDTO.self, from: data)
                return decoded.replies
            }
        } catch {}
        return []
    }

    public func addReply(postId: String, content: String) async -> NearbyReplyItem? {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/posts/\(postId)/replies") else { return nil }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body = ["content": content]
            request.httpBody = try? JSONEncoder().encode(body)
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201 {
                let reply = try JSONDecoder().decode(NearbyReplyItem.self, from: data)
                if let index = posts.firstIndex(where: { $0.id == postId }) {
                    posts[index].replyCount += 1
                }
                return reply
            }
        } catch {}
        return nil
    }

    public func resolvePost(postId: String, isResolved: Bool) async -> Bool {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/posts/\(postId)/resolve") else { return false }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body: [String: Any] = ["is_resolved": isResolved]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                if let index = posts.firstIndex(where: { $0.id == postId }) {
                    posts[index].isResolved = isResolved
                }
                if let index = myPosts.firstIndex(where: { $0.id == postId }) {
                    myPosts[index].isResolved = isResolved
                }
                return true
            }
        } catch {}
        return false
    }

    public func deletePost(postId: String) async -> Bool {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/posts/\(postId)") else { return false }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                posts.removeAll { $0.id == postId }
                myPosts.removeAll { $0.id == postId }
                return true
            }
        } catch {}
        return false
    }

    public func sendChatRequest(postId: String, message: String) async -> Bool {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/requests") else { return false }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body = ["post_id": postId, "message": message]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201
        } catch {
            return false
        }
    }

    public func fetchChatRequests() async {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/requests") else { return }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ChatRequestsResponseDTO.self, from: data)
                self.chatRequests = decoded.requests
            }
        } catch {}
    }

    public func respondChatRequest(requestId: String, accept: Bool) async -> Bool {
        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/nearby/requests/\(requestId)/respond") else { return false }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let body = ["accept": accept]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                chatRequests.removeAll { $0.id == requestId }
                return true
            }
        } catch {}
        return false
    }
}
