import RxSwift

class ApplicationCoordinator: RxBaseCoordinator<Void> {

    var window: UIWindow

    @Inject private var api: RestAPI

    init(window: UIWindow) {
        self.window = window

        let router = ApplicationCoordinator.createRouterForHorizontalFlows()
        
        window.rootViewController = router.toPresent()
        window.makeKeyAndVisible()
        
        super.init(router: router)
    }

    override func start() -> Single<Void> {
        Single<Void>.create { [unowned self] _ in
            DispatchQueue.main.async { [unowned self] in
                self.runMainFlow()
            }
            return Disposables.create()
        }
    }
}

private extension ApplicationCoordinator {
    func runMainFlow() {
        // in order to release screens horizontal flows created before main flow we need to reset router
        let router = ApplicationCoordinator.createRouterForHorizontalFlows()
        resetCoordinator(newRouter: router)
        
//        tabbarCoordinator = TabbarFactory().makeTabbarCoordinator()
//
//        guard let coordinator = tabbarCoordinator else { return }
//        coordinate(to: coordinator, with: deeplinkOption)
//            .subscribe { result in
//                log.debug("Main Flow has ended the flow with result: \(result)")
//            } onFailure: { err in
//                log.error(err)
//            }
//            .disposed(by: bag)
//
//        coordinator.logoutAction
//            .subscribe({ [unowned self] event in
//                switch event {
//                case .next:
//                    self.restart()
//                default:
//                    break
//                }
//            })
//            .disposed(by: bag)

        //window.rootViewController = coordinator.tabbarController.toPresent()
        window.makeKeyAndVisible()
    }
    
    static func createRouterForHorizontalFlows() -> Router {
        let navigationController = NavigationController()
        let router = CoordinatorFactory().router(navigationController)
        
        return router
    }
}
