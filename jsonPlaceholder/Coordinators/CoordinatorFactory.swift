import UIKit

final class CoordinatorFactory {
    public init() {}

    #warning("Worth to hide using Type Erasuere")
    func  applicationCoordinator(window: UIWindow) -> RxBaseCoordinator<Void> {
        ApplicationCoordinator(window: window)
    }

    func router(_ navController: NavigationController?) -> Router {
        RouterImp(rootController: navigationController(navController))
    }

    func navigationController(_ navController: NavigationController?) -> NavigationController {
        navController ?? NavigationController(rootViewController: UIViewController())
    }
}
