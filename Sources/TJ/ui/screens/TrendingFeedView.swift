import SwiftUI

public struct TrendingFeedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activeHashtag: String? = nil

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

    public init() {}

    public var body: some View {
        NavigationStack {
            List(trendingTopics, id: \.self) { topic in
                Button(action: {
                    let clean = topic.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    activeHashtag = clean
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(topic)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Trending in South Africa")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Trending Now 🔥")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .sheet(item: $activeHashtag) { tag in
                ContestFeedView(hashtag: tag)
            }
        }
    }
}
