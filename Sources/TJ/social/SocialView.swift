import SwiftUI

public struct SocialView: View {
    @EnvironmentObject var socialViewModel: SocialViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @State private var showingCreatePost: Bool = false
    @State private var selectedPostForComments: SocialPost? = nil
    @State private var selectedPostForMenu: SocialPost? = nil
    @State private var selectedCategory: String = "All"
    @State private var selectedQualityMode: String = "Balanced (default)"

    @State private var showContests: Bool = false
    @State private var showTrending: Bool = false
    @State private var showCreateContest: Bool = false
    @State private var activeContestHashtag: String? = nil

    public init() {}

    private let categories = ["All", "Technology", "Music", "Gaming"]
    private let qualityOptions = [
        "Off",
        "Balanced (default)",
        "High quality only",
        "Following only",
        "Topics I follow",
        "Anti-ragebait filter"
    ]

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("TJ")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(AppColors.tealAccent)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? AppColors.primaryGradient : LinearGradient(colors: [AppColors.cardDark], startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // Sub-Bar: Quality, Contests, Trending
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Menu {
                            ForEach(qualityOptions, id: \.self) { opt in
                                Button(action: { selectedQualityMode = opt }) {
                                    HStack {
                                        Text(opt)
                                        if selectedQualityMode == opt {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Quality: \(selectedQualityMode) ▾")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.cardDark)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                        }

                        // 🏆 Contests Chip Button
                        Button(action: { showContests = true }) {
                            HStack(spacing: 4) {
                                Text("🏆 Contests")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "60A5FA"))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "2563EB").opacity(0.15))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "2563EB"), lineWidth: 1))
                        }

                        // 🔥 Trending Chip Button
                        Button(action: { showTrending = true }) {
                            HStack(spacing: 4) {
                                Text("🔥 Trending")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "F87171"))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "EF4444").opacity(0.15))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "EF4444"), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }

                // Feed Items
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(socialViewModel.posts.enumerated()), id: \.element.id) { index, post in
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 12) {
                                    // Author Header
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .stroke(AppColors.primaryGradient, lineWidth: 2)
                                                .frame(width: 44, height: 44)

                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 38, height: 38)
                                                .foregroundColor(AppColors.greyMedium)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(post.authorName)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("@\(post.authorHandle) • \(post.timeAgo)")
                                                .font(.caption)
                                                .foregroundColor(AppColors.greyLight)
                                        }

                                        Spacer()

                                        Button(action: {}) {
                                            Image(systemName: "ellipsis")
                                                .foregroundColor(.white)
                                        }
                                    }

                                    // Content Text
                                    Text(post.content)
                                        .font(.body)
                                        .foregroundColor(.white)

                                    // Media
                                    if let mediaUrl = post.mediaUrl {
                                        AsyncImage(url: URL(string: mediaUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxHeight: 300)
                                                .cornerRadius(12)
                                                .clipped()
                                        } placeholder: {
                                            Rectangle()
                                                .fill(AppColors.greyMedium.opacity(0.3))
                                                .frame(height: 200)
                                                .cornerRadius(12)
                                        }
                                    }

                                    // Action Pills
                                    HStack(spacing: 12) {
                                        if post.isContest {
                                            ContestVoteButton(initialVotes: max(post.likesCount, 10))
                                        }

                                        // Tip 💸 Button (ALWAYS shown)
                                        Button(action: {}) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "dollarsign.circle.fill")
                                                Text("Tip 💸")
                                            }
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppColors.tealAccent)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppColors.primaryGradient.opacity(0.3))
                                            .clipShape(Capsule())
                                        }

                                        // Reply
                                        Button(action: { selectedPostForComments = post }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "bubble.left")
                                                Text("Reply \(post.repliesCount)")
                                            }
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppColors.cardDark)
                                            .clipShape(Capsule())
                                        }

                                        // Repost
                                        Button(action: {}) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.2.squarepath")
                                                Text("Repost \(post.repostsCount)")
                                            }
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppColors.cardDark)
                                            .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding()
                                .background(AppColors.cardDark)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                                .padding(.horizontal)

                                if index % 3 == 0, let ad = AdItem.samples.first {
                                    AdCardView(ad: ad)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
            .background(AppColors.darkCharcoal.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
            .sheet(item: $selectedPostForComments) { post in
                CommentsSheetView(post: post)
            }
            .fullScreenCover(isPresented: $showContests) {
                ContestDiscoveryView(
                    onNavigateBack = { showContests = false },
                    onSelectContest = { tag in
                        showContests = false
                        activeContestHashtag = tag
                    },
                    onCreateContestClick = {
                        showContests = false
                        showCreateContest = true
                    }
                )
            }
            .fullScreenCover(isPresented: $showTrending) {
                TrendingFeedView(
                    onNavigateBack = { showTrending = false },
                    onTopicClick = { topic in
                        showTrending = false
                        activeContestHashtag = topic
                    }
                )
            }
            .fullScreenCover(item: Binding(get: { activeContestHashtag.map { StringWrapper(value: $0) } }, set: { activeContestHashtag = $0?.value })) { wrapper in
                ContestFeedView(hashtag: wrapper.value, onNavigateBack: { activeContestHashtag = nil })
            }
            .fullScreenCover(isPresented: $showCreateContest) {
                CreateContestView(
                    onNavigateBack = { showCreateContest = false },
                    onContestCreated = { tag in
                        showCreateContest = false
                        activeContestHashtag = tag
                    }
                )
            }
        }
    }
}

struct StringWrapper: Identifiable {
    let id = UUID()
    let value: String
}
