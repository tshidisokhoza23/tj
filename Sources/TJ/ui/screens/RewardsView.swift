import SwiftUI

public struct RewardsView: View {
    @StateObject public var viewModel: RewardViewModel
    @State private var showInfoDialog = false

    public init(viewModel: RewardViewModel? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel ?? RewardViewModel())
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch viewModel.uiState {
                case .loading:
                    Spacer()
                    ProgressView("Loading points dashboard...")
                    Spacer()

                case .error(let msg):
                    Spacer()
                    VStack(spacing: 12) {
                        Text(msg)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            viewModel.fetchDashboard()
                        }
                        .font(.system(size: 15, weight: .bold))
                    }
                    .padding(24)
                    Spacer()

                case .success(let dash):
                    ScrollView {
                        VStack(spacing: 16) {
                            // Total Points Header Card
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text("Total Points")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Button(action: { showInfoDialog = true }) {
                                                Image(systemName: "info.circle")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                        Text("\(Int(dash.totalPoints)) pts")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.primary)
                                    }

                                    Spacer()

                                    ZStack {
                                        Circle()
                                            .fill(Color.orange.opacity(0.15))
                                            .frame(width: 52, height: 52)
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.orange)
                                    }
                                }

                                Divider()

                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Daily Ads Watched")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        Text("\(dash.adsWatchedToday) / \(dash.maxDailyAds)")
                                            .font(.system(size: 14, weight: .bold))
                                    }

                                    Spacer()

                                    Button(action: {
                                        viewModel.showRewardedAd(taskId: "watch_ad") {
                                            viewModel.fetchDashboard()
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "play.circle.fill")
                                            Text("Watch Ad (+10 pts)")
                                        }
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(viewModel.hasRewardedAdsAvailable ? Color.accentColor : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                    }
                                    .disabled(!viewModel.hasRewardedAdsAvailable)
                                }
                            }
                            .padding(16)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(18)

                            // Available Tasks Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DAILY REWARD TASKS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)

                                if dash.tasks.isEmpty {
                                    HStack {
                                        Text("Watch short ads or complete daily actions to earn extra points.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(14)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(14)
                                } else {
                                    ForEach(dash.tasks) { task in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(task.title)
                                                    .font(.system(size: 15, weight: .bold))
                                                Text("+\(task.pointsReward) points")
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(.orange)
                                            }

                                            Spacer()

                                            if task.is_completed {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 20))
                                            } else {
                                                Button("Claim") {
                                                    viewModel.showRewardedAd(taskId: task.id) {
                                                        viewModel.fetchDashboard()
                                                    }
                                                }
                                                .font(.system(size: 13, weight: .bold))
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 6)
                                                .background(Color.accentColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(16)
                                            }
                                        }
                                        .padding(14)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(14)
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Rewards & Points")
            .navigationBarTitleDisplayMode(.inline)
            .alert("About Points & Rewards", isPresented: $showInfoDialog) {
                Button("Got it", role: .cancel) {}
            } message: {
                Text("You earn 10 points after watching a rewarded ad. Points are used to vote in contests, top up your wallet, or unlock special features.")
            }
        }
    }
}
