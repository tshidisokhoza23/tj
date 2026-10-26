import SwiftUI

public struct ContestDiscoveryView: View {
    @StateObject private var contestManager = ContestManager.shared
    @State private var searchQuery = ""
    @State private var activeFeedHashtag: String? = nil
    @State private var showCreateContest = false
    @Environment(\.dismiss) private var dismiss

    public init() {}

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search contests and hashtags...", text: $searchQuery)
                        .textFieldStyle(.plain)
                        .onChange(of: searchQuery) { query in
                            Task { await contestManager.fetchContests(query: query) }
                        }
                }
                .padding(10)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if contestManager.isLoading && contestManager.contests.isEmpty {
                    Spacer()
                    ProgressView("Loading active contests...")
                    Spacer()
                } else if contestManager.contests.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "trophy")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("No contests found")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Spacer()
                } else {
                    List(contestManager.contests) { contest in
                        Button(action: {
                            activeFeedHashtag = contest.hashtag
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(.orange)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(contest.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("#\(contest.hashtag.replacingOccurrences(of: "#", with: ""))")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.accentColor)
                                    Text("\(contest.voteCount) votes • \(contest.entryCount) contestants")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Contests & Hashtags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("+ Host Contest") {
                        showCreateContest = true
                    }
                    .font(.system(size: 14, weight: .bold))
                }
            }
            .task {
                await contestManager.fetchContests()
            }
            .sheet(item: $activeFeedHashtag) { tag in
                ContestFeedView(hashtag: tag)
            }
            .sheet(isPresented: $showCreateContest) {
                CreateContestView()
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct CreateContestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var hashtag = ""
    @State private var limit = "20"
    @State private var createdContest: ApiContestItem? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("CONTEST DETAILS") {
                    TextField("Contest Title (e.g. Miss Thembisa 2026)", text: $title)
                    TextField("Description", text: $description)
                    TextField("Custom Hashtag (e.g. #MissThembisa)", text: $hashtag)
                    TextField("Participant Limit", text: $limit)
                        .keyboardType(.numberPad)
                }

                if let created = createdContest, let codes = created.codes, !codes.isEmpty {
                    Section("MANAGER ACCESS CODES") {
                        Text("Share these Manager Access Codes with contestant managers. Each code grants 1 verified entry into the contest:")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        ForEach(codes, id: \.self) { code in
                            HStack {
                                Text(code)
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                                Button("Copy") {
                                    UIPasteboard.general.string = code
                                }
                                .font(.system(size: 13, weight: .semibold))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Contest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            let contestLimit = Int(limit) ?? 20
                            let created = await ContestManager.shared.createContest(
                                title: title,
                                description: description,
                                hashtag: hashtag,
                                limit: contestLimit
                            )
                            if let created {
                                self.createdContest = created
                            }
                        }
                    }
                    .disabled(title.isEmpty || hashtag.isEmpty)
                }
            }
        }
    }
}
