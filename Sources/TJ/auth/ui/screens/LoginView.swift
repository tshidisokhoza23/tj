import SwiftUI

public struct LoginView: View {
    @StateObject public var viewModel: AuthViewModel
    private var onLoginSuccess: (AuthResponse?) -> Void
    private var onNavigateToOtp: (String, String?, String?, String?, String?, String?) -> Void

    @State private var alertMessage: String? = nil
    @State private var showAlert = false

    @MainActor public init(
        viewModel: AuthViewModel? = nil,
        onLoginSuccess: @escaping (AuthResponse?) -> Void,
        onNavigateToOtp: @escaping (String, String?, String?, String?, String?, String?) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel ?? AuthViewModel())
        self.onLoginSuccess = onLoginSuccess
        self.onNavigateToOtp = onNavigateToOtp
    }

    public var body: some View {
        ZStack {
            // Gradient background: deep blue top to cyan/bottom blue
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "0A2A6B"), location: 0.0),
                    .init(color: Color(hex: "0077E6"), location: 0.35),
                    .init(color: Color(hex: "00C4E0"), location: 0.7),
                    .init(color: Color(hex: "0099CC"), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle diagonal light shape
            LinearGradient(
                colors: [Color.clear, Color(hex: "00E5FF").opacity(0.13), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 72)

                // TJ Logo Container
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                        .frame(width: 88, height: 88)

                    Image("app_logo_main")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }

                Spacer().frame(height: 56)

                // Main title
                Text("Welcome to TJ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(-0.5)

                Spacer().frame(height: 16)

                // Subtitle
                Text("By continuing you accept the terms\nand conditions")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)

                Spacer()

                // Continue with Google Button
                Button(action: {
                    viewModel.signInWithGoogle()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4A90E2"), Color(hex: "5B9FEA"), Color(hex: "6BB0F0")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        if viewModel.authState?.isLoading == true {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)

                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .tracking(0.2)
                            }
                        }
                    }
                    .frame(height: 56)
                }
                .disabled(viewModel.authState?.isLoading == true)
                .padding(.horizontal, 32)

                Spacer().frame(height: 48)

                // Terms and conditions link
                Button(action: {
                    if let url = URL(string: "https://firstappserver.fly.dev/privacy") {
                        #if canImport(UIKit)
                        UIApplication.shared.open(url)
                        #endif
                    }
                }) {
                    Text("Terms and conditions")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer().frame(height: 36)
            }
        }
        .onReceive(viewModel.$authState) { state in
            if case .success(let response) = state {
                onLoginSuccess(response)
            } else if case .error(let message, _) = state {
                alertMessage = message
                showAlert = true
            }
        }
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }
}
