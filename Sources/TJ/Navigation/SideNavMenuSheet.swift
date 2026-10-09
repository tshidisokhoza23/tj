import SwiftUI

public struct SideNavMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    var onProfileClick: () -> Void = {}
    var onCreatePostClick: () -> Void = {}
    var onNotificationsClick: () -> Void = {}
    var onCirclesClick: () -> Void = {}
    var onCreatorDashboardClick: () -> Void = {}

    @State private var showCirclesSheet: Bool = false
    @State private var showCreatorDashboardSheet: Bool = false

    public init(
        onProfileClick: @escaping () -> Void = {},
        onCreatePostClick: @escaping () -> Void = {},
        onNotificationsClick: @escaping () -> Void = {},
        onCirclesClick: @escaping () -> Void = {},
        onCreatorDashboardClick: @escaping () -> Void = {}
    ) {
        self.onProfileClick = onProfileClick
        self.onCreatePostClick = onCreatePostClick
        self.onNotificationsClick = onNotificationsClick
        self.onCirclesClick = onCirclesClick
        self.onCreatorDashboardClick = onCreatorDashboardClick
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                menuButton(icon: "person", title: "View Profile") {
                    dismiss()
                    onProfileClick()
                }

                menuButton(icon: "plus.app", title: "Create Post") {
                    dismiss()
                    onCreatePostClick()
                }

                menuButton(icon: "bell", title: "Notifications") {
                    dismiss()
                    onNotificationsClick()
                }

                menuButton(icon: "bubble.left.and.bubble.right", title: "Direct Messages") {
                    dismiss()
                }
            }

            Divider().background(AppColors.borderDark).padding(.vertical, 8)

            Group {
                menuButton(icon: "person.3", title: "Circles", accent: true) {
                    showCirclesSheet = true
                }

                menuButton(icon: "square.grid.2x2", title: "Creator Dashboard", accent: true) {
                    showCreatorDashboardSheet = true
                }

                menuButton(icon: "chart.bar", title: "Analytics") {
                    dismiss()
                }
            }

            Divider().background(AppColors.borderDark).padding(.vertical, 8)

            Group {
                menuButton(icon: "bookmark", title: "Saved Posts") {
                    dismiss()
                }

                menuButton(icon: "gearshape", title: "Settings") {
                    dismiss()
                }
            }

            Spacer()
        }
        .padding()
        .background(AppColors.darkCharcoal.ignoresSafeArea())
        .sheet(isPresented: $showCirclesSheet) {
            CirclesView()
        }
        .sheet(isPresented: $showCreatorDashboardSheet) {
            CreatorDashboardView()
        }
    }

    private func menuButton(icon: String, title: String, accent: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(accent ? AppColors.tealAccent : .white)
                Text(title)
                    .font(.headline)
                    .fontWeight(accent ? .bold : .semibold)
                    .foregroundColor(accent ? AppColors.tealAccent : .white)
                Spacer()
            }
            .padding(.vertical, 12)
        }
    }
}
