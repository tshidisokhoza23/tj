import Foundation
import Combine
import SwiftUI
import Contacts

@MainActor
public class ContactPickerViewModel: ObservableObject {
    @Published public var contacts: Resource<[Contact]> = .loading()
    @Published public var searchResults: [Contact] = []

    private var allContacts: [Contact] = []

    public var currentUserId: String? {
        UserDefaults.standard.string(forKey: "user_id")
    }

    public init() {
        fetchContacts()
    }

    private func sortContacts(_ list: [Contact]) -> [Contact] {
        let myId = currentUserId
        return list.filter { contact in
            if let myId = myId, !myId.isEmpty, (contact.id == myId || contact.id == "user_\(myId)" || contact.id.replacingOccurrences(of: "user_", with: "") == myId.replacingOccurrences(of: "user_", with: "")) {
                return false
            }
            return true
        }.sorted { a, b in
            if a.isRegistered != b.isRegistered {
                return a.isRegistered && !b.isRegistered
            }
            return a.displayName.localizedCaseInsensitiveCompare(b.displayName) == .orderedAscending
        }
    }

    public func fetchContacts() {
        Task {
            let cachedEntities = await LocalDatabase.shared.getContacts()
            let cached = sortContacts(cachedEntities.map { entity in
                Contact(
                    id: entity.id,
                    username: entity.username,
                    displayName: entity.displayName,
                    avatarUrl: entity.avatarUrl,
                    phoneNumber: entity.phoneNumber,
                    isRegistered: entity.isRegistered
                )
            })
            if !cached.isEmpty {
                self.allContacts = cached
                self.contacts = .success(cached)
            } else if self.allContacts.isEmpty {
                self.contacts = .loading(nil)
            }

            await syncDeviceContacts()
        }
    }

    private func syncDeviceContacts() async {
        let matched = sortContacts(await ContactSyncManager.shared.syncAccountContacts())
        if !matched.isEmpty {
            allContacts = matched
            contacts = .success(matched)
        } else if allContacts.isEmpty {
            if !ContactSyncManager.shared.canReadContacts() {
                contacts = .error("Allow contacts, or sign in on a phone that already saved them", allContacts)
            } else {
                contacts = .success([])
            }
        }
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
