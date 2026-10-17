import SwiftUI
import UIKit

public struct ShareStoryScreen: View {
    var draft: ShareDraft
    var onBack: () -> Void
    var onPosted: () -> Void

    @State private var selectedPrivacy = "contacts"
    @State private var allowScreenshots = true
    @State private var postToProfile = true
    @State private var isPosting = false
    @State private var errorMessage = ""

    private let privacyOptions = [
        ("contacts", "Contacts", "person.2.fill"),
        ("everyone", "Everyone", "globe"),
        ("except", "Contacts Except...", "person.fill.xmark")
    ]

    public init(
        draft: ShareDraft,
        onBack: @escaping () -> Void,
        onPosted: @escaping () -> Void
    ) {
        self.draft = draft
        self.onBack = onBack
        self.onPosted = onPosted
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Preview Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PREVIEW")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            if draft.type == "video" {
                                Image(systemName: "video.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                            } else if let data = draft.data, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Image(systemName: "quote.bubble.fill")
                                    .font(.title)
                                    .foregroundColor(.purple)
                                    .frame(width: 60, height: 60)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(12)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(draft.content.isEmpty ? "Story Update" : draft.content)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)

                                Text(draft.type.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)

                    // Privacy Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WHO CAN SEE THIS STORY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)

                        VStack(spacing: 0) {
                            ForEach(privacyOptions, id: \.0) { option in
                                Button(action: { selectedPrivacy = option.0 }) {
                                    HStack {
                                        Image(systemName: option.2)
                                            .foregroundColor(.blue)
                                            .frame(width: 24)

                                        Text(option.1)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        if selectedPrivacy == option.0 {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                }

                                if option.0 != privacyOptions.last?.0 {
                                    Divider().padding(.leading, 52)
                                }
                            }
                        }
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                    }

                    // Preferences
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SETTINGS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)

                        VStack(spacing: 0) {
                            Toggle(isOn: $allowScreenshots) {
                                Label("Allow Screenshots", systemImage: "camera.viewfinder")
                            }
                            .padding()

                            Divider()

                            Toggle(isOn: $postToProfile) {
                                Label("Share to Profile", systemImage: "person.circle")
                            }
                            .padding()
                        }
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                    }

                    Spacer()

                    // Post Button
                    Button(action: postStory) {
                        HStack {
                            if isPosting {
                                ProgressView().tint(.white)
                                    .padding(.trailing, 8)
                            }
                            Text(isPosting ? "Posting Story..." : "Share Story")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isPosting ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(28)
                    }
                    .disabled(isPosting)
                }
                .padding()
            }
            .navigationTitle("New Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onBack)
                        .disabled(isPosting)
                }
            }
            .alert("Error Posting Story", isPresented: Binding(get: { !errorMessage.isEmpty }, set: { if !$0 { errorMessage = "" } })) {
                Button("OK", role: .cancel) { errorMessage = "" }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func postStory() {
        guard !isPosting else { return }
        isPosting = true

        Task {
            do {
                var contentUrl: String? = nil
                if let data = draft.data, !data.isEmpty {
                    let base64 = data.base64EncodedString()
                    contentUrl = "data:\(draft.mime);base64,\(base64)"
                }

                let success = try await StoryRepository.shared.createStory(
                    content: draft.content,
                    contentUrl: contentUrl,
                    type: draft.type,
                    privacy: selectedPrivacy
                )

                await MainActor.run {
                    isPosting = false
                    if success {
                        onPosted()
                    } else {
                        errorMessage = "Failed to publish story. Please try again."
                    }
                }
            } catch {
                await MainActor.run {
                    isPosting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
