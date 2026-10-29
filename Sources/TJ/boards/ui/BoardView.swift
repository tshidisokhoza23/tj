import SwiftUI

public struct BoardCopy {
    public let title: String
    public let noun: String
    public let priceHint: String
    public let action: String

    public init(title: String, noun: String, priceHint: String, action: String) {
        self.title = title
        self.noun = noun
        self.priceHint = priceHint
        self.action = action
    }
}

public func getBoardCopy(_ board: String) -> BoardCopy {
    switch board {
    case "rent":
        return BoardCopy(title: "Rooms available", noun: "room", priceHint: "R3,500 / month", action: "Ask about this room")
    case "services":
        return BoardCopy(title: "Handyman services", noun: "service", priceHint: "From R250", action: "Request this service")
    default:
        return BoardCopy(title: "Second-hand market", noun: "item", priceHint: "R150", action: "Message seller")
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
                    HStack {
                        TextField("Search area or title", text: $query)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Search") {
                            viewModel.load(query: query)
                        }
                        .buttonStyle(.borderedProminent)
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
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Your Listings
                    if !viewModel.mine.isEmpty {
                        Text("Your listings")
                            .font(.headline)
                        ForEach(viewModel.mine) { item in
                            ListingCardView(item: item, actionLabel: "Mark unavailable") {
                                viewModel.close(id: item.id)
                            }
                        }
                    }

                    // Available Listings
                    Text("Available")
                        .font(.headline)

                    if viewModel.items.isEmpty {
                        Text("Nothing is listed yet. Be the first to post.")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.items) { item in
                            ListingCardView(item: item, actionLabel: "View") {
                                selectedItem = item
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
                    Button(posting ? "Close" : "Post") {
                        posting.toggle()
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

                            Text("\(item.priceLabel.isEmpty ? "Price on request" : item.priceLabel) • \(item.area.isEmpty ? "Area not set" : item.area)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

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
    public let actionLabel: String
    public let action: () -> Void

    public init(item: BoardListing, actionLabel: String, action: @escaping () -> Void) {
        self.item = item
        self.actionLabel = actionLabel
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !item.photoUrl.isEmpty, let url = URL(string: item.photoUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 140)
                .clipped()
                .cornerRadius(8)
            }

            Text(item.title)
                .font(.headline)

            Text("\(item.priceLabel.isEmpty ? "Price on request" : item.priceLabel) • \(item.area.isEmpty ? "Area not set" : item.area)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !item.description.isEmpty {
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Spacer()
                Button(actionLabel, action: action)
                    .font(.footnote.bold())
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
