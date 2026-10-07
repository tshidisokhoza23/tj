import Foundation
import Combine
import SwiftUI
import Contacts

@MainActor
public class ContactPickerViewModel: ObservableObject {
    @Published public var contacts: Resource<[Contact]> = .loading()
    @Published public var searchResults: [Contact] = []

    private var allContacts: [Contact] = []

    public init() {
        fetchContacts()
    }

    public func fetchContacts() {
        contacts = .loading(allContacts)
        Task { await syncDeviceContacts() }
    }

    private func syncDeviceContacts() async {
        let matched = await ContactSyncManager.shared.syncAccountContacts()
        allContacts = matched
        if matched.isEmpty && !ContactSyncManager.shared.canReadContacts() {
            contacts = .error("Allow contacts, or sign in on a phone that already saved them", allContacts)
            return
        }
        contacts = .success(matched)
    }

    public func searchContacts(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchResults = []
            return
        }
        searchResults = allContacts.filter {
            $0.displayName.localizedCaseInsensitiveContains(trimmed) ||
            $0.phoneNumber.contains(trimmed) ||
            $0.username.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
