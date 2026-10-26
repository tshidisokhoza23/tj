import SwiftUI

public struct RootActiveCallOverlayBanner: View {
    @ObservedObject public var callState: GlobalCallState

    public init(callState: GlobalCallState = GlobalCallState.shared) {
        self.callState = callState
    }

    private var durationLabel: String {
        let seconds = callState.callDurationSeconds
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 36, height: 36)
                Image(systemName: callState.activeCallType == .video ? "video.fill" : "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(callState.activeParticipantName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Text(callState.isConnectionEstablished ? "Connected • \(durationLabel)" : (callState.isRinging ? "Ringing..." : "Connecting..."))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Button(action: {
                callState.endCall()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 36, height: 36)
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: "0A2A6B"))
        .cornerRadius(20)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
