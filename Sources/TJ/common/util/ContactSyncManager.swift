import Foundation
import Contacts

public struct ContactInfo: Codable, Sendable {
    public let displayName: String
    public let phoneNumber: String

    public enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case phoneNumber = "phone_number"
    }

    public init(displayName: String, phoneNumber: String) {
        self.displayName = displayName
        self.phoneNumber = phoneNumber
    }
}

public protocol ChatRepositoryContactSyncProtocol {
    func syncContacts(phoneNumbers: [String]) async throws
}

public final class ContactSyncManager {

    public static let shared = ContactSyncManager()

    private let contactStore = CNContactStore()
    private var observerRegistered = false
    public var onContactsChanged: (() -> Void)?

    private init() {}

    // MARK: - Permission Check

    public func canReadContacts() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status.rawValue == 3 || status.rawValue == 4
    }

    public func requestContactsAccess() async -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if canReadContacts() { return true }
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            do {
                return try await contactStore.requestAccess(for: .contacts)
            } catch {
                return false
            }
        default:
            return false
        }
    }

    // MARK: - Fetch Contacts

    public func fetchAllContacts() -> [ContactInfo] {
        guard canReadContacts() else {
            return []
        }

        var contacts: [ContactInfo] = []
        var seenNumbers = Set<String>()
        let defaultPrefix = getDefaultPhonePrefix()

        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]

        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

        do {
            try contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
                for phoneNumberValue in contact.phoneNumbers {
                    let rawNumber = phoneNumberValue.value.stringValue
                    let formattedNumber = self.formatPhoneNumber(rawNumber, defaultPrefix: defaultPrefix)
                    if self.isValidPhoneNumber(formattedNumber) && !seenNumbers.contains(formattedNumber) {
                        seenNumbers.insert(formattedNumber)
                        contacts.append(ContactInfo(displayName: name, phoneNumber: formattedNumber))
                    }
                }
            }
        } catch {
            print("[ContactSyncManager] Failed to fetch contacts: \(error.localizedDescription)")
        }

        return contacts
    }

    public func getContactNameByNumber(_ phoneNumber: String) -> String? {
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return nil
        }

        let defaultPrefix = getDefaultPhonePrefix()
        let cleanInput = formatPhoneNumber(phoneNumber, defaultPrefix: defaultPrefix)

        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: cleanInput))
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor]

        do {
            let matches = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            if let first = matches.first {
                let fullName = "\(first.givenName) \(first.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
                return fullName.isEmpty ? nil : fullName
            }
        } catch {
            print("[ContactSyncManager] Lookup error: \(error.localizedDescription)")
        }

        return nil
    }

    // MARK: - Observer

    public func startObserving() {
        guard !observerRegistered else { return }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContactsDidChange(_:)),
            name: .CNContactStoreDidChange,
            object: nil
        )
        observerRegistered = true
    }

    public func stopObserving() {
        guard observerRegistered else { return }
        NotificationCenter.default.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
        observerRegistered = false
    }

    @objc private func handleContactsDidChange(_ notification: Notification) {
        onContactsChanged?()
    }

    // MARK: - Background Sync

    /// Reads the phone book, saves those numbers to the account, then reads the
    /// saved list back. A new phone with an empty address book still gets them.
    public func syncAccountContacts() async -> [Contact] {
        let allowed = await requestContactsAccess()
        let device = allowed ? fetchAllContacts() : []
        if !device.isEmpty {
            let payload = device.map { ["name": $0.displayName, "phone_number": $0.phoneNumber] }
            _ = try? await API.data("users/persistent-contacts", method: "POST", json: ["contacts": payload])
        }

        var saved: [ContactInfo] = []
        if let data = try? await API.data("users/persistent-contacts") {
            saved = Self.savedContacts(from: data)
        }

        var byKey: [String: ContactInfo] = [:]
        for item in saved + device {
            let key = Self.phoneKey(item.phoneNumber)
            guard !key.isEmpty else { continue }
            let current = byKey[key]
            if current == nil || current?.displayName.isEmpty == true {
                byKey[key] = item
            }
        }

        var registeredByKey: [String: Contact] = [:]
        let numbers = byKey.values.map(\.phoneNumber)
        if !numbers.isEmpty, let data = try? await API.data("users/sync-contacts", method: "POST", json: ["phone_numbers": numbers]) {
            let rows = (LiveJSON.object(data)["contacts"] as? [[String: Any]]) ?? []
            for row in rows {
                let id = LiveJSON.string(row["id"])
                guard !id.isEmpty else { continue }
                let phone = LiveJSON.string(row["phone_number"])
                let key = Self.phoneKey(phone)
                let localName = byKey[key]?.displayName ?? ""
                let serverName = LiveJSON.string(row["display_name"])
                let username = LiveJSON.string(row["username"])
                let name = !localName.isEmpty ? localName : (!serverName.isEmpty ? serverName : (!username.isEmpty ? username : phone))
                registeredByKey[key] = Contact(
                    id: id,
                    username: username,
                    displayName: name,
                    avatarUrl: LiveJSON.string(row["avatar_url"]).nilIfEmpty,
                    phoneNumber: phone.isEmpty ? (byKey[key]?.phoneNumber ?? "") : phone,
                    isRegistered: true,
                    isVerified: LiveJSON.bool(row["is_verified"])
                )
            }
        }

        var result: [Contact] = []
        var seen = Set<String>()
        for (key, item) in byKey {
            seen.insert(key)
            if var registered = registeredByKey[key] {
                if registered.displayName.isEmpty { registered.displayName = item.displayName }
                if registered.phoneNumber.isEmpty { registered.phoneNumber = item.phoneNumber }
                result.append(registered)
            } else {
                let name = item.displayName.isEmpty ? item.phoneNumber : item.displayName
                result.append(Contact(
                    id: "phone:\(item.phoneNumber)",
                    username: item.phoneNumber,
                    displayName: name,
                    phoneNumber: item.phoneNumber,
                    isRegistered: false,
                    isAuthenticated: false
                ))
            }
        }
        for (key, registered) in registeredByKey where !seen.contains(key) {
            result.append(registered)
        }
        result.sort { a, b in
            if a.isRegistered != b.isRegistered {
                return a.isRegistered && !b.isRegistered
            }
            return a.displayName.localizedCaseInsensitiveCompare(b.displayName) == .orderedAscending
        }

        await LocalDatabase.shared.upsertContacts(result.map {
            ContactEntity(
                id: $0.id,
                username: $0.username,
                displayName: $0.displayName,
                avatarUrl: $0.avatarUrl,
                phoneNumber: $0.phoneNumber,
                isRegistered: $0.isRegistered
            )
        })
        return result
    }

    static func savedContacts(from data: Data) -> [ContactInfo] {
        let json = try? JSONSerialization.jsonObject(with: data)
        let rows: [[String: Any]]
        if let list = json as? [[String: Any]] {
            rows = list
        } else if let object = json as? [String: Any] {
            rows = (object["contacts"] as? [[String: Any]]) ?? []
        } else {
            rows = []
        }
        return rows.compactMap { row in
            let phone = LiveJSON.string(row["phone_number"])
            guard !phone.isEmpty else { return nil }
            let name = LiveJSON.string(row["name"])
            return ContactInfo(displayName: name, phoneNumber: phone)
        }
    }

    static func phoneKey(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        guard digits.count >= 9 else { return digits }
        return String(digits.suffix(9))
    }

    public func syncContacts(repository: ChatRepositoryContactSyncProtocol) async {
        guard await requestContactsAccess() else { return }

        let contacts = fetchAllContacts()
        let phoneNumbers = contacts.map { $0.phoneNumber }

        do {
            try await repository.syncContacts(phoneNumbers: phoneNumbers)
            print("[ContactSyncManager] Background contact sync successful (\(phoneNumbers.count) contacts)")
        } catch {
            print("[ContactSyncManager] Contact sync error: \(error.localizedDescription)")
        }
    }

    // MARK: - Formatting Helpers

    public func formatPhoneNumber(_ number: String, defaultPrefix: String) -> String {
        let clean = number.components(separatedBy: CharacterSet(charactersIn: "0123456789+").inverted).joined()

        if clean.hasPrefix("+") {
            return clean
        }
        if clean.hasPrefix("00") {
            return "+" + String(clean.dropFirst(2))
        }
        if clean.hasPrefix("0") {
            return "+\(defaultPrefix)" + String(clean.dropFirst(1))
        }
        if clean.count <= 9 {
            return "+\(defaultPrefix)\(clean)"
        }
        if clean.hasPrefix(defaultPrefix) {
            return "+\(clean)"
        }
        return "+\(clean)"
    }

    public func formatDisplayPhone(_ number: String?) -> String {
        guard let number = number, !number.isEmpty else { return "" }
        let clean = number.components(separatedBy: CharacterSet(charactersIn: "0123456789+").inverted).joined()
        guard clean.hasPrefix("+") else { return clean }

        let digits = String(clean.dropFirst())
        if digits.count == 11 {
            let c = digits.map { String($0) }
            return "+\(c[0...1].joined()) \(c[2...3].joined()) \(c[4...6].joined()) \(c[7...10].joined())"
        } else if digits.count == 10 {
            let c = digits.map { String($0) }
            return "+\(c[0]) \(c[1...3].joined()) \(c[4...6].joined()) \(c[7...9].joined())"
        }
        return clean
    }

    private func isValidPhoneNumber(_ number: String) -> Bool {
        let regex = "^\\+[1-9]\\d{6,14}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: number)
    }

    private func getDefaultPhonePrefix() -> String {
        let regionCode = Locale.current.region?.identifier ?? "ZA"
        switch regionCode {
        case "US", "CA": return "1"
        case "GB": return "44"
        case "ZA": return "27"
        case "IN": return "91"
        case "AU": return "61"
        case "DE": return "49"
        case "FR": return "33"
        default: return "27"
        }
    }
}
