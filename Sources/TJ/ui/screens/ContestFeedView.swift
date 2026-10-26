import SwiftUI

public struct ContestFeedView: View {
    public let hashtag: String
    @StateObject private var contestManager = ContestManager.shared
    @Environment(\.dismiss) private var dismiss

    public init(hashtag: String) {
        self.hashtag = hashtag
    }

    private var cleanHashtag: String {
        hashtag.hasPrefix("#") ? hashtag : "#\(hashtag)"
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if contestManager.isLoading && contestManager.activeFeedPosts.isEmpty {
                    Spacer()
                    ProgressView("Loading contest feed...")
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Contest Header Card
                            VStack(alignment: .leading, spacing: 10) {
                                Text(contestManager.activeContest?.title ?? cleanHashtag)
                                    .font(.system(size: 20, weight: .bold))

                                Text(contestManager.activeContest?.description ?? "Enter with a manager code, then ask people to vote.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)

                                let participantCount = contestManager.activeContest?.entryCount ?? contestManager.leaderboard.count
                                Text("\(participantCount) participant\(participantCount == 1 ? "" : "s") • \(contestManager.activeContest?.voteCount ?? 0) votes • \(contestManager.userPoints) points left")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.orange)

                                if !contestManager.leaderboard.isEmpty {
                                    Text("Leaderboard")
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.top, 6)

                                    ForEach(Array(contestManager.leaderboard.prefix(5).enumerated()), id: \.element.id) { index, entry in
                                        HStack {
                                            Text("\(index + 1). \(entry.authorName.isEmpty ? "Contestant" : entry.authorName)")
                                                .font(.system(size: 13, weight: .medium))
                                            Spacer()
                                            Text("\(entry.votes) votes")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(18)

                            // Feed Posts List
                            if contestManager.activeFeedPosts.isEmpty {
                                Text("No contestant entries yet. Create a post with this hashtag and a manager code.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 20)
                            } else {
                                ForEach(contestManager.activeFeedPosts) { post in
                                    FeedPostCard(
                                        post: post,
                                        onOpen: {},
                                        onProfile: { _ in },
                                        onReply: {},
                                        onRepost: {},
                                        onLike: {
                                            Task { _ = await contestManager.castVote(postId: post.id) }
                                        },
                                        onSave: {},
                                        onShare: {},
                                        onMore: {}
                                    )
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(cleanHashtag)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .task {
                await contestManager.fetchContestFeed(hashtag: hashtag)
            }
        }
    }
}

public struct ContestVoteButton: View {
    @State public var initialVotes: Int
    @State private var isVoting = false

    public init(initialVotes: Int) {
        self._initialVotes = State(initialValue: initialVotes)
    }

    public var body: some View {
        Button(action: {
            guard !isVoting else { return }
            isVoting = true
            initialVotes += 1
            Task {
                _ = await ContestManager.shared.castVote(postId: "contest_vote")
                isVoting = false
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                Text("Vote \(initialVotes)")
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.15))
            .foregroundColor(.orange)
            .cornerRadius(16)
        }
    }
}
