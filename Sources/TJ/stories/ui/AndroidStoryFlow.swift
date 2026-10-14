import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation
import UIKit

/// Same screens Android opens from the story menu: New Story, Text Story, Share Story, Posted stories.
public struct AndroidStoryFlow: View {
    public enum Start: String, Identifiable {
        case image
        case video
        case media
        case text
        case posted
        public var id: String { rawValue }
    }

    @State private var step: Start
    @State private var share: ShareDraft?
    @State private var playing: UserStory?
    @State private var playIndex = 0
    @State private var note = ""
    private let stories: [UserStory]
    private let currentUserId: String?
    private let onClose: () -> Void
    private let onPosted: () -> Void

    public init(start: Start, stories: [UserStory], currentUserId: String?, onClose: @escaping () -> Void, onPosted: @escaping () -> Void) {
        self._step = State(initialValue: start)
        self.stories = stories
        self.currentUserId = currentUserId
        self.onClose = onClose
        self.onPosted = onPosted
    }

    public var body: some View {
        Group {
            if let playing {
                StoryViewer(story: playing, startIndex: playIndex, onClose: {
                    self.playing = nil
                    if step == .posted { return }
                    onClose()
                })
            } else if let share {
                ShareStoryScreen(draft: share, onBack: { self.share = nil }, onPosted: {
                    onPosted()
                    let latest = StoryRepository.shared.userStories
                    if let mine = AndroidStoryFlow.myStory(in: latest.isEmpty ? stories : latest, userId: currentUserId) {
                        playIndex = 0
                        playing = mine
                    } else {
                        onClose()
                    }
                })
            } else {
                switch step {
                case .image:
                    NewStoryScreen(
                        filter: .images,
                        onBack: onClose,
                        onNext: { draft in share = draft }
                    )
                case .video:
                    NewStoryScreen(
                        filter: .videos,
                        onBack: onClose,
                        onNext: { draft in share = draft }
                    )
                case .media:
                    NewStoryScreen(
                        filter: .any(of: [.images, .videos]),
                        onBack: onClose,
                        onNext: { draft in share = draft }
                    )
                case .text:
                    TextStoryScreen(
                        onBack: onClose,
                        onShare: { text in
                            share = ShareDraft(content: text, type: "text", data: nil, filename: "", mime: "")
                        }
                    )
                case .posted:
                    PostedStoriesScreen(
                        currentUserId: currentUserId,
                        onBack: onClose,
                        onOpen: { story, index in
                            playIndex = index
                            playing = story
                        },
                        onText: { step = .text },
                        onMedia: { step = .image }
                    )
                }
            }
        }
        .alert("Story", isPresented: Binding(get: { !note.isEmpty }, set: { if !$0 { note = "" } })) {
            Button("OK", role: .cancel) { note = "" }
        } message: {
            Text(note)
        }
    }

    static func myStory(in stories: [UserStory], userId: String?) -> UserStory? {
        guard let userId, !userId.isEmpty else { return nil }
        let bare = userId.replacingOccurrences(of: "user_", with: "")
        return stories.first { story in
            let ids = [story.id, story.userId]
            return ids.contains(userId) || ids.contains(bare) || ids.contains("user_\(bare)")
        }
    }
}

struct ShareDraft: Identifiable {
    let id = UUID()
    var content: String
    var type: String
    var data: Data?
    var filename: String
    var mime: String
}

struct NewStoryScreen: View {
    var filter: PHPickerFilter = .any(of: [.images, .videos])
    var onBack: () -> Void
    var onNext: (ShareDraft) -> Void

    @State private var pickerItem: PhotosPickerItem?
    @State private var showPicker = true
    @State private var editorMediaURL: URL?
    @State private var isVideo = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let editorMediaURL {
                MediaEditorOverlay(
                    mediaURL: editorMediaURL,
                    isVideo: isVideo,
                    onDismiss: {
                        self.editorMediaURL = nil
                        onBack()
                    },
                    onSend: { editedURL, caption in
                        let data = (try? Data(contentsOf: editedURL)) ?? Data()
                        let mime = isVideo ? "video/mp4" : "image/jpeg"
                        let filename = isVideo ? "story.mp4" : "story.jpg"
                        let mediaType = isVideo ? "video" : "image"
                        onNext(ShareDraft(content: caption, type: mediaType, data: data, filename: filename, mime: mime))
                    }
                )
            } else {
                ProgressView().tint(.white)
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: filter)
        .onChange(of: showPicker) { isPresented in
            if !isPresented && pickerItem == nil && editorMediaURL == nil {
                onBack()
            }
        }
        .onChange(of: pickerItem) { item in
            guard let item else {
                if editorMediaURL == nil {
                    onBack()
                }
                return
            }
            Task { await load(item) }
        }
    }

    private func load(_ item: PhotosPickerItem) async {
        let type = item.supportedContentTypes.first
        let mime = type?.preferredMIMEType ?? "application/octet-stream"
        let vid = mime.hasPrefix("video")
        guard let data = try? await item.loadTransferable(type: Data.self), !data.isEmpty else {
            onBack()
            return
        }
        let ext = vid ? "mp4" : "jpg"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("story_\(Date().timeIntervalSince1970).\(ext)")
        try? data.write(to: tempURL)
        self.isVideo = vid
        self.editorMediaURL = tempURL
    }
}

struct TextStoryScreen: View {
    var onBack: () -> Void
    var onShare: (String) -> Void
    @State private var text = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "xmark")
                }
                Text("Text Story").font(.headline)
                Spacer()
            }
            .padding()
            Spacer()
            TextField("Type a story...", text: $text, axis: .vertical)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            Button("Share story") {
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onShare(text)
            }
            .font(.headline)
            .padding()
        }
    }
}
