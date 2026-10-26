import Foundation
import Combine
import SwiftUI

public struct NewsArticleItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let source: String
    public let category: String
    public let title: String
    public let summary: String
    public let imageUrl: String?
    public let originalUrl: String
    public var likeCount: Int
    public var commentCount: Int
    public let publishedAt: String?
    public let createdAt: String?
    public var hasLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case source
        case category
        case title
        case summary
        case imageUrl = "image_url"
        case originalUrl = "original_url"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case hasLiked = "has_liked"
    }

    public init(
        id: String,
        source: String = "News24",
        category: String = "General",
        title: String,
        summary: String = "",
        imageUrl: String? = nil,
        originalUrl: String = "https://www.news24.com",
        likeCount: Int = 0,
        commentCount: Int = 0,
        publishedAt: String? = nil,
        createdAt: String? = nil,
        hasLiked: Bool = false
    ) {
        self.id = id
        self.source = source
        self.category = category
        self.title = title
        self.summary = summary
        self.imageUrl = imageUrl
        self.originalUrl = originalUrl
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.publishedAt = publishedAt
        self.createdAt = createdAt
        self.hasLiked = hasLiked
    }
}

struct NewsResponseDTO: Codable {
    let articles: [NewsArticleItem]?
    let next_cursor: String?
}

struct ToggleNewsLikeResponseDTO: Codable {
    let article_id: String
    let has_liked: Bool
    let like_count: Int
}

@MainActor
public final class NewsManager: ObservableObject {
    public static let shared = NewsManager()

    @Published public var articles: [NewsArticleItem] = []
    @Published public var isLoading: Bool = false
    @Published public var isPaginationLoading: Bool = false
    @Published public var errorMessage: String? = nil

    private var nextCursor: String? = nil
    private var canLoadMore: Bool = true

    private init() {}

    public func fetchInitialNews(category: String? = "All") async {
        isLoading = true
        errorMessage = nil
        nextCursor = nil
        canLoadMore = true

        var components = URLComponents(string: "\(NetworkClient.shared.baseURL)/news")!
        var queryItems = [URLQueryItem(name: "limit", value: "20")]
        if let category, !category.isEmpty, !category.caseInsensitiveCompare("All").contains(.orderedSame) {
            queryItems.append(URLQueryItem(name: "category", value: category.lowercased()))
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
                let decoded = try JSONDecoder().decode(NewsResponseDTO.self, from: data)
                self.articles = decoded.articles ?? []
                self.nextCursor = decoded.next_cursor
                self.canLoadMore = decoded.next_cursor != nil && !self.articles.isEmpty
            } else {
                self.errorMessage = "Could not load news"
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func loadMoreNews(category: String? = "All") async {
        guard !isPaginationLoading, canLoadMore, let cursor = nextCursor, !cursor.isEmpty else { return }
        isPaginationLoading = true

        var components = URLComponents(string: "\(NetworkClient.shared.baseURL)/news")!
        var queryItems = [
            URLQueryItem(name: "cursor", value: cursor),
            URLQueryItem(name: "limit", value: "20")
        ]
        if let category, !category.isEmpty, !category.caseInsensitiveCompare("All").contains(.orderedSame) {
            queryItems.append(URLQueryItem(name: "category", value: category.lowercased()))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            isPaginationLoading = false
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
                let decoded = try JSONDecoder().decode(NewsResponseDTO.self, from: data)
                let newArticles = decoded.articles ?? []
                self.nextCursor = decoded.next_cursor
                self.canLoadMore = decoded.next_cursor != nil && !newArticles.isEmpty

                var existingIds = Set(self.articles.map { $0.id })
                for art in newArticles {
                    if !existingIds.contains(art.id) {
                        existingIds.insert(art.id)
                        self.articles.append(art)
                    }
                }
            }
        } catch {}
        isPaginationLoading = false
    }

    public func toggleLike(articleId: String) async {
        guard let index = articles.firstIndex(where: { $0.id == articleId }) else { return }
        articles[index].hasLiked.toggle()
        articles[index].likeCount += articles[index].hasLiked ? 1 : -1

        guard let url = URL(string: "\(NetworkClient.shared.baseURL)/news/\(articleId)/like") else { return }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            if let token = NetworkClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ToggleNewsLikeResponseDTO.self, from: data)
                articles[index].hasLiked = decoded.has_liked
                articles[index].likeCount = decoded.like_count
            }
        } catch {}
    }
}
