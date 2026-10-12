import SwiftUI

enum ReplyAudience: String, CaseIterable, Identifiable {
    case everyone = "Public ▾"
    case following = "Followers ▾"
    case mentioned = "Circles ▾"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .everyone: return "globe"
        case .following: return "person.2.fill"
        case .mentioned: return "circle.grid.cross"
        }
    }
}

public struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var socialViewModel: SocialViewModel

    @State private var postText: String = ""
    @State private var selectedAudience: ReplyAudience = .everyone
    @State private var showAudienceSheet: Bool = false
    @State private var attachedImages: [String] = []
    @State private var showAiAssistSheet: Bool = false
    @State private var isAiImproved: Bool = false

    private let maxCharacters = 280

    private var remainingCharacters: Int {
        maxCharacters - postText.count
    }

    private var isValidPost: Bool {
        let trimmed = postText.trimmingCharacters(in: .whitespacesAndNewlines)
        return (!trimmed.isEmpty || !attachedImages.isEmpty) && remainingCharacters >= 0
    }

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                // Main Area with Progress Ring Avatar
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(AppColors.primaryGradient, lineWidth: 2)
                            .frame(width: 48, height: 48)

                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(AppColors.greyMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $postText)
                            .frame(height: 120)
                            .font(.body)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .overlay(
                                Group {
                                    if postText.isEmpty {
                                        Text("Share your thoughts...")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 4)
                                            .padding(.top, 8)
                                    }
                                },
                                alignment: .topLeading
                            )

                        // Feeling creative pill (compact)
                        Button(action: { showAiAssistSheet = true }) {
                            Text("Feeling creative ✨")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.tealAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .overlay(Capsule().stroke(AppColors.tealAccent, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal)

                // Template Chips (Compact 30pt height)
                VStack(alignment: .leading, spacing: 4) {
                    Text("TEMPLATES")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach([
                                ("🔥 Hot take", "Hot take: "),
                                ("❓ Question", "Question for community: "),
                                ("🧵 Thread", "Thread 🧵 (1/N):\n"),
                                ("📢 Announcement", "📢 Big announcement: ")
                            ], id: \.0) { label, prefix in
                                Button(action: {
                                    if !postText.hasPrefix(prefix) {
                                        postText = prefix + postText
                                    }
                                }) {
                                    Text(label)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.tealAccent)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .frame(height: 30)
                                        .background(AppColors.cardDark)
                                        .cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                if !attachedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(attachedImages.indices, id: \.self) { idx in
                                ZStack(alignment: .topTrailing) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.tealAccent.opacity(0.15))
                                        .frame(width: 90, height: 90)
                                        .overlay(
                                            Image(systemName: "photo.fill")
                                                .foregroundColor(AppColors.tealAccent)
                                        )

                                    Button(action: { attachedImages.remove(at: idx) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                    }
                                    .padding(4)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                // Floating Bottom Panel (Dark Translucent)
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: { showAudienceSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: selectedAudience.iconName)
                            Text(selectedAudience.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppColors.tealAccent)
                    }

                    Divider().background(AppColors.borderDark)

                    // Icon Row
                    HStack(spacing: 0) {
                        Group {
                            Button(action: { attachedImages.append("sample_photo") }) {
                                Image(systemName: "photo")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "video")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "hand.raised")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "waveform")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "chart.bar")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "location")
                            }
                            Spacer()
                            Button(action: { showAiAssistSheet = true }) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(AppColors.tealAccent)
                            }
                        }
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.tealAccent)
                    }
                }
                .padding()
                .background(AppColors.cardDark.opacity(0.95))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.borderDark, lineWidth: 1))
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(AppColors.darkCharcoal.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("\(remainingCharacters)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(remainingCharacters < 0 ? .red : AppColors.tealAccent)
                            Text("Draft saved")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        Button(action: submitPost) {
                            Text("Share")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(isValidPost ? AnyView(AppColors.primaryGradient) : AnyView(Color.gray.opacity(0.4)))
                                .clipShape(Capsule())
                        }
                        .disabled(!isValidPost)
                    }
                }
            }
            .confirmationDialog("Who can reply?", isPresented: $showAudienceSheet, titleVisibility: .visible) {
                ForEach(ReplyAudience.allCases) { audience in
                    Button(audience.rawValue) {
                        selectedAudience = audience
                    }
                }
            }
            .sheet(isPresented: $showAiAssistSheet) {
                AiAssistSheetView(initialText: postText) { newText, isImproved in
                    postText = newText
                    isAiImproved = isImproved
                }
            }
        }
    }

    private func submitPost() {
        let newPost = SocialPost(
            id: UUID().uuidString,
            authorName: "Alex Morgan",
            authorAvatar: "https://i.pravatar.cc/150?u=usr_1",
            timestamp: "Just now",
            textContent: postText,
            imageUrl: attachedImages.isEmpty ? nil : "attached_image",
            likesCount: 0,
            commentsCount: 0,
            isLiked: false,
            isAiImproved: isAiImproved
        )
        socialViewModel.posts.insert(newPost, at: 0)
        dismiss()
    }
}
