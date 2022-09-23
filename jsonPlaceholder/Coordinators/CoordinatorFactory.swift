import UIKit

class CoordinatorFactory {
    public init() {}

    func router(_ navController: NavigationController?) -> Router {
        RouterImp(rootController: navigationController(navController))
    }

    func navigationController(_ navController: NavigationController?) -> NavigationController {
        navController ?? NavigationController(rootViewController: UIViewController())
    }
}
