import SwiftUI

public struct ContestFeedView: View {
    public let hashtag: String
    public var onNavigateBack: () -> Void

    private var cleanHashtag: String {
        hashtag.hasPrefix("#") ? hashtag : "#\(hashtag)"
    }

    @Environment(\.colorScheme) private var colorScheme

    private var bgColor: Color {
        Color(UIColor.systemBackground)
    }

    private var cardBgColor: Color {
        Color(UIColor.secondarySystemBackground)
    }

    private var textColor: Color {
        .primary
    }

    private var secondaryTextColor: Color {
        .secondary
    }

    private var accentBlue: Color {
        Color(hex: "2563EB")
    }

    private var goldYellow: Color {
        Color(hex: "F59E0B")
    }

    public init(hashtag: String, onNavigateBack: @escaping () -> Void) {
        self.hashtag = hashtag
        self.onNavigateBack = onNavigateBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onNavigateBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }

                Spacer()

                Text(cleanHashtag)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(textColor)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(bgColor)

            ScrollView {
                VStack(spacing: 16) {
                    // Pinned Top 3 Leaderboard Banner
                    VStack(spacing: 16) {
                        HStack {
                            Text("\(cleanHashtag) • Week 1")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(accentBlue)
                            Spacer()
                            Text("Ends in 3d 14h")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(goldYellow)
                        }

                        // Top 3 Podium
                        HStack(alignment: .bottom, spacing: 20) {
                            podiumContestant(name: "Lerato M.", rank: 2, votes: "1,420")
                            podiumContestant(name: "Bokang S.", rank: 1, votes: "2,150")
                            podiumContestant(name: "Zinhle N.", rank: 3, votes: "980")
                        }
                    }
                    .padding(16)
                    .background(cardBgColor)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)

                    // Submissions Section Header
                    HStack {
                        Text("Contestant Submissions")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(textColor)
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // Contest Post Cards
                    ForEach(1...10, id: \.self) { rank in
                        contestPostCard(rank: rank)
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .background(bgColor.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func podiumContestant(name: String, rank: Int, votes: String) -> some View {
        let size: CGFloat = rank == 1 ? 72 : 56
        let badgeColor = rank == 1 ? goldYellow : (rank == 2 ? Color.gray : Color.orange)

        return VStack(spacing: 6) {
            ZStack(alignment: .bottom) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(badgeColor, lineWidth: 2))

                Text("#\(rank)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(badgeColor)
                    .cornerRadius(10)
                    .offset(y: 8)
            }
            Text(name)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(textColor)
                .padding(.top, 4)
            Text("\(votes) votes")
                .font(.system(size: 11))
                .foregroundColor(secondaryTextColor)
        }
    }

    private func contestPostCard(rank: Int) -> some View {
        let post = FeedPost(
            id: "contest_post_\(rank)",
            authorId: "candidate_\(rank)",
            authorName: "Candidate #\(rank)",
            authorHandle: "candidate_\(rank)",
            authorAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
            content: "Vote for me in \(cleanHashtag)! Representation matters. ✨",
            mediaURLs: ["https://images.unsplash.com/photo-1534528741775-53994a69daeb"],
            likes: 1500 - (rank * 110),
            repliesCount: 12 + rank,
            postType: "standard",
            isLiked: false,
            isBookmarked: false,
            views: 4200 - (rank * 200),
            shares: 18 + rank,
            repostCount: 5 + rank,
            quoteCount: 0,
            isReposted: false,
            mediaType: "image",
            isVerifiedAuthor: true,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            isAuthorFollowed: false,
            repostOfId: "",
            originalAuthorId: "",
            originalAuthorName: "",
            originalAuthorHandle: "",
            originalAuthorAvatar: nil,
            originalContent: "",
            originalMediaURLs: [],
            originalMediaType: "",
            originalPostType: "",
            latestReplyAuthor: "",
            latestReplyText: "",
            mood: "",
            aiAssisted: false,
            collaboratorCount: 0,
            isContest: true
        )

        return FeedPostCard(
            post: post,
            onOpen: {},
            onProfile: {},
            onReply: {},
            onRepost: {},
            onLike: {},
            onSave: {},
            onShare: {},
            onMore: {}
        )
    }
}
