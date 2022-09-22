import Lottie
import RxCocoa
import RxSwift

extension UIViewController {
    /// Returns the name of a class
    static var identifier: String {
        var identifier = String(describing: self)
        // If a class used with generic it returns whole name with generic
        // like ClassName<Generic>, to avoid this, here is cutting
        // only first part - class name
        if let cuttedIndex = identifier.firstIndex(of: "<") {
            identifier = String(identifier[..<cuttedIndex])
        }
        return identifier
    }
    
    var identifier: String {
        type(of: self).identifier
    }
}

extension UIViewController {
    public func showAlert(title: String, message: String,
                          actions: [UIAlertAction] = [], completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        if actions.isEmpty {
            let okAction = UIAlertAction(title: "Ok", style: .default) { [weak alertController] _ in
                alertController?.dismiss(animated: true)
            }
            alertController.addAction(okAction)
        } else {
            actions.forEach { alertController.addAction($0) }
        }
        present(alertController, animated: true, completion: completion)
    }
}

class LoaderBuilder {
    public static let shared = LoaderBuilder(animation: .loader)

    private var animation: Animation
    
    init(animation: Animation) {
        self.animation = animation
    }
    
    public func setup(animation: Animation) {
        self.animation = animation
    }

    func createLoader() -> Loader {
        let loader = Loader(animation: animation)
        return loader
    }
}

// MARK: - Loader
extension UIViewController {
    var materialiseLoader: ((Bool) -> Loader) {
        { _ in LoaderBuilder.shared.createLoader() }
    }

    public func showLoader(shouldTimeout: Bool = true) {
        showLoader(loader: materialiseLoader(shouldTimeout))
    }

    func showLoader(loader: Loader) {
        if children.contains(where: { $0 is Loader }) {
            return
        }
        add(loader)
        UIView.animate(withDuration: 0.3) {
            loader.view.alpha = 1
            loader.animateAppearing()
        }
    }

    public func hideLoader(completion: (() -> Void)? = nil) {
        children.forEach { viewController in
            if viewController is Loader {
                UIView.animate(withDuration: 0.2, animations: {
                    viewController.view.alpha = 0
                }, completion: { _ in
                    viewController.removeChildViewController()
                })
            }
        }
        completion?()
    }
}

extension UIViewController {
    func add(_ childViewController: UIViewController, in subView: UIView? = nil, enablingConstraints: Bool = true) {
        guard let containerView = subView ?? view else { return }

        childViewController.willMove(toParent: self)
        addChild(childViewController)
        childViewController.view.frame = containerView.bounds
        containerView.addSubview(childViewController.view)

        if enablingConstraints {
            childViewController.view.translatesAutoresizingMaskIntoConstraints = false
            childViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            childViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            childViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            childViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }

        childViewController.didMove(toParent: self)

        if enablingConstraints {
            containerView.layoutIfNeeded()
        }
    }

    func removeChildViewController() {
        self.willMove(toParent: nil)
        self.viewWillDisappear(true)
        self.removeFromParent()
        self.view.removeFromSuperview()
        self.view.layoutIfNeeded()
    }
}

extension UIViewController {
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }
}

public extension Reactive where Base: UIViewController {
    var backgroundColor: Binder<UIColor?> {
        Binder(self.base) { controller, color in
            guard let color = color else { return }
            controller.view.backgroundColor = color
        }
    }
}
