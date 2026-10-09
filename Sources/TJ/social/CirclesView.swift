import SwiftUI

public struct CircleItemModel: Identifiable {
    public let id: String
    public let name: String
    public let memberCount: Int
    public let isTemporary: BooleanLiteralType

    public init(id: String, name: String, memberCount: Int, isTemporary: Bool = false) {
        self.id = id
        self.name = name
        self.memberCount = memberCount
        self.isTemporary = isTemporary
    }
}

public struct CirclesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var circles: [CircleItemModel] = []
    @State private var status: String = "Loading circles..."
    @State private var showCreateDialog: Bool = false
    @State private var newCircleName: String = ""

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.tealAccent)
                    TextField("Search circles...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(AppColors.cardDark)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                .padding(.horizontal)

                if !status.isEmpty {
                    Text(status)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                Text("YOUR CIRCLES")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.tealAccent)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(circles) { circle in
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(AppColors.purpleAccent.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Image(systemName: "person.3.fill")
                                            .foregroundColor(AppColors.tealAccent)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(circle.name)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)

                                        if circle.isTemporary {
                                            Text("Temporary")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(AppColors.waitlistOrange)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AppColors.waitlistOrange.opacity(0.2))
                                                .cornerRadius(6)
                                        }
                                    }

                                    Text("\(circle.memberCount) members")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button(action: {}) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(AppColors.cardDark)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Create New Circle Floating Button
                Button(action: { showCreateDialog = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Create New Circle")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryGradient)
                    .clipShape(Capsule())
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(AppColors.darkCharcoal.ignoresSafeArea())
            .navigationTitle("Circles")
            .task { await loadCircles() }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert("New Circle", isPresented: $showCreateDialog) {
                TextField("Circle Name", text: $newCircleName)
                Button("Create") {
                    let name = newCircleName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { return }
                    newCircleName = ""
                    Task { await createCircle(name) }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    private func loadCircles() async {
        do {
            let data = try await API.data("circles")
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let rows = json?["circles"] as? [[String: Any]] ?? []
            circles = rows.map { row in
                CircleItemModel(
                    id: row["id"] as? String ?? UUID().uuidString,
                    name: row["name"] as? String ?? "Circle",
                    memberCount: row["member_count"] as? Int ?? 0,
                    isTemporary: row["is_temporary"] as? Bool ?? false
                )
            }
            status = circles.isEmpty ? "No circles yet. Create one to share with a real group." : ""
        } catch {
            circles = []
            status = error.localizedDescription
        }
    }

    private func createCircle(_ name: String) async {
        do {
            _ = try await API.data("circles", method: "POST", json: ["name": name, "is_temporary": false])
            await loadCircles()
        } catch {
            status = error.localizedDescription
        }
    }
}
