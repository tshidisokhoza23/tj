import SwiftUI

public struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: Int = 3 // Default to Portfolio for Artist
    @State private var showingHeaderMenu: Bool = false
    @State private var selectedPortfolioFilter: String = "All"

    public init() {}

    private let portfolioItems = [
        ("Cyberpunk Neon Character", "1.2K Views • 45 Tips", "Series: Neo-Tokyo"),
        ("Ethereal Landscape", "850 Views • 22 Tips", "Series: Mythos"),
        ("Mecha Unit 04 Concept", "2.1K Views • 89 Tips", "Series: Mecha Warfare"),
        ("Portrait Study #12", "600 Views • 15 Tips", "Series: Daily Sketches")
    ]

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Profile Header Row
                    HStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .stroke(AppColors.primaryGradient, lineWidth: 3)
                                .frame(width: 84, height: 84)

                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 76, height: 76)
                                .foregroundColor(AppColors.greyMedium)

                            // Artist Badge
                            Text("Artist")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.primaryGradient)
                                .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tshidiso Khoza")
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            Text("@tshidisokhoza23")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // Stats Row
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Text("\(viewModel.followersCount)").fontWeight(.bold).foregroundColor(.white)
                                    Text("Followers").foregroundColor(.gray)
                                }
                                Text("•").foregroundColor(.gray)
                                HStack(spacing: 4) {
                                    Text("340").fontWeight(.bold).foregroundColor(.white)
                                    Text("Following").foregroundColor(.gray)
                                }
                                Text("•").foregroundColor(.gray)
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill").foregroundColor(AppColors.tealAccent)
                                    Text("Reputation 82").fontWeight(.bold).foregroundColor(AppColors.tealAccent)
                                }
                            }
                            .font(.caption)
                            .padding(.top, 2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Commission Status Pill
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppColors.openGreen)
                                .frame(width: 8, height: 8)
                            Text("Open for Commissions")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.openGreen)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.openGreen.opacity(0.15))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.openGreen, lineWidth: 1))

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Text("Edit profile")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppColors.primaryGradient)
                                .clipShape(Capsule())
                        }

                        Button(action: {}) {
                            Text("Share profile")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(Capsule().stroke(AppColors.borderDark, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)

                    // Quick Action Pills
                    HStack(spacing: 8) {
                        ForEach(["Circles", "Analytics", "Monetize"], id: \.self) { act in
                            Button(action: {}) {
                                Text(act)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Mediums & Styles Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(["Digital Character Design", "Concept Art", "Illustration"], id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.tealAccent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.borderDark, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Segmented Tabs
                    Picker("Profile Segment", selection: $selectedTab) {
                        Text("Posts").tag(0)
                        Text("Replies").tag(1)
                        Text("Media").tag(2)
                        Text("Portfolio").tag(3)
                        Text("Shorts").tag(4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Tab Contents
                    if selectedTab == 3 {
                        // Portfolio Tab Grid
                        VStack(alignment: .leading, spacing: 12) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(["All", "Available", "Sold", "Process"], id: \.self) { filter in
                                        let isSel = selectedPortfolioFilter == filter
                                        Button(action: { selectedPortfolioFilter = filter }) {
                                            Text(filter)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(isSel ? AppColors.tealAccent : .white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(isSel ? AppColors.tealAccent.opacity(0.2) : AppColors.cardDark)
                                                .cornerRadius(16)
                                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSel ? AppColors.tealAccent : AppColors.borderDark, lineWidth: 1))
                                        }
                                    }
                                }
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(portfolioItems, id: \.0) { item in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Rectangle()
                                            .fill(AppColors.primaryGradient)
                                            .frame(height: 120)
                                            .cornerRadius(12)

                                        Text(item.0)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .lineLimit(1)

                                        Text(item.2)
                                            .font(.caption2)
                                            .foregroundColor(AppColors.tealAccent)

                                        Text(item.1)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(8)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.borderDark, lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else if selectedTab == 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Latest artwork preview in progress! Stay tuned. ✨")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .background(AppColors.cardDark)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No items to display.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding(.top)
            }
            .background(AppColors.darkCharcoal.ignoresSafeArea())
            .navigationTitle("Artist Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingHeaderMenu = true }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(AppColors.tealAccent)
                    }
                }
            }
            .confirmationDialog("Profile Options", isPresented: $showingHeaderMenu, titleVisibility: .visible) {
                Button("Share Profile") { }
                Button("Copy Link") { }
            }
        }
    }
}
