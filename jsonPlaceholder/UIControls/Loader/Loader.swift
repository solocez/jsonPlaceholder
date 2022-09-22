import Lottie
import RxSwift

final class Loader: UIViewController {
    private var containerView: UIView?
    private var lottieView: AnimationView?
    private var loadingLabel: UILabel?
    
    private var animation: Animation
    private let bag = DisposeBag()

    public init(animation: Animation) {
        self.animation = animation
        super.init(nibName: nil, bundle: Loader.bundle)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupRxBindings()

        view.alpha = 0
        let scale = CGAffineTransform(scaleX: 0.70, y: 0.70)
        lottieView?.layer.setAffineTransform(scale)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lottieView?.play(completion: nil)
    }
    
    public func animateAppearing() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.view.alpha = 1
            self.lottieView?.layer.setAffineTransform(CGAffineTransform.identity)
        }, completion: { [weak self] _ in
            self?.lottieView?.play()
        })
    }

    public func animateDisappearing() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: { [weak self] _ in
            self?.dismiss(animated: false)
        })
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        lottieView?.stop()
    }
}

// MARK: - View
private extension Loader {
    func setupView() {
        modalPresentationStyle = .overCurrentContext
        view.isOpaque = false

        setupContainerView()
        setupLottieView(animation: animation)
        setupLoadingLabel()
        setupShadow()
    }

    func setupContainerView() {
        let containerView = UIView()
        view.addSubview(containerView)

        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        containerView.clipsToBounds = true

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.containerView = containerView
    }

    func setupLottieView(animation: Animation) {
        guard let containerView = containerView else { return }
        let lottieView = animation.animationView
        lottieView.loopMode = .loop
        view.addSubview(lottieView)

        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lottieView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        lottieView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 30).isActive = true
        lottieView.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -30).isActive = true
        lottieView.heightAnchor.constraint(equalTo: lottieView.widthAnchor).isActive = true

        self.lottieView = lottieView
    }

    func setupLoadingLabel() {
        guard let containerView = containerView, let lottieView = lottieView else { return }
        let loadingLabel = UILabel()
        //loadingLabel.text = Loc.Generics.Loader.Normal.title
        loadingLabel.adjustsFontSizeToFitWidth = true
        //loadingLabel.font = Font.Montserrat.medium(16)
        loadingLabel.numberOfLines = 3
        loadingLabel.textAlignment = .center
        containerView.addSubview(loadingLabel)

        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingLabel.topAnchor.constraint(equalTo: lottieView.bottomAnchor, constant: 20),
            loadingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            loadingLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        self.loadingLabel = loadingLabel
    }

    func setupShadow() {
        containerView?.clipsToBounds = false
        containerView?.layer.setShadow(for: .loader)
    }

    func setupTimeOutView() {
        guard let containerView = containerView else { return }

        containerView.alpha = 0
        lottieView?.removeFromSuperview()
        loadingLabel?.removeFromSuperview()
        let timeOutView = LoaderTimeOutView(frame: .zero)
        timeOutView.dismissAction = { [weak self] in
            self?.animateDisappearing()
        }
        timeOutView.place(in: containerView)
        view.layoutSubviews()

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            containerView.alpha = 1
        })
    }

    func setupTimeOutLabel() {
        guard let containerView = containerView,
            let loadingLabel = loadingLabel
            else { return }

        loadingLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
    }

    func setupRxBindings() {
        bindTheme()
    }

    func bindTheme() {
    }
}
