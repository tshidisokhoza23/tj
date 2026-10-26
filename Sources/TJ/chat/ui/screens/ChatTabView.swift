import SwiftUI
import PhotosUI

public struct ChatTabView: View {
    @StateObject public var viewModel: ChatViewModel
    @StateObject public var rewardViewModel: RewardViewModel
    @StateObject private var channelsViewModel = ChannelsViewModel()
    @StateObject private var jobViewModel = JobViewModel()
    @StateObject private var storyRepository = StoryRepository.shared

    public var onChatSelected: (ChatMessage) -> Void = { _ in }
    public var onNewChatClick: () -> Void = {}
    public var onArchivedClick: () -> Void = {}
    public var onProfileClick: () -> Void = {}

    @State private var selectedTab: Int = 0 // 0: Chats, 1: Channels, 2: Jobs, 3: Rewards
    @State private var searchQuery: String = ""
    @State private var isSearchActive: Bool = false
    @State private var showTopMenu: Bool = false
    @State private var showDirectMessages: Bool = false
    @State private var activeChannelDetail: Channel? = nil
    @State private var activeJobDetail: Job? = nil
    @State private var showCreateChannel: Bool = false
    @State private var channelQuery = ""
    @State private var channelSearch: [Channel] = []
    @State private var showPostJob: Bool = false
    @State private var showStarred: Bool = false
    @State private var showApplications: Bool = false
    @State private var showJobProfile: Bool = false
    @State private var showWallet: Bool = false
    @State private var showSettings: Bool = false
    @State private var showMingleActivity: Bool = false
    @State private var showGroup: Bool = false
    @State private var activeStory: UserStory? = nil
    @State private var storyStart: AndroidStoryFlow.Start?
    @State private var storyDraft: String = ""
    @State private var infoChat: ChatMessage?

    private let subTabs = ["Chats", "Channels", "Jobs", "Rewards"]

    @MainActor public init(
        viewModel: ChatViewModel? = nil,
        rewardViewModel: RewardViewModel? = nil,
        onChatSelected: @escaping (ChatMessage) -> Void = { _ in },
        onNewChatClick: @escaping () -> Void = {},
        onArchivedClick: @escaping () -> Void = {},
        onProfileClick: @escaping () -> Void = {}
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel ?? ChatViewModel())
        self._rewardViewModel = StateObject(wrappedValue: rewardViewModel ?? RewardViewModel())
        self.onChatSelected = onChatSelected
        self.onNewChatClick = onNewChatClick
        self.onArchivedClick = onArchivedClick
        self.onProfileClick = onProfileClick
    }

    private var regularChats: [ChatMessage] {
        (viewModel.uiState.chats.data ?? []).filter {
            !$0.isSecretMingleChat && $0.type != .channel && $0.type != .jobChat
        }
    }

    private var jobChats: [ChatMessage] {
        let rows = (viewModel.uiState.chats.data ?? []).filter { $0.type == .jobChat && !$0.isArchived }
        if searchQuery.isEmpty { return rows }
        return rows.filter {
            $0.consistentName().localizedCaseInsensitiveContains(searchQuery) ||
            $0.lastMessage.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    private var chatsList: [ChatMessage] {
        if searchQuery.isEmpty {
            return regularChats.filter { !$0.isArchived }
        } else {
            return regularChats.filter {
                !$0.isArchived &&
                ($0.consistentName().localizedCaseInsensitiveContains(searchQuery) ||
                 $0.lastMessage.localizedCaseInsensitiveContains(searchQuery))
            }
        }
    }

    private var registeredContactsNotInChats: [Contact] {
        let activeUserIds = Set(chatsList.compactMap { $0.otherUserId ?? $0.id })
        let allContacts = viewModel.contacts.data ?? []
        let currentUserId = UserDefaults.standard.string(forKey: "user_id") ?? ""
        return allContacts.filter { contact in
            contact.isRegistered &&
            contact.id != currentUserId &&
            !activeUserIds.contains(contact.id) &&
            !activeUserIds.contains("user_\(contact.id)") &&
            !activeUserIds.contains(contact.id.replacingOccurrences(of: "user_", with: ""))
        }
    }

    private var archivedCount: Int {
        regularChats.filter(\.isArchived).count
    }

    private var totalUnreadCount: Int {
        regularChats.reduce(0) { $0 + $1.unreadCount }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top App Bar
            HStack {
                if isSearchActive {
                    HStack(spacing: 12) {
                        Button(action: {
                            isSearchActive = false
                            searchQuery = ""
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                        }

                        TextField("Search chats, contacts, messages...", text: $searchQuery)
                            .textFieldStyle(PlainTextFieldStyle())

                        if !searchQuery.isEmpty {
                            Button(action: { searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Left Menu Button with Unread Badge
                    Button(action: { showTopMenu = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)

                            if totalUnreadCount > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }

                    Spacer()

                    // Center TJ Logo
                    AppLogo(size: 36)

                    Spacer()

                    // Right Search Button
                    Button(action: { isSearchActive = true }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // Horizontal Scrollable Sub-Tab Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<subTabs.count, id: \.self) { index in
                        let isSelected = selectedTab == index
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                                viewModel.setActiveSubTab(index)
                            }
                        }) {
                            Text(subTabs[index])
                                .font(.system(size: 13, weight: .black))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.appPrimary : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(isSelected ? .white : .primary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }

            Divider()

            // Sub Tab Content
            switch selectedTab {
            case 0:
                chatsTabContent
            case 1:
                channelsTabContent
            case 2:
                jobsTabContent
            case 3:
                rewardsTabContent
            default:
                chatsTabContent
            }
            LiveBannerAd()
        }
        .sheet(item: $infoChat) { chat in
            ConversationInfoView(chat: chat, onOpenUser: { _ in infoChat = nil }, onLeft: { infoChat = nil })
        }
        .onAppear {
            viewModel.fetchChats()
            channelsViewModel.fetchChannels()
            jobViewModel.fetchJobs()
            Task {
                _ = await ContactSyncManager.shared.syncAccountContacts()
            }
        }
        .sheet(isPresented: $showTopMenu) {
            TopMoreMenuSheetView(
                selectedTab: selectedTab,
                onContacts: { showTopMenu = false; onNewChatClick() },
                onNewGroup: { showTopMenu = false; showGroup = true },
                onStarred: { showTopMenu = false; showStarred = true },
                onArchived: { showTopMenu = false; onArchivedClick() },
                onMingle: { showTopMenu = false; showMingleActivity = true },
                onCreateChannel: { showTopMenu = false; showCreateChannel = true },
                onPostJob: { showTopMenu = false; showPostJob = true },
                onApplications: { showTopMenu = false; showApplications = true },
                onJobProfile: { showTopMenu = false; showJobProfile = true },
                onWallet: { showTopMenu = false; showWallet = true },
                onSettings: { showTopMenu = false; showSettings = true },
                onSignOut: {
                    showTopMenu = false
                    Task { await SessionActions.logout() }
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showStarred) { StarredMessagesView() }
        .sheet(isPresented: $showApplications) {
            JobApplicationsView(onBack: { showApplications = false }, onViewJobDetails: { _ in }, onContactRecruiter: { _ in }, onSetReminder: { _ in })
        }
        .sheet(isPresented: $showJobProfile) { JobProfileView(onClose: { showJobProfile = false }) }
        .sheet(isPresented: $showWallet) { WalletView() }
        .sheet(isPresented: $showSettings) { SettingsView(router: NavigationRouter()) }
        .sheet(isPresented: $showMingleActivity) {
            MingleActivitySheet { conversationId, name in
                showMingleActivity = false
                onChatSelected(ChatMessage(id: conversationId, type: .mingle, senderName: name, isMingle: true))
            }
        }
        .sheet(isPresented: $showGroup) {
            ContactPickerView(
                initialIsGroupMode: true,
                onBack: { showGroup = false },
                onGroupCreate: { name, contacts in
                    showGroup = false
                    viewModel.createGroup(name: name, contactIds: contacts.map(\.id)) { chat in
                        onChatSelected(chat)
                    }
                }
            )
        }
        .sheet(isPresented: $showDirectMessages) {
            DirectMessagesView(
                onConversationClick: { item in
                    showDirectMessages = false
                    onChatSelected(ChatMessage(id: item.id, senderName: item.contactName))
                },
                onNewChatClick: {
                    showDirectMessages = false
                    onNewChatClick()
                }
            )
        }
        .sheet(item: $activeChannelDetail) { ch in
            ChannelDetailView(
                channel: ch,
                onBack: { activeChannelDetail = nil },
                onSubscribe: { id in
                    channelsViewModel.subscribeToChannel(channelId: id)
                }
            )
        }
        .sheet(item: $activeJobDetail) { job in
            JobDetailView(
                job: job,
                onBack: { activeJobDetail = nil },
                onApply: {
                    jobViewModel.applyForJob(jobId: job.id)
                }
            )
        }
        .fullScreenCover(item: $activeStory) { story in
            StoryRowPlayer(startUserId: story.userId.isEmpty ? story.id : story.userId, onClose: { activeStory = nil })
        }
        .fullScreenCover(item: $storyStart) { start in
            AndroidStoryFlow(
                start: start,
                stories: storyRepository.userStories,
                currentUserId: SessionStore.shared.userId,
                onClose: { storyStart = nil },
                onPosted: {
                    storyStart = nil
                    Task { await storyRepository.syncStories() }
                }
            )
        }
        .task { await storyRepository.syncStories() }
    }

    // MARK: - Chats Tab Content

    private var chatsTabContent: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    // Horizontal Stories Header Row
                    StoriesHeaderRow(
                        stories: storyRepository.userStories,
                        currentUserId: SessionStore.shared.userId,
                        onStoryClick: { activeStory = $0 },
                        onImageStoryClick: { storyStart = .image },
                        onVideoStoryClick: { storyStart = .video },
                        onMediaStoryClick: { storyStart = .media },
                        onTextStoryClick: { storyStart = .text },
                        onPostedStoriesClick: { storyStart = .posted }
                    )
                    .padding(.vertical, 8)

                    Divider()

                    // Archived Header Item
                    if archivedCount > 0 {
                        Button(action: onArchivedClick) {
                            HStack {
                                Image(systemName: "archivebox.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.appPrimary)
                                Text("Archived")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(archivedCount)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.appPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        Divider()
                    }

                    if viewModel.uiState.isChatsFetching && chatsList.isEmpty && registeredContactsNotInChats.isEmpty {
                        ProgressView("Loading chats...")
                            .padding(.top, 40)
                    } else if chatsList.isEmpty && registeredContactsNotInChats.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No chats yet")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            Button("Start New Chat", action: onNewChatClick)
                                .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(chatsList) { chat in
                                ChatItemRow(
                                    chat: chat,
                                    onAvatarClick: {
                                        infoChat = chat
                                    }
                                )
                                .onTapGesture {
                                    onChatSelected(chat)
                                }

                                Divider()
                                    .padding(.leading, 72)
                            }

                            ForEach(registeredContactsNotInChats) { contact in
                                RegisteredContactRowView(
                                    contact: contact,
                                    onClick: {
                                        onChatSelected(ChatMessage(id: contact.id, type: .direct, senderName: contact.displayName, otherUserId: contact.id))
                                    }
                                )

                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                }
            }

            // Double Floating Action Buttons
            VStack(alignment: .trailing, spacing: 12) {
                Button(action: { showDirectMessages = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.appBottomNavPill)
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

                        Image(systemName: "phone.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.appPrimary)
                    }
                }

                Button(action: onNewChatClick) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.appPrimary)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.appPrimary.opacity(0.35), radius: 6, x: 0, y: 3)

                        Image(systemName: "person.crop.square.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 16)
        }
    }

    private func searchChannels() async {
        let q = channelQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { channelSearch = []; return }
        guard let data = try? await API.data("chats/channels/search", query: ["query": q]) else { return }
        channelSearch = ChannelJSON.list(from: data)
    }

    // MARK: - Channels Tab Content

    private var channelsTabContent: some View {
        ZStack(alignment: .bottomTrailing) {
            let channelList = channelQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? (channelsViewModel.channels.data ?? [])
                : channelSearch
            VStack(spacing: 0) {
                TextField("Search channels", text: $channelQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .onSubmit { Task { await searchChannels() } }
                    .onChange(of: channelQuery) { value in
                        let q = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        if q.isEmpty { channelSearch = [] } else { Task { await searchChannels() } }
                    }
                if channelList.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "megaphone")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text(channelsViewModel.channels.isLoading ? "Loading channels..." : (channelsViewModel.channels.message ?? (channelQuery.isEmpty ? "No channels available" : "No channels match that search")))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(channelList) { ch in
                        ChannelItemView(
                            channel: ch,
                            currentUserId: SessionStore.shared.userId,
                            onSelect: { activeChannelDetail = ch },
                            onSubscribe: { id in
                                channelsViewModel.subscribeToChannel(channelId: id)
                            }
                        )
                    }
                    .listStyle(.plain)
                }
            }

            Button(action: { showCreateChannel = true }) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showCreateChannel) {
            CreateChannelView(
                onBack: { showCreateChannel = false },
                onChannelCreated: { ch in
                    showCreateChannel = false
                    channelsViewModel.fetchChannels()
                    activeChannelDetail = ch
                }
            )
        }
    }

    // MARK: - Jobs Tab Content

    private var jobsTabContent: some View {
        JobsHomeView()
    }

    // MARK: - Rewards Tab Content

    private var rewardsTabContent: some View {
        RewardsView(viewModel: rewardViewModel)
    }
}

struct RegisteredContactRowView: View {
    let contact: Contact
    var onClick: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 48, height: 48)
                Text(String(contact.displayName.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Text(contact.bio?.isEmpty == false ? contact.bio! : (contact.username.isEmpty ? "Tap to message" : "@\(contact.username)"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture(perform: onClick)
    }
}
