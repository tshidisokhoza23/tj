import SwiftUI

public struct ContestDiscoveryView: View {
    public var onNavigateBack: () -> Void
    public var onSelectContest: (String) -> Void
    public var onCreateContestClick: () -> Void

    @State private var searchQuery: String = ""
    @State private var selectedFilter: String = "Trending"

    private let darkBg = Color(hex: "121417")
    private let darkSurface = Color(hex: "1E2228")
    private let accentBlue = Color(hex: "2563EB")
    private let goldYellow = Color(hex: "F59E0B")

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
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Contests & Pageants")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: onCreateContestClick) {
                    Text("+ Host")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(accentBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(darkBg)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search 10k+ contests (e.g., #MissThembisa)", text: $searchQuery)
                            .foregroundColor(.white)
                        if !searchQuery.isEmpty {
                            Button(action: { searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(darkSurface)
                    .cornerRadius(24)

                    if !searchQuery.isEmpty {
                        // Search Autocomplete Results
                        Text("Search Results")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
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
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("Ends in 3d")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 12)
                            }
                            Divider().background(darkSurface)
                        }
                    } else {
                        // Top 20 Carousel
                        Text("🔥 Top Pageants This Week")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { idx in
                                    Button(action: { onSelectContest("#MissThembisa") }) {
                                        VStack(spacing: 8) {
                                            ZStack(alignment: .bottomTrailing) {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 64, height: 64)

                                                Text("\(idx)")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.black)
                                                    .frame(width: 20, height: 20)
                                                    .background(goldYellow)
                                                    .clipShape(Circle())
                                            }

                                            Text("#MissThembisa")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                                .lineLimit(1)

                                            Text("4.2k voters")
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(12)
                                        .frame(width: 130)
                                        .background(darkSurface)
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
                                        .foregroundColor(selectedFilter == filter ? .white : .gray)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? accentBlue : darkSurface)
                                        .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)

                        // Active Contests Vertical List
                        Text("Active Contests")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

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
                                                .foregroundColor(.white)
                                            Text("20 Contestants • Ends in 3d 14h")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(darkSurface)
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
        .background(darkBg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
