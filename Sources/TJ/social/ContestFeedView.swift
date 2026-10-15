import SwiftUI

public struct ContestFeedView: View {
    public let hashtag: String
    public var onNavigateBack: () -> Void

    private var cleanHashtag: String {
        hashtag.hasPrefix("#") ? hashtag : "#\(hashtag)"
    }

    private let darkBg = Color(hex: "121417")
    private let darkSurface = Color(hex: "1E2228")
    private let accentBlue = Color(hex: "2563EB")
    private let goldYellow = Color(hex: "F59E0B")

    public init(hashtag: String, onNavigateBack: @escaping () -> Void) {
        self.hashtag = hashtag
        self.onNavigateBack = onNavigateBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onNavigateBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text(cleanHashtag)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(darkBg)

            ScrollView {
                VStack(spacing: 16) {
                    // Pinned Top 3 Leaderboard Banner
                    VStack(spacing: 16) {
                        HStack {
                            Text("\(cleanHashtag) • Week 1")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(accentBlue)
                            Spacer()
                            Text("Ends in 3d 14h")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(goldYellow)
                        }

                        // Top 3 Podium
                        HStack(alignment: .bottom, spacing: 20) {
                            podiumContestant(name: "Lerato M.", rank: 2, votes: "1,420")
                            podiumContestant(name: "Bokang S.", rank: 1, votes: "2,150")
                            podiumContestant(name: "Zinhle N.", rank: 3, votes: "980")
                        }
                    }
                    .padding(16)
                    .background(darkSurface)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)

                    // Submissions Section Header
                    HStack {
                        Text("Contestant Submissions")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // Contest Post Cards
                    ForEach(1...10, id: \.self) { rank in
                        contestPostCard(rank: rank)
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .background(darkBg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func podiumContestant(name: String, rank: Int, votes: String) -> some View {
        let size: CGFloat = rank == 1 ? 72 : 56
        let badgeColor = rank == 1 ? goldYellow : (rank == 2 ? Color.gray : Color.orange)

        return VStack(spacing: 6) {
            ZStack(alignment: .bottom) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(badgeColor, lineWidth: 2))

                Text("#\(rank)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(badgeColor)
                    .cornerRadius(10)
                    .offset(y: 8)
            }
            Text(name)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)
            Text("\(votes) votes")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }

    private func contestPostCard(rank: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(goldYellow)
                        .font(.system(size: 14))
                    Text("Rank #\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(goldYellow)
                }
                Spacer()
                Text("@mgr_thembisa")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Text("Vote for me in \(cleanHashtag)! Representation matters. ✨")
                .font(.system(size: 14))
                .foregroundColor(.white)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 280)

            HStack {
                Text("Candidate #\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                ContestVoteButton(initialVotes: 1500 - (rank * 110))
            }
        }
        .padding(16)
        .background(darkSurface)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}
