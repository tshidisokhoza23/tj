import SwiftUI

public struct SocialPost: Identifiable, Codable, Hashable {
    public let id: String
    public let authorName: String
    public let authorAvatar: String
    public let timestamp: String
    public let textContent: String
    public let imageUrl: String?
    public var likesCount: Int
    public var commentsCount: Int
    public var isLiked: Bool

    public init(id: String, authorName: String, authorAvatar: String, timestamp: String, textContent: String, imageUrl: String?, likesCount: Int, commentsCount: Int, isLiked: Bool) {
        self.id = id
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.timestamp = timestamp
        self.textContent = textContent
        self.imageUrl = imageUrl
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
    }
}

public struct AdItem: Identifiable {
    public let id: String
    public let sponsorName: String
    public let headline: String
    public let ctaText: String
    public let imageUrl: String?

    public static let samples = [
        AdItem(id: "ad_1", sponsorName: "TJ Premium", headline: "Get unlimited cloud storage & HD video calls", ctaText: "Try Free", imageUrl: nil)
    ]
}

public struct AdCardView: View {
    public let ad: AdItem

    public init(ad: AdItem) {
        self.ad = ad
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SPONSORED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.brandPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.brandPrimary.opacity(0.1))
                    .cornerRadius(4)

                Text(ad.sponsorName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
            }

            Text(ad.headline)
                .font(.headline)

            Button(action: {}) {
                Text(ad.ctaText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.brandPrimary)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

public struct CommentsSheetView: View {
    let post: SocialPost
    @Environment(\.dismiss) var dismiss
    @State private var commentText: String = ""

    public init(post: SocialPost) {
        self.post = post
    }

    public var body: some View {
        NavigationView {
            VStack {
                List {
                    Text("No comments yet. Be the first to comment!")
                        .foregroundColor(AppColors.greyMedium)
                }

                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)

                    Button("Send") { commentText = "" }
                        .disabled(commentText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
