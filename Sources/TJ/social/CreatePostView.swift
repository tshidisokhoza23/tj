import SwiftUI
import PhotosUI

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
    @State private var showGifSheet: Bool = false
    @State private var gifQuery: String = ""
    @State private var attachedImages: [String] = []
    @State private var photoItem: PhotosPickerItem?
    @State private var pendingEditorURL: URL? = nil
    @State private var pendingIsVideo: Bool = false
    @State private var showAiAssistSheet: Bool = false
    @State private var isAiImproved: Bool = false
    @State private var isContestSelected: Bool = false
    @State private var contestHashtagInput: String = ""
    @State private var managerAccessCodeInput: String = ""

    private let maxCharacters = 280

    private var remainingCharacters: Int {
        maxCharacters - postText.count
    }

    private var isValidPost: Bool {
        let trimmed = postText.trimmingCharacters(in: .whitespacesAndNewlines)
        return (!trimmed.isEmpty || !attachedImages.isEmpty || !pollOptions.first!.isEmpty) && remainingCharacters >= 0
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
                    mainInputSection
                    categorySection
                    templatesSection

                    if !attachedImages.isEmpty {
                        mediaGridSection
                    }

                    Spacer().frame(height: 16)

                    bottomToolPanel
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

                ToolbarItem(placement: .principal) {
                    Text("\(remainingCharacters)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(remainingCharacters < 0 ? .red : AppColors.brandPrimary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: submitPost) {
                        Text("Share")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(isValidPost ? AnyView(AppColors.primaryGradient) : AnyView(Color.gray.opacity(0.4)))
                            .clipShape(Capsule())
                    }
                    .disabled(!isValidPost)
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
            .sheet(isPresented: $showGifSheet) {
                NavigationStack {
                    Form {
                        TextField("Search GIFs", text: $gifQuery)
                    }
                    .navigationTitle("GIFs")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showGifSheet = false }
                        }
                    }
                }
                .presentationDetents([.height(200)])
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
            .sheet(isPresented: $showCollaboratorsSheet) {
                NavigationStack {
                    Form {
                        TextField("Search people", text: $collaboratorQuery)
                    }
                    .navigationTitle("Collaborators")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showCollaboratorsSheet = false }
                        }
                    }
                }
                .presentationDetents([.height(220)])
            }
            .onChange(of: photoItem) { newItem in
                guard let newItem else { return }
                Task {
                    let type = newItem.supportedContentTypes.first
                    let mime = type?.preferredMIMEType ?? ""
                    let isVid = mime.hasPrefix("video")
                    if let data = try? await newItem.loadTransferable(type: Data.self), !data.isEmpty {
                        let ext = isVid ? "mp4" : "jpg"
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("post_media_\(Date().timeIntervalSince1970).\(ext)")
                        try? data.write(to: tempURL)
                        await MainActor.run {
                            self.pendingIsVideo = isVid
                            self.pendingEditorURL = tempURL
                        }
                    }
                }
            }
            .overlay {
                if let pendingEditorURL {
                    MediaEditorOverlay(
                        mediaURL: pendingEditorURL,
                        isVideo: pendingIsVideo,
                        onDismiss = {
                            self.pendingEditorURL = nil
                        },
                        onSend = { editedURL, caption in
                            if !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && postText.isEmpty {
                                postText = caption
                            }
                            attachedImages.append(editedURL.absoluteString)
                            self.pendingEditorURL = nil
                        }
                    )
                }
            }
        }
    }

    // MARK: - Subviews

    private var mainInputSection: some View {
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

                Button(action: { showMoodSheet = true }) {
                    Text(selectedMood.isEmpty ? "Add a mood" : selectedMood)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.brandPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .frame(height: 28)
                        .overlay(Capsule().stroke(AppColors.brandPrimary.opacity(0.6), lineWidth: 1))
                }
            }
        }
        .padding(.horizontal)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CATEGORY")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.horizontal)

            CreatePostFlowLayout(spacing: 6) {
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
                            .background(isSelected ? AnyView(AppColors.primaryGradient) : AnyView(AppColors.cardDark))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.clear : AppColors.borderDark, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var templatesSection: some View {
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
    }

    private var mediaGridSection: some View {
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

    private var bottomToolPanel: some View {
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

            Toggle(isOn: $isContestSelected) {
                HStack(spacing: 6) {
                    Text("🏆 Enter Contest / Pageant")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .tint(AppColors.brandPrimary)

            if isContestSelected {
                let validHashtags = ["#missthembisa", "#thembisatalent", "#misssoweto", "#gautengpageant", "#missection1"]
                let cleanTag = contestHashtagInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let isValidTag = cleanTag.isEmpty || validHashtags.contains(cleanTag.hasPrefix("#") ? cleanTag : "#\(cleanTag)")

                VStack(alignment: .leading, spacing: 6) {
                    TextField("Contest Hashtag (e.g. #MissThembisa)", text: $contestHashtagInput)
                        .padding(10)
                        .background(AppColors.cardDark)
                        .cornerRadius(8)
                        .foregroundColor(.white)

                    if !isValidTag {
                        Text("Hashtag must match an active contest (e.g. #MissThembisa)")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }

                    TextField("Manager Access Code (e.g. MGR-THEMB-1001)", text: $managerAccessCodeInput)
                        .padding(10)
                        .background(AppColors.cardDark)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }

            Divider().background(AppColors.borderDark)

            HStack(spacing: 0) {
                Group {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Image(systemName: "photo")
                    }
                    Spacer()
                    PhotosPicker(selection: $photoItem, matching: .videos) {
                        Image(systemName: "video")
                    }
                    Spacer()
                    Button(action: { showPollSheet = true }) {
                        Image(systemName: "chart.bar")
                    }
                    Spacer()
                    Button(action: { showGifSheet = true }) {
                        Text("GIF").font(.caption.bold())
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

    private func submitPost() {
        var postTextToSubmit = postText
        if isContestSelected && !contestHashtagInput.isEmpty {
            let tag = contestHashtagInput.hasPrefix("#") ? contestHashtagInput : "#\(contestHashtagInput)"
            if !postTextToSubmit.contains(tag) {
                postTextToSubmit = postTextToSubmit.isEmpty ? tag : "\(postTextToSubmit) \(tag)"
            }
        }

        let newPost = SocialPost(
            id: UUID().uuidString,
            authorName: "Alex Morgan",
            authorAvatar: "https://i.pravatar.cc/150?u=usr_1",
            timestamp: "Just now",
            textContent: postTextToSubmit,
            imageUrl: attachedImages.isEmpty ? nil : "attached_image",
            likesCount: 0,
            commentsCount: 0,
            isLiked: false,
            isAiImproved: isAiImproved,
            isContest: isContestSelected
        )
        socialViewModel.posts.insert(newPost, at: 0)
        dismiss()
    }
}

// MARK: - Official Layout Protocol FlowLayout for Wrapped Category Chips

struct CreatePostFlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return CGSize(width: width, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
