import SwiftUI

public struct ShortVideoItem: Identifiable, Codable, Hashable {
    public let id: String
    public let creatorName: String
    public let creatorAvatar: String
    public let videoTitle: String
    public let audioTrack: String
    public let videoUrl: String
    public var likesCount: Int
    public var commentsCount: Int
    public var isLiked: Bool

    public init(id: String, creatorName: String, creatorAvatar: String, videoTitle: String, audioTrack: String, videoUrl: String, likesCount: Int, commentsCount: Int, isLiked: Bool) {
        self.id = id
        self.creatorName = creatorName
        self.creatorAvatar = creatorAvatar
        self.videoTitle = videoTitle
        self.audioTrack = audioTrack
        self.videoUrl = videoUrl
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
    }
}

public class ShortsViewModel: ObservableObject {
    @Published public var shortVideos: [ShortVideoItem] = []
    @Published public var currentVideoIndex: Int = 0

    public init() {}

    public func toggleLike(for video: ShortVideoItem) {
        if let index = shortVideos.firstIndex(where: { $0.id == video.id }) {
            shortVideos[index].isLiked.toggle()
            shortVideos[index].likesCount += shortVideos[index].isLiked ? 1 : -1
        }
    }
}

public class SocialViewModel: ObservableObject {
    @Published public var posts: [SocialPost] = []

    public init() {}

    public func toggleLike(for post: SocialPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isLiked.toggle()
            posts[index].likesCount += posts[index].isLiked ? 1 : -1
        }
    }
}
