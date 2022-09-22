import RxCocoa
import RxSwift

class NavigationController: UINavigationController {

    open var backBarButtonItem: UIBarButtonItem!
    let shadowIsVisible = BehaviorRelay(value: false)
    let bag = DisposeBag()

    override public var viewControllers: [UIViewController] {
        didSet {
            interactivePopGestureRecognizer?.isEnabled = viewControllers.count > 1
        }
    }

    // MARK: - Init
    override public init(rootViewController: UIViewController = UIViewController()) {
        super.init(rootViewController: rootViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Life Cycle
    override open func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupRxBindings()
        interactivePopGestureRecognizer?.delegate = self
    }

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)

        isNavigationBarHidden = false
        viewController.navigationItem.hidesBackButton = true
        
        if viewControllers.count > 1 {
            viewController.navigationItem.leftBarButtonItems = [backBarButtonItem]
        }
    }

    public func showSnackBar(with snackBarView: UIView) {
        let snackBarViewHeight = snackBarView.frame.height
        snackBarView.frame = CGRect(x: 0, y: -snackBarViewHeight, width: view.frame.width, height: snackBarViewHeight)

        let dismissGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissSnackBar(_:)))
        dismissGesture.direction = .up
        snackBarView.addGestureRecognizer(dismissGesture)

        view.addSubview(snackBarView)

        UIView.animate(withDuration: 0.5) { [snackBarView] in
            snackBarView.frame.origin.y = 0
        }
    }

    @objc private func dismissSnackBar(_ sender: UISwipeGestureRecognizer) {
        guard let senderView = sender.view else { return }
        let height = senderView.frame.height
        UIView.animate(withDuration: 0.3) { [senderView, height] in
            senderView.frame.origin.y = -height
        }
    }

    // MARK: - View
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
    }

    public func setupBackBarButtonItem(image: UIImage) {
        backBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(backBarButtonItemPressed(sender:))
        )
    }

    // *****************************************************************************************************************
    // MARK: - Rx Bindings
    private func setupRxBindings() {
        bindTheme()
        bindShadowVisibility()
    }

    private func bindTheme() {
    }

    private func bindShadowVisibility() {
        shadowIsVisible
            .subscribe(onNext: { [weak self] shadowIsVisible in
                self?.navigationBar.layer.shadowOpacity = shadowIsVisible ? 1 : 0
            })
            .disposed(by: bag)
    }

    // *****************************************************************************************************************
    // MARK: - Events
    @objc private func backBarButtonItemPressed(sender: UIBarButtonItem) {
        popViewController(animated: true)
    }

    @objc private func dismissBarButtonItemPressed(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension NavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
