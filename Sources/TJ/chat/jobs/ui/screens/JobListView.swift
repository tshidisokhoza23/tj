import SwiftUI

private let jobCategories = [
    "All", "General", "IT", "Finance", "Sales", "Healthcare", "Education",
    "Engineering", "Marketing", "Hospitality", "Logistics", "Admin", "Legal", "Construction"
]

public struct JobsHomeView: View {
    @StateObject private var viewModel = JobViewModel()
    @State private var selected: Job?
    @State private var showPostJob = false
    @State private var showMenu = false
    @State private var showApplications = false
    @State private var showProfile = false
    @State private var searching = false
    @State private var query = ""
    @Environment(\.openURL) private var openURL

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    if searching {
                        HStack {
                            TextField("Search jobs", text: $query)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: query) { value in viewModel.search(value) }
                            Button("Cancel") {
                                searching = false
                                query = ""
                                viewModel.fetchJobs()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    } else {
                        HStack {
                            Button(action: { showMenu = true }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            AppLogo(size: 36)
                            Spacer()
                            Button(action: { searching = true }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(jobCategories, id: \.self) { chip in
                                let selectedChip = viewModel.feedChip == chip
                                Button(chip) { viewModel.selectFeedChip(chip) }
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 4)
                                    .frame(height: 32)
                                    .foregroundColor(selectedChip ? .white : AppColors.brandPrimary)
                                    .background {
                                        if selectedChip { AppColors.primaryGradient } else { AppColors.cardDark }
                                    }
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedChip ? Color.clear : AppColors.borderDark, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                    }

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

                    JobListView(
                        jobs: viewModel.jobs.data ?? [],
                        emptyMessage: viewModel.feedChip == "All" ? "Open roles show up here. Post one from the menu or + button." : "Try another category or check back later."
                    ) { selected = $0 }
                }

                // Floating Action Button (FAB) for Post Job
                Button(action: { showPostJob = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(AppColors.primaryGradient)
                        .clipShape(Circle())
                        .shadow(radius: 6)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .toolbar(.hidden, for: .navigationBar)
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
        .sheet(isPresented: $showApplications) {
            JobApplicationsView(
                onBack: { showApplications = false },
                onViewJobDetails: { _ in showApplications = false },
                onContactRecruiter: { _ in },
                onSetReminder: { _ in }
            )
        }
        .sheet(isPresented: $showProfile) {
            JobProfileView(onClose: { showProfile = false })
        }
        .confirmationDialog("Jobs", isPresented: $showMenu, titleVisibility: .visible) {
            Button("Post a job") { showPostJob = true }
            Button("My applications") { showApplications = true }
            Button("Job profile") { showProfile = true }
            Button("My listings") { viewModel.fetchMyJobs() }
            Button("Anonymize applications") { Task { _ = await viewModel.anonymizeJobData() } }
            Button("Cancel", role: .cancel) {}
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
