import SwiftUI
import AVFoundation
import AVKit
import PhotosUI
import UniformTypeIdentifiers
import UIKit

public struct FeedPost: Identifiable, Codable, Sendable {
    public let id: String
    let authorId: String
    let authorName: String
    let authorHandle: String
    let authorAvatar: String?
    let content: String
    let mediaURLs: [String]
    var likes: Int
    var repliesCount: Int
    let postType: String
    var isLiked: Bool
    var isBookmarked: Bool
    var views: Int
    var shares: Int
    var repostCount: Int
    var quoteCount: Int
    var isReposted: Bool
    let mediaType: String
    var isVerifiedAuthor: Bool
    var timestamp: Int64
    var isAuthorFollowed: Bool
    var repostOfId: String
    var originalAuthorId: String
    var originalAuthorName: String
    var originalAuthorHandle: String
    var originalAuthorAvatar: String?
    var originalContent: String
    var originalMediaURLs: [String]
    var originalMediaType: String
    var originalPostType: String
    var latestReplyAuthor: String
    var latestReplyText: String
    var mood: String
    var aiAssisted: Bool
    var collaboratorCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case authorName = "author_name"
        case authorHandle = "author_handle"
        case authorAvatar = "author_avatar_url"
        case content
        case views
        case shares
        case repostCount = "repost_count"
        case quoteCount = "quote_count"
        case isReposted = "is_reposted"
        case mediaType = "media_type"
        case mediaURLs = "media_urls"
        case likes
        case repliesCount = "replies_count"
        case postType = "post_type"
        case isLiked = "is_liked"
        case isBookmarked = "is_bookmarked"
    }

    init(
        id: String = UUID().uuidString,
        authorId: String = "",
        authorName: String = "",
        authorHandle: String = "",
        authorAvatar: String? = nil,
        content: String = "",
        mediaURLs: [String] = [],
        likes: Int = 0,
        repliesCount: Int = 0,
        postType: String = "",
        isLiked: Bool = false,
        isBookmarked: Bool = false,
        views: Int = 0,
        shares: Int = 0,
        repostCount: Int = 0,
        quoteCount: Int = 0,
        isReposted: Bool = false,
        mediaType: String = "",
        isVerifiedAuthor: Bool = false,
        timestamp: Int64 = 0,
        isAuthorFollowed: Bool = false,
        repostOfId: String = "",
        originalAuthorId: String = "",
        originalAuthorName: String = "",
        originalAuthorHandle: String = "",
        originalAuthorAvatar: String? = nil,
        originalContent: String = "",
        originalMediaURLs: [String] = [],
        originalMediaType: String = "",
        originalPostType: String = "",
        latestReplyAuthor: String = "",
        latestReplyText: String = "",
        mood: String = "",
        aiAssisted: Bool = false,
        collaboratorCount: Int = 0
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorHandle = authorHandle
        self.authorAvatar = authorAvatar
        self.content = content
        self.mediaURLs = mediaURLs
        self.likes = likes
        self.repliesCount = repliesCount
        self.postType = postType
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
        self.views = views
        self.shares = shares
        self.repostCount = repostCount
        self.quoteCount = quoteCount
        self.isReposted = isReposted
        self.mediaType = mediaType
        self.isVerifiedAuthor = isVerifiedAuthor
        self.timestamp = timestamp
        self.isAuthorFollowed = isAuthorFollowed
        self.repostOfId = repostOfId
        self.originalAuthorId = originalAuthorId
        self.originalAuthorName = originalAuthorName
        self.originalAuthorHandle = originalAuthorHandle
        self.originalAuthorAvatar = originalAuthorAvatar
        self.originalContent = originalContent
        self.originalMediaURLs = originalMediaURLs
        self.originalMediaType = originalMediaType
        self.originalPostType = originalPostType
        self.latestReplyAuthor = latestReplyAuthor
        self.latestReplyText = latestReplyText
        self.mood = mood
        self.aiAssisted = aiAssisted
        self.collaboratorCount = collaboratorCount
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(authorId, forKey: .authorId)
        try c.encode(authorName, forKey: .authorName)
        try c.encode(authorHandle, forKey: .authorHandle)
        try c.encodeIfPresent(authorAvatar, forKey: .authorAvatar)
        try c.encode(content, forKey: .content)
        try c.encode(views, forKey: .views)
        try c.encode(shares, forKey: .shares)
        try c.encode(repostCount, forKey: .repostCount)
        try c.encode(quoteCount, forKey: .quoteCount)
        try c.encode(isReposted, forKey: .isReposted)
        try c.encode(mediaType, forKey: .mediaType)
        try c.encode(mediaURLs, forKey: .mediaURLs)
        try c.encode(likes, forKey: .likes)
        try c.encode(repliesCount, forKey: .repliesCount)
        try c.encode(postType, forKey: .postType)
        try c.encode(isLiked, forKey: .isLiked)
        try c.encode(isBookmarked, forKey: .isBookmarked)
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        views = Self.flexInt(c, .views)
        shares = Self.flexInt(c, .shares)
        repostCount = Self.flexInt(c, .repostCount)
        quoteCount = Self.flexInt(c, .quoteCount)
        isReposted = (try? c.decode(Bool.self, forKey: .isReposted)) ?? false
        mediaType = try c.decodeIfPresent(String.self, forKey: .mediaType) ?? ""
        id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        authorId = try c.decodeIfPresent(String.self, forKey: .authorId) ?? ""
        authorName = try c.decodeIfPresent(String.self, forKey: .authorName) ?? ""
        authorHandle = try c.decodeIfPresent(String.self, forKey: .authorHandle) ?? ""
        authorAvatar = try c.decodeIfPresent(String.self, forKey: .authorAvatar)
        content = try c.decodeIfPresent(String.self, forKey: .content) ?? ""
        mediaURLs = (try? c.decode([String].self, forKey: .mediaURLs)) ?? []
        likes = Self.flexInt(c, .likes)
        repliesCount = Self.flexInt(c, .repliesCount)
        postType = try c.decodeIfPresent(String.self, forKey: .postType) ?? ""
        isLiked = (try? c.decode(Bool.self, forKey: .isLiked)) ?? false
        isBookmarked = (try? c.decode(Bool.self, forKey: .isBookmarked)) ?? false
        isVerifiedAuthor = false
        timestamp = 0
        isAuthorFollowed = false
        repostOfId = ""
        originalAuthorId = ""
        originalAuthorName = ""
        originalAuthorHandle = ""
        originalAuthorAvatar = nil
        originalContent = ""
        originalMediaURLs = []
        originalMediaType = ""
        originalPostType = ""
        latestReplyAuthor = ""
        latestReplyText = ""
        mood = ""
        aiAssisted = false
        collaboratorCount = 0
    }

    private static func flexInt(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> Int {
        if let value = try? c.decode(Int.self, forKey: key) { return value }
        if let value = try? c.decode(Double.self, forKey: key) { return Int(value) }
        return 0
    }

    var title: String {
        if !authorName.isEmpty { return authorName }
        if !authorHandle.isEmpty { return "@\(authorHandle)" }
        return ""
    }

    var formattedTimestamp: String {
        guard timestamp > 0 else { return "" }
        let now = Date().timeIntervalSince1970
        let ts = timestamp > 1_000_000_000_000 ? Double(timestamp) / 1000 : Double(timestamp)
        let seconds = max(0, Int64(now - ts))
        if seconds < 60 { return "now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h" }
        let days = hours / 24
        if days < 7 { return "\(days)d" }
        let weeks = days / 7
        return "\(weeks)w"
    }

    var mediaURL: URL? { Self.resolve(mediaURLs.first) }

    var playbackURL: URL? {
        let preferred = mediaURLs.first { raw in
            let lower = raw.lowercased()
            return !lower.contains("thumb") && (lower.contains(".mp4") || lower.contains(".m3u8") || lower.contains(".mov") || lower.contains(".m4v") || lower.contains(".webm") || lower.contains(".tmp") || lower.contains("video") || lower.contains("/shorts/"))
        } ?? mediaURLs.first { !$0.lowercased().contains("thumb") } ?? mediaURLs.first
        return Self.resolve(preferred)
    }

    var playsAsVideo: Bool {
        let type = mediaType.uppercased()
        if type.contains("VIDEO") { return true }
        if postType == "short" { return playbackURL != nil }
        let raw = (playbackURL ?? mediaURL)?.absoluteString.lowercased() ?? ""
        return raw.contains(".mp4") || raw.contains(".m3u8") || raw.contains(".mov") || raw.contains("video") || raw.contains("/shorts/")
    }

    var hasOriginal: Bool {
        !repostOfId.isEmpty && (!originalContent.isEmpty || !originalMediaURLs.isEmpty || !originalAuthorName.isEmpty)
    }

    var isSimpleRepost: Bool {
        hasOriginal && content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var quotedPost: FeedPost? {
        guard hasOriginal else { return nil }
        return FeedPost(
            id: repostOfId,
            authorId: originalAuthorId,
            authorName: originalAuthorName,
            authorHandle: originalAuthorHandle,
            authorAvatar: originalAuthorAvatar,
            content: originalContent,
            mediaURLs: originalMediaURLs,
            postType: originalPostType,
            mediaType: originalMediaType
        )
    }

    var displayPost: FeedPost { isSimpleRepost ? (quotedPost ?? self) : self }

    static func resolve(_ raw: String?) -> URL? {
        guard var raw, !raw.isEmpty else { return nil }
        let origin = AppBackend.origin.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") || raw.hasPrefix("data:") || raw.hasPrefix("file:") {
            if raw.contains("://localhost") || raw.contains("://127.0.0.1"), let host = URL(string: raw)?.host {
                raw = raw
                    .replacingOccurrences(of: "http://\(host)", with: origin)
                    .replacingOccurrences(of: "https://\(host)", with: origin)
            }
            if raw.hasPrefix("http://"), origin.hasPrefix("https://") {
                raw = "https://" + String(raw.dropFirst("http://".count))
            }
            return URL(string: raw)
        }
        var path = raw.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if !path.hasPrefix("uploads/") {
            path = "uploads/" + path
        }
        return URL(string: origin + "/" + path)
    }

    static func decodeList(_ data: Data) -> [FeedPost] {
        if let list = try? JSONDecoder().decode([FeedPost].self, from: data) {
            return list
        }
        struct Envelope: Decodable {
            struct Item: Decodable { let post: FeedPost? }
            let items: [Item]?
            let shorts: [FeedPost]?
            let posts: [FeedPost]?
        }
        guard let envelope = try? JSONDecoder().decode(Envelope.self, from: data) else { return [] }
        if let shorts = envelope.shorts { return shorts }
        if let posts = envelope.posts { return posts }
        return (envelope.items ?? []).compactMap(\.post)
    }
}

enum MediaActions {
    static func like(_ id: String) async { _ = try? await API.data("posts/\(id)/like", method: "POST") }
    static func bookmark(_ id: String) async { _ = try? await API.data("posts/\(id)/bookmark", method: "POST") }
    static func repost(_ id: String) async { _ = try? await API.data("posts/\(id)/repost", method: "POST") }
    static func view(_ id: String) async { _ = try? await API.data("posts/\(id)/view", method: "POST") }
    static func share(_ id: String) async { _ = try? await API.data("posts/\(id)/share", method: "POST") }
    static func reply(_ id: String, text: String) async throws {
        _ = try await API.data("posts/\(id)/replies", method: "POST", json: ["reply_text": text])
    }
    static func quote(_ id: String, text: String) async throws {
        _ = try await API.data("posts", method: "POST", json: [
            "content": text,
            "post_type": "standard",
            "repost_of_id": id
        ])
    }
    static func report(_ id: String, reason: String) async {
        _ = try? await API.data("posts/\(id)/report", method: "POST", json: ["reason": reason])
    }
    static func shareSheet(_ post: FeedPost) {
        let link = "https://firstapp.com/post/\(post.id)"
        let intro = post.playsAsVideo ? "Watch this short on TJ" : "See this on TJ"
        let body = post.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = body.isEmpty ? "\(intro)\n\(link)" : "\(intro)\n\(body)\n\(link)"
        DispatchQueue.main.async {
            let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let root = scene.windows.first?.rootViewController else { return }
            var presenter = root
            while let presented = presenter.presentedViewController { presenter = presented }
            presenter.present(controller, animated: true)
        }
    }
    static func copyLink(_ post: FeedPost) {
        UIPasteboard.general.string = "https://firstapp.com/post/\(post.id)"
    }
    static func likeReply(_ id: String) async { _ = try? await API.data("post-replies/\(id)/like", method: "POST") }
    static func repostReply(_ id: String) async { _ = try? await API.data("post-replies/\(id)/repost", method: "POST") }
    static func bookmarkReply(_ id: String) async { _ = try? await API.data("post-replies/\(id)/bookmark", method: "POST") }
    static func create(content: String, type: String = "standard", mediaURLs: [String] = [], location: String = "", compose: [String: Any] = [:]) async throws -> String {
        let data = try await API.data("posts", method: "POST", json: [
            "content": content,
            "post_type": type,
            "media_urls": mediaURLs,
            "location": location
        ])
        let json = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
        let nested = json["post"] as? [String: Any]
        let id = (json["id"] as? String) ?? (nested?["id"] as? String) ?? ""
        if !id.isEmpty, !compose.isEmpty {
            _ = try? await API.data("compose/posts/\(id)", method: "PUT", json: compose)
        }
        return id
    }
    static func userPosts(userId: String, type: String) async -> [FeedPost] {
        guard !userId.isEmpty, userId != "me", userId != "currentUser" else { return [] }
        guard let data = try? await API.data("posts", query: ["user_id": userId, "type": type, "page": "1"]) else { return [] }
        let parsed = LiveJSON.posts(from: data)
        return parsed.isEmpty ? FeedPost.decodeList(data) : parsed
    }

    static func upload(data: Data, filename: String, mime: String, folder: String) async throws -> String {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        func append(_ text: String) { body.append(Data(text.utf8)) }
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"folder\"\r\n\r\n\(folder)\r\n")
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\nContent-Type: \(mime)\r\n\r\n")
        body.append(data)
        append("\r\n--\(boundary)--\r\n")
        guard var req = API.request("uploads", method: "POST", body: body) else { throw APIError.badURL }
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let (responseData, response) = try await URLSession.shared.data(for: req)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(code),
              let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let url = json["url"] as? String, !url.isEmpty else {
            throw APIError.status(code, String(data: responseData, encoding: .utf8) ?? "upload failed")
        }
        return url
    }
}

/// Android Social tab: `GET media/feed` matching Screenshot 2.
public struct ConnectedSocialFeedView: View {
    public var onProfileClick: (String) -> Void
    public var onDirectMessagesClick: () -> Void

    public init(onProfileClick: @escaping (String) -> Void = { _ in }, onDirectMessagesClick: @escaping () -> Void = {}) {
        self.onProfileClick = onProfileClick
        self.onDirectMessagesClick = onDirectMessagesClick
    }

    public var body: some View {
        SocialFeedView(onProfileClick: onProfileClick, onDirectMessagesClick: onDirectMessagesClick)
    }
}

struct SocialFeedView: View {
    public var onProfileClick: (String) -> Void = { _ in }
    public var onDirectMessagesClick: () -> Void = {}

    @State private var posts: [FeedPost] = []
    @State private var nextOffset = 0
    @State private var hasMore = true
    @State private var loadingMore = false
    @State private var status = "Loading social feed..."
    @State private var draft = ""
    @State private var selectedCategory = 0
    @State private var replyPost: FeedPost?
    @State private var replyText = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedPost: FeedPost?
    @State private var repostTarget: FeedPost?
    @State private var moreTarget: FeedPost?
    @State private var quoteTarget: FeedPost?
    @State private var quoteText = ""
    @State private var showSocialMenu = false
    @State private var showCreatePost = false
    @State private var showSavedPosts = false
    @State private var showSocialNotes = false
    @State private var showSocialSettings = false
    @State private var showSocialSearch = false
    @State private var showCircles = false
    @State private var showCreatorDashboard = false
    @State private var qualityMode = "balanced"
    @State private var postContext = ""
    @State private var contextPostId = ""
    @State private var contextNoteId = ""

    private let categories = [
        ("all", "All"), ("tech", "Technology"), ("music", "Music"), ("gaming", "Gaming"),
        ("sports", "Sports"), ("news", "News"), ("entertainment", "Entertainment"), ("art", "Art")
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Top App Bar matching Screenshot 2
                HStack {
                    Button(action: { showSocialMenu = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    AppLogo(size: 36)

                    Spacer()

                    Button(action: { showSocialSearch = true }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // Category Sub-Pills Row matching Screenshot 2
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<categories.count, id: \.self) { idx in
                            let isSelected = selectedCategory == idx
                            Button(action: {
                                selectedCategory = idx
                                posts = []
                                nextOffset = 0
                                hasMore = true
                                Task { await load(reset: true) }
                            }) {
                                Text(categories[idx].1)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 4)
                                    .frame(height: 32)
                                    .foregroundColor(isSelected ? .white : AppColors.brandPrimary)
                                    .background {
                                        if isSelected {
                                            AppColors.primaryGradient
                                        } else {
                                            AppColors.cardDark
                                        }
                                    }
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.clear : AppColors.borderDark, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                Menu {
                    Button("Off") { setQuality("off") }
                    Button("Balanced") { setQuality("balanced") }
                    Button("High quality only") { setQuality("high") }
                    Button("Following only") { setQuality("following") }
                    Button("Topics I follow") { setQuality("topics") }
                    Button("Anti-ragebait filter") { setQuality("calm") }
                } label: {
                    Text("Quality mode ▾  \(qualityLabel)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.brandPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 6)

                Divider()

                // Main Posts Feed List
                Group {
                    if posts.isEmpty {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text(status).font(.subheadline).foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(feedEntries) { entry in
                                    switch entry.kind {
                                    case .post(let post):
                                        FeedPostCard(
                                            post: post,
                                            onOpen: { selectedPost = post },
                                            onProfile: { onProfileClick(post.authorId) },
                                            onReply: { selectedPost = post },
                                            onRepost: { repostTarget = post },
                                            onLike: { toggleLike(post.id) },
                                            onSave: { toggleSave(post.id) },
                                            onShare: { share(post.id) },
                                            onMore: { moreTarget = post }
                                        )
                                        .id(post.id)
                                    case .ad(let slot):
                                        StableFeedAd(slot: slot)
                                            .id(slot)
                                    }
                                }
                                if hasMore {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .onAppear { Task { await load(reset: false) } }
                                }
                            }
                        }
                        .transaction { $0.animation = nil }
                    }
                }
            }

            // Floating Action Button (FAB) for Create Post
            Button(action: { showCreatePost = true }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(AppColors.primaryGradient)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .fullScreenCover(isPresented: Binding(get: { selectedPost != nil }, set: { if !$0 { selectedPost = nil } })) {
            if let post = selectedPost {
                PostDetailView(post: post, onProfileClick: onProfileClick, onClose: { selectedPost = nil })
            }
        }
        .confirmationDialog("Repost", isPresented: Binding(get: { repostTarget != nil }, set: { if !$0 { repostTarget = nil } }), titleVisibility: .visible) {
            Button(repostTarget?.isReposted == true ? "Undo Repost" : "Repost") {
                if let id = repostTarget?.id { toggleRepost(id) }
            }
            Button("Quote Post") {
                quoteTarget = repostTarget
                quoteText = ""
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showSocialMenu) {
            SocialMenuSheet(
                onProfile: {
                    showSocialMenu = false
                    let myId = UserDefaults.standard.string(forKey: "tj_user_id") ?? ""
                    if !myId.isEmpty { onProfileClick(myId) }
                },
                onCreate: { showSocialMenu = false; showCreatePost = true },
                onNotifications: { showSocialMenu = false; showSocialNotes = true },
                onMessages: { showSocialMenu = false; onDirectMessagesClick() },
                onSettings: { showSocialMenu = false; showSocialSettings = true },
                onSaved: { showSocialMenu = false; showSavedPosts = true },
                onCircles: { showSocialMenu = false; showCircles = true },
                onCreator: { showSocialMenu = false; showCreatorDashboard = true }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showCircles) {
            CirclesView()
        }
        .sheet(isPresented: $showCreatorDashboard) {
            CreatorDashboardView()
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
        .sheet(isPresented: $showSavedPosts) {
            SavedPostsSheet { post in
                showSavedPosts = false
                selectedPost = post
            }
        }
        .sheet(isPresented: $showSocialNotes) {
            SocialNotesSheet { item in
                showSocialNotes = false
                Task { await openNotification(item) }
            }
        }
        .sheet(isPresented: $showSocialSearch) {
            SocialPostSearch { post in
                showSocialSearch = false
                selectedPost = post
            }
        }
        .sheet(isPresented: $showSocialSettings) {
            SettingsView(router: NavigationRouter())
        }
        .alert("Post context", isPresented: Binding(get: { !postContext.isEmpty }, set: { if !$0 { postContext = ""; contextNoteId = "" } })) {
            Button("OK", role: .cancel) { postContext = ""; contextNoteId = "" }
            if !contextNoteId.isEmpty {
                Button("Mark note helpful") {
                    let postId = contextPostId
                    let noteId = contextNoteId
                    postContext = ""
                    contextNoteId = ""
                    Task { _ = try? await API.data("posts/\(postId)/notes/\(noteId)/vote", method: "POST", json: ["helpful": true]) }
                }
            }
        } message: {
            Text(postContext)
        }
        .confirmationDialog("Post", isPresented: Binding(get: { moreTarget != nil }, set: { if !$0 { moreTarget = nil } }), titleVisibility: .visible) {
            Button("Share") { if let id = moreTarget?.id { share(id) } }
            Button("Notes, edits, and reputation") {
                if let post = moreTarget {
                    Task { await showPostContext(post) }
                }
            }
            Button("Request a commission") {
                if let post = moreTarget {
                    Task { await requestCommission(post) }
                }
            }
            Button("Copy link") { if let post = moreTarget { MediaActions.copyLink(post) } }
            Button("Save") { if let id = moreTarget?.id { toggleSave(id) } }
            Button("Report", role: .destructive) { if let id = moreTarget?.id { Task { await MediaActions.report(id, reason: "report") } } }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(item: $quoteTarget) { post in
            NavigationStack {
                VStack(spacing: 12) {
                    TextField("Add a comment", text: $quoteText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    Button("Post") {
                        let text = quoteText.trimmingCharacters(in: .whitespacesAndNewlines)
                        quoteTarget = nil
                        Task {
                            try? await MediaActions.quote(post.id, text: text)
                            await load(reset: true)
                        }
                    }
                    .disabled(quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Spacer()
                }
                .padding()
                .navigationTitle("Quote Post")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { quoteTarget = nil }
                    }
                }
            }
        }
        .task { await load(reset: posts.isEmpty) }
        .refreshable { await load(reset: true) }
    }

    private func postIndex(_ id: String) -> Int? {
        posts.firstIndex(where: { $0.id == id })
    }

    private func toggleLike(_ id: String) {
        guard let index = postIndex(id) else { return }
        posts[index].isLiked.toggle()
        posts[index].likes += posts[index].isLiked ? 1 : -1
        Task { await MediaActions.like(id) }
    }

    private func toggleSave(_ id: String) {
        guard let index = postIndex(id) else { return }
        posts[index].isBookmarked.toggle()
        Task { await MediaActions.bookmark(id) }
    }

    private func toggleRepost(_ id: String) {
        guard let index = postIndex(id) else { return }
        posts[index].isReposted.toggle()
        posts[index].repostCount += posts[index].isReposted ? 1 : -1
        Task { await MediaActions.repost(id) }
    }

    private func showPostContext(_ post: FeedPost) async {
        async let contextData = try? API.data("posts/\(post.id)/context")
        async let editsData = try? API.data("posts/\(post.id)/edits")
        let author = post.authorId.isEmpty ? "me" : post.authorId
        async let scoreData = try? API.data("reputation/\(author)")
        let contextJSON = (try? JSONSerialization.jsonObject(with: await contextData ?? Data())) as? [String: Any]
        let editsJSON = (try? JSONSerialization.jsonObject(with: await editsData ?? Data())) as? [String: Any]
        let scoreJSON = (try? JSONSerialization.jsonObject(with: await scoreData ?? Data())) as? [String: Any]
        let noteRows = contextJSON?["notes"] as? [[String: Any]] ?? []
        let notes = noteRows.compactMap { row -> String? in
            let body = row["body"] as? String ?? ""
            guard !body.isEmpty else { return nil }
            let helpful = row["helpful_count"] as? Int ?? 0
            return "@\(row["author"] as? String ?? "user"): \(body) (\(helpful) helpful)"
        }
        let links = contextJSON?["links"] as? [String] ?? []
        let edits = (editsJSON?["edits"] as? [[String: Any]])?.compactMap { $0["previous_text"] as? String } ?? []
        let score = scoreJSON?["score"] as? Int ?? 0
        let explanation = scoreJSON?["note"] as? String ?? "Reputation uses real posts, replies, and followers."
        let noteId = noteRows.first?["id"] as? String ?? ""
        await MainActor.run {
            contextPostId = post.id
            contextNoteId = noteId
            postContext = "\(explanation)\nScore \(score).\n\nLinks\n\(links.isEmpty ? "None." : links.joined(separator: "\n"))\n\nCommunity notes\n\(notes.isEmpty ? "None yet." : notes.joined(separator: "\n"))\n\nEdit history\n\(edits.isEmpty ? "No edits." : edits.joined(separator: "\n"))"
        }
    }

    private func requestCommission(_ post: FeedPost) async {
        let artist = post.authorId
        guard !artist.isEmpty else { return }
        do {
            _ = try await API.data("commissions", method: "POST", json: ["artist_id": artist, "brief": "Commission request from your post"])
            await MainActor.run { status = "Commission request sent." }
        } catch {
            await MainActor.run { status = error.localizedDescription }
        }
    }

    private func setQuality(_ mode: String) {
        qualityMode = mode
        posts = []
        nextOffset = 0
        hasMore = true
        Task { await load(reset: true) }
    }

    private func share(_ id: String) {
        guard let index = postIndex(id) else { return }
        posts[index].shares += 1
        let post = posts[index]
        MediaActions.shareSheet(post)
        Task { await MediaActions.share(id) }
    }

    private func attachPhoto(_ item: PhotosPickerItem) async {
        defer { photoItem = nil }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let url = try await MediaActions.upload(data: data, filename: "post.jpg", mime: "image/jpeg", folder: "posts")
            let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
            draft = ""
            try await MediaActions.create(content: text, mediaURLs: [url])
            await load(reset: true)
        } catch {
            status = error.localizedDescription
        }
    }

    private func openNotification(_ item: SocialNoteItem) async {
        _ = try? await API.data("social/notifications/\(item.id)/read", method: "POST")
        if item.action == "FOLLOW", !item.actorId.isEmpty {
            onProfileClick(item.actorId)
            return
        }
        guard !item.postId.isEmpty,
              let data = try? await API.data("posts/\(item.postId)"),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let post = LiveJSON.post(json["post"] as? [String: Any] ?? json) else { return }
        selectedPost = post
    }

    private var qualityLabel: String {
        switch qualityMode {
        case "off": return "Off"
        case "high": return "High quality only"
        case "following": return "Following only"
        case "topics": return "Topics I follow"
        case "calm": return "Anti-ragebait filter"
        default: return "Balanced"
        }
    }

    private var feedEntries: [SocialFeedEntry] {
        var rows: [SocialFeedEntry] = []
        for (index, post) in posts.enumerated() where !post.id.isEmpty {
            rows.append(SocialFeedEntry(kind: .post(post)))
            if AdConfig.nativeUnit != nil, (index + 1) % 5 == 0 {
                rows.append(SocialFeedEntry(kind: .ad("feed-ad-\((index + 1) / 5)")))
            }
        }
        return rows
    }

    private func load(reset: Bool) async {
        if loadingMore { return }
        if !reset && !hasMore { return }
        loadingMore = true
        defer { loadingMore = false }
        let pageOffset = reset ? 0 : nextOffset
        var query = ["limit": "15", "offset": "\(pageOffset)", "quality": qualityMode]
        let categoryId = categories[selectedCategory].0
        if categoryId != "all" { query["category_id"] = categoryId }
        if reset && posts.isEmpty, let cached = AppDiskCache.loadResponse(path: "media/feed", query: query) {
            let parsed = LiveJSON.posts(from: cached)
            posts = organicPosts(parsed.isEmpty ? FeedPost.decodeList(cached) : parsed)
            if !posts.isEmpty { status = "" }
        }
        do {
            let data = try await API.data("media/feed", query: query)
            let parsed = LiveJSON.posts(from: data)
            let incoming = organicPosts(parsed.isEmpty ? FeedPost.decodeList(data) : parsed)
            apply(incoming, reset: reset)
            nextOffset = pageOffset + incoming.count
            hasMore = incoming.count >= 15
            status = posts.isEmpty ? "No posts yet" : ""
        } catch {
            if posts.isEmpty { status = error.localizedDescription }
        }
    }

    private func organicPosts(_ list: [FeedPost]) -> [FeedPost] {
        list.filter { post in
            let type = post.postType.uppercased()
            return !post.id.isEmpty && type != "AD" && type != "AD_UNIT" && type != "NATIVE_AD" && !post.id.hasPrefix("ad-")
        }
    }

    /// Updates rows in place. A refresh only inserts posts that were not already on screen.
    private func apply(_ incoming: [FeedPost], reset: Bool) {
        if posts.isEmpty {
            posts = incoming
            return
        }
        var indexByID = Dictionary(uniqueKeysWithValues: posts.enumerated().map { ($0.element.id, $0.offset) })
        if reset {
            let fresh = incoming.filter { indexByID[$0.id] == nil }
            if !fresh.isEmpty {
                posts.insert(contentsOf: fresh, at: 0)
                indexByID = Dictionary(uniqueKeysWithValues: posts.enumerated().map { ($0.element.id, $0.offset) })
            }
        }
        for post in incoming {
            if let index = indexByID[post.id] {
                posts[index] = post
            } else if !reset {
                posts.append(post)
                indexByID[post.id] = posts.count - 1
            }
        }
    }
}

private struct SocialFeedEntry: Identifiable {
    enum Kind { case post(FeedPost), ad(String) }
    let kind: Kind
    var id: String {
        switch kind {
        case .post(let post): return "post-\(post.id)"
        case .ad(let slot): return slot
        }
    }
}

private struct StableFeedAd: View {
    let slot: String
    @State private var loaded = false

    var body: some View {
        ZStack {
            Color.clear
            NativeAdRow(slot: slot)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear { refresh() }
                .task(id: slot) {
                    for _ in 0..<20 {
                        #if canImport(GoogleMobileAds)
                        if NativeAdPool.shared.claim(slot: slot) != nil {
                            loaded = true
                            return
                        }
                        #endif
                        try? await Task.sleep(nanoseconds: 400_000_000)
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .clipped()
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func refresh() {
        #if canImport(GoogleMobileAds)
        loaded = NativeAdPool.shared.claim(slot: slot) != nil
        #endif
    }
}

struct FeedPostCard: View {
    let post: FeedPost
    var onOpen: () -> Void
    var onProfile: () -> Void
    var onReply: () -> Void
    var onRepost: () -> Void
    var onLike: () -> Void
    var onSave: () -> Void
    var onShare: () -> Void
    var onMore: () -> Void

    @State private var isExpanded = false
    private var shown: FeedPost { post.displayPost }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Repost Header
            if post.isSimpleRepost {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 13, weight: .bold))
                    Text("\(post.authorName) reposted")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.secondary)
            }

            // Top Row: Profile Header & Follow Button
            HStack(spacing: 10) {
                Button(action: onProfile) {
                    AsyncImage(url: FeedPost.resolve(shown.authorAvatar)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.15))
                            .overlay(
                                Text(String(shown.title.prefix(1)).uppercased())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.appPrimary)
                            )
                    }
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                }
                .buttonStyle(.borderless)

                Button(action: onProfile) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(shown.title.isEmpty ? (shown.authorHandle.isEmpty ? "User" : shown.authorHandle) : shown.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            if shown.isVerifiedAuthor {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.00, green: 0.82, blue: 1.00))
                            }
                            if !shown.formattedTimestamp.isEmpty {
                                Text("· \(shown.formattedTimestamp)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        if !shown.authorHandle.isEmpty {
                            Text("@\(shown.authorHandle)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .buttonStyle(.borderless)

                Spacer()

                if !shown.isAuthorFollowed && shown.authorId != (UserDefaults.standard.string(forKey: "tj_user_id") ?? "") {
                    Button("Follow") {
                        Task { _ = try? await API.data("users/\(shown.authorId)/follow", method: "POST") }
                    }
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.primary)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .clipShape(Capsule())
                    .buttonStyle(.borderless)
                }

                Button(action: onMore) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderless)
            }

            if !shown.mood.isEmpty || shown.aiAssisted || shown.collaboratorCount > 0 {
                HStack(spacing: 8) {
                    if !shown.mood.isEmpty {
                        Text(shown.mood).font(.system(size: 12, weight: .semibold)).foregroundColor(.appPrimary)
                    }
                    if shown.aiAssisted {
                        Text("Improved with AI").font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    if shown.collaboratorCount > 0 {
                        Text("\(shown.collaboratorCount) collaborator\(shown.collaboratorCount == 1 ? "" : "s")")
                            .font(.system(size: 12)).foregroundColor(.secondary)
                    }
                }
            }

            // Caption Text
            if !shown.content.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HashtagText(text: shown.content, lineLimit: isExpanded ? nil : 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !isExpanded && shown.content.count > 200 {
                        Button("Show More") { isExpanded = true }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.appPrimary)
                    }
                }
            }

            // Media Grid or Video Player
            if !shown.mediaURLs.isEmpty {
                if shown.playsAsVideo, let url = shown.playbackURL ?? shown.mediaURL {
                    FeedVideoPreview(url: url)
                        .frame(maxWidth: .infinity)
                        .frame(height: 480)
                        .clipped()
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: onOpen)
                } else {
                    PostMediaGrid(urls: shown.mediaURLs, onMediaClick: { _ in onOpen() })
                }
            }

            // Quoted Post Embed
            if let original = post.quotedPost, !post.isSimpleRepost {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        AsyncImage(url: FeedPost.resolve(original.authorAvatar)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())

                        Text(original.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                        if !original.authorHandle.isEmpty {
                            Text("@\(original.authorHandle)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    if !original.content.isEmpty {
                        Text(original.content)
                            .font(.system(size: 14))
                            .lineLimit(3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .contentShape(Rectangle())
                .onTapGesture(perform: onOpen)
            }

            // Social Action Bar
            PostActionBar(
                post: post,
                onReply: onReply,
                onRepost: onRepost,
                onLike: onLike,
                onSave: onSave,
                onShare: onShare
            )
            if !post.latestReplyText.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Text(post.latestReplyAuthor.isEmpty ? "Reply" : post.latestReplyAuthor)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    Text(post.latestReplyText)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                }
                .frame(minHeight: 32, alignment: .topLeading)
                .contentShape(Rectangle())
                .onTapGesture(perform: onOpen)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}

struct PostMediaGrid: View {
    let urls: [String]
    var onMediaClick: (Int) -> Void

    var body: some View {
        let validURLs = urls.compactMap { FeedPost.resolve($0) }
        guard !validURLs.isEmpty else { return AnyView(EmptyView()) }

        if validURLs.count == 1 {
            return AnyView(
                AsyncImage(url: validURLs[0]) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 480)
                .clipped()
                .cornerRadius(12)
                .contentShape(Rectangle())
                .onTapGesture { onMediaClick(0) }
            )
        } else if validURLs.count == 2 {
            return AnyView(
                HStack(spacing: 4) {
                    gridImage(validURLs[0], index: 0)
                    gridImage(validURLs[1], index: 1)
                }
                .frame(height: 380)
                .cornerRadius(12)
            )
        } else if validURLs.count == 3 {
            return AnyView(
                HStack(spacing: 4) {
                    gridImage(validURLs[0], index: 0)
                    VStack(spacing: 4) {
                        gridImage(validURLs[1], index: 1)
                        gridImage(validURLs[2], index: 2)
                    }
                }
                .frame(height: 420)
                .cornerRadius(12)
            )
        } else {
            return AnyView(
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        gridImage(validURLs[0], index: 0)
                        gridImage(validURLs[1], index: 1)
                    }
                    HStack(spacing: 4) {
                        gridImage(validURLs[2], index: 2)
                        ZStack {
                            gridImage(validURLs[3], index: 3)
                            if validURLs.count > 4 {
                                Color.black.opacity(0.5)
                                Text("+\(validURLs.count - 4)")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(height: 450)
                .cornerRadius(12)
            )
        }
    }

    private func gridImage(_ url: URL, index: Int) -> some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color.gray.opacity(0.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture { onMediaClick(index) }
    }
}

struct PostActionBar: View {
    let post: FeedPost
    var onReply: () -> Void
    var onRepost: () -> Void
    var onLike: () -> Void
    var onSave: () -> Void
    var onShare: () -> Void

    var body: some View {
        HStack {
            actionButton(
                icon: "bubble.left",
                count: post.repliesCount,
                color: .secondary,
                action: onReply
            )
            Spacer()
            actionButton(
                icon: "arrow.2.squarepath",
                count: post.repostCount,
                color: post.isReposted ? Color(red: 0.00, green: 0.73, blue: 0.49) : .secondary,
                action: onRepost
            )
            Spacer()
            actionButton(
                icon: post.isLiked ? "heart.fill" : "heart",
                count: post.likes,
                color: post.isLiked ? Color(red: 0.976, green: 0.094, blue: 0.502) : .secondary,
                action: onLike
            )
            Spacer()
            actionButton(
                icon: "chart.bar",
                count: post.views,
                color: .secondary,
                action: {}
            )
            Spacer()
            actionButton(
                icon: post.isBookmarked ? "bookmark.fill" : "bookmark",
                count: post.quoteCount,
                color: post.isBookmarked ? Color(red: 0.114, green: 0.608, blue: 0.941) : .secondary,
                action: onSave
            )
            Spacer()
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 32, minHeight: 32)
            }
            .buttonStyle(.borderless)
            CreatorTipButton(postId: post.id, authorId: post.authorId)
        }
        .padding(.top, 4)
    }

    private func actionButton(icon: String, count: Int, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                if count > 0 {
                    Text(formatNumber(count))
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .foregroundColor(color)
            .frame(minWidth: 32, minHeight: 32)
        }
        .buttonStyle(.borderless)
    }

    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 { return String(format: "%.1fM", Double(num) / 1_000_000) }
        if num >= 1_000 { return String(format: "%.1fK", Double(num) / 1_000) }
        return "\(num)"
    }
}

private struct PostPill: View {
    let text: String
    var selected: Bool = false
    var tint: Color = .primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(selected ? tint : .primary)
                .padding(.horizontal, 14)
                .frame(minHeight: 36)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
        }
        .buttonStyle(.borderless)
        .frame(minHeight: 44)
    }
}

private struct FeedVideoPreview: View {
    let url: URL
    var body: some View {
        ZStack {
            Color.black
            Image(systemName: "play.circle.fill")
                .font(.system(size: 42))
                .foregroundColor(.white)
        }
    }
}

private struct SocialMenuSheet: View {
    var onProfile: () -> Void
    var onCreate: () -> Void
    var onNotifications: () -> Void
    var onMessages: () -> Void
    var onSettings: () -> Void
    var onSaved: () -> Void
    var onCircles: () -> Void
    var onCreator: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule().fill(AppColors.borderDark).frame(width: 40, height: 4).frame(maxWidth: .infinity).padding(.top, 10)
            menuRow("person", "View Profile", onProfile)
            menuRow("square.and.pencil", "Create Post", onCreate)
            menuRow("bell", "Notifications", onNotifications)
            menuRow("paperplane", "Direct Messages", onMessages)
            Divider().background(AppColors.borderDark).padding(.vertical, 6)
            menuRow("circle.grid.2x2", "Circles", onCircles)
            menuRow("doc", "Drafts", onCreate)
            menuRow("chart.bar", "Analytics", onCreator)
            menuRow("dollarsign.circle", "Creator Dashboard", onCreator)
            Divider().background(AppColors.borderDark).padding(.vertical, 6)
            menuRow("bookmark", "Saved Posts", onSaved)
            menuRow("gearshape", "Settings", onSettings)
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color(hex: "1F1F1F"))
    }

    private func menuRow(_ icon: String, _ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(AppColors.tealAccent).frame(width: 22)
                Text(title).font(.system(size: 16)).foregroundColor(.white)
                Spacer()
            }
            .frame(height: 52)
        }
    }
}

struct CreatePostSheet: View {
    var replyToPost: FeedPost? = nil
    var quotingPost: FeedPost? = nil
    var onPost: (String, [String], String, [String: Any]) -> Void
    @Environment(\.dismiss) private var dismiss

    init(replyToPost: FeedPost? = nil, quotingPost: FeedPost? = nil, onPost: @escaping (String, [String]) -> Void) {
        self.replyToPost = replyToPost
        self.quotingPost = quotingPost
        self.onPost = { text, media, _, _ in onPost(text, media) }
    }

    init(replyToPost: FeedPost? = nil, quotingPost: FeedPost? = nil, onPost: @escaping (String, [String], String, [String: Any]) -> Void) {
        self.replyToPost = replyToPost
        self.quotingPost = quotingPost
        self.onPost = onPost
    }


    @State private var postText = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedData: [Data] = []
    @State private var uploadedURLs: [String] = []
    @State private var selectedLocation: String? = nil
    @State private var locationDraft = ""
    @State private var showLocation = false
    @State private var showPoll = false
    @State private var pollOptions: [String] = ["", ""]
    @State private var isPosting = false
    @State private var note = ""
    @State private var showAiAssist = false
    @State private var audience = "public"
    @State private var circleId = ""
    @State private var circles: [(id: String, name: String)] = []
    @State private var showAudience = false
    @State private var mood = ""
    @State private var showMood = false
    @State private var scheduledAt: Int64?
    @State private var aiAssisted = false
    @State private var collaborators: [(id: String, name: String)] = []
    @State private var peopleQuery = ""
    @State private var people: [(id: String, name: String)] = []
    @State private var showCollaborators = false
    @State private var draftLabel = ""
    @State private var recording = false
    @State private var recorder: AVAudioRecorder?
    @State private var voiceURL: URL?
    @State private var isArtist = false
    @State private var artistTags: Set<String> = []
    @State private var showGifs = false
    @State private var gifQuery = ""
    @State private var gifNote = "Search real GIFs. A token is required on the server."
    @State private var gifs: [(title: String, url: String)] = []

    private let charLimit = 280

    private var isTextValid: Bool {
        !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var isMediaValid: Bool {
        !loadedData.isEmpty || !uploadedURLs.isEmpty
    }
    private var isPollValid: Bool {
        showPoll && !pollOptions.isEmpty
    }
    private var canPost: Bool {
        if postText.count > charLimit { return false }
        return isTextValid || isMediaValid || isPollValid
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView { composerFields.padding(16) }
                Divider()
                composerBar
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("\(max(charLimit - postText.count, 0))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(postText.count > charLimit ? Color.red : AppColors.tealAccent)
                        if !draftLabel.isEmpty {
                            Text(draftLabel).font(.system(size: 11)).foregroundColor(Color.gray)
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(replyToPost != nil ? "Reply" : "Share") { Task { await publish() } }
                        .font(.system(size: 15, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background {
                            if canPost && !isPosting { AppColors.primaryGradient } else { Color.gray.opacity(0.4) }
                        }
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .disabled(!canPost || isPosting)
                }
            }
            .onChange(of: selectedPhotos) { _ in Task { await loadSelectedPhotos(selectedPhotos) } }
            .sheet(isPresented: $showAiAssist) {
                AiAssistSheetView(initialText: postText) { text, _ in
                    postText = String(text.prefix(charLimit))
                    aiAssisted = true
                }
            }
            .confirmationDialog("Who can see this", isPresented: $showAudience, titleVisibility: .visible) {
                Button("Public") { audience = "public"; circleId = "" }
                Button("Followers only") { audience = "followers"; circleId = "" }
                ForEach(circles, id: \.id) { circle in
                    Button(circle.name) { audience = "circle"; circleId = circle.id }
                }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("Mood", isPresented: $showMood, titleVisibility: .visible) {
                Button("Feeling creative") { mood = "Feeling creative" }
                Button("Hot take") { mood = "Hot take" }
                Button("Question") { mood = "Question" }
                Button("Excited") { mood = "Excited" }
                Button("Grateful") { mood = "Grateful" }
                Button("Clear", role: .destructive) { mood = "" }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Location", isPresented: $showLocation) {
                TextField("Place", text: $locationDraft)
                Button("Save") { selectedLocation = locationDraft.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Collaborators", isPresented: $showCollaborators) {
                TextField("Search people", text: $peopleQuery)
                Button("Search") { Task { await searchPeople() } }
                Button("Done", role: .cancel) {}
            } message: {
                Text(people.isEmpty ? "Search by name" : people.map(\.name).joined(separator: ", "))
            }
            .alert("GIFs", isPresented: $showGifs) {
                TextField("Search", text: $gifQuery)
                Button("Search") { Task { await searchGifs() } }
                Button("Close", role: .cancel) {}
            } message: {
                Text(gifs.isEmpty ? gifNote : gifs.map(\.title).joined(separator: "\n"))
            }
            .task { await loadDraft(); await loadCircles(); await loadArtistFlag() }
            .onChange(of: postText) { _ in Task { try? await Task.sleep(nanoseconds: 800_000_000); await saveDraft() } }
        }
    }

    @ViewBuilder
    private var composerFields: some View {
ScrollView {
    VStack(alignment: .leading, spacing: 12) {
        // Replying To Banner
        if let replyToPost {
            HStack(spacing: 4) {
                Text("Replying to")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text("@\(replyToPost.authorHandle.isEmpty ? "user" : replyToPost.authorHandle)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
            }
        }

        // User Avatar & Text Editor
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .trim(from: 0, to: min(CGFloat(postText.count) / CGFloat(charLimit), 1))
                    .stroke(Color(red: 0.114, green: 0.608, blue: 0.941), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 46, height: 46)
                Circle()
                    .fill(Color.appPrimary)
                    .frame(width: 42, height: 42)
                    .overlay(Image(systemName: "person.fill").foregroundColor(.white))
            }

            TextField(
                replyToPost != nil ? "Post your reply" : "What's happening? Add #hashtags",
                text: $postText,
                axis: .vertical
            )
            .font(.system(size: 18))
            .lineSpacing(4)
            .frame(minHeight: 100, alignment: .topLeading)
        }

        if !mood.isEmpty {
            Text(mood + " ✨")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.tealAccent)
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(AppColors.surfaceElevated)
                .overlay(Capsule().stroke(AppColors.borderDark, lineWidth: 1))
                .clipShape(Capsule())
        }

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([("Hot take", "Hot take: "), ("Question", "Question: "), ("Thread", "Thread:\n"), ("Announcement", "Announcement: ")], id: \.0) { label, prefix in
                    Button(label) {
                        if !postText.hasPrefix(prefix) { postText = prefix + postText }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.tealAccent)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(AppColors.surfaceElevated)
                    .overlay(Capsule().stroke(AppColors.borderDark, lineWidth: 1))
                    .clipShape(Capsule())
                }
            }
        }

        if isArtist {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["Add to Portfolio", "Process / WIP", "Part of Series", "Open for Commissions"], id: \.self) { tag in
                        Button(tag) {
                            if artistTags.contains(tag) { artistTags.remove(tag) } else { artistTags.insert(tag) }
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(artistTags.contains(tag) ? .white : AppColors.tealAccent)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(artistTags.contains(tag) ? AnyShapeStyle(AppColors.primaryGradient) : AnyShapeStyle(AppColors.surfaceElevated))
                        .clipShape(Capsule())
                    }
                }
            }
        }

        // Location Badge
        if let selectedLocation {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                Text(selectedLocation)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                Button {
                    self.selectedLocation = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(red: 0.114, green: 0.608, blue: 0.941).opacity(0.12))
            .clipShape(Capsule())
        }

        // Poll Creator Options
        if showPoll {
            VStack(alignment: .leading, spacing: 10) {
                Text("Poll Options")
                    .font(.system(size: 14, weight: .bold))

                ForEach(pollOptions.indices, id: \.self) { idx in
                    TextField("Choice \(idx + 1)", text: $pollOptions[idx])
                        .textFieldStyle(.roundedBorder)
                }

                if pollOptions.count < 4 {
                    Button("+ Add Choice") {
                        pollOptions.append("")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                }
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }

        // Attached Photo Thumbnails Row with Remove (X) Overlay
        if !loadedData.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(loadedData.indices, id: \.self) { idx in
                        ZStack(alignment: .topTrailing) {
                            if let uiImage = UIImage(data: loadedData[idx]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 130, height: 130)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Button {
                                loadedData.remove(at: idx)
                                if selectedPhotos.indices.contains(idx) {
                                    selectedPhotos.remove(at: idx)
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding(6)
                        }
                    }
                }
            }
        }

        // Quoted Post Card Preview
        if let quotingPost {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(quotingPost.title)
                        .font(.system(size: 14, weight: .bold))
                    if !quotingPost.authorHandle.isEmpty {
                        Text("@\(quotingPost.authorHandle)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                if !quotingPost.content.isEmpty {
                    Text(quotingPost.content)
                        .font(.system(size: 13))
                        .lineLimit(3)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }

        if !draftLabel.isEmpty {
            Text(draftLabel).font(.system(size: 12)).foregroundColor(.secondary)
        }
        if !mood.isEmpty {
            Text(mood).font(.system(size: 13, weight: .semibold)).foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
        }
        if !collaborators.isEmpty {
            Text("With " + collaborators.map(\.name).joined(separator: ", "))
                .font(.system(size: 12)).foregroundColor(.secondary)
        }
        if scheduledAt != nil {
            Text("Scheduled for one hour from now").font(.system(size: 12)).foregroundColor(.secondary)
        }
        if !note.isEmpty {
            Text(note)
                .font(.system(size: 12))
                .foregroundColor(.red)
        }
    }
    .padding(16)
}

    }

    @ViewBuilder
    private var composerBar: some View {
// Reply Scope & Media Action Bar
VStack(spacing: 8) {
    Button { showAudience = true } label: {
        HStack {
            Image(systemName: "globe")
                .font(.system(size: 13))
            Text(audience == "followers" ? "Followers only" : (audience == "circle" ? "Circle" : "Public"))
                .font(.system(size: 13, weight: .semibold))
            Spacer()
        }
        .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)

    HStack {
        PhotosPicker(
            selection: $selectedPhotos,
            maxSelectionCount: 4,
            matching: .any(of: [.images, .videos])
        ) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }
        .disabled(loadedData.count >= 4)

        Button {
            showPoll.toggle()
            if showPoll { loadedData.removeAll() }
        } label: {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }

        Button { showGifs = true } label: {
            Image(systemName: "face.smiling.inverse")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }
        Button { Task { await artistCaption() } } label: {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }
        if replyToPost != nil {
            Button { Task { await suggestReply() } } label: {
                Image(systemName: "text.bubble")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                    .frame(width: 36, height: 36)
            }
        }
        Button {
            showAiAssist = true
        } label: {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }

        Button { showLocation = true } label: {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }
        Button { showMood = true } label: {
            Image(systemName: "face.smiling")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }
        Button {
            scheduledAt = scheduledAt == nil ? Int64(Date().addingTimeInterval(3600).timeIntervalSince1970 * 1000) : nil
        } label: {
            Image(systemName: "clock")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }
        Button { showCollaborators = true } label: {
            Image(systemName: "person.2")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }
        Button { toggleVoice() } label: {
            Image(systemName: recording ? "stop.circle" : "mic")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.114, green: 0.608, blue: 0.941))
                .frame(width: 36, height: 36)
        }

        Spacer()

        let remaining = charLimit - postText.count
        Text("\(remaining)")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(remaining < 0 ? .red : .secondary)
    }
    .padding(.horizontal, 12)
    .padding(.bottom, 8)
}
.background(Color(UIColor.secondarySystemBackground))
    }

    private func searchGifs() async {
        do {
            let data = try await API.data("gifs", query: ["q": gifQuery])
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let rows = json?["gifs"] as? [[String: Any]] ?? []
            let found = rows.compactMap { row -> (title: String, url: String)? in
                let url = row["url"] as? String ?? ""
                guard !url.isEmpty else { return nil }
                return (row["title"] as? String ?? url, url)
            }
            await MainActor.run {
                gifs = found
                gifNote = found.isEmpty ? "No GIFs found." : ""
                if let first = found.first {
                    postText = [postText, first.url].filter { !$0.isEmpty }.joined(separator: "\n")
                    showGifs = false
                }
            }
        } catch {
            await MainActor.run { gifNote = error.localizedDescription }
        }
    }

    private func artistCaption() async {
        var image = uploadedURLs.first
        if image == nil, let data = loadedData.first {
            image = try? await MediaActions.upload(data: data, filename: "caption.jpg", mime: "image/jpeg", folder: "posts")
            if let image { uploadedURLs = [image] + uploadedURLs }
        }
        guard let image else {
            note = "Add a photo first, then ask for a caption."
            return
        }
        do {
            let data = try await API.data("ai/artist-helper", method: "POST", json: ["image_url": image, "story": "Write a caption for this image.", "title": "Photo"])
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let caption = (json?["caption"] as? String) ?? (json?["result"] as? String) ?? ""
            await MainActor.run { if !caption.isEmpty { postText = caption } }
        } catch {
            await MainActor.run { note = error.localizedDescription }
        }
    }

    private func suggestReply() async {
        guard let id = replyToPost?.id, !id.isEmpty else { return }
        do {
            let data = try await API.data("ai/smart-replies", query: ["post_id": id])
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let reply = (json?["suggestions"] as? [String])?.first ?? (json?["replies"] as? [String])?.first ?? ""
            await MainActor.run { if !reply.isEmpty { postText = reply } }
        } catch {
            await MainActor.run { note = error.localizedDescription }
        }
    }

    private func loadDraft() async {
        guard let data = try? await API.data("compose/draft"),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        let content = json["content"] as? String ?? ""
        guard postText.isEmpty, !content.isEmpty else { return }
        postText = String(content.prefix(charLimit))
        mood = json["mood"] as? String ?? ""
        audience = json["audience"] as? String ?? "public"
        circleId = json["circle_id"] as? String ?? ""
        draftLabel = "Draft restored"
    }

    private func saveDraft() async {
        guard !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        draftLabel = "Saving draft"
        _ = try? await API.data("compose/draft", method: "PUT", json: [
            "content": postText, "mood": mood, "audience": audience, "circle_id": circleId
        ])
        draftLabel = "Draft saved"
    }

    private func loadArtistFlag() async {
        guard let data = try? await API.data("users/me"),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        let user = json["user"] as? [String: Any] ?? json
        isArtist = user["is_artist"] as? Bool ?? false
    }

    private func loadCircles() async {
        guard let data = try? await API.data("circles"),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rows = json["circles"] as? [[String: Any]] else { return }
        circles = rows.compactMap { row in
            let id = row["id"] as? String ?? ""
            guard !id.isEmpty else { return nil }
            return (id, (row["name"] as? String)?.isEmpty == false ? (row["name"] as? String ?? "Circle") : "Circle")
        }
    }

    private func searchPeople() async {
        guard peopleQuery.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2,
              let data = try? await API.data("compose/people", query: ["q": peopleQuery]),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rows = json["people"] as? [[String: Any]] else { return }
        people = rows.compactMap { row in
            let id = row["id"] as? String ?? ""
            guard !id.isEmpty else { return nil }
            let handle = row["handle"] as? String ?? ""
            let name = handle.isEmpty ? (row["name"] as? String ?? "User") : handle
            return (id, name)
        }
        if let first = people.first, collaborators.allSatisfy({ $0.id != first.id }) {
            collaborators.append(first)
        }
    }

    private func toggleVoice() {
        if recording {
            recorder?.stop()
            recording = false
            return
        }
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("post-voice-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1
        ]
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            guard allowed else { return }
            DispatchQueue.main.async {
                try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
                try? AVAudioSession.sharedInstance().setActive(true)
                recorder = try? AVAudioRecorder(url: file, settings: settings)
                recorder?.record()
                voiceURL = file
                recording = true
            }
        }
    }

    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        var datas: [Data] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                datas.append(data)
            }
        }
        loadedData = datas
    }

    private func publish() async {
        guard canPost, !isPosting else { return }
        isPosting = true
        defer { isPosting = false }

        var urls: [String] = []
        for (idx, data) in loadedData.enumerated() {
            if let url = try? await MediaActions.upload(data: data, filename: "post_\(idx).jpg", mime: "image/jpeg", folder: "posts") {
                urls.append(url)
            }
        }
        if let voiceURL, let data = try? Data(contentsOf: voiceURL),
           let url = try? await MediaActions.upload(data: data, filename: "post-voice.m4a", mime: "audio/mp4", folder: "posts") {
            urls.append(url)
        }

        var text = postText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !artistTags.isEmpty {
            let extra = artistTags.sorted().joined(separator: " · ")
            if !text.contains(extra) { text = text.isEmpty ? extra : text + "\n" + extra }
        }
        var compose: [String: Any] = [
            "content": text,
            "mood": mood,
            "audience": audience,
            "circle_id": circleId,
            "ai_assisted": aiAssisted,
            "collaborators": collaborators.map(\.id),
            "splits": collaborators.isEmpty ? [] : collaborators.map { ["user_id": $0.id, "percent": max(1, 100 / (collaborators.count + 1))] }
        ]
        if let scheduledAt { compose["scheduled_at"] = scheduledAt }
        onPost(text, urls, selectedLocation ?? "", compose)
        dismiss()
    }
}

/// Android Scroll tab: `GET media/feed/shorts` matching Screenshot 8.
public struct ConnectedShortsFeedView: View {
    public var onProfileClick: (String) -> Void

    public init(onProfileClick: @escaping (String) -> Void = { _ in }) {
        self.onProfileClick = onProfileClick
    }

    public var body: some View {
        ShortsFeedView(onProfileClick: onProfileClick)
    }
}

/// Android Court/Mingle tab matching Screenshot 5.
public struct ConnectedMingleFeedView: View {
    public var onProfileClick: (String) -> Void
    public var onChatClick: (String) -> Void

    public init(onProfileClick: @escaping (String) -> Void = { _ in }, onChatClick: @escaping (String) -> Void = { _ in }) {
        self.onProfileClick = onProfileClick
        self.onChatClick = onChatClick
    }

    public var body: some View {
        MingleView(onMatchClick: { conversationId, _ in onChatClick(conversationId) })
    }
}

struct ShortsFeedView: View {
    public var onProfileClick: (String) -> Void = { _ in }
    @State private var shorts: [FeedPost] = []
    @State private var status = "Loading shorts..."
    @State private var selectedShort: FeedPost?
    @State private var page = 0
    @State private var showCreateShort = false
    @State private var showShortSearch = false
    @State private var commentShort: FeedPost?
    @State private var dismissedShortAds: Set<Int> = []
    @State private var showShortsAd = false
    @State private var shortPaused = false
    @State private var shortMuted = false
    @State private var shortProgress = 0.0

    var body: some View {
        Group {
            if shorts.isEmpty {
                VStack(spacing: 12) {
                    if status == "Loading shorts..." { ProgressView() }
                    Text(status).font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                    if status == "No shorts yet" {
                        Button("Create Short") { showCreateShort = true }
                            .font(.headline)
                    }
                }
                .padding()
            } else {
                GeometryReader { geo in
                VerticalShortsPlayer(
                    posts: shorts,
                    page: $page,
                    paused: $shortPaused,
                    muted: $shortMuted,
                    progress: $shortProgress,
                    onDoubleLike: { if shorts.indices.contains(page) { toggleShortLike(shorts[page].id) } }
                )
                    .frame(width: geo.size.width, height: geo.size.height)
                    .overlay(alignment: .topLeading) {
                        Button { showCreateShort = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.35))
                                .clipShape(Circle())
                        }
                        .padding(.top, 48)
                        .padding(.leading, 16)
                    }
                    .overlay(alignment: .topTrailing) {
                        if shorts.indices.contains(page) {
                            HStack(spacing: 10) {
                                Button { shortMuted.toggle() } label: {
                                    Image(systemName: shortMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.black.opacity(0.35))
                                        .clipShape(Circle())
                                }
                                Button { showShortSearch = true } label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.black.opacity(0.35))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.top, 48)
                            .padding(.trailing, 16)
                        }
                    }
                    .overlay {
                        if shortPaused {
                            Image(systemName: "play.fill")
                                .font(.system(size: 54))
                                .foregroundColor(.white)
                                .padding(22)
                                .background(Color.black.opacity(0.35))
                                .clipShape(Circle())
                                .allowsHitTesting(false)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        GeometryReader { bar in
                            Rectangle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: max(bar.size.width * shortProgress, 0), height: 3)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        }
                        .frame(height: 3)
                        .allowsHitTesting(false)
                    }
                    .overlay(alignment: .bottom) {
                        if shorts.indices.contains(page) {
                            ShortsChrome(
                                post: shorts[page],
                                onProfile: {
                                    let authorId = shorts[page].authorId
                                    if !authorId.isEmpty { onProfileClick(authorId) }
                                },
                                onOpen: { selectedShort = shorts[page] },
                                onComment: { commentShort = shorts[page] },
                                onLike: { toggleShortLike(shorts[page].id) },
                                onSave: { toggleShortSave(shorts[page].id) },
                                onShare: { shareShort(shorts[page].id) },
                                onFollow: { toggleShortFollow(shorts[page].id) }
                            )
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
        .onChange(of: page) { _ in
            shortPaused = false
            shortProgress = 0
        }
        .fullScreenCover(isPresented: Binding(get: { selectedShort != nil }, set: { if !$0 { selectedShort = nil } })) {
            if let post = selectedShort {
                PostDetailView(post: post, onProfileClick: onProfileClick, onClose: { selectedShort = nil })
            }
        }
        .sheet(item: $commentShort) { post in
            ShortCommentsSheet(post: post) { count in
                if let index = shorts.firstIndex(where: { $0.id == post.id }) {
                    shorts[index].repliesCount = count
                }
            }
        }
        .sheet(isPresented: $showCreateShort) {
            CreateShortSheet {
                showCreateShort = false
                Task { await load() }
            }
        }
        .sheet(isPresented: $showShortSearch) {
            LiveSearchView(
                onOpenProfile: { id in
                    showShortSearch = false
                    onProfileClick(id)
                },
                onOpenChat: { id, _ in
                    showShortSearch = false
                    NotificationCenter.default.post(name: TJEvents.openChat, object: nil, userInfo: ["id": id])
                }
            )
        }
        .task {
            #if canImport(GoogleMobileAds)
            NativeAdPool.shared.warm()
            #endif
            await load()
        }
        .refreshable { await load() }
    }

    private func load() async {
        if shorts.isEmpty, let cached = AppDiskCache.loadResponse(path: "media/feed/shorts", query: ["page": "1"]) {
            let parsed = LiveJSON.posts(from: cached)
            shorts = parsed.isEmpty ? FeedPost.decodeList(cached) : parsed
            if !shorts.isEmpty { status = "" }
        }
        do {
            var collected: [FeedPost] = []
            for page in 1...5 {
                let data = try await API.data("media/feed/shorts", query: ["page": "\(page)"])
                let parsed = LiveJSON.posts(from: data)
                let batch = parsed.isEmpty ? FeedPost.decodeList(data) : parsed
                if batch.isEmpty { break }
                for post in batch where !collected.contains(where: { $0.id == post.id }) {
                    collected.append(post)
                }
                if batch.count < 5 { break }
            }
            shorts = collected
            status = shorts.isEmpty ? "No shorts yet" : ""
        } catch {
            if shorts.isEmpty { status = error.localizedDescription }
        }
    }

    private func toggleShortLike(_ id: String) {
        guard let index = shorts.firstIndex(where: { $0.id == id }) else { return }
        shorts[index].isLiked.toggle()
        shorts[index].likes += shorts[index].isLiked ? 1 : -1
        Task { await MediaActions.like(id) }
    }

    private func toggleShortSave(_ id: String) {
        guard let index = shorts.firstIndex(where: { $0.id == id }) else { return }
        shorts[index].isBookmarked.toggle()
        Task { await MediaActions.bookmark(id) }
    }

    private func toggleShortFollow(_ id: String) {
        guard let index = shorts.firstIndex(where: { $0.id == id }) else { return }
        let authorId = shorts[index].authorId
        guard !authorId.isEmpty else { return }
        let next = !shorts[index].isAuthorFollowed
        shorts[index].isAuthorFollowed = next
        Task {
            let path = next ? "users/\(authorId)/follow" : "users/\(authorId)/unfollow"
            if (try? await API.data(path, method: "POST")) == nil {
                if let current = shorts.firstIndex(where: { $0.id == id }) {
                    shorts[current].isAuthorFollowed = !next
                }
            }
        }
    }

    private func shareShort(_ id: String) {
        guard let index = shorts.firstIndex(where: { $0.id == id }) else { return }
        shorts[index].shares += 1
        MediaActions.shareSheet(shorts[index])
        Task { await MediaActions.share(id) }
    }
}

private struct ShortsChrome: View {
    let post: FeedPost
    var onProfile: () -> Void
    var onOpen: () -> Void
    var onComment: () -> Void = {}
    var onLike: () -> Void
    var onSave: () -> Void
    var onShare: () -> Void
    var onFollow: () -> Void = {}
    @State private var showMore = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Button(action: onProfile) {
                        Text(post.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    if !post.isAuthorFollowed && post.authorId != (UserDefaults.standard.string(forKey: "tj_user_id") ?? "") {
                        Button("Follow", action: onFollow)
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                }
                if !post.content.isEmpty {
                    HashtagText(
                        text: post.content,
                        color: .white,
                        font: .system(size: 14),
                        lineLimit: 3
                    )
                }
            }
            Spacer(minLength: 0)
            VStack(spacing: 18) {
                Button(action: onLike) {
                    VStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 28))
                            .foregroundColor(post.isLiked ? .red : .white)
                        Text("\(post.likes)").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    }
                }
                CreatorTipButton(postId: post.id, authorId: post.authorId, tint: .white)
                Button(action: onComment) {
                    VStack(spacing: 4) {
                        Image(systemName: "message.fill").font(.system(size: 26)).foregroundColor(.white)
                        Text("\(post.repliesCount)").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    }
                }
                Button(action: onSave) {
                    Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
                Button(action: onShare) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
                Button { showMore = true } label: {
                    Image(systemName: "ellipsis").font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                }
                .confirmationDialog("Short", isPresented: $showMore, titleVisibility: .visible) {
                    Button("Share", action: onShare)
                    Button("Copy link") { MediaActions.copyLink(post) }
                    Button("Report", role: .destructive) { Task { await MediaActions.report(post.id, reason: "report") } }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }
}

// MARK: - Short Clip View matching Screenshot 8

private struct ShortClipView: View {
    let post: FeedPost
    var isActive: Bool = false
    var showsVideo: Bool = true
    let onProfile: () -> Void
    var onOpen: () -> Void = {}
    var onLike: () -> Void = {}
    var onSave: () -> Void = {}
    var onShare: () -> Void = {}
    @State private var player: AVPlayer?
    @State private var showMore = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if showsVideo {
                if let player {
                    ShortPlayerSurface(player: player)
                        .ignoresSafeArea()
                } else if let image = post.mediaURL {
                    AsyncImage(url: image) { loaded in
                        loaded.resizable().scaledToFill()
                    } placeholder: {
                        Color.black
                    }
                    .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }
            }

            // Top Right Search Icon Overlay matching Screenshot 8
            HStack {
                Spacer()
                Button(action: onOpen) {
                    Circle()
                        .fill(Color.black.opacity(0.35))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 48)
            .frame(maxHeight: .infinity, alignment: .top)

            // Right Action Sidebar matching Screenshot 8
            HStack(alignment: .bottom) {
                // Bottom Left Author Info Overlay matching Screenshot 8
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: onProfile) {
                        HStack(spacing: 10) {
                            AsyncImage(url: FeedPost.resolve(post.authorAvatar)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.4))
                                    .overlay(Text(String(post.title.prefix(1)).uppercased()).foregroundColor(.white))
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            Text(post.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                    }

                    if !post.content.isEmpty {
                        Text(post.content)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .onTapGesture(perform: onOpen)
                    }
                }

                Spacer()

                VStack(spacing: 20) {
                    Button(action: onProfile) {
                        AsyncImage(url: FeedPost.resolve(post.authorAvatar)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.4))
                                .overlay(Text(String(post.title.prefix(1)).uppercased()).foregroundColor(.white))
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    }

                    Button(action: onLike) {
                        VStack(spacing: 4) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 28))
                                .foregroundColor(post.isLiked ? .red : .white)
                            Text("\(post.likes)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    CreatorTipButton(postId: post.id, authorId: post.authorId, tint: .white)

                    Button(action: onOpen) {
                        VStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                            Text("\(post.repliesCount)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Button(action: onSave) {
                        VStack(spacing: 4) {
                            Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                            Text("Save")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Button(action: onShare) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                            Text("Share")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Button { showMore = true } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .confirmationDialog("Short", isPresented: $showMore, titleVisibility: .visible) {
                        Button("Share", action: onShare)
                        Button("Copy link") { MediaActions.copyLink(post) }
                        Button("Report", role: .destructive) { Task { await MediaActions.report(post.id, reason: "report") } }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .onAppear { if showsVideo { startPlayback() } }
        .onChange(of: isActive) { active in
            guard showsVideo else { return }
            if active { startPlayback() } else { player?.pause() }
        }
        .onDisappear { player?.pause() }
    }

    private func startPlayback() {
        guard showsVideo else { return }
        guard isActive || player == nil else {
            player?.play()
            return
        }
        guard let url = post.playbackURL ?? post.mediaURL else { return }
        if player == nil {
            let next = AVPlayer(url: url)
            next.isMuted = false
            player = next
        }
        if isActive {
            player?.play()
            Task { await MediaActions.view(post.id) }
        }
    }
}

private struct ShortPlayerSurface: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> ShortPlayerView {
        let view = ShortPlayerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: ShortPlayerView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private final class ShortPlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

private struct VerticalShortsPlayer: UIViewControllerRepresentable {
    let posts: [FeedPost]
    @Binding var page: Int
    @Binding var paused: Bool
    @Binding var muted: Bool
    @Binding var progress: Double
    var onDoubleLike: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var paused = false
        var muted = false
    }

    func makeUIViewController(context: Context) -> ShortsPagingController {
        let controller = ShortsPagingController()
        bind(controller, context: context)
        return controller
    }

    func updateUIViewController(_ controller: ShortsPagingController, context: Context) {
        bind(controller, context: context)
        controller.setPosts(posts, page: page)
        if context.coordinator.paused != paused || context.coordinator.muted != muted {
            context.coordinator.paused = paused
            context.coordinator.muted = muted
            controller.apply(paused: paused, muted: muted)
        }
    }

    private func bind(_ controller: ShortsPagingController, context: Context) {
        controller.onPage = { newPage in
            if page != newPage { page = newPage }
        }
        controller.onProgress = { value in
            if abs(progress - value) > 0.01 { progress = value }
        }
        controller.onTogglePause = { paused.toggle() }
        controller.onDoubleLike = onDoubleLike
    }
}

struct SocialNoteItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let actorId: String
    let postId: String
    let action: String
}

private struct SavedPostsSheet: View {
    var onOpen: (FeedPost) -> Void
    @State private var posts: [FeedPost] = []
    @State private var note = "Loading..."

    var body: some View {
        NavigationStack {
            List(posts) { post in
                Button { onOpen(post) } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.authorName).font(.headline).foregroundColor(.primary)
                        Text(post.content).lineLimit(2).font(.subheadline).foregroundColor(.secondary)
                    }
                }
            }
            .overlay { if posts.isEmpty { Text(note).foregroundColor(.secondary) } }
            .navigationTitle("Saved Posts")
            .task { await load() }
        }
    }

    private func load() async {
        do {
            let data = try await API.data("media/feed", query: ["category_id": "saved", "limit": "20", "offset": "0"])
            let parsed = LiveJSON.posts(from: data)
            posts = parsed.isEmpty ? FeedPost.decodeList(data) : parsed
            note = posts.isEmpty ? "No saved posts yet" : ""
        } catch {
            note = "Could not load saved posts"
        }
    }
}

private struct SocialNotesSheet: View {
    var onOpen: (SocialNoteItem) -> Void
    @State private var rows: [SocialNoteItem] = []
    @State private var note = "Loading..."

    var body: some View {
        NavigationStack {
            List(rows) { row in
                Button { onOpen(row) } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.title).font(.headline).foregroundColor(.primary)
                        if !row.subtitle.isEmpty { Text(row.subtitle).font(.caption).foregroundColor(.secondary) }
                    }
                }
            }
            .overlay { if rows.isEmpty { Text(note).foregroundColor(.secondary) } }
            .navigationTitle("Notifications")
            .task { await load() }
        }
    }

    private func load() async {
        do {
            let data = try await API.data("social/notifications")
            rows = LiveJSON.list(data, keys: ["items", "notifications"]).compactMap { item in
                let id = LiveJSON.string(item["id"])
                guard !id.isEmpty else { return nil }
                let rawName = LiveJSON.string(item["actor_name"])
                let name = (rawName == "User" || rawName == "Someone") ? "" : rawName
                let action = LiveJSON.string(item["action_text"])
                let snippet = LiveJSON.string(item["post_snippet"])
                return SocialNoteItem(
                    id: id,
                    title: name.isEmpty ? action : name,
                    subtitle: name.isEmpty ? snippet : action,
                    actorId: LiveJSON.string(item["actor_id"]),
                    postId: LiveJSON.string(item["target_post_id"]),
                    action: LiveJSON.string(item["action_type"])
                )
            }
            note = rows.isEmpty ? "No social notifications yet" : ""
        } catch {
            note = "Could not load notifications"
        }
    }
}

private final class ShortsPagingController: UIViewController, UIScrollViewDelegate {
    var onPage: ((Int) -> Void)?
    var onProgress: ((Double) -> Void)?
    var onTogglePause: (() -> Void)?
    var onDoubleLike: (() -> Void)?
    private let scrollView = UIScrollView()
    private var posts: [FeedPost] = []
    private var players: [AVPlayer] = []
    private var layers: [AVPlayerLayer] = []
    private var hosts: [UIView] = []
    private var appliedPage = -1
    private var loopObservers: [NSObjectProtocol] = []
    private var userPaused = false
    private var muted = false
    private var progressToken: Any?
    private var progressPlayer: AVPlayer?
    private let heart = UIImageView(image: UIImage(systemName: "heart.fill"))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(doubleTap)
        scrollView.addGestureRecognizer(singleTap)
        heart.tintColor = .white
        heart.contentMode = .scaleAspectFit
        heart.alpha = 0
        heart.isUserInteractionEnabled = false
        view.addSubview(heart)
    }

    @objc private func singleTapped() {
        onTogglePause?()
    }

    @objc private func doubleTapped() {
        onDoubleLike?()
        heart.frame = CGRect(x: (view.bounds.width - 96) / 2, y: (view.bounds.height - 96) / 2, width: 96, height: 96)
        heart.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        heart.alpha = 1
        UIView.animate(withDuration: 0.45, delay: 0.15, options: .curveEaseOut) {
            self.heart.alpha = 0
            self.heart.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        }
    }

    func apply(paused: Bool, muted: Bool) {
        userPaused = paused
        self.muted = muted
        for player in players {
            player.isMuted = muted
        }
        guard players.indices.contains(appliedPage) else { return }
        if paused {
            players[appliedPage].pause()
        } else if players[appliedPage].currentItem != nil {
            players[appliedPage].play()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPages()
        if appliedPage < 0, !posts.isEmpty, view.bounds.height > 1 {
            appliedPage = 0
            play(0)
            onPage?(0)
        }
    }

    func setPosts(_ posts: [FeedPost], page: Int) {
        let ids = posts.map(\.id)
        if ids != self.posts.map(\.id) {
            self.posts = posts
            rebuild()
        }
        guard view.bounds.height > 1, posts.indices.contains(page), page != appliedPage else { return }
        appliedPage = page
        scrollView.setContentOffset(CGPoint(x: 0, y: view.bounds.height * CGFloat(page)), animated: false)
        play(page)
    }

    private func rebuild() {
        if let progressToken, let progressPlayer {
            progressPlayer.removeTimeObserver(progressToken)
        }
        progressToken = nil
        progressPlayer = nil
        loopObservers.forEach { NotificationCenter.default.removeObserver($0) }
        loopObservers.removeAll()
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        hosts.forEach { $0.removeFromSuperview() }
        hosts.removeAll()
        players.removeAll()
        layers.removeAll()
        appliedPage = -1
        for post in posts {
            let host = UIView()
            host.backgroundColor = .black
            host.isUserInteractionEnabled = false
            let player = AVPlayer()
            player.isMuted = muted
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = .resizeAspectFill
            host.layer.addSublayer(layer)
            let label = UILabel()
            label.text = post.authorName.isEmpty ? post.content : post.authorName
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 16)
            label.tag = 8
            label.isHidden = true
            host.addSubview(label)
            if post.playbackURL == nil {
                let missing = UILabel()
                missing.text = "This short has no video"
                missing.textColor = .white
                missing.textAlignment = .center
                missing.tag = 7
                host.addSubview(missing)
            }
            scrollView.addSubview(host)
            hosts.append(host)
            players.append(player)
            layers.append(layer)
        }
        layoutPages()
    }

    private func layoutPages() {
        let size = view.bounds.size
        guard size.height > 1 else { return }
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: size.width, height: size.height * CGFloat(max(posts.count, 1)))
        for (index, host) in hosts.enumerated() {
            host.frame = CGRect(x: 0, y: size.height * CGFloat(index), width: size.width, height: size.height)
            if layers.indices.contains(index) {
                layers[index].frame = host.bounds
            }
            host.viewWithTag(7)?.frame = host.bounds
            host.viewWithTag(8)?.frame = CGRect(x: 16, y: host.bounds.height - 92, width: host.bounds.width - 32, height: 24)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        settle()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { settle() }
    }

    private func settle() {
        let height = max(view.bounds.height, 1)
        let index = Int(round(scrollView.contentOffset.y / height))
        let clamped = min(max(index, 0), max(posts.count - 1, 0))
        appliedPage = clamped
        userPaused = false
        onPage?(clamped)
        play(clamped)
    }

    private func watchProgress(_ player: AVPlayer) {
        if let progressToken, let progressPlayer {
            progressPlayer.removeTimeObserver(progressToken)
        }
        let token = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main) { [weak self, weak player] time in
            guard let self, let item = player?.currentItem else { return }
            let duration = item.duration.seconds
            guard duration.isFinite, duration > 0 else { return }
            self.onProgress?(min(max(time.seconds / duration, 0), 1))
        }
        progressToken = token
        progressPlayer = player
    }

    private func play(_ index: Int) {
        guard players.indices.contains(index) else { return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback)
        try? session.setActive(true)
        for (offset, player) in players.enumerated() where offset != index {
            player.pause()
        }
        let player = players[index]
        guard let remote = posts[index].playbackURL ?? posts[index].mediaURL else {
            showNote(index, "This short has no video")
            return
        }
        let postId = posts[index].id
        Task {
            let playable = await AuthenticatedMedia.localFile(for: remote) ?? remote
            await MainActor.run {
                guard players.indices.contains(index) else { return }
                let item = AVPlayerItem(url: playable)
                player.replaceCurrentItem(with: item)
                let end = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
                    player.seek(to: .zero)
                    if self?.userPaused == true {
                        player.pause()
                    } else {
                        player.play()
                    }
                }
                let failed = NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main) { note in
                    let message = (note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error)?.localizedDescription ?? "Video could not play"
                    self.showNote(index, message)
                }
                loopObservers.append(end)
                loopObservers.append(failed)
                player.isMuted = self.muted
                if self.userPaused {
                    player.pause()
                } else {
                    player.play()
                }
                self.watchProgress(player)
                if layers.indices.contains(index) {
                    layers[index].player = player
                }
            }
            await MediaActions.view(postId)
        }
    }

    private func showNote(_ index: Int, _ text: String) {
        guard hosts.indices.contains(index) else { return }
        let host = hosts[index]
        let label = (host.viewWithTag(7) as? UILabel) ?? UILabel()
        label.tag = 7
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 3
        label.frame = host.bounds
        if label.superview == nil { host.addSubview(label) }
    }
}

private struct HashtagText: View {
    let text: String
    var color: Color = .primary
    var font: Font = .system(size: 15)
    var lineLimit: Int? = nil
    @State private var selectedTag: String?

    var body: some View {
        Text(Self.linked(text, color: color))
            .font(font)
            .lineSpacing(3)
            .foregroundColor(color)
            .lineLimit(lineLimit)
            .multilineTextAlignment(.leading)
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "tjtag" else { return .systemAction }
                let raw = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let tag = raw.removingPercentEncoding ?? raw
                guard !tag.isEmpty else { return .discarded }
                selectedTag = tag
                return .handled
            })
            .sheet(isPresented: Binding(get: { selectedTag != nil }, set: { if !$0 { selectedTag = nil } })) {
                if let selectedTag {
                    HashtagResultsSheet(tag: selectedTag)
                }
            }
    }

    private static func linked(_ text: String, color: Color) -> AttributedString {
        var attributed = AttributedString(text)
        guard let regex = try? NSRegularExpression(pattern: "#[A-Za-z0-9_]{2,40}") else { return attributed }
        let ns = text as NSString
        for match in regex.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            guard let range = Range(match.range, in: text),
                  let start = AttributedString.Index(range.lowerBound, within: attributed),
                  let end = AttributedString.Index(range.upperBound, within: attributed) else { continue }
            let tag = String(text[range]).dropFirst()
            let encoded = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String(tag)
            if let url = URL(string: "tjtag://hashtag/\(encoded)") {
                attributed[start..<end].link = url
            }
            attributed[start..<end].foregroundColor = color == .white ? UIColor.white : UIColor(red: 0.11, green: 0.63, blue: 0.95, alpha: 1)
            attributed[start..<end].underlineStyle = .single
        }
        return attributed
    }
}

private struct HashtagResultsSheet: View {
    let tag: String
    @Environment(\.dismiss) private var dismiss
    @State private var posts: [FeedPost] = []
    @State private var note = "Searching posts and shorts..."

    var body: some View {
        NavigationStack {
            List(posts) { post in
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.authorName.isEmpty ? "Post" : post.authorName).font(.headline)
                    Text(post.content).font(.subheadline).foregroundColor(.secondary).lineLimit(3)
                }
            }
            .overlay { if posts.isEmpty { Text(note).foregroundColor(.secondary).padding() } }
            .navigationTitle("#\(tag)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Follow") { Task { await followTopic() } }
                }
            }
            .task { await load() }
        }
    }

    private func followTopic() async {
        let current = (try? await API.data("topics")).flatMap { data in
            (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["followed"] as? [String]
        } ?? []
        var topics = current
        if !topics.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) {
            topics.append(tag)
        }
        _ = try? await API.data("topics", method: "PUT", json: ["topics": topics])
        await MainActor.run { note = "Following #\(tag). Quality mode uses this list." }
    }

    private func load() async {
        do {
            let data = try await API.data("posts", query: ["hashtag": tag, "page": "1"])
            let parsed = LiveJSON.posts(from: data)
            posts = parsed.isEmpty ? FeedPost.decodeList(data) : parsed
            note = posts.isEmpty ? "No posts use #\(tag) yet." : ""
        } catch {
            note = "Could not search #\(tag)"
        }
    }
}
