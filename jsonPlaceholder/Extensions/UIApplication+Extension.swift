import RxCocoa
import RxSwift

public extension UIApplication {
    static func topViewController(controller: UIViewController? = UIWindow.key?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }

        if !(controller?.isVisible ?? false) {
            log.warning("No visible topmost viewController found. Nil returned.")
            return nil
        }

        return controller
    }
}
