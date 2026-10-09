import SwiftUI

public struct CreatorDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timeRange: String = "30D"
    @State private var acceptTips: Bool = true
    @State private var acceptCommissions: Bool = false
    @State private var monthEarnings: String = "R 0.00"
    @State private var allEarnings: String = "R 0.00"
    @State private var tipsAmount: String = "R 0.00"
    @State private var tipsCount: Int = 0
    @State private var postViews: Int = 0
    @State private var newFollowers: Int = 0
    @State private var posts: [(String, Int, Int)] = []
    @State private var note: String = ""
    @State private var settingsReady: Bool = false

    public init() {}

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Range Selector
                    if !note.isEmpty {
                        Text(note)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    if !posts.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("YOUR POSTS")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.tealAccent)
                            ForEach(Array(posts.enumerated()), id: \.offset) { _, post in
                                Text("\(post.1) views · \(post.2) likes · \(post.0.isEmpty ? "Post" : post.0)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                    HStack {
                        Text("OVERVIEW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.tealAccent)

                        Spacer()

                        HStack(spacing: 6) {
                            ForEach(["7D", "30D", "All"], id: \.self) { range in
                                let isSel = timeRange == range
                                Button(action: {
                                    timeRange = range
                                    Task { await loadDashboard() }
                                }) {
                                    Text(range)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(isSel ? AppColors.tealAccent : .white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(isSel ? AppColors.tealAccent.opacity(0.2) : AppColors.cardDark)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSel ? AppColors.tealAccent : AppColors.borderDark, lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 2x2 Overview Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("This Month")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(monthEarnings)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("All time: \(allEarnings)")
                                .font(.caption2)
                                .foregroundColor(AppColors.tealAccent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tips Received")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(tipsAmount)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(tipsCount) tips total")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.purpleAccent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Post views")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(postViews)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("New Followers")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("+\(newFollowers)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                    }
                    .padding(.horizontal)

                    // Artist Tools & Commission Requests
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ARTIST TOOLS & COMMISSIONS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.tealAccent)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Commission Requests Inbox")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("0 Pending")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.tealAccent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppColors.tealAccent.opacity(0.2))
                                    .cornerRadius(10)
                            }

                            Divider().background(AppColors.borderDark)

                            Text("No commission requests. This inbox stays empty until someone sends a real request.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))

                        // Active Commissions Tracker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Commissions Tracker")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("No active commissions.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                    }
                    .padding(.horizontal)

                    // Monetization Controls
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MONETIZATION CONTROLS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.tealAccent)

                        VStack(spacing: 12) {
                            Toggle("Accept Tips on Posts", isOn: $acceptTips)
                                .foregroundColor(.white)
                                .tint(AppColors.tealAccent)

                            Divider().background(AppColors.borderDark)

                            Toggle("Accept Commissions", isOn: $acceptCommissions)
                                .foregroundColor(.white)
                                .tint(AppColors.tealAccent)

                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Text("Set Prices")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.tealAccent)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .overlay(Capsule().stroke(AppColors.tealAccent, lineWidth: 1))
                                }
                                Button(action: {}) {
                                    Text("Payout Settings")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(AppColors.darkCharcoal.ignoresSafeArea())
            .navigationTitle("Creator Dashboard")
            .task { await loadDashboard() }
            .onChange(of: acceptTips) { _ in Task { await saveSettings() } }
            .onChange(of: acceptCommissions) { _ in Task { await saveSettings() } }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private func loadDashboard() async {
        do {
            let data = try await API.data("creator/dashboard", query: ["range": timeRange])
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            monthEarnings = Self.rand(json["earnings_this_month_cents"] as? Int ?? 0)
            allEarnings = Self.rand(json["earnings_all_time_cents"] as? Int ?? 0)
            tipsAmount = Self.rand(json["tips_cents"] as? Int ?? 0)
            tipsCount = json["tips_count"] as? Int ?? 0
            postViews = json["post_views"] as? Int ?? 0
            newFollowers = json["new_followers"] as? Int ?? 0
            acceptTips = json["accept_tips"] as? Bool ?? true
            acceptCommissions = json["accept_commissions"] as? Bool ?? false
            let rows = json["posts"] as? [[String: Any]] ?? []
            posts = rows.map { row in
                (row["text"] as? String ?? "Post", row["views"] as? Int ?? 0, row["likes"] as? Int ?? 0)
            }
            note = ""
            settingsReady = true
        } catch {
            note = error.localizedDescription
        }
    }

    private func saveSettings() async {
        guard settingsReady else { return }
        _ = try? await API.data("creator/settings", method: "PUT", json: [
            "accept_tips": acceptTips,
            "accept_commissions": acceptCommissions
        ])
    }

    private static func rand(_ cents: Int) -> String {
        let sign = cents < 0 ? "-" : ""
        let value = abs(cents)
        return String(format: "%@R %d.%02d", sign, value / 100, value % 100)
    }
}
