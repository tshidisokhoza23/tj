import SwiftUI

public struct TrendingFeedView: View {
    public var onNavigateBack: () -> Void
    public var onTopicClick: (String) -> Void
    public var onRefresh: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme

    private var bgColor: Color {
        colorScheme == .dark ? Color(hex: "121417") : Color.white
    }

    private var textColor: Color {
        colorScheme == .dark ? Color(hex: "F3F4F6") : Color.black
    }

    private var dividerColor: Color {
        colorScheme == .dark ? Color(hex: "22262C") : Color(hex: "EEEEEE")
    }

    // Dynamic Top 20 Trending Dataset
    private let trendingTopics = [
        "The ConCourt",
        "Edwin Sifuna",
        "Fikile Mbalula",
        "Julius Malema",
        "#HuntersICED",
        "#ChillersLager",
        "#Sibiya",
        "LGE 2026",
        "#MissThembisa",
        "#FridayFeeling",
        "Bafana Bafana",
        "#AmapianoAwards",
        "Kabelo",
        "Stage 2",
        "Midrand N1",
        "#SowetoDerby",
        "SARS",
        "Gold Reef",
        "#TaxSeason",
        "Uncle Waffles"
    ]

    public init(
        onNavigateBack: @escaping () -> Void,
        onTopicClick: @escaping (String) -> Void,
        onRefresh: @escaping () -> Void = {}
    ) {
        self.onNavigateBack = onNavigateBack
        self.onTopicClick = onTopicClick
        self.onRefresh = onRefresh
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: onNavigateBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }

                Spacer()

                HStack(spacing: 6) {
                    Text("Trending Now")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(textColor)
                    Text("🔥")
                        .font(.system(size: 18))
                }

                Spacer()

                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(bgColor)

            Divider().background(dividerColor)

            // Top 20 List
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(trendingTopics.prefix(20), id: \.self) { topic in
                        Button(action: { onTopicClick(topic) }) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(topic)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(textColor)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)

                                Divider().background(dividerColor).padding(.horizontal, 20)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .background(bgColor.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
