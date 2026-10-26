import Foundation
import Combine
import SwiftUI

public enum CallType: String, Codable, Sendable {
    case voice = "voice"
    case video = "video"
}

@MainActor
public final class GlobalCallState: ObservableObject {
    public static let shared = GlobalCallState()

    @Published public var isCallActive: Bool = false
    @Published public var activeSessionId: String? = nil
    @Published public var activeParticipantId: String? = nil
    @Published public var activeCallType: CallType = .voice
    @Published public var isConnectionEstablished: Bool = false
    @Published public var isRinging: Bool = false
    @Published public var isAnswered: Bool = false
    @Published public var callDurationSeconds: Int = 0
    @Published public var activeParticipantName: String = "In Call"

    @Published public var contactNames: [String: String] = [:]
    @Published public var contactPhones: [String: String] = [:]

    private var durationTimer: Timer? = nil

    private init() {}

    public func updateContactInfo(userId: String, name: String, phone: String?) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanName.isEmpty && cleanName != userId {
            contactNames[userId] = cleanName
        }
        if let phone, !phone.isEmpty {
            contactPhones[userId] = phone
        }
    }

    public func getContactName(_ userId: String) -> String? {
        return contactNames[userId]
    }

    public func getContactPhone(_ userId: String) -> String? {
        return contactPhones[userId]
    }

    public func startCall(sessionId: String = UUID().uuidString, participantId: String, name: String?, type: CallType) {
        self.isCallActive = true
        self.activeSessionId = sessionId
        self.activeParticipantId = participantId
        self.activeCallType = type
        self.activeParticipantName = name?.isEmpty == false ? name! : (contactNames[participantId] ?? "In Call")
        self.isRinging = true
        self.isAnswered = false
        self.isConnectionEstablished = false
        self.callDurationSeconds = 0

        startTimer()
    }

    public func setConnectionEstablished(_ established: Bool) {
        self.isConnectionEstablished = established
        if established {
            self.isRinging = false
            self.isAnswered = true
        }
    }

    public func setAnswered(_ answered: Bool) {
        self.isAnswered = answered
        if answered {
            self.isRinging = false
        }
    }

    public func endCall() {
        self.isCallActive = false
        self.activeSessionId = nil
        self.activeParticipantId = nil
        self.isConnectionEstablished = false
        self.isRinging = false
        self.isAnswered = false
        self.callDurationSeconds = 0

        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isCallActive else { return }
                self.callDurationSeconds += 1
            }
        }
    }

    private func stopTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
}
