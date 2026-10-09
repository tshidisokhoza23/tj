import SwiftUI

public struct SocialView: View {
    @EnvironmentObject var socialViewModel: SocialViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @State private var showingCreatePost: Bool = false
    @State private var selectedPostForComments: SocialPost? = nil
    @State private var selectedPostForMenu: SocialPost? = nil
    @State private var selectedCategory: String = "All"
    @State private var selectedQualityMode: String = "Balanced (default)"

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
                            .foregroundColor(AppColors.tealAccent)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                // Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            let isSelected = selectedCategory == cat
                            Button(action: { selectedCategory = cat }) {
                                Text(cat)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(isSelected ? .white : AppColors.tealAccent)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? AnyView(AppColors.primaryGradient) : AnyView(AppColors.cardDark))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSelected ? Color.clear : AppColors.borderDark, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 4)

                // Quality Mode Dropdown Chip
                HStack {
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

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

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
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(post.timestamp)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Button(action: { selectedPostForMenu = post }) {
                                            Image(systemName: "ellipsis")
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    // Content Text
                                    Text(post.textContent)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)

                                    if post.isAiImproved {
                                        Text("Improved with AI ✨")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }

                                    if let _ = post.imageUrl {
                                        Rectangle()
                                            .fill(AppColors.primaryGradient.opacity(0.2))
                                            .frame(height: 200)
                                            .cornerRadius(12)
                                            .overlay(
                                                Image(systemName: "photo.fill")
                                                    .font(.largeTitle)
                                                    .foregroundColor(AppColors.tealAccent)
                                            )
                                    }

                                    // Engagement Bar
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            // Reply
                                            Button(action: { selectedPostForComments = post }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "bubble.left")
                                                    Text("\(post.commentsCount)")
                                                }
                                                .font(.caption)
                                                .foregroundColor(AppColors.tealAccent)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(AppColors.cardDark)
                                                .clipShape(Capsule())
                                            }

                                            // Repost
                                            Button(action: {}) {
                                                Image(systemName: "arrow.2.squarepath")
                                                    .font(.caption)
                                                    .foregroundColor(AppColors.tealAccent)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(AppColors.cardDark)
                                                    .clipShape(Capsule())
                                            }

                                            // Like
                                            Button(action: { socialViewModel.toggleLike(for: post) }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                                        .foregroundColor(post.isLiked ? .red : AppColors.tealAccent)
                                                    Text("\(post.likesCount)")
                                                }
                                                .font(.caption)
                                                .foregroundColor(post.isLiked ? .red : AppColors.tealAccent)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(AppColors.cardDark)
                                                .clipShape(Capsule())
                                            }

                                            // Views
                                            HStack(spacing: 4) {
                                                Image(systemName: "eye")
                                                Text("\(post.viewsCount)")
                                            }
                                            .font(.caption)
                                            .foregroundColor(AppColors.tealAccent)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppColors.cardDark)
                                            .clipShape(Capsule())

                                            // Bookmark
                                            Button(action: {}) {
                                                Image(systemName: "bookmark")
                                                    .font(.caption)
                                                    .foregroundColor(AppColors.tealAccent)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(AppColors.cardDark)
                                                    .clipShape(Capsule())
                                            }

                                            // Tip
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
        }
    }
}
