import RxSwift
import UIKit

class LoaderTimeOutView: NibLoadingView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var button: UIButton!

    let bag = DisposeBag()
    public var dismissAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        bindTheme()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
        bindTheme()
    }

    private func setupView() {
        setupTitleLabel()
        setupContentLabel()
        setupSeparatorView()
        setupButton()
    }

    private func setupTitleLabel() {
        titleLabel.text = "Timeout"
    }

    private func setupContentLabel() {
        contentLabel.text = "Content"
    }

    private func setupSeparatorView() {
        separatorView.alpha = 0.1
        separatorView.frame.size.height = 0.5
    }

    private func setupButton() {
        button.setTitle("Ok", for: .normal)
        button.addTarget(self, action: #selector(actionHandler), for: .touchUpInside)
    }

    @objc private func actionHandler() {
        dismissAction?()
    }

    private func bindTheme() {
    }
}
