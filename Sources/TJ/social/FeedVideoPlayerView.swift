import SwiftUI
import AVKit

public struct FeedVideoPlayerView: View {
    public let url: URL
    @State private var player: AVPlayer?
    @State private var isMuted: Bool = true

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let player {
                VideoPlayer(player: player)
                    .frame(height: 260)
                    .cornerRadius(12)
                    .clipped()
                    .onAppear {
                        player.isMuted = isMuted
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }

                Button(action: {
                    isMuted.toggle()
                    player.isMuted = isMuted
                }) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.65))
                        .clipShape(Circle())
                }
                .padding(12)
            } else {
                Rectangle()
                    .fill(AppColors.cardDark)
                    .frame(height: 260)
                    .cornerRadius(12)
                    .overlay(ProgressView().tint(.white))
                    .onAppear {
                        let p = AVPlayer(url: url)
                        p.actionAtItemEnd = .none
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: p.currentItem,
                            queue: .main
                        ) { _ in
                            p.seek(to: .zero)
                            p.play()
                        }
                        self.player = p
                    }
            }
        }
    }
}
