import SwiftUI

public struct NearbyView: View {
    @StateObject private var nearbyManager = NearbyManager.shared
    @State private var selectedRadius: Int = 10
    @State private var selectedCategory: String = "All"
    @State private var showCreatePost = false
    @State private var activeDiscussionPost: NearbyPostItem? = nil
    @State private var chatRequestTargetPost: NearbyPostItem? = nil
    @State private var showMyPosts = false
    @State private var showChatRequests = false

    private let radiusOptions = [1, 5, 10, 25, 50]
    private let categories = ["All", "Discussions", "Events", "Alerts", "Marketplace"]

    public init() {}

    private var filteredPosts: [NearbyPostItem] {
        if selectedCategory == "All" {
            return nearbyManager.posts
        }
        return nearbyManager.posts.filter { post in
            post.content.localizedCaseInsensitiveContains(selectedCategory)
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Top Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                                Text("Nearby")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                                Text("\(nearbyManager.selectedAreaName) • Within \(selectedRadius) km")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Button(action: { showChatRequests = true }) {
                            Image(systemName: "tray.full.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.blue.opacity(0.12))
                                .clipShape(Circle())
                        }

                        Button(action: { showMyPosts = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                Text("My Posts")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(16)
                        }

                        Button(action: {
                            Task {
                                await nearbyManager.fetchNearbyPosts(radiusKm: selectedRadius, area: nearbyManager.selectedAreaName)
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .bold))
                                .padding(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    // Radius Selector Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Text("Radius:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)

                            ForEach(radiusOptions, id: \.self) { radius in
                                let isSelected = selectedRadius == radius
                                Button(action: {
                                    selectedRadius = radius
                                    Task {
                                        await nearbyManager.fetchNearbyPosts(radiusKm: radius, area: nearbyManager.selectedAreaName)
                                    }
                                }) {
                                    Text("\(radius) km")
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? Color.blue : Color(UIColor.tertiarySystemFill))
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }

                    // Category Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                let isSelected = selectedCategory == cat
                                Button(action: { selectedCategory = cat }) {
                                    Text(cat)
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? Color.primary : Color(UIColor.secondarySystemBackground))
                                        .foregroundColor(isSelected ? Color(UIColor.systemBackground) : .primary)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                    }

                    Divider()

                    // Main Posts List
                    if nearbyManager.isLoading && nearbyManager.posts.isEmpty {
                        Spacer()
                        ProgressView("Loading nearby posts...")
                        Spacer()
                    } else if filteredPosts.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "location.slash")
                                .font(.system(size: 44))
                                .foregroundColor(.secondary)
                            Text("No nearby posts within \(selectedRadius) km")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Be the first to post a neighborhood update or question around \(nearbyManager.selectedAreaName)!")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredPosts) { post in
                                NearbyPostCard(
                                    post: post,
                                    onLike: {
                                        Task { await nearbyManager.toggleLike(postId: post.id) }
                                    },
                                    onReply: {
                                        activeDiscussionPost = post
                                    },
                                    onRequestChat: {
                                        chatRequestTargetPost = post
                                    },
                                    onShare: {
                                        #if canImport(UIKit)
                                        let activity = UIActivityViewController(activityItems: [post.content], applicationActivities: nil)
                                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                            scene.windows.first?.rootViewController?.present(activity, animated: true)
                                        }
                                        #endif
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }

                // Floating Action Button: Post +
                Button(action: { showCreatePost = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                        Text("Post")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .task {
                await nearbyManager.fetchNearbyPosts(radiusKm: selectedRadius)
            }
            .sheet(isPresented: $showCreatePost) {
                CreateNearbyPostView(
                    areaName: nearbyManager.selectedAreaName,
                    onCreated: {
                        showCreatePost = false
                        Task { await nearbyManager.fetchNearbyPosts(radiusKm: selectedRadius) }
                    }
                )
            }
            .sheet(item: $activeDiscussionPost) { post in
                NearbyDiscussionThreadView(post: post)
            }
            .sheet(item: $chatRequestTargetPost) { post in
                PrivateChatRequestSheet(post: post) { msg in
                    Task {
                        _ = await nearbyManager.sendChatRequest(postId: post.id, message: msg)
                        chatRequestTargetPost = nil
                    }
                }
            }
            .sheet(isPresented: $showMyPosts) {
                MyNearbyPostsView()
            }
            .sheet(isPresented: $showChatRequests) {
                NearbyChatRequestsView()
            }
        }
    }
}

struct NearbyPostCard: View {
    let post: NearbyPostItem
    var onLike: () -> Void
    var onReply: () -> Void
    var onRequestChat: () -> Void
    var onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author Row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                    Text(String(post.authorName.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.system(size: 15, weight: .bold))
                    HStack(spacing: 4) {
                        Text(post.areaName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f km away", post.distanceKm))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                if post.isResolved {
                    Text("Resolved")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                }
            }

            // Post Content
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(.primary)

            // Attached Images Grid
            if !post.imageUrls.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.imageUrls, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 180, height: 180)
                                .cornerRadius(12)
                                .clipped()
                            }
                        }
                    }
                }
            }

            // Action Bar
            HStack(spacing: 16) {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .secondary)
                        Text("\(post.likeCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: onReply) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.secondary)
                        Text("\(post.replyCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: onRequestChat) {
                    HStack(spacing: 4) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                        Text("Request Chat")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }

                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct PrivateChatRequestSheet: View {
    let post: NearbyPostItem
    let onSend: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var message: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Message \(post.authorName) Privately")
                    .font(.title3.bold())

                Text("Regarding post: \"\(post.content)\"")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                TextEditor(text: $message)
                    .padding(8)
                    .background(Color(UIColor.tertiarySystemFill))
                    .cornerRadius(12)

                Spacer()
            }
            .padding(16)
            .navigationTitle("Request Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        onSend(message)
                        dismiss()
                    }
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct CreateNearbyPostView: View {
    let areaName: String
    var onCreated: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var category: String = "Discussions"
    @State private var isPosting = false
    private let categories = ["Discussions", "Events", "Alerts", "Marketplace"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text("Area: \(areaName)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }

                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                TextEditor(text: $text)
                    .padding(8)
                    .background(Color(UIColor.tertiarySystemFill))
                    .cornerRadius(12)

                Spacer()
            }
            .padding(16)
            .navigationTitle("New Nearby Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            isPosting = true
                            let fullContent = "[\(category)] \(text)"
                            let ok = await NearbyManager.shared.createNearbyPost(
                                content: fullContent,
                                areaName: areaName,
                                latitude: -26.19,
                                longitude: 28.03
                            )
                            isPosting = false
                            if ok {
                                onCreated()
                                dismiss()
                            }
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
                }
            }
        }
    }
}

struct NearbyDiscussionThreadView: View {
    let post: NearbyPostItem
    @Environment(\.dismiss) private var dismiss

    @State private var replies: [NearbyReplyItem] = []
    @State private var newReplyText = ""
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Original Post
                        NearbyPostCard(
                            post: post,
                            onLike: {},
                            onReply: {},
                            onRequestChat: {},
                            onShare: {}
                        )

                        Divider()
                            .padding(.vertical, 8)

                        Text("Replies (\(replies.count))")
                            .font(.system(size: 16, weight: .bold))

                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if replies.isEmpty {
                            Text("No replies yet. Be the first to comment!")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(replies) { reply in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(reply.authorName)
                                            .font(.system(size: 14, weight: .bold))
                                        Spacer()
                                    }
                                    Text(reply.content)
                                        .font(.system(size: 14))
                                }
                                .padding(12)
                                .background(Color(UIColor.tertiarySystemFill))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                }

                // Reply Composer Bar
                HStack(spacing: 12) {
                    TextField("Write a reply...", text: $newReplyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Send") {
                        let text = newReplyText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        Task {
                            if let reply = await NearbyManager.shared.addReply(postId: post.id, content: text) {
                                replies.append(reply)
                                newReplyText = ""
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .disabled(newReplyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
            }
            .navigationTitle("Discussion Thread")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                isLoading = true
                replies = await NearbyManager.shared.fetchReplies(postId: post.id)
                isLoading = false
            }
        }
    }
}

struct MyNearbyPostsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var nearbyManager = NearbyManager.shared

    var body: some View {
        NavigationStack {
            List {
                if nearbyManager.myPosts.isEmpty {
                    Text("You haven't posted any nearby updates yet.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(nearbyManager.myPosts) { post in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(post.content)
                                .font(.system(size: 15, weight: .semibold))
                            HStack {
                                Text("Area: \(post.areaName) • Likes: \(post.likeCount) • Replies: \(post.replyCount)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(post.isResolved ? "Resolved" : "Mark Resolved") {
                                    Task {
                                        _ = await nearbyManager.resolvePost(postId: post.id, isResolved: !post.isResolved)
                                    }
                                }
                                .font(.caption.bold())
                                .foregroundColor(post.isResolved ? .green : .blue)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let item = nearbyManager.myPosts[index]
                            Task {
                                _ = await nearbyManager.deletePost(postId: item.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Nearby Posts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await nearbyManager.fetchMyPosts()
            }
        }
    }
}

struct NearbyChatRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var nearbyManager = NearbyManager.shared

    var body: some View {
        NavigationStack {
            List {
                if nearbyManager.chatRequests.isEmpty {
                    Text("No message requests.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(nearbyManager.chatRequests) { req in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From \(req.senderName)").font(.headline)
                            Text("Regarding: \"\(req.postSnippet)\"").font(.caption).foregroundColor(.secondary)
                            Text(req.message).font(.subheadline)

                            HStack(spacing: 12) {
                                Button("Decline") {
                                    Task { _ = await nearbyManager.respondChatRequest(requestId: req.id, accept: false) }
                                }
                                .foregroundColor(.red)

                                Spacer()

                                Button("Accept") {
                                    Task { _ = await nearbyManager.respondChatRequest(requestId: req.id, accept: true) }
                                }
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Message Requests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await nearbyManager.fetchChatRequests()
            }
        }
    }
}
