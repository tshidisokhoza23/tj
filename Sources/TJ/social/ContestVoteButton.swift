import SwiftUI

public struct ContestVoteButton: View {
    public let initialVotes: Int
    public var candidateName: String = "Candidate"
    public var onCastVote: (Int, Int) -> Void // (votesCount, pointsSpent)

    @State private var currentVotes: Int
    @State private var userPointsBalance: Int = 20
    @State private var showVoteSheet: Bool = false

    public init(initialVotes: Int, candidateName: String = "Candidate", onCastVote: @escaping (Int, Int) -> Void = { _, _ in }) {
        self.initialVotes = initialVotes
        self.candidateName = candidateName
        self._currentVotes = State(initialValue: initialVotes)
        self.onCastVote = onCastVote
    }

    public var body: some View {
        Button(action: { showVoteSheet = true }) {
            Text("Vote (\(currentVotes))")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "2563EB"))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showVoteSheet) {
            InteractiveVotingSheetView(
                candidateName: candidateName,
                currentVotes: currentVotes,
                userPointsBalance: $userPointsBalance,
                onConfirmVote: { votesToCast, ptsCost in
                    if userPointsBalance >= ptsCost {
                        userPointsBalance -= ptsCost
                        currentVotes += votesToCast
                        onCastVote(votesToCast, ptsCost)
                        showVoteSheet = false
                    }
                }
            )
            .presentationDetents([.height(380)])
        }
    }
}

public struct InteractiveVotingSheetView: View {
    public let candidateName: String
    public let currentVotes: Int
    @Binding public var userPointsBalance: Int
    public var onConfirmVote: (Int, Int) -> Void

    @State private var voteQty: Int = 1

    private var pointsCost: Int {
        voteQty * 5
    }

    private var hasEnoughPoints: Bool {
        userPointsBalance >= pointsCost
    }

    public var body: some View {
        VStack(spacing: 12) {
            Text("Vote for \(candidateName)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text("Current Votes: \(currentVotes)")
                .font(.system(size: 13))
                .foregroundColor(.gray)

            // Quantity Selector: [-] [ N Votes ] [+]
            HStack(spacing: 16) {
                Button(action: { if voteQty > 1 { voteQty -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color(hex: "2A303A"))
                        .clipShape(Circle())
                }

                Text("\(voteQty) Vote\(voteQty == 1 ? "" : "s")")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 100)

                Button(action: { if voteQty < 20 { voteQty += 1 } }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color(hex: "2563EB"))
                        .clipShape(Circle())
                }
            }
            .padding(.vertical, 4)

            Text("Cost: \(pointsCost) Points (5 pts / vote)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "F59E0B"))

            // User Points Balance Badge
            Text("Your Balance: \(userPointsBalance) Points")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(hasEnoughPoints ? Color(hex: "10B981") : Color(hex: "EF4444"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "2A303A"))
                .cornerRadius(12)

            // Confirm Vote Button
            Button(action: { onConfirmVote(voteQty, pointsCost) }) {
                Text(hasEnoughPoints ? "Confirm Vote (\(pointsCost) pts)" : "Need \(pointsCost - userPointsBalance) More Points")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(hasEnoughPoints ? Color(hex: "2563EB") : Color(hex: "374151"))
                    .cornerRadius(12)
            }
            .disabled(!hasEnoughPoints)

            // Ad Top-Up Option
            VStack(spacing: 4) {
                Text("Running low on points?")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Button(action: {
                    userPointsBalance += 10
                }) {
                    Text("🎬 Watch Video Ad (+10 pts)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "A78BFA"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "7C3AED"), lineWidth: 1))
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(Color(hex: "1E2228").ignoresSafeArea())
    }
}
