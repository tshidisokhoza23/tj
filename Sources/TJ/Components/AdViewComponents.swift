import SwiftUI

public struct StableFeedAd: View {
    public let slot: String
    public let unitID: String

    public init(slot: String, unitID: String = "ca-app-pub-3940256099942544/3986624511") {
        self.slot = slot
        self.unitID = unitID
    }

    public var body: some View {
        NativeAdRow(slot: slot, unitID: unitID)
    }
}

public struct NativeAdRow: View {
    public let slot: String
    public let unitID: String

    public init(slot: String, unitID: String = "ca-app-pub-3940256099942544/3986624511") {
        self.slot = slot
        self.unitID = unitID
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("Ad")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(4)

                Text("Sponsored • Google Test Ad")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()
            }

            Text("Discover Featured Updates & Special Offers")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)

            Text("Tap to learn more about featured community products, events, and special promotions.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            AdBannerView(unitID: "ca-app-pub-3940256099942544/2934735716")
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.vertical, 6)
    }
}
