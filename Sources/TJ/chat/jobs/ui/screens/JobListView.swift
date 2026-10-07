import SwiftUI

public struct JobsHomeView: View {
    @StateObject private var viewModel = JobViewModel()
    @State private var selected: Job?
    @State private var showPostJob = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                JobListView(jobs: viewModel.jobs.data ?? []) { selected = $0 }
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
                onApply: { viewModel.applyForJob(jobId: job.id) }
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
    public var onJobClick: (Job) -> Void

    public init(jobs: [Job], topBarHeight: CGFloat = 0, onJobClick: @escaping (Job) -> Void) {
        self.jobs = jobs
        self.topBarHeight = topBarHeight
        self.onJobClick = onJobClick
    }

    public var body: some View {
        if jobs.isEmpty {
            VStack(spacing: 8) {
                Text("No jobs yet")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Open roles show up here. Use the button to post one.")
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
                        ForEach(jobs) { job in
                            JobItemView(job: job, onClick: {
                                onJobClick(job)
                            })
                            Divider()
                        }
                    }
                }
                .padding(.bottom, 160)
            }
        }
    }
}
