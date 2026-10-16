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
    public var viewsCount: Int
    public var isLiked: Bool
    public var isBookmarked: Bool
    public var isAiImproved: Bool
    public var tipCount: Int
    public var isContest: Bool

    public init(
        id: String,
        authorName: String,
        authorAvatar: String,
        timestamp: String,
        textContent: String,
        imageUrl: String?,
        likesCount: Int,
        commentsCount: Int,
        viewsCount: Int = 120,
        isLiked: Bool,
        isBookmarked: Bool = false,
        isAiImproved: Bool = false,
        tipCount: Int = 0,
        isContest: Bool = false
    ) {
        self.id = id
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.timestamp = timestamp
        self.textContent = textContent
        self.imageUrl = imageUrl
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.viewsCount = viewsCount
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
        self.isAiImproved = isAiImproved
        self.tipCount = tipCount
        self.isContest = isContest
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
                    .foregroundColor(AppColors.tealAccent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.tealAccent.opacity(0.1))
                    .cornerRadius(4)

                Text(ad.sponsorName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }

            Text(ad.headline)
                .font(.headline)
                .foregroundColor(.white)

            Button(action: {}) {
                Text(ad.ctaText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.tealAccent)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
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
                .background(AppColors.darkCharcoal)

                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .padding(10)
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .foregroundColor(.white)

                    Button("Send") { commentText = "" }
                        .foregroundColor(AppColors.tealAccent)
                        .disabled(commentText.isEmpty)
                }
                .padding()
            }
            .background(AppColors.darkCharcoal)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}
