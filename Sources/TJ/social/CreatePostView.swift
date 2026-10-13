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
    @State private var selectedCategory: String = "Technology"
    @State private var selectedMood: String = ""
    @State private var selectedAudience: ReplyAudience = .everyone
    @State private var showAudienceSheet: Bool = false
    @State private var showMoodSheet: Bool = false
    @State private var showLocationSheet: Bool = false
    @State private var locationText: String = ""
    @State private var showPollSheet: Bool = false
    @State private var pollOptions: [String] = ["", ""]
    @State private var showScheduleSheet: Bool = false
    @State private var isScheduled: Bool = false
    @State private var showCollaboratorsSheet: Bool = false
    @State private var collaboratorQuery: String = ""
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

    private let categoriesList = [
        "All", "Technology", "Music", "Gaming",
        "Sports", "News", "Entertainment", "Art",
        "Lifestyle", "Business", "Education", "Health",
        "Food", "Comedy", "Relationships"
    ]

    private let moodsList = ["Feeling creative", "Hot take", "Question", "Excited", "Grateful"]

    public init() {}

    public var body: some View {
        NavigationView {
            ScrollView {
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
                                .frame(height: 100)
                                .font(.body)
                                .foregroundColor(.primary)
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

                            // Add a mood pill button (compact)
                            Button(action: { showMoodSheet = true }) {
                                Text(selectedMood.isEmpty ? "Add a mood" : selectedMood)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.brandPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .overlay(Capsule().stroke(AppColors.brandPrimary.opacity(0.6), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Category Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CATEGORY")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(categoriesList, id: \.self) { cat in
                                    let isSelected = selectedCategory == cat
                                    Button(action: { selectedCategory = cat }) {
                                        Text(cat)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(isSelected ? .white : AppColors.brandPrimary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .frame(height: 30)
                                            .background {
                                                if isSelected { AppColors.primaryGradient } else { AppColors.cardDark }
                                            }
                                            .cornerRadius(16)
                                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.clear : AppColors.borderDark, lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Template Chips
                    VStack(alignment: .leading, spacing: 6) {
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
                                            .foregroundColor(AppColors.brandPrimary)
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
                                            .fill(AppColors.brandPrimary.opacity(0.15))
                                            .frame(width: 90, height: 90)
                                            .overlay(
                                                Image(systemName: "photo.fill")
                                                    .foregroundColor(AppColors.brandPrimary)
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

                    Spacer().frame(height: 20)

                    // Floating Bottom Panel
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: { showAudienceSheet = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: selectedAudience.iconName)
                                Text(selectedAudience.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(AppColors.brandPrimary)
                        }

                        Divider().background(AppColors.borderDark)

                        // Icon Row
                        HStack(spacing: 0) {
                            Group {
                                Button(action: { attachedImages.append("sample_photo") }) {
                                    Image(systemName: "photo")
                                }
                                Spacer()
                                Button(action: { attachedImages.append("sample_video") }) {
                                    Image(systemName: "video")
                                }
                                Spacer()
                                Button(action: { showPollSheet = true }) {
                                    Image(systemName: "chart.bar")
                                }
                                Spacer()
                                Button(action: { showLocationSheet = true }) {
                                    Image(systemName: "location")
                                }
                                Spacer()
                                Button(action: { showScheduleSheet = true }) {
                                    Image(systemName: "calendar")
                                }
                                Spacer()
                                Button(action: { showCollaboratorsSheet = true }) {
                                    Image(systemName: "person.2")
                                }
                                Spacer()
                                Button(action: { showAiAssistSheet = true }) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppColors.brandPrimary)
                                }
                            }
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.brandPrimary)
                        }
                    }
                    .padding()
                    .background(AppColors.cardDark.opacity(0.95))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.borderDark, lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding(.top, 8)
            }
            .background(AppColors.darkCharcoal.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("\(remainingCharacters)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(remainingCharacters < 0 ? .red : AppColors.brandPrimary)
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
            .confirmationDialog("Select Mood", isPresented: $showMoodSheet, titleVisibility: .visible) {
                ForEach(moodsList, id: \.self) { mood in
                    Button(mood) { selectedMood = mood }
                }
                Button("Clear Mood", role: .destructive) { selectedMood = "" }
            }
            .sheet(isPresented: $showAiAssistSheet) {
                AiAssistSheetView(initialText: postText) { newText, isImproved in
                    postText = newText
                    isAiImproved = isImproved
                }
            }
            .sheet(isPresented: $showLocationSheet) {
                NavigationStack {
                    Form {
                        TextField("Place / Location", text: $locationText)
                    }
                    .navigationTitle("Location")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showLocationSheet = false }
                        }
                    }
                }
                .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showPollSheet) {
                NavigationStack {
                    Form {
                        TextField("Option 1", text: $pollOptions[0])
                        TextField("Option 2", text: $pollOptions[1])
                    }
                    .navigationTitle("Add Poll")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showPollSheet = false }
                        }
                    }
                }
                .presentationDetents([.height(220)])
            }
            .sheet(isPresented: $showScheduleSheet) {
                NavigationStack {
                    VStack(spacing: 16) {
                        Text(isScheduled ? "Scheduled to publish 1 hour from now." : "Publish immediately or schedule.")
                            .padding()
                        Button(isScheduled ? "Clear Schedule" : "Schedule in 1 hour") {
                            isScheduled.toggle()
                            showScheduleSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .navigationTitle("Schedule")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showScheduleSheet = false }
                        }
                    }
                }
                .presentationDetents([.height(200)])
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
