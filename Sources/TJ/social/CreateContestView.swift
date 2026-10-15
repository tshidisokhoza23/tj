import SwiftUI

public struct CreateContestView: View {
    public var onNavigateBack: () -> Void
    public var onContestCreated: (String) -> Void

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var hashtag: String = ""
    @State private var participantLimit: String = "20"
    @State private var generatedCodes: [String] = []
    @State private var isSubmitted: Bool = false

    private let darkBg = Color(hex: "121417")
    private let darkSurface = Color(hex: "1E2228")
    private let accentBlue = Color(hex: "2563EB")
    private let goldYellow = Color(hex: "F59E0B")

    public init(onNavigateBack: @escaping () -> Void, onContestCreated: @escaping (String) -> Void) {
        self.onNavigateBack = onNavigateBack
        self.onContestCreated = onContestCreated
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onNavigateBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Host a Pageant / Contest")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(darkBg)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if !isSubmitted {
                        TextField("Contest Title (e.g. Miss Thembisa 2026)", text: $title)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(darkSurface)
                            .cornerRadius(12)

                        TextField("Custom Hashtag (e.g. #MissThembisa)", text: $hashtag)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(darkSurface)
                            .cornerRadius(12)
                            .onChange(of: hashtag) { val in
                                let cleaned = val.replacingOccurrences(of: " ", with: "").lowercased()
                                hashtag = cleaned.hasPrefix("#") ? cleaned : "#\(cleaned)"
                            }

                        TextField("Contest Bio & Rules", text: $descriptionText, axis: .vertical)
                            .lineLimit(4...8)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(darkSurface)
                            .cornerRadius(12)

                        TextField("Contestant Limit (Default: 20)", text: $participantLimit)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(darkSurface)
                            .cornerRadius(12)

                        Button(action: {
                            guard !title.isEmpty, !hashtag.isEmpty else { return }
                            let limit = Int(participantLimit) ?? 20
                            let prefix = String(hashtag.replacingOccurrences(of: "#", with: "").prefix(5)).uppercased()
                            generatedCodes = (1...limit).map { idx in
                                "MGR-\(prefix)-\(1000 + idx)"
                            }
                            isSubmitted = true
                        }) {
                            Text("🚀 Create and Launch Contest")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(accentBlue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 12)
                    } else {
                        Text("✅ Contest Created Successfully!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(goldYellow)

                        Text("Share these Manager Access Codes with contestant managers. Each code grants 1 verified entry to \(hashtag).")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)

                        ForEach(generatedCodes, id: \.self) { code in
                            HStack {
                                Text(code)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: {
                                    UIPasteboard.general.string = code
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(accentBlue)
                                }
                            }
                            .padding(12)
                            .background(darkSurface)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            onContestCreated(hashtag)
                        }) {
                            Text("Go to Contest Feed")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(accentBlue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(16)
            }
        }
        .background(darkBg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
