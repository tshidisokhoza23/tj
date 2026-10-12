import SwiftUI

public struct PostJobView: View {
    public var onBack: () -> Void
    @StateObject private var viewModel: JobViewModel

    @State private var title: String = ""
    @State private var category: String = ""
    @State private var descriptionText: String = ""
    @State private var skills: String = ""
    @State private var location: String = ""
    @State private var packageType: String = "basic"
    @Environment(\.openURL) private var openURL

    @MainActor public init(onBack: @escaping () -> Void, viewModel: JobViewModel? = nil) {
        self.onBack = onBack
        self._viewModel = StateObject(wrappedValue: viewModel ?? JobViewModel())
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Job Details")
                        .font(.title3.bold())
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Job Title").font(.caption).foregroundColor(.secondary)
                        TextField("Job Title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category (e.g., Software, General Work)").font(.caption).foregroundColor(.secondary)
                        TextField("Category", text: $category)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description").font(.caption).foregroundColor(.secondary)
                        TextEditor(text: $descriptionText)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location").font(.caption).foregroundColor(.secondary)
                        TextField("City", text: $location)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Button("Basic R119") { packageType = "basic" }
                            .padding(8)
                            .background(packageType == "basic" ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(packageType == "basic" ? .white : .primary)
                            .cornerRadius(8)
                        Button("Featured R279") { packageType = "featured" }
                            .padding(8)
                            .background(packageType == "featured" ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(packageType == "featured" ? .white : .primary)
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Required Skills (comma separated)").font(.caption).foregroundColor(.secondary)
                        TextField("Kotlin, Swift, UI Design", text: $skills)
                            .textFieldStyle(.roundedBorder)
                    }

                    Spacer().frame(height: 16)

                    Button(action: {
                        let skillsList = skills.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        viewModel.createJob(title: title, description: descriptionText, category: category, skills: skillsList, durationDays: 30, locationCity: location, packageType: packageType)
                    }) {
                        Text(packageType == "featured" ? "Post featured job (R279)" : "Post job (R119)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Text("Listings run for 30 days. Payment opens after you post, unless you have a credit.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .navigationTitle("Post a Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .onChange(of: viewModel.createJobResult) { result in
                if case .success(let job)? = result {
                    if let raw = job.authorizationUrl, let url = URL(string: raw) {
                        openURL(url)
                    }
                    onBack()
                }
            }
        }
    }
}
