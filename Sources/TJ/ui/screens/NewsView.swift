import SwiftUI
import SafariServices

public struct NewsView: View {
    @StateObject private var newsManager = NewsManager.shared
    @State private var selectedCategory: String = "All"
    @State private var activeArticleUrl: URL? = nil
    @Environment(\.dismiss) private var dismiss

    private let categories = ["All", "Politics", "Business", "Technology", "Entertainment", "Sports"]

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Pills Header
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            let isSelected = selectedCategory == cat
                            Button(action: {
                                selectedCategory = cat
                                Task { await newsManager.fetchInitialNews(category: cat) }
                            }) {
                                Text(cat)
                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }

                Divider()

                if newsManager.isLoading && newsManager.articles.isEmpty {
                    Spacer()
                    ProgressView("Loading news...")
                    Spacer()
                } else if newsManager.articles.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "newspaper")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("No news articles found")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(Array(newsManager.articles.enumerated()), id: \.element.id) { index, article in
                            NewsCardView(
                                article: article,
                                onCardClick: {
                                    if let url = URL(string: article.originalUrl) {
                                        activeArticleUrl = url
                                    }
                                },
                                onLike: {
                                    Task { await newsManager.toggleLike(articleId: article.id) }
                                },
                                onShare: {
                                    #if canImport(UIKit)
                                    let text = "\(article.title)\n\(article.source)\n\(article.originalUrl)\nRead on TJ News!"
                                    let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                        scene.windows.first?.rootViewController?.present(activity, animated: true)
                                    }
                                    #endif
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .onAppear {
                                if article.id == newsManager.articles.last?.id {
                                    Task { await newsManager.loadMoreNews(category: selectedCategory) }
                                }
                            }

                            if (index + 1) % 5 == 0 {
                                NativeAdRow(slot: "news-\(index)")
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowSeparator(.hidden)
                            }
                        }

                        if newsManager.isPaginationLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("News")
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
                await newsManager.fetchInitialNews(category: selectedCategory)
            }
            .sheet(item: $activeArticleUrl) { url in
                SafariView(url: url)
            }
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

struct NewsCardView: View {
    let article: NewsArticleItem
    var onCardClick: () -> Void
    var onLike: () -> Void
    var onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Image
            let imgUrl = article.imageUrl ?? "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800"
            if let url = URL(string: imgUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .cornerRadius(14)
                .clipped()
            }

            // Title & Source
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(3)
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Text(article.source)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    if let pub = article.publishedAt, !pub.isEmpty {
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(pub)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Action Row
            HStack(spacing: 12) {
                // Comments pill
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 12))
                    Text("\(article.commentCount) Comments")
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(12)

                // Like button
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: article.hasLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(article.hasLiked ? .accentColor : .secondary)
                        Text("\(article.likeCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Share to Chat button
                Button(action: onShare) {
                    HStack(spacing: 4) {
                        Text("Share to Chat")
                            .font(.system(size: 13, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .contentShape(Rectangle())
        .onTapGesture(perform: onCardClick)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
