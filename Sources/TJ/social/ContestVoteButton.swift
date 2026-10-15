import SwiftUI

public enum VoteState {
    case freeAvailable
    case watchAd
    case completedLocked
}

public struct ContestVoteButton: View {
    public let initialVotes: Int
    public var onCastVote: (Bool) -> Void // isAdVote

    @State private var voteCount: Int
    @State private var voteState: VoteState = .freeAvailable

    public init(initialVotes: Int, onCastVote: @escaping (Bool) -> Void = { _ in }) {
        self.initialVotes = initialVotes
        self._voteCount = State(initialValue: initialVotes)
        self.onCastVote = onCastVote
    }

    private var buttonInfo: (text: String, color: Color) {
        switch voteState {
        case .freeAvailable:
            return ("Vote (\(voteCount))", Color(hex: "2563EB"))
        case .watchAd:
            return ("Vote Again (Watch Ad)", Color(hex: "7C3AED"))
        case .completedLocked:
            return ("Voted Today ✓", Color(hex: "374151"))
        }
    }

    public var body: some View {
        Button(action: {
            switch voteState {
            case .freeAvailable:
                voteCount += 1
                voteState = .watchAd
                onCastVote(false)
            case .watchAd:
                // Show Rewarded Ad or fallback
                voteCount += 1
                voteState = .completedLocked
                onCastVote(true)
            case .completedLocked:
                break
            }
        }) {
            Text(buttonInfo.text)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(buttonInfo.color)
                .cornerRadius(20)
        }
        .disabled(voteState == .completedLocked)
        .buttonStyle(.plain)
    }
}
