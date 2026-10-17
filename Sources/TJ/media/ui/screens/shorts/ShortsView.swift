import SwiftUI
import AVKit

public struct ShortItemModel: Identifiable, Hashable {
    public let id: String
    public let authorName: String
    public let authorHandle: String
    public let avatarUrl: String?
    public let caption: String
    public let videoUrl: String
    public var likesCount: Int
    public var commentsCount: Int
    public var sharesCount: Int
    public var isLiked: Bool
    public var isBookmarked: Bool

    public init(
        id: String = UUID().uuidString,
        authorName: String,
        authorHandle: String,
        avatarUrl: String? = nil,
        caption: String,
        videoUrl: String,
        likesCount: Int = 0,
        commentsCount: Int = 0,
        sharesCount: Int = 0,
        isLiked: Bool = false,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.authorName = authorName
        self.authorHandle = authorHandle
        self.avatarUrl = avatarUrl
        self.caption = caption
        self.videoUrl = videoUrl
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.sharesCount = sharesCount
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
    }
}

public struct ShortsView: View {
    @State private var shorts: [ShortItemModel] = [
        ShortItemModel(
            authorName: "Akani Simbine",
            authorHandle: "akani_runner",
            caption: "Speed training at the track! 🏃‍♂️💨 #Shorts #TrackAndField",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            likesCount: 1240,
            commentsCount: 88,
            sharesCount: 45
        ),
        ShortItemModel(
            authorName: "Tech Trends SA",
            authorHandle: "tech_sa",
            caption: "Unboxing the newest device in 30 seconds! 📱🔥 #Tech #Unboxing",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            likesCount: 3410,
            commentsCount: 210,
            sharesCount: 112
        )
    ]

    @State private var currentIndex: Int = 0
    @State private var showCreateShort: Bool = false
    @State private var activeShortForComments: ShortItemModel? = nil

    public init() {}

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if shorts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No Shorts Available")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            } else {
                GeometryReader { geo in
                    TabView(selection: $currentIndex) {
                        ForEach(Array(shorts.enumerated()), id: \.element.id) { index, short in
                            ShortPageCell(
                                short: short,
                                isCurrent: currentIndex == index,
                                onLike: { toggleLike(at: index) },
                                onBookmark: { toggleBookmark(at: index) },
                                onComment: {
                                    activeShortForComments = short
                                }
                            )
                            .tag(index)
                            .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .ignoresSafeArea()
            }

            // Top Bar Overlay
            VStack {
                HStack {
                    Text("Shorts")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { showCreateShort = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Create")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)

                Spacer()
            }
        }
        .sheet(isPresented: $showCreateShort) {
            CreateShortView { newShort in
                shorts.insert(newShort, at: 0)
                currentIndex = 0
            }
        }
        .sheet(item: $activeShortForComments) { short in
            CommentsSheetView(post: SocialPost(
                id: short.id,
                authorName: short.authorName,
                authorHandle: short.authorHandle,
                timeAgo: "Now",
                content: short.caption,
                mediaUrl: short.videoUrl,
                likesCount: short.likesCount,
                repliesCount: short.commentsCount,
                repostsCount: short.sharesCount
            ))
        }
    }

    private func toggleLike(at index: Int) {
        guard index < shorts.count else { return }
        shorts[index].isLiked.toggle()
        shorts[index].likesCount += shorts[index].isLiked ? 1 : -1
    }

    private func toggleBookmark(at index: Int) {
        guard index < shorts.count else { return }
        shorts[index].isBookmarked.toggle()
    }
}

struct ShortPageCell: View {
    let short: ShortItemModel
    let isCurrent: Bool
    let onLike: () -> Void
    let onBookmark: () -> Void
    let onComment: () -> Void

    @State private var player: AVPlayer?
    @State private var isMuted = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()

            if let url = URL(string: short.videoUrl) {
                if let player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .onAppear {
                            if isCurrent {
                                player.isMuted = isMuted
                                player.play()
                            }
                        }
                        .onChange(of: isCurrent) { playing in
                            if playing {
                                player.play()
                            } else {
                                player.pause()
                            }
                        }
                } else {
                    ProgressView().tint(.white)
                        .onAppear {
                            let p = AVPlayer(url: url)
                            p.actionAtItemEnd = .none
                            NotificationCenter.default.addObserver(
                                forName: .AVPlayerItemDidPlayToEndTime,
                                object: p.currentItem,
                                queue: .main
                            ) { _ in
                                p.seek(to: .zero)
                                p.play()
                            }
                            self.player = p
                            if isCurrent { p.play() }
                        }
                }
            }

            // Right Action Controls Overlay
            VStack(spacing: 22) {
                Button(action: onLike) {
                    VStack(spacing: 4) {
                        Image(systemName: short.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 28))
                            .foregroundColor(short.isLiked ? .red : .white)
                        Text("\(short.likesCount)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                }

                Button(action: onComment) {
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                        Text("\(short.commentsCount)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                }

                Button(action: onBookmark) {
                    VStack(spacing: 4) {
                        Image(systemName: short.isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 26))
                            .foregroundColor(short.isBookmarked ? .yellow : .white)
                        Text("Save")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                }

                Button(action: {
                    isMuted.toggle()
                    player?.isMuted = isMuted
                }) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100)

            // Bottom Caption & Author Details Overlay
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(short.authorName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("@\(short.authorHandle)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Text(short.caption)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(3)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
