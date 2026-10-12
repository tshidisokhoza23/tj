import Foundation
import Combine

@MainActor
public class JobViewModel: ObservableObject {
    @Published public var jobs: Resource<[Job]> = .loading(nil)
    @Published public var feedChip: String = "All"
    @Published public var location: String = ""
    @Published public var salaryMin: String = ""
    @Published public var postedWithinDays: Int = 0
    @Published public var myJobs: [Job] = []
    @Published public var jobProfile: JobProfileData? = nil
    @Published public var applications: [JobApplication] = []
    @Published public var createJobResult: Resource<Job>? = nil

    private let repository: JobRepository

    public init(repository: JobRepository? = nil) {
        self.repository = repository ?? JobRepositoryImpl()
        fetchJobs()
        fetchJobApplications()
        Task {
            if case .success(let profile) = await self.repository.getJobProfile() {
                self.jobProfile = profile
            }
        }
    }

    public func selectFeedChip(_ chip: String) {
        feedChip = chip
        fetchJobs()
    }

    public func setLocation(_ value: String) {
        location = value
        fetchJobs()
    }

    public func setSalaryMin(_ value: String) {
        salaryMin = value
        fetchJobs()
    }

    public func setPostedWithinDays(_ days: Int) {
        postedWithinDays = days
        fetchJobs()
    }

    public func fetchJobs() {
        let category = feedChip == "All" ? nil : feedChip
        let salary = Double(salaryMin)
        Task {
            for await result in repository.getJobs(cursor: nil, limit: 50, jobType: nil, featuredOnly: false, location: location.isEmpty ? nil : location, salaryMin: salary, postedWithinDays: postedWithinDays > 0 ? postedWithinDays : nil, category: category) {
                self.jobs = result
            }
        }
    }

    public func search(_ query: String) {
        let category = feedChip == "All" ? nil : feedChip
        Task {
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                fetchJobs()
                return
            }
            for await result in repository.searchJobs(query: query, category: category) {
                self.jobs = result
            }
        }
    }

    public func reportJob(jobId: String, reason: String) {
        Task { _ = await repository.reportJob(jobId: jobId, reason: reason, details: "") }
    }

    public func fetchMyJobs() {
        Task {
            if case .success(let jobs) = await repository.listMyJobs() {
                self.myJobs = jobs
            }
        }
    }

    public func closeJob(jobId: String) {
        Task {
            if case .success = await repository.closeJob(jobId: jobId) {
                fetchMyJobs()
            }
        }
    }

    public func renewJob(jobId: String, packageType: String = "basic") async -> String? {
        if case .success(let url) = await repository.renewJob(jobId: jobId, packageType: packageType) {
            return url
        }
        return nil
    }

    public func anonymizeJobData() async -> Bool {
        if case .success = await repository.anonymizeJobData() { return true }
        return false
    }

    public func fetchJobApplications() {
        Task {
            for await result in repository.getJobApplications() {
                self.applications = result.data ?? []
            }
        }
    }

    public func applyForJob(jobId: String) {
        Task {
            for await result in repository.applyForJob(jobId: jobId) {
                if case .success = result {
                    fetchJobs()
                    fetchJobApplications()
                }
            }
        }
    }

    public func updateJobProfile(_ profile: JobProfileData) {
        Task {
            let result = await repository.updateJobProfile(profile: profile)
            if case .success = result {
                self.jobProfile = profile
            }
        }
    }

    public func withdrawApplication(applicationId: String) {
        Task {
            let result = await repository.withdrawApplication(applicationId: applicationId)
            if case .success = result {
                applications.removeAll { $0.id == applicationId }
            }
        }
    }

    public func createJob(title: String, description: String, category: String, skills: [String], durationDays: Int, company: String? = nil, locationCity: String? = nil, jobType: String? = nil, packageType: String = "basic", salaryMin: Double? = nil, salaryMax: Double? = nil, requirements: String? = nil) {
        Task {
            let result = await repository.createJob(title: title, description: description, category: category, skills: skills, durationDays: durationDays, company: company, locationCity: locationCity, jobType: jobType, packageType: packageType, salaryMin: salaryMin, salaryMax: salaryMax, requirements: requirements)
            self.createJobResult = result
        }
    }
}
