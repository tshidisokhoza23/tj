import SwiftUI

public struct AppNavigation: View {
    @EnvironmentObject var globalCallState: GlobalCallState
    @StateObject private var socialViewModel = SocialViewModel()
    @StateObject private var chatViewModel = ChatViewModel()

    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            ChatTabView()
                .environmentObject(chatViewModel)
                .tabItem {
                    Label("Chats", systemImage: "message.fill")
                }
                .tag(0)

            SocialView()
                .environmentObject(socialViewModel)
                .environmentObject(chatViewModel)
                .tabItem {
                    Label("Social", systemImage: "newspaper.fill")
                }
                .tag(1)

            ShortsView()
                .tabItem {
                    Label("Shorts", systemImage: "play.tv.fill")
                }
                .tag(2)

            DriveView()
                .tabItem {
                    Label("Drive", systemImage: "folder.fill")
                }
                .tag(3)

            MingleView()
                .tabItem {
                    Label("Mingle", systemImage: "heart.square.fill")
                }
                .tag(4)

            VocabView()
                .tabItem {
                    Label("Vocab", systemImage: "book.fill")
                }
                .tag(5)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(6)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(7)
        }
        .tint(AppColors.tealAccent)
    }
}
