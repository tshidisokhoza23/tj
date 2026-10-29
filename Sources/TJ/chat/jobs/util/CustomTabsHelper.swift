import UIKit
import SafariServices

public enum CustomTabsHelper {
    public static func applicantDestination(_ raw: String?) -> URL? {
        let value = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if value.isEmpty { return nil }
        let uriString: String
        if value.hasPrefix("http://") || value.hasPrefix("https://") || value.hasPrefix("mailto:") || value.hasPrefix("tel:") {
            uriString = value
        } else if value.contains("@") {
            uriString = "mailto:\(value)"
        } else if value.hasPrefix("+") || value.filter({ $0.isNumber }).count >= 9 {
            let digits = value.filter { $0.isNumber }
            uriString = "https://wa.me/\(digits)"
        } else {
            return nil
        }
        return URL(string: uriString)
    }

    @MainActor
    public static func launchUrl(_ urlString: String, from viewController: UIViewController? = nil) {
        let destUrl = applicantDestination(urlString) ?? URL(string: urlString)
        guard let url = destUrl else {
            print("Invalid external application URL")
            return
        }

        if url.scheme == "mailto" || url.scheme == "tel" || url.host?.contains("wa.me") == true {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false

        let safariVC = SFSafariViewController(url: url, configuration: config)

        let presentingVC = viewController ?? topViewController()
        if let presentingVC = presentingVC {
            presentingVC.present(safariVC, animated: true)
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @MainActor
    private static func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let base = controller ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController

        if let nav = base as? UINavigationController {
            return topViewController(controller: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(controller: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(controller: presented)
        }
        return base
    }
}
