import Foundation
import Combine

public protocol JobRepository {
    func getJobs(cursor: String?, limit: Int, jobType: String?, featuredOnly: Bool, location: String?, salaryMin: Double?, postedWithinDays: Int?, category: String?) -> AsyncStream<Resource<[Job]>>
    func searchJobs(query: String, location: String?, salaryMin: Double?, jobType: String?, featuredOnly: Bool, postedWithinDays: Int?, category: String?) -> AsyncStream<Resource<[Job]>>
    func applyForJob(jobId: String) -> AsyncStream<Resource<String>>
    func saveJob(jobId: String) async -> Resource<Bool>
    func unsaveJob(jobId: String) async -> Resource<Bool>
    func getJobApplications() -> AsyncStream<Resource<[JobApplication]>>
    func withdrawApplication(applicationId: String) async -> Resource<Bool>
    func getJobProfile() async -> Resource<JobProfileData>
    func updateJobProfile(profile: JobProfileData) async -> Resource<Bool>
    func createJob(title: String, description: String, category: String, skills: [String], durationDays: Int, company: String?, locationCity: String?, jobType: String?, packageType: String, salaryMin: Double?, salaryMax: Double?, requirements: String?) async -> Resource<Job>
    func reportJob(jobId: String, reason: String, details: String) async -> Resource<Bool>
    func anonymizeJobData() async -> Resource<Bool>
    func listMyJobs() async -> Resource<[Job]>
    func closeJob(jobId: String) async -> Resource<Bool>
    func renewJob(jobId: String, packageType: String) async -> Resource<String?>
    func markClickedExternalLocally(jobId: String) async
}

public extension JobRepository {
    func getJobs(cursor: String?, limit: Int, jobType: String? = nil, featuredOnly: Bool = false) -> AsyncStream<Resource<[Job]>> {
        getJobs(cursor: cursor, limit: limit, jobType: jobType, featuredOnly: featuredOnly, location: nil, salaryMin: nil, postedWithinDays: nil, category: nil)
    }
}

public final class JobRepositoryImpl: JobRepository, @unchecked Sendable {
    public static let shared = JobRepositoryImpl()
    private let jobApi: JobApiProtocol
    private let localStore: JobLocalStore

    public init(jobApi: JobApiProtocol? = nil, localStore: JobLocalStore? = nil) {
        self.jobApi = jobApi ?? JobApi.shared
        self.localStore = localStore ?? JobLocalStore()
    }

    public func getJobs(cursor: String? = nil, limit: Int = 50, jobType: String? = nil, featuredOnly: Bool = false, location: String? = nil, salaryMin: Double? = nil, postedWithinDays: Int? = nil, category: String? = nil) -> AsyncStream<Resource<[Job]>> {
        AsyncStream { continuation in
            Task {
                continuation.yield(.loading(nil))
                let filtering = !(jobType ?? "").isEmpty || featuredOnly || !(location ?? "").isEmpty || salaryMin != nil || (postedWithinDays ?? 0) > 0
                do {
                    let response = try await jobApi.getJobs(page: 1, cursor: cursor, limit: limit, jobType: jobType, featuredOnly: featuredOnly, location: location, salaryMin: salaryMin, postedWithinDays: postedWithinDays, category: category)
                    let models = response.jobs.map { $0.toModel() }
                    if !filtering {
                        await localStore.insertJobs(models.map { $0.toEntity() })
                    }
                    continuation.yield(.success(models))
                } catch {
                    let cached = filtering ? [] : await localStore.getJobsList()
                    continuation.yield(.error("Network error: \(error.localizedDescription)", cached.map { $0.toModel() }))
                }
                continuation.finish()
            }
        }
    }

    public func searchJobs(query: String, location: String? = nil, salaryMin: Double? = nil, jobType: String? = nil, featuredOnly: Bool = false, postedWithinDays: Int? = nil, category: String? = nil) -> AsyncStream<Resource<[Job]>> {
        AsyncStream { continuation in
            Task {
                continuation.yield(.loading(nil))
                do {
                    let response = try await jobApi.search(query: query, location: location, salaryMin: salaryMin, jobType: jobType, featuredOnly: featuredOnly, postedWithinDays: postedWithinDays, category: category)
                    let models = response.jobs.map { $0.toModel() }
                    continuation.yield(.success(models))
                } catch {
                    let cached = await localStore.searchJobs(query: query)
                    continuation.yield(.error("Search failed: \(error.localizedDescription)", cached.map { $0.toModel() }))
                }
                continuation.finish()
            }
        }
    }

    public func applyForJob(jobId: String) -> AsyncStream<Resource<String>> {
        AsyncStream { continuation in
            Task {
                continuation.yield(.loading(nil))
                do {
                    let response = try await jobApi.applyForJob(jobId: jobId)
                    await localStore.updateAppliedStatus(jobId: jobId, isApplied: true)
                    continuation.yield(.success(response.conversationId))
                } catch {
                    continuation.yield(.error("Application failed: \(error.localizedDescription)", nil))
                }
                continuation.finish()
            }
        }
    }

    public func markClickedExternalLocally(jobId: String) async {
        await localStore.markClickedExternalLocally(jobId: jobId)
    }

    public func saveJob(jobId: String) async -> Resource<Bool> {
        do {
            _ = try await jobApi.saveJob(jobId: jobId)
            await localStore.updateSavedStatus(jobId: jobId, isSaved: true)
            return .success(true)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func unsaveJob(jobId: String) async -> Resource<Bool> {
        do {
            _ = try await jobApi.unsaveJob(jobId: jobId)
            await localStore.updateSavedStatus(jobId: jobId, isSaved: false)
            return .success(true)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func getJobApplications() -> AsyncStream<Resource<[JobApplication]>> {
        AsyncStream { continuation in
            Task {
                continuation.yield(.loading(nil))
                do {
                    let response = try await jobApi.getJobApplications()
                    let models = response.applications.map { $0.toModel() }
                    await localStore.insertApplications(models.map { $0.toEntity() })
                    continuation.yield(.success(models))
                } catch {
                    let cached = await localStore.getApplicationsList()
                    continuation.yield(.error("Failed to load applications: \(error.localizedDescription)", cached.map { $0.toModel() }))
                }
                continuation.finish()
            }
        }
    }

    public func withdrawApplication(applicationId: String) async -> Resource<Bool> {
        do {
            _ = try await jobApi.withdrawApplication(applicationId: applicationId)
            await localStore.deleteApplication(applicationId: applicationId)
            return .success(true)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func getJobProfile() async -> Resource<JobProfileData> {
        do {
            let profile = try await jobApi.getJobProfile()
            return .success(profile)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func updateJobProfile(profile: JobProfileData) async -> Resource<Bool> {
        do {
            _ = try await jobApi.updateJobProfile(profile: profile)
            return .success(true)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func createJob(title: String, description: String, category: String, skills: [String], durationDays: Int, company: String? = nil, locationCity: String? = nil, jobType: String? = nil, packageType: String = "basic", salaryMin: Double? = nil, salaryMax: Double? = nil, requirements: String? = nil) async -> Resource<Job> {
        do {
            let req = CreateJobRequest(
                title: title,
                description: description,
                job_category: category,
                required_skills: skills,
                duration_days: durationDays,
                company: company,
                location_city: locationCity,
                job_type: jobType,
                package_type: packageType,
                salary_min: salaryMin,
                salary_max: salaryMax,
                requirements: requirements
            )
            let apiJob = try await jobApi.createJob(request: req)
            let model = apiJob.toModel()
            await localStore.insertJobs([model.toEntity()])
            return .success(model)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func reportJob(jobId: String, reason: String, details: String = "") async -> Resource<Bool> {
        do {
            _ = try await jobApi.reportJob(jobId: jobId, reason: reason, details: details)
            return .success(true)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func anonymizeJobData() async -> Resource<Bool> {
        do {
            _ = try await jobApi.anonymizeJobData()
            return .success(true)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func listMyJobs() async -> Resource<[Job]> {
        do {
            let response = try await jobApi.getMyJobs()
            return .success(response.jobs.map { $0.toModel() })
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func closeJob(jobId: String) async -> Resource<Bool> {
        do {
            _ = try await jobApi.closeJob(jobId: jobId)
            return .success(true)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }

    public func renewJob(jobId: String, packageType: String) async -> Resource<String?> {
        do {
            let payment = try await jobApi.renewJob(jobId: jobId, packageType: packageType)
            return .success(payment.authorization_url)
        } catch {
            return .error(error.localizedDescription, nil)
        }
    }
}
