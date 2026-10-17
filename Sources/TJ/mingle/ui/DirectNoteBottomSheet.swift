import SwiftUI

public struct DirectNoteBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    public let recipientName: String
    public let recipientId: String
    public var availableTokens: Int
    public var onSendNote: (String) -> Void
    public var onOpenPaywall: () -> Void

    @State private var noteText: String = ""
    @State private var isSending: Bool = false
    private let charLimit = 140

    public init(
        recipientName: String,
        recipientId: String,
        availableTokens: Int,
        onSendNote: @escaping (String) -> Void,
        onOpenPaywall: @escaping () -> Void
    ) {
        self.recipientName = recipientName
        self.recipientId = recipientId
        self.availableTokens = availableTokens
        self.onSendNote = onSendNote
        self.onOpenPaywall = onOpenPaywall
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Tokens Bar Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                        Text("\(availableTokens) Direct Note Tokens Left")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    if availableTokens <= 0 {
                        Button(action: {
                            dismiss()
                            onOpenPaywall()
                        }) {
                            Text("Get Tokens")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)

                Text("Send a Direct Note to \(recipientName)")
                    .font(.headline)

                Text("A Direct Note goes straight to \(recipientName)'s Message Requests. Once sent, further messages are locked until they accept.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Character Capped Input Field
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $noteText)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                        .onChange(of: noteText) { text in
                            if text.count > charLimit {
                                noteText = String(text.prefix(charLimit))
                            }
                        }

                    if noteText.isEmpty {
                        Text("Type your 140-char opener...")
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                            .padding(.top, 16)
                    }
                }

                HStack {
                    Spacer()
                    Text("\(noteText.count)/\(charLimit)")
                        .font(.caption)
                        .foregroundColor(noteText.count >= charLimit ? .red : .secondary)
                }

                Spacer()

                // Action Button
                if availableTokens > 0 {
                    Button(action: sendNote) {
                        HStack {
                            if isSending {
                                ProgressView().tint(.white)
                                    .padding(.trailing, 8)
                            }
                            Text(isSending ? "Sending Note..." : "Send Direct Note (1 Token)")
                                .font(.headline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(28)
                    }
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                } else {
                    Button(action: {
                        dismiss()
                        onOpenPaywall()
                    }) {
                        Text("Unlock Court Pass to Send Direct Notes")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryGradient)
                            .foregroundColor(.white)
                            .cornerRadius(28)
                    }
                }
            }
            .padding()
            .navigationTitle("Direct Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func sendNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, availableTokens > 0, !isSending else { return }
        isSending = true

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                isSending = false
                onSendNote(trimmed)
                dismiss()
            }
        }
    }
}
