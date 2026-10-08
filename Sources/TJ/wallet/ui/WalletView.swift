import StoreKit
import SwiftUI

// MARK: - Wallet Models

public enum TransactionType: String, Codable {
    case received
    case sent
    case payout
    case reward
}

public enum TransactionStatus: String, Codable {
    case completed = "Completed"
    case pending = "Pending"
    case failed = "Failed"

    public var statusColor: Color {
        switch self {
        case .completed: return .green
        case .pending: return .orange
        case .failed: return .red
        }
    }
}

public struct WalletTransaction: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let counterparty: String
    public let timestamp: String
    public let amountFormatted: String
    public let isCredit: Bool
    public let type: TransactionType
    public let status: TransactionStatus

    public init(id: String, title: String, counterparty: String, timestamp: String, amountFormatted: String, isCredit: Bool, type: TransactionType, status: TransactionStatus = .completed) {
        self.id = id
        self.title = title
        self.counterparty = counterparty
        self.timestamp = timestamp
        self.amountFormatted = amountFormatted
        self.isCredit = isCredit
        self.type = type
        self.status = status
    }
}

// MARK: - WalletView

public struct WalletView: View {
    @State private var tokenBalance: Double = 0
    @State private var purchasedCoins: Int = 0
    @State private var availableCents: Int = 0
    @State private var canWithdraw = false
    @State private var coinProducts: [Product] = []
    @State private var selectedFilter: WalletFilter = .all
    @State private var showPayoutSheet: Bool = false
    @State private var legalName = ""
    @State private var accountNumber = ""
    @State private var bankCode = ""
    @State private var alertToastMessage: String? = nil
    @State private var showAlertToast: Bool = false
    @State private var busy = false

    enum WalletFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case received = "Received"
        case sent = "Sent"
        case payouts = "Payouts"

        var id: String { rawValue }
    }

    private let payoutMethods: [String] = []

    @State private var transactions: [WalletTransaction] = []

    public init() {}

    private var filteredTransactions: [WalletTransaction] {
        transactions.filter { tx in
            switch selectedFilter {
            case .all: return true
            case .received: return tx.isCredit
            case .sent: return !tx.isCredit && tx.type != .payout
            case .payouts: return tx.type == .payout
            }
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    LiveBannerAd()
                    // Balance Header Card
                    balanceCardView

                    // Quick Action Row
                    quickActionsRow

                    creatorCoinCard
                    linkedPayoutMethodsCard

                    // Transaction History Section
                    transactionHistorySection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .task { await reloadWallet() }
            .navigationTitle("Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert("Wallet Notice", isPresented: $showAlertToast) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertToastMessage ?? "")
            }
            .sheet(isPresented: $showPayoutSheet) {
                payoutModalSheet
            }
        }
    }

    // MARK: - Subviews

    private var balanceCardView: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Ad points", systemImage: "star.fill")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("Not cash")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(String(format: "%.2f", tokenBalance))")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
                Text("points")
                    .font(.title3.bold())
                    .foregroundColor(.cyan)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("Ad points cannot be tipped or withdrawn. Creator coins are a separate purchase.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color.indigo, Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(radius: 8)
    }

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            walletActionButton(title: "Coins", icon: "gift.fill", color: .blue) {
                alertToastMessage = "Buy coin packs below. Coins can only tip posts inside TJ."
                showAlertToast = true
            }

            walletActionButton(title: "Bank", icon: "building.columns.fill", color: .green) {
                showPayoutSheet = true
            }

            walletActionButton(title: "Hold", icon: "clock.fill", color: .purple) {
                alertToastMessage = "Creator earnings stay on hold for 14 days and are taxable income. A payout is not paid until the bank transfer completes."
                showAlertToast = true
            }

            walletActionButton(title: "Payout", icon: "banknote.fill", color: .orange) {
                payoutAmountText = ""
                showPayoutSheet = true
            }
        }
    }

    private func walletActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)

                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
        }
    }

    private var linkedPayoutMethodsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LINKED PAYOUT METHODS")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            VStack(spacing: 0) {
                HStack {
                    Label("No payout method on file", systemImage: "building.columns.fill")
                        .font(.subheadline.bold())
                    Spacer()
                    Text("Primary")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    private var transactionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TRANSACTION HISTORY")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(WalletFilter.allCases) { filter in
                        Button(action: { selectedFilter = filter }) {
                            Text(filter.rawValue)
                                .font(.footnote)
                                .fontWeight(selectedFilter == filter ? .bold : .medium)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(selectedFilter == filter ? Color.blue : Color(.tertiarySystemBackground))
                                .foregroundColor(selectedFilter == filter ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
            }

            VStack(spacing: 0) {
                ForEach(filteredTransactions) { tx in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(tx.isCredit ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: tx.isCredit ? "arrow.down.left" : "arrow.up.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(tx.isCredit ? .green : .red)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(tx.title)
                                .font(.subheadline.weight(.semibold))
                            Text("\(tx.counterparty) • \(tx.timestamp)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(tx.amountFormatted)
                                .font(.subheadline.bold())
                                .foregroundColor(tx.isCredit ? .green : .primary)

                            Text(tx.status.rawValue)
                                .font(.caption2.bold())
                                .foregroundColor(tx.status.statusColor)
                        }
                    }
                    .padding()

                    if tx.id != filteredTransactions.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    private var creatorCoinCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CREATOR COINS")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            Text("Coins to tip: \(purchasedCoins)")
                .font(.headline)
            Text("Available creator earnings: R\(String(format: "%.2f", Double(availableCents) / 100)) before the bank fee. Minimum payout is R500.")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Purchased coins are not a bank balance and cannot be withdrawn. Payouts are rand earnings for the creator, not a coin cash-out.")
                .font(.caption)
                .foregroundColor(.secondary)
            if coinProducts.isEmpty {
                Text("Coin packs are not available from the App Store on this account yet. Packs are sold in South African rand only.")
                    .font(.caption)
            }
            ForEach(coinProducts) { product in
                Button(product.displayPrice + " · " + product.displayName) {
                    Task { await buy(product) }
                }
                .disabled(busy)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var payoutModalSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("South African payout")
                        .font(.title2.bold())
                        .padding(.top)
                    Text("The account name must match the legal name exactly. The full account number is sent once to the bank and is not stored on this phone.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Legal name", text: $legalName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Account number", text: $accountNumber)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    TextField("Bank code", text: $bankCode)
                        .textFieldStyle(.roundedBorder)
                    Button("Verify bank name") {
                        Task { await saveBank() }
                    }
                    .disabled(busy || legalName.count < 2 || accountNumber.count < 6 || bankCode.isEmpty)
                    Button(canWithdraw ? "Request payout" : "Payout not available yet") {
                        Task { await requestPayout() }
                    }
                    .disabled(busy || !canWithdraw)
                }
                .padding(.horizontal)
            }
            .navigationBarItems(trailing: Button("Close") { showPayoutSheet = false })
        }
        .presentationDetents([.medium, .large])
    }

    private func reloadWallet() async {
        if let data = try? await API.data("rewards/balance"),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            tokenBalance = (json["balance"] as? Double) ?? Double(json["balance"] as? Int ?? 0)
        } else if let cached = SessionStore.shared.user?.walletBalance {
            tokenBalance = cached
        }
        if let wallet = try? await CreatorWalletAPI.json("wallet") {
            purchasedCoins = CreatorWalletAPI.intValue(wallet["purchased_coins"])
        }
        if let earnings = try? await CreatorWalletAPI.json("wallet/earnings") {
            availableCents = CreatorWalletAPI.intValue(earnings["withdrawable_cents"])
            canWithdraw = earnings["can_withdraw"] as? Bool ?? false
        }
        coinProducts = (try? await Product.products(for: ["tj_coins_100", "tj_coins_500", "tj_coins_1000"])) ?? []
        await recoverUnfinishedPurchases()
    }

    private func buy(_ product: Product) async {
        busy = true
        defer { busy = false }
        do {
            let result = try await product.purchase()
            guard case .success(let verification) = result else { return }
            try await CreatorWalletAPI.credit(verification)
            await reloadWallet()
            alertToastMessage = "Coins added. They can only be used to tip inside TJ."
            showAlertToast = true
        } catch {
            alertToastMessage = CreatorWalletAPI.message(error)
            showAlertToast = true
        }
    }

    private func recoverUnfinishedPurchases() async {
        for await verification in Transaction.unfinished {
            guard case .verified(let transaction) = verification,
                  ["tj_coins_100", "tj_coins_500", "tj_coins_1000"].contains(transaction.productID) else { continue }
            try? await CreatorWalletAPI.credit(verification)
        }
    }

    private func saveBank() async {
        busy = true
        defer { busy = false }
        do {
            _ = try await API.data("wallet/bank", method: "PUT", json: [
                "legal_name": legalName,
                "account_number": accountNumber,
                "bank_code": bankCode
            ])
            accountNumber = ""
            alertToastMessage = "Bank name checked. Only the last 4 digits are kept."
            showAlertToast = true
        } catch {
            alertToastMessage = CreatorWalletAPI.message(error)
            showAlertToast = true
        }
    }

    private func requestPayout() async {
        busy = true
        defer { busy = false }
        do {
            let data = try await API.data("wallet/payouts", method: "POST", json: [
                "idempotency_key": UUID().uuidString
            ])
            let json = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
            alertToastMessage = "Payout \(json["status"] as? String ?? "requested"). It is not paid until the bank transfer completes."
            showAlertToast = true
            await reloadWallet()
        } catch {
            alertToastMessage = CreatorWalletAPI.message(error)
            showAlertToast = true
        }
    }
}

enum CreatorWalletAPI {
    static func json(_ path: String, method: String = "GET", body: [String: Any]? = nil) async throws -> [String: Any] {
        let data = try await API.data(path, method: method, json: body)
        return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }

    static func credit(_ verification: VerificationResult<Transaction>) async throws {
        guard case .verified(let transaction) = verification else {
            throw APIError.status(400, "The App Store purchase could not be verified")
        }
        _ = try await API.data("wallet/purchases", method: "POST", json: [
            "platform": "IOS",
            "product_id": transaction.productID,
            "signed_transaction": verification.jwsRepresentation
        ])
        await transaction.finish()
    }

    static func intValue(_ value: Any?) -> Int {
        if let number = value as? Int { return number }
        if let number = value as? Double { return Int(number) }
        if let number = value as? NSNumber { return number.intValue }
        return 0
    }

    static func message(_ error: Error) -> String {
        let raw = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        guard let start = raw.firstIndex(of: "{"),
              let data = String(raw[start...]).data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let message = json["error"] as? String, !message.isEmpty else {
            return "The wallet request was rejected."
        }
        return message
    }
}

struct CreatorTipButton: View {
    let postId: String
    let authorId: String
    var tint: Color = .secondary
    @State private var showTip = false

    private var canTip: Bool {
        let mine = UserDefaults.standard.string(forKey: "tj_user_id") ?? ""
        return !postId.isEmpty && !authorId.isEmpty && authorId != mine
    }

    var body: some View {
        if canTip {
            Button { showTip = true } label: {
                Image(systemName: "gift")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(minWidth: 32, minHeight: 32)
            }
            .buttonStyle(.borderless)
            .sheet(isPresented: $showTip) {
                CreatorTipSheet(postId: postId)
            }
        }
    }
}

struct CreatorTipSheet: View {
    let postId: String
    @Environment(\.dismiss) private var dismiss
    @State private var coins = "10"
    @State private var note: String?
    @State private var busy = false
    @State private var key = UUID().uuidString

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Minimum tip is 10 purchased coins. You cannot tip your own post. Coins are not cash.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Coins", text: $coins)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                if let note { Text(note).font(.caption) }
                Button(busy ? "Sending" : "Send tip") {
                    Task { await send() }
                }
                .disabled(busy || (Int(coins) ?? 0) < 10)
                Spacer()
            }
            .padding()
            .navigationTitle("Tip this post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
        .presentationDetents([.medium])
    }

    private func send() async {
        busy = true
        defer { busy = false }
        do {
            _ = try await API.data("wallet/tips", method: "POST", json: [
                "post_id": postId,
                "coins": Int(coins) ?? 0,
                "idempotency_key": key
            ])
            note = "Tip sent. The creator's earnings stay on hold for 14 days."
        } catch {
            note = CreatorWalletAPI.message(error)
        }
    }
}

#Preview {
    WalletView()
}
