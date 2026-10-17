import SwiftUI

public enum CourtPassTier: String, CaseIterable, Identifiable {
    case daily = "Daily Pass"
    case weekly = "Weekly Pass"
    case monthly = "Monthly Pass"

    public var id: String { rawValue }

    public var priceLabel: String {
        switch self {
        case .daily: return "R25.00 / 24h"
        case .weekly: return "R49.00 / 7 days"
        case .monthly: return "R100.00 / 30 days"
        }
    }

    public var durationText: String {
        switch self {
        case .daily: return "24 Hours Access"
        case .weekly: return "7 Days Access"
        case .monthly: return "30 Days Access"
        }
    }

    public var dmTokens: Int {
        switch self {
        case .daily: return 2
        case .weekly: return 7
        case .monthly: return 25
        }
    }

    public var badgeText: String? {
        switch self {
        case .daily: return nil
        case .weekly: return "POPULAR"
        case .monthly: return "BEST VALUE"
        }
    }
}

public struct CourtPassPaywallSheet: View {
    @Environment(\.dismiss) private var dismiss
    public var onPurchaseSuccess: (CourtPassTier) -> Void

    @State private var selectedTier: CourtPassTier = .weekly
    @State private var isProcessing: Bool = false
    @State private var alertMessage: String = ""

    public init(onPurchaseSuccess: @escaping (CourtPassTier) -> Void = { _ in }) {
        self.onPurchaseSuccess = onPurchaseSuccess
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header Banner
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "F59E0B"))

                    Text("Court Pass")
                        .font(.title.bold())
                        .foregroundColor(.primary)

                    Text("Unlock Who Liked You & Direct Notes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                // Perks List
                VStack(alignment: .leading, spacing: 12) {
                    perkRow(icon: "eye.fill", color: .purple, title: "Unlimited 'Who Liked Me' Unblur", desc: "See everyone who liked your profile instantly.")
                    perkRow(icon: "paperplane.fill", color: .blue, title: "Direct Notes (Unmatched DMs)", desc: "Send 140-char direct openers to anyone.")
                    perkRow(icon: "bolt.fill", color: .yellow, title: "Priority Visibility", desc: "Get featured at the top of local feeds.")
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // Tiers Selection
                VStack(spacing: 12) {
                    ForEach(CourtPassTier.allCases) { tier in
                        Button(action: { selectedTier = tier }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(tier.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        if let badge = tier.badgeText {
                                            Text(badge)
                                                .font(.caption2.bold())
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(tier == .monthly ? Color.green : Color.blue)
                                                .cornerRadius(8)
                                        }
                                    }

                                    Text("\(tier.durationText) • \(tier.dmTokens) Direct Note Tokens")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(tier.priceLabel)
                                    .font(.headline.bold())
                                    .foregroundColor(AppColors.brandPrimary)
                            }
                            .padding()
                            .background(selectedTier == tier ? AppColors.brandPrimary.opacity(0.1) : Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedTier == tier ? AppColors.brandPrimary : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Unlock Button
                Button(action: processPurchase) {
                    HStack {
                        if isProcessing {
                            ProgressView().tint(.white)
                                .padding(.trailing, 8)
                        }
                        Text(isProcessing ? "Processing..." : "Unlock \(selectedTier.rawValue) • \(selectedTier.priceLabel)")
                            .font(.headline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primaryGradient)
                    .foregroundColor(.white)
                    .cornerRadius(28)
                    .padding(.horizontal)
                }
                .disabled(isProcessing)
            }
            .navigationTitle("Court / Mingle VIP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Court Pass", isPresented: Binding(get: { !alertMessage.isEmpty }, set: { if !$0 { alertMessage = "" } })) {
                Button("OK", role: .cancel) { alertMessage = "" }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func perkRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func processPurchase() {
        guard !isProcessing else { return }
        isProcessing = true

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                isProcessing = false
                alertMessage = "Your \(selectedTier.rawValue) is now active! Unblurred likes & Direct Notes unlocked."
                onPurchaseSuccess(selectedTier)
                dismiss()
            }
        }
    }
}
