import SwiftUI
import PhotosUI

public struct CreateShortView: View {
    @Environment(\.dismiss) private var dismiss
    public var onCreated: (ShortItemModel) -> Void

    @State private var caption: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var isUploading: Bool = false

    public init(onCreated: @escaping (ShortItemModel) -> Void) {
        self.onCreated = onCreated
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if videoURL != nil {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black)
                            .frame(height: 240)

                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.green)
                            Text("Video Ready for Short")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    PhotosPicker(selection: $selectedItem, matching: .videos) {
                        VStack(spacing: 12) {
                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.red)
                            Text("Select Video Clip")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }

                TextField("Add a caption...", text: $caption)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Spacer()

                Button(action: publishShort) {
                    HStack {
                        if isUploading {
                            ProgressView().tint(.white)
                                .padding(.trailing, 8)
                        }
                        Text(isUploading ? "Publishing Short..." : "Publish Short")
                            .font(.headline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(videoURL == nil ? Color.gray : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(28)
                    .padding(.horizontal)
                }
                .disabled(videoURL == nil || isUploading)
            }
            .navigationTitle("New Short")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: selectedItem) { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self), !data.isEmpty {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("short_\(Date().timeIntervalSince1970).mp4")
                        try? data.write(to: tempURL)
                        await MainActor.run {
                            self.videoURL = tempURL
                        }
                    }
                }
            }
        }
    }

    private func publishShort() {
        guard let videoURL, !isUploading else { return }
        isUploading = true

        Task {
            let sample = ShortItemModel(
                authorName: "My Story",
                authorHandle: "me",
                caption: caption.isEmpty ? "New Short Clip" : caption,
                videoUrl: videoURL.absoluteString
            )
            await MainActor.run {
                isUploading = false
                onCreated(sample)
                dismiss()
            }
        }
    }
}
