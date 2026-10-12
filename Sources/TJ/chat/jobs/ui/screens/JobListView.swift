import SwiftUI

public struct JobsHomeView: View {
    @StateObject private var viewModel = JobViewModel()
    @State private var selected: Job?
    @State private var showPostJob = false
    @Environment(\.openURL) private var openURL

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        HStack {
                            TextField("Location", text: Binding(get: { viewModel.location }, set: { viewModel.setLocation($0) }))
                                .textFieldStyle(.roundedBorder)
                            TextField("Min salary", text: Binding(get: { viewModel.salaryMin }, set: { viewModel.setSalaryMin($0) }))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal, 16)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach([(0, "Any date"), (1, "24h"), (7, "7 days"), (30, "30 days")], id: \.0) { days, label in
                                    Button(label) { viewModel.setPostedWithinDays(days) }
                                        .font(.system(size: 13, weight: .semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(viewModel.postedWithinDays == days ? Color.appPrimary : Color.primary.opacity(0.08))
                                        .foregroundColor(viewModel.postedWithinDays == days ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["All", "Full-time", "Part-time", "Remote", "Featured"], id: \.self) { chip in
                                Button(chip) { viewModel.selectFeedChip(chip) }
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(viewModel.feedChip == chip ? Color.appPrimary : Color.primary.opacity(0.08))
                                    .foregroundColor(viewModel.feedChip == chip ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    HStack {
                        Button("My listings") { viewModel.fetchMyJobs() }
                        Button("Anonymize applications") { Task { _ = await viewModel.anonymizeJobData() } }
                    }
                    .font(.caption)
                    if !viewModel.myJobs.isEmpty {
                        ForEach(viewModel.myJobs.prefix(5)) { job in
                            HStack {
                                Text(job.title).lineLimit(1)
                                Spacer()
                                Button("Close") { viewModel.closeJob(jobId: job.id) }
                                Button("Renew") {
                                    Task {
                                        if let url = await viewModel.renewJob(jobId: job.id), let link = URL(string: url) {
                                            openURL(link)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    JobListView(jobs: viewModel.jobs.data ?? [], emptyMessage: viewModel.feedChip == "All" ? "Open roles show up here. Use the button to post one." : "Try another filter or check back later.") { selected = $0 }
                }
                Button(action: { showPostJob = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(24)
                }
            }
            .navigationTitle("Jobs")
        }
        .sheet(item: $selected) { job in
            JobDetailView(
                job: job,
                onBack: { selected = nil },
                onApply: { viewModel.applyForJob(jobId: job.id) },
                onReportJob: { id, reason in viewModel.reportJob(jobId: id, reason: reason) }
            )
        }
        .sheet(isPresented: $showPostJob) {
            PostJobView(onBack: { showPostJob = false })
        }
    }
}

public struct JobListView: View {
    public let jobs: [Job]
    public var topBarHeight: CGFloat = 0
    public var emptyMessage: String
    public var onJobClick: (Job) -> Void

    public init(jobs: [Job], topBarHeight: CGFloat = 0, emptyMessage: String = "Open roles show up here. Use the button to post one.", onJobClick: @escaping (Job) -> Void) {
        self.jobs = jobs
        self.topBarHeight = topBarHeight
        self.emptyMessage = emptyMessage
        self.onJobClick = onJobClick
    }

    public var body: some View {
        if jobs.isEmpty {
            VStack(spacing: 8) {
                Text("No jobs found")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: topBarHeight)
                    LazyVStack(spacing: 0) {
                        ForEach(Array(jobs.enumerated()), id: \.element.id) { index, job in
                            JobItemView(job: job, onClick: {
                                onJobClick(job)
                            })
                            if (index + 1) % 6 == 0 {
                                NativeAdRow(slot: "jobs-\(index)")
                            }
                            Divider()
                        }
                    }
                }
                .padding(.bottom, 160)
            }
        }
    }
}
