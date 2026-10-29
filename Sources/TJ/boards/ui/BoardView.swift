import SwiftUI

public struct BoardCopy {
    public let title: String
    public let noun: String
    public let priceHint: String
    public let action: String
    public let yourHeader: String
    public let filters: [String]

    public init(title: String, noun: String, priceHint: String, action: String, yourHeader: String, filters: [String]) {
        self.title = title
        self.noun = noun
        self.priceHint = priceHint
        self.action = action
        self.yourHeader = yourHeader
        self.filters = filters
    }
}

public func getBoardCopy(_ board: String) -> BoardCopy {
    switch board {
    case "rent":
        return BoardCopy(
            title: "Rooms available",
            noun: "room",
            priceHint: "R3,500 / month",
            action: "Ask about this room",
            yourHeader: "Your rooms",
            filters: ["Nearest", "Under R1500", "With Parking"]
        )
    case "services":
        return BoardCopy(
            title: "Handyman services",
            noun: "service",
            priceHint: "From R250",
            action: "Request this service",
            yourHeader: "Your services",
            filters: ["Nearest", "Plumbers", "Electricians"]
        )
    default:
        return BoardCopy(
            title: "Second-hand market",
            noun: "item",
            priceHint: "R150",
            action: "Message seller",
            yourHeader: "Your listings",
            filters: ["Nearby (5km)", "Appliances", "Clothes"]
        )
    }
}

public func formatPriceLabel(_ price: String, board: String) -> String {
    let trimmed = price.trimmingCharacters(in: .whitespaces)
    if trimmed.isEmpty { return "" }
    switch board {
    case "rent":
        return trimmed.localizedCaseInsensitiveContains("month") ? trimmed : "\(trimmed) / month"
    case "services":
        return (trimmed.localizedCaseInsensitiveContains("hr") || trimmed.localizedCaseInsensitiveContains("hour")) ? trimmed : "\(trimmed) / hr"
    default:
        return trimmed
    }
}

public struct RentView: View {
    public var onBack: () -> Void
    public var onChat: (String) -> Void

    public init(onBack: @escaping () -> Void = {}, onChat: @escaping (String) -> Void = { _ in }) {
        self.onBack = onBack
        self.onChat = onChat
    }

    public var body: some View {
        BoardView(board: "rent", onBack: onBack, onChat: onChat)
    }
}

public struct ServicesView: View {
    public var onBack: () -> Void
    public var onChat: (String) -> Void

    public init(onBack: @escaping () -> Void = {}, onChat: @escaping (String) -> Void = { _ in }) {
        self.onBack = onBack
        self.onChat = onChat
    }

    public var body: some View {
        BoardView(board: "services", onBack: onBack, onChat: onChat)
    }
}

public struct MarketView: View {
    public var onBack: () -> Void
    public var onChat: (String) -> Void

    public init(onBack: @escaping () -> Void = {}, onChat: @escaping (String) -> Void = { _ in }) {
        self.onBack = onBack
        self.onChat = onChat
    }

    public var body: some View {
        BoardView(board: "market", onBack: onBack, onChat: onChat)
    }
}

@MainActor
public class BoardViewModel: ObservableObject {
    @Published public var items: [BoardListing] = []
    @Published public var mine: [BoardListing] = []
    @Published public var message: String = ""
    public var board: String = "market"

    private let api: BoardApiProtocol

    public init(api: BoardApiProtocol? = nil) {
        self.api = api ?? BoardApi.shared
    }

    public func load(query: String = "") {
        Task {
            do {
                let res = try await api.list(board: board, query: query.trimmingCharacters(in: .whitespaces).isEmpty ? nil : query)
                self.items = res.listings
                self.message = ""
            } catch {
                self.message = "Could not load listings"
            }
            do {
                let mineRes = try await api.mine(board: board)
                self.mine = mineRes.listings
            } catch {
                // Ignore mine fetch errors silently
            }
        }
    }

    public func publish(title: String, description: String, price: String, area: String, photo: String) {
        Task {
            do {
                let req = CreateListingRequest(title: title, description: description, priceLabel: price, area: area, photoUrl: photo)
                _ = try await api.create(board: board, request: req)
                self.message = "Published"
                self.load()
            } catch {
                self.message = "Sign in and add a title before posting"
            }
        }
    }

    public func close(id: String) {
        Task {
            do {
                _ = try await api.update(board: board, id: id, request: UpdateListingRequest(status: "closed"))
                self.load()
            } catch {
                self.message = "Could not update listing"
            }
        }
    }

    public func interest(id: String, note: String, onChat: @escaping (String) -> Void) {
        Task {
            do {
                let res = try await api.interest(board: board, id: id, request: InterestRequest(note: note))
                if !res.conversationId.isEmpty {
                    onChat(res.conversationId)
                } else {
                    self.message = "Could not open chat. Sign in and try again."
                }
            } catch {
                self.message = "Could not open chat. Sign in and try again."
            }
        }
    }
}

public struct BoardView: View {
    public let board: String
    public var onBack: () -> Void
    public var onChat: (String) -> Void

    @StateObject private var viewModel = BoardViewModel()
    @State private var query: String = ""
    @State private var selectedFilter: Int = 0
    @State private var posting: Bool = false
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var price: String = ""
    @State private var area: String = ""
    @State private var photoUrl: String = ""
    @State private var note: String = ""
    @State private var selectedItem: BoardListing? = nil

    private var copy: BoardCopy {
        getBoardCopy(board)
    }

    private let tealAccent = Color(red: 0.0, green: 0.82, blue: 0.71)
    private let tealSelectedBg = Color(red: 0.06, green: 0.30, blue: 0.27)
    private let darkCardBg = Color(red: 0.09, green: 0.13, blue: 0.17)

    public init(board: String, onBack: @escaping () -> Void = {}, onChat: @escaping (String) -> Void = { _ in }) {
        self.board = board
        self.onBack = onBack
        self.onChat = onChat
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search area or title", text: $query)
                            .onChange(of: query) { newValue in
                                viewModel.load(query: newValue)
                            }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(Capsule())

                    // Filter Chips Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(copy.filters.enumerated()), id: \.offset) { index, filter in
                                let isSelected = selectedFilter == index
                                Button(action: {
                                    selectedFilter = index
                                    viewModel.load(query: index == 0 ? query : filter)
                                }) {
                                    Text("[ \(filter) ]")
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? tealAccent : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? tealSelectedBg : Color(UIColor.tertiarySystemFill))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(isSelected ? tealAccent : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    if !viewModel.message.isEmpty {
                        Text(viewModel.message)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    // Post Creation Form
                    if posting {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("New \(copy.noun.capitalized) Listing")
                                .font(.headline)

                            TextField("\(copy.noun.capitalized) title", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Details", text: $details, axis: .vertical)
                                .lineLimit(3...5)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField(copy.priceHint, text: $price)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Area", text: $area)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Photo URL", text: $photoUrl)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            HStack {
                                Spacer()
                                Button("Publish") {
                                    viewModel.publish(
                                        title: title.trimmingCharacters(in: .whitespaces),
                                        description: details.trimmingCharacters(in: .whitespaces),
                                        price: price.trimmingCharacters(in: .whitespaces),
                                        area: area.trimmingCharacters(in: .whitespaces),
                                        photo: photoUrl.trimmingCharacters(in: .whitespaces)
                                    )
                                    posting = false
                                    title = ""; details = ""; price = ""; area = ""; photoUrl = ""
                                }
                                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(12)
                        .background(darkCardBg)
                        .cornerRadius(16)
                    }

                    // Your Listings / Services / Rooms
                    Text(copy.yourHeader)
                        .font(.system(size: 18, weight: .bold))

                    if !viewModel.mine.isEmpty {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(viewModel.mine) { item in
                                ListingCardView(
                                    item: item,
                                    board: board,
                                    actionLabel: "Mark unavailable",
                                    onActionClick: { viewModel.close(id: item.id) },
                                    onClick: { selectedItem = item }
                                )
                            }
                        }
                    }

                    // Available Listings
                    Text("Available")
                        .font(.system(size: 18, weight: .bold))

                    if viewModel.items.isEmpty {
                        Text("Nothing is listed yet. Be the first to post.")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(viewModel.items) { item in
                                ListingCardView(
                                    item: item,
                                    board: board,
                                    onClick: { selectedItem = item }
                                )
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle(copy.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { posting.toggle() }) {
                        Text(posting ? "Close" : "Post")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if !item.photoUrl.isEmpty, let url = URL(string: item.photoUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(12)
                            }

                            Text(item.title)
                                .font(.title2.bold())

                            Text("\(formatPriceLabel(item.priceLabel, board: board)) • \(item.area.isEmpty ? "Gauteng" : item.area)")
                                .font(.subheadline)
                                .foregroundColor(tealAccent)

                            Text(item.description)
                                .font(.body)

                            if !item.sellerName.isEmpty {
                                Text("Posted by \(item.sellerName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            Text("Send a message")
                                .font(.headline)

                            TextField("Message", text: $note)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(copy.action) {
                                let messageText = note.trimmingCharacters(in: .whitespaces).isEmpty ? "Hi, I'm interested in \(item.title)" : note
                                viewModel.interest(id: item.id, note: messageText) { chatId in
                                    selectedItem = nil
                                    onChat(chatId)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(16)
                    }
                    .navigationTitle(item.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                selectedItem = nil
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.board = board
                viewModel.load()
            }
        }
    }
}

public struct ListingCardView: View {
    public let item: BoardListing
    public let board: String
    public var actionLabel: String? = nil
    public var onActionClick: (() -> Void)? = nil
    public let onClick: () -> Void

    private let tealAccent = Color(red: 0.0, green: 0.82, blue: 0.71)
    private let darkCardBg = Color(red: 0.09, green: 0.13, blue: 0.17)

    public init(
        item: BoardListing,
        board: String,
        actionLabel: String? = nil,
        onActionClick: (() -> Void)? = nil,
        onClick: @escaping () -> Void
    ) {
        self.item = item
        self.board = board
        self.actionLabel = actionLabel
        self.onActionClick = onActionClick
        self.onClick = onClick
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !item.photoUrl.isEmpty, let url = URL(string: item.photoUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
                .frame(height: 125)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 125)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            VStack(alignment: .leading, spacing: 2) {
                let displayPrice = formatPriceLabel(item.priceLabel, board: board)
                if !displayPrice.isEmpty {
                    Text(displayPrice)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(tealAccent)
                }

                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if !item.sellerName.isEmpty && item.sellerName != item.title {
                    Text(item.sellerName)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }

                Text(item.area.isEmpty ? "Gauteng" : item.area)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                if let actionLabel = actionLabel, let onActionClick = onActionClick {
                    Button(action: onActionClick) {
                        Text(actionLabel)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(12)
        }
        .background(darkCardBg)
        .cornerRadius(16)
        .contentShape(Rectangle())
        .onTapGesture {
            onClick()
        }
    }
}
