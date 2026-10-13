import SwiftUI

public struct AppLogo: View {
    public var size: CGFloat

    public init(size: CGFloat = 90) {
        self.size = size
    }

    public var body: some View {
        Image("app_logo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

public struct AppLogoWithText: View {
    public var size: CGFloat

    public init(size: CGFloat = 32) {
        self.size = size
    }

    public var body: some View {
        HStack(spacing: 10) {
            AppLogo(size: size)
            Text("TJ")
                .font(.system(size: size * 0.65, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    AppLogo(size: 90)
}
