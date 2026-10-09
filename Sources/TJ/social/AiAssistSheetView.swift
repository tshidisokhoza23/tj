import SwiftUI

public struct AiAssistSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let initialText: String
    let onApply: (String, Bool) -> Void

    @State private var selectedAction: String? = nil
    @State private var isLoading: Bool = false
    @State private var resultText: String = ""
    @State private var suggestedHashtags: [String] = []

    private let actions = [
        ("Improve writing", "improve"),
        ("Make shorter", "shorter"),
        ("Make longer", "longer"),
        ("Add humor", "humor"),
        ("Make professional", "professional"),
        ("Suggest hashtags", "hashtags"),
        ("Fix grammar", "grammar"),
        ("Thread mode", "thread")
    ]

    public init(initialText: String, onApply: @escaping (String, Bool) -> Void) {
        self.initialText = initialText
        self.onApply = onApply
        self._resultText = State(initialValue: initialText)
    }

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppColors.tealAccent)
                        .font(.title3)
                    Text("AI Assist ✨")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }

                Text("CHOOSE ENHANCEMENT")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.tealAccent)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(actions, id: \.1) { label, key in
                            let isSelected = selectedAction == key
                            Button(action: {
                                selectedAction = key
                                runAiAssist(actionKey: key)
                            }) {
                                Text(label)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSelected ? AppColors.tealAccent : .white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? AppColors.tealAccent.opacity(0.2) : AppColors.cardDark)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSelected ? AppColors.tealAccent : AppColors.borderDark, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Output Preview Box
                VStack(alignment: .leading, spacing: 10) {
                    if isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                                .tint(AppColors.tealAccent)
                            Text("AI is refining your draft...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 12)
                    } else {
                        Text(resultText.isEmpty ? (initialText.isEmpty ? "Type text above or pick an action." : initialText) : resultText)
                            .font(.body)
                            .foregroundColor(.white)

                        if !suggestedHashtags.isEmpty {
                            Text(suggestedHashtags.joined(separator: " "))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.tealAccent)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardDark)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.borderDark, lineWidth: 1))

                Spacer()

                // Actions
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("Discard")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
                    }

                    Button(action: {
                        let final = suggestedHashtags.isEmpty ? resultText : "\(resultText)\n\n\(suggestedHashtags.joined(separator: " "))"
                        onApply(final, true)
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text("Accept")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.tealAccent)
                        .clipShape(Capsule())
                    }
                    .disabled(isLoading || resultText.isEmpty)
                }
            }
            .padding()
            .background(AppColors.darkCharcoal.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private func runAiAssist(actionKey: String) {
        isLoading = true
        suggestedHashtags = []
        Task {
            defer { isLoading = false }
            do {
                let data = try await API.data("ai/assist", method: "POST", json: [
                    "action": actionKey,
                    "text": initialText,
                    "tone_preference": "Casual"
                ])
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                let suggested = (json["suggested_text"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                resultText = suggested.isEmpty ? initialText : suggested
                suggestedHashtags = json["suggested_hashtags"] as? [String] ?? []
                if json["source"] as? String == "offline" {
                    resultText += resultText.isEmpty ? "Write something first." : ""
                }
            } catch {
                resultText = error.localizedDescription
                suggestedHashtags = []
            }
        }
    }
}
