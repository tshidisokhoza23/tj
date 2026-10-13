import Foundation
import Contacts

public final class ContactSyncManager: @unchecked Sendable {
    public static let shared = ContactSyncManager()
    private let contactStore = CNContactStore()

    private init() {}

    public func canReadContacts() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status == .authorized
    }

    public func requestContactsPermission() async -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized { return true }
        if status == .denied || status == .restricted { return false }
        do {
            return try await contactStore.requestAccess(for: .contacts)
        } catch {
            return false
        }
    }

    public func fetchDevicePhoneNumbers() async -> [String] {
        guard await requestContactsPermission() else { return [] }

        var phoneNumbers = Set<String>()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor
        ]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

        do {
            try contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                for phoneNumber in contact.phoneNumbers {
                    let rawNumber = phoneNumber.value.stringValue
                    let digits = rawNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    if digits.count >= 7 {
                        let formatted = rawNumber.hasPrefix("+") ? "+\(digits)" : digits
                        phoneNumbers.insert(formatted)
                    }
                }
            }
        } catch {
            print("Failed to enumerate device contacts: \(error)")
        }

        return Array(phoneNumbers)
    }

    @discardableResult
    public func syncAccountContacts() async -> [Contact] {
        let phoneNumbers = await fetchDevicePhoneNumbers()
        guard !phoneNumbers.isEmpty else { return [] }

        do {
            let response = try await ChatApi.shared.syncContacts(phoneNumbers: phoneNumbers)
            let matchedContacts = response.contacts.map { apiUser in
                Contact(
                    id: apiUser.id,
                    displayName: apiUser.displayName.isEmpty ? apiUser.username : apiUser.displayName,
                    username: apiUser.username,
                    phoneNumber: apiUser.phoneNumber ?? "",
                    avatarUrl: apiUser.avatarUrl,
                    serverProfileName: apiUser.displayName,
                    isRegistered: true
                )
            }
            return matchedContacts
        } catch {
            print("Failed to sync contacts with backend: \(error)")
            return []
        }
    }
}
