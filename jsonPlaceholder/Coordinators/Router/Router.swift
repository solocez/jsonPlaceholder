import UIKit

protocol Router: Presentable {
    func present(_ module: Presentable?)
    func present(_ module: Presentable?, animated: Bool)
    func presentOverFullScreen(_ module: Presentable?, animated: Bool)
    func presentAsPopover(_ module: Presentable?, animated: Bool)

    func push(_ module: Presentable?)
    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?)

    func popModule()
    func popModule(animated: Bool)
    // Pops only controllers from stack
    func removeModule(by screensAmount: Int, animated: Bool)
    func removeModule(to screenIdentifier: String, animated: Bool)

    func dismissModule()
    func dismissModule(animated: Bool, completion: (() -> Void)?)

    func setRootModule(_ module: Presentable?)
    func setRoot(_ rootController: UINavigationController)

    func popToRootModule(animated: Bool)
}
