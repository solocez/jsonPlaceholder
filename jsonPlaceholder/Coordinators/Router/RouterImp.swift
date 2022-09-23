import UIKit

class RouterImp: Router {
    private weak var rootController: UINavigationController?
    private var completions: [UIViewController : () -> Void]

    init(rootController: UINavigationController) {
        self.rootController = rootController
        completions = [:]
    }

    func toPresent() -> UIViewController? {
        rootController
    }

    func present(_ module: Presentable?) {
        present(module, animated: true)
    }

    func present(_ module: Presentable?, animated: Bool) {
        guard let controller = module?.toPresent() else { return }
        rootController?.present(controller, animated: animated, completion: nil)
    }

    func dismissModule() {
        dismissModule(animated: true, completion: nil)
    }

    func dismissModule(animated: Bool, completion: (() -> Void)?) {
        guard let root = rootController?.topViewController else { return }
        RouterImp.getLastPresentedViewController(in: root).dismiss(animated: animated, completion: completion)
    }

    func push(_ module: Presentable?) {
        push(module, animated: true)
    }

    func push(_ module: Presentable?, animated: Bool) {
        push(module, animated: animated, completion: nil)
    }

    func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?) {
        guard
            let controller = module?.toPresent(),
            (controller is UINavigationController == false)
            else { assertionFailure("Deprecated push UINavigationController."); return }

        if let completion = completion {
            completions[controller] = completion
        }
        rootController?.pushViewController(controller, animated: animated)
    }

    func popModule() {
        popModule(animated: true)
    }

    func popModule(animated: Bool) {
        if let controller = rootController?.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }
    
    func removeModule(by screensAmount: Int, animated: Bool) {
        guard let rootController = self.rootController,
            let topController = UIApplication.topViewController(),
            rootController.viewControllers.count > screensAmount,
            !topController.isModal else {
            return assertionFailure("ViewControllers are not enough for this operation or top controller is modal")
        }
        
        var newStack = rootController.viewControllers
        newStack.removeLast(screensAmount)
        rootController.setViewControllers(newStack, animated: animated)
    }
    
    func removeModule(to screenIdentifier: String, animated: Bool) {
        guard let rootController = self.rootController,
            let topController = UIApplication.topViewController(),
            !topController.isModal else {
            return assertionFailure("ViewControllers are not enough for this operation or top controller is modal")
        }
        
        var newStack = rootController.viewControllers
        var index: Int?
        newStack.enumerated().forEach({ idx, controller in
            if controller.identifier == screenIdentifier {
                index = idx
            }
        })
        
        guard let idx = index else {
            log.error("There is no \(screenIdentifier) controller to pop")
            return
        }
        
        let screensCount = (rootController.viewControllers.count - 1) - idx
        newStack.removeLast(screensCount)
        rootController.setViewControllers(newStack, animated: animated)
    }

    func setRootModule(_ module: Presentable?) {
        guard let controller = module?.toPresent() else { return }
        rootController?.setViewControllers([controller], animated: false)
    }
    
    func setRoot(_ rootController: UINavigationController) {
        self.rootController = rootController
    }

    func popToRootModule(animated: Bool) {
        if let controllers = rootController?.popToRootViewController(animated: animated) {
            controllers.forEach { controller in
                runCompletion(for: controller)
            }
        }
    }

    private func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }

    func presentOverFullScreen(_ module: Presentable?, animated: Bool) {
        guard let controller = module?.toPresent(),
            let root = rootController?.topViewController
            else { return }
        controller.modalPresentationStyle = .fullScreen
        RouterImp.getLastPresentedViewController(in: root).present(controller, animated: animated)
    }

    func presentAsPopover(_ module: Presentable?, animated: Bool) {
        guard let controller = module?.toPresent(),
            let root = rootController?.topViewController
            else { return }
        controller.modalPresentationStyle = .custom
        RouterImp.getLastPresentedViewController(in: root).present(controller, animated: animated)
    }

    static func getLastPresentedViewController(in viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return RouterImp.getLastPresentedViewController(in: presented)
        }
        return viewController
    }
}
