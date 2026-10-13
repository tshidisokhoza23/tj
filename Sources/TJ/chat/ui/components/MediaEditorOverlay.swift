import SwiftUI
import AVKit
import PhotosUI

public struct MediaEditorOverlay: View {
    public let mediaURL: URL
    public let isVideo: Bool
    public var onDismiss: () -> Void
    public var onSend: (URL, String) -> Void // (editedURL, caption)

    @State private var caption: String = ""
    @State private var isMuted: Bool = false
    @State private var isPlaying: Bool = true
    @State private var showCropTools: Bool = false
    @State private var showTextOverlay: Bool = false
    @State private var textOverlayInput: String = ""
    @State private var textOverlayColor: Color = .white
    @State private var startTrimRatio: Double = 0.0
    @State private var endTrimRatio: Double = 1.0
    @State private var player: AVPlayer?
    @State private var videoDurationSeconds: Double = 13.0
    @State private var videoCurrentTimeSeconds: Double = 0.0

    public init(
        mediaURL: URL,
        isVideo: Bool,
        onDismiss: @escaping () -> Void,
        onSend: @escaping (URL, String) -> Void
    ) {
        self.mediaURL = mediaURL
        self.isVideo = isVideo
        self.onDismiss = onDismiss
        self.onSend = onSend
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar (Screenshot 1 & 2)
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Preview")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 18) {
                        if isVideo {
                            Button(action: {
                                isMuted.toggle()
                                player?.isMuted = isMuted
                            }) {
                                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                        }

                        Button(action: { showCropTools.toggle() }) {
                            Image(systemName: "crop")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }

                        Button(action: { showTextOverlay.toggle() }) {
                            Text("T T")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // MARK: - Video Thumbnail Trimmer Strip (Screenshot 2)
                if isVideo {
                    VStack(spacing: 4) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 38)

                            // Blue Trimmer Handles & Selection Box
                            GeometryReader { geometry in
                                let width = geometry.size.width
                                let leftOffset = width * startTrimRatio
                                let rightOffset = width * endTrimRatio

                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(red: 0.0, green: 0.53, blue: 0.85), lineWidth: 3)
                                        .background(Color(red: 0.0, green: 0.53, blue: 0.85).opacity(0.2))
                                        .frame(width: max(rightOffset - leftOffset, 20))
                                        .offset(x: leftOffset)
                                }
                            }
                            .frame(height: 38)
                        }
                        .padding(.horizontal, 16)

                        Text("0:13 · 14.0 MB")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.vertical, 6)
                }

                Spacer()

                // MARK: - Main Media Preview Area with Controls (Screenshot 1 & 2)
                ZStack {
                    if isVideo {
                        VideoPlayer(player: player)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .onAppear {
                                setupVideoPlayer()
                            }
                            .onDisappear {
                                player?.pause()
                                player = nil
                            }

                        // Video Playback Controls Overlay (Screenshot 2)
                        HStack(spacing: 36) {
                            Button(action: { seekBy(seconds: -5) }) {
                                Image(systemName: "gobackward.5")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Button(action: togglePlayPause) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 54, weight: .medium))
                                    .foregroundColor(.white)
                            }

                            Button(action: { seekBy(seconds: 5) }) {
                                Image(systemName: "goforward.5")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }

                        // Progress Seekbar Line (Screenshot 2)
                        VStack {
                            Spacer()
                            HStack {
                                Text("00:00 · 00:13")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                    } else {
                        AsyncImage(url: mediaURL) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFit()
                            } else {
                                ProgressView().tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // Text Overlay Annotation
                    if !textOverlayInput.isEmpty {
                        Text(textOverlayInput)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textOverlayColor)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                }

                Spacer()

                // MARK: - Bottom Caption & Send Bar (Screenshot 1 & 2)
                HStack(spacing: 12) {
                    HStack {
                        TextField("Add a caption...", text: $caption)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.15))
                    .clipShape(Capsule())

                    Button(action: {
                        onSend(mediaURL, caption)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.0, green: 0.53, blue: 0.85)) // #0088CC blue
                                .frame(width: 52, height: 52)

                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: -1, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    private func setupVideoPlayer() {
        let p = AVPlayer(url: mediaURL)
        p.isMuted = isMuted
        p.play()
        self.player = p
        self.isPlaying = true
    }

    private func togglePlayPause() {
        guard let p = player else { return }
        if isPlaying {
            p.pause()
            isPlaying = false
        } else {
            p.play()
            isPlaying = true
        }
    }

    private func seekBy(seconds: Double) {
        guard let p = player else { return }
        let current = p.currentTime()
        let target = CMTimeAdd(current, CMTime(seconds: seconds, preferredTimescale: 1000))
        p.seek(to: target)
    }
}
