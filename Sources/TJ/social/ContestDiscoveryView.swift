import SwiftUI

public struct ContestDiscoveryView: View {
    public var onNavigateBack: () -> Void
    public var onSelectContest: (String) -> Void
    public var onCreateContestClick: () -> Void

    @State private var searchQuery: String = ""
    @State private var selectedFilter: String = "Trending"

    @Environment(\.colorScheme) private var colorScheme

    private var bgColor: Color {
        Color(UIColor.systemBackground)
    }

    private var cardBgColor: Color {
        Color(UIColor.secondarySystemBackground)
    }

    private var textColor: Color {
        .primary
    }

    private var secondaryTextColor: Color {
        .secondary
    }

    private var accentBlue: Color {
        Color(hex: "2563EB")
    }

    private var goldYellow: Color {
        Color(hex: "F59E0B")
    }

    private let topContests = [
        ("#MissThembisa", "4.2k voters"),
        ("#ThembisaTalent", "3.8k voters"),
        ("#ThembisaQueen", "3.1k voters"),
        ("#MissSoweto", "2.9k voters"),
        ("#GautengPageant", "2.4k voters")
    ]

    public init(
        onNavigateBack: @escaping () -> Void,
        onSelectContest: @escaping (String) -> Void,
        onCreateContestClick: @escaping () -> Void
    ) {
        self.onNavigateBack = onNavigateBack
        self.onSelectContest = onSelectContest
        self.onCreateContestClick = onCreateContestClick
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top App Bar
            HStack {
                Button(action: onNavigateBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }

                Spacer()

                Text("Contests & Hashtags")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(textColor)

                Spacer()

                Button(action: onCreateContestClick) {
                    Text("+ Host")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(accentBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(bgColor)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(secondaryTextColor)
                        TextField("Search 10k+ contests (e.g., #MissThembisa)", text: $searchQuery)
                            .foregroundColor(textColor)
                        if !searchQuery.isEmpty {
                            Button(action: { searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(secondaryTextColor)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(cardBgColor)
                    .cornerRadius(24)

                    if !searchQuery.isEmpty {
                        // Search Autocomplete Results
                        Text("Search Results")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(textColor)
                            .padding(.top, 8)

                        ForEach(["#MissThembisa", "#ThembisaTalent", "#ThembisaQueen", "#MissSoweto"], id: \.self) { tag in
                            Button(action: { onSelectContest(tag) }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tag)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(accentBlue)
                                        Text("Active • 2.8k votes")
                                            .font(.system(size: 12))
                                            .foregroundColor(secondaryTextColor)
                                    }
                                    Spacer()
                                    Text("Ends in 3d")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                                .padding(.vertical, 12)
                            }
                            Divider().background(cardBgColor)
                        }
                    } else {
                        // Top 20 Carousel
                        Text("🔥 Top Contests This Week")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(textColor)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(topContests.enumerated()), id: \.element.0) { idx, item in
                                    Button(action: { onSelectContest(item.0) }) {
                                        VStack(spacing: 8) {
                                            ZStack(alignment: .bottomTrailing) {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 64, height: 64)

                                                Text("\(idx + 1)")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.black)
                                                    .frame(width: 20, height: 20)
                                                    .background(goldYellow)
                                                    .clipShape(Circle())
                                            }

                                            Text(item.0)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(textColor)
                                                .lineLimit(1)

                                            Text(item.1)
                                                .font(.system(size: 11))
                                                .foregroundColor(secondaryTextColor)
                                        }
                                        .padding(12)
                                        .frame(width: 130)
                                        .background(cardBgColor)
                                        .cornerRadius(16)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Filter Chips Row
                        HStack(spacing: 8) {
                            ForEach(["Trending", "Ending Soon", "New"], id: \.self) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(selectedFilter == filter ? .white : secondaryTextColor)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? accentBlue : cardBgColor)
                                        .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)

                        // Active Contests Vertical List
                        Text("Active Contests")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(textColor)

                        VStack(spacing: 12) {
                            ForEach(1...10, id: \.self) { index in
                                let hashtag = index == 1 ? "#MissThembisa" : "#MissSection\(index)"
                                Button(action: { onSelectContest(hashtag) }) {
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 50, height: 50)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(hashtag)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(textColor)
                                            Text("20 Contestants • Ends in 3d 14h")
                                                .font(.system(size: 12))
                                                .foregroundColor(secondaryTextColor)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(cardBgColor)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(bgColor.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
