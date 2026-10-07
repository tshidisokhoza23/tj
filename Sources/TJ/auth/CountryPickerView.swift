import SwiftUI

public struct CountryPickerView: View {
    @Environment(\.dismiss) var dismiss
    public var onSelectCountry: (String, String) -> Void

    public init(onSelectCountry: @escaping (String, String) -> Void) {
        self.onSelectCountry = onSelectCountry
    }

    let countries = [
        ("United States", "+1"),
        ("South Africa", "+27"),
        ("United Kingdom", "+44"),
        ("Canada", "+1"),
        ("Australia", "+61"),
        ("Germany", "+49"),
        ("France", "+33"),
        ("India", "+91")
    ]

    public var body: some View {
        NavigationView {
            List {
                ForEach(countries, id: \.1) { country in
                    Button(action: {
                        onSelectCountry(country.0, country.1)
                        dismiss()
                    }) {
                        HStack {
                            Text(country.0)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(country.1)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
