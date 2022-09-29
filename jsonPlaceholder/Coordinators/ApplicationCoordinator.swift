import RxSwift

final class ApplicationCoordinator: RxBaseCoordinator<Void> {

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
        let vm = FirstScreenViewModel()
        vm.modelResult
            .asObservable()
            .subscribe(onNext: { modelResult in
                switch modelResult {
                case .success(_):
                    log.debug("")
                case .failure(_):
                    log.debug("")
                }
            }, onError: { error in
                
            })
            .disposed(by: bag)
        let firstScreen = ScreenFactory().createFirstScreen(viewModel: vm)
        router.setRootModule(firstScreen)
    }
    
    static func createRouterForHorizontalFlows() -> Router {
        let navigationController = NavigationController()
        return CoordinatorFactory().router(navigationController)
    }
}
