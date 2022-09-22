import UIKit

class GhostButton: UIButton {

    // MARK: - Inspectable elements

    @IBInspectable private var cornerRadius: CGFloat = 2 {
        didSet {
            updateCornerRadius()
        }
    }

    @IBInspectable private var ghostColor: UIColor = .black {
        didSet {
            updateGhostColor()
        }
    }

    @IBInspectable private var borderWidth: CGFloat = 1 {
        didSet {
            updateBorderWidth()
        }
    }

    // MARK: - Override variable

    override open var isEnabled: Bool {
        didSet {
            titleLabel?.alpha = 1
            alpha = isEnabled ? 1 : 0.5
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            titleLabel?.alpha = 1
            alpha = isHighlighted ? 0.5 : 1
        }
    }

    // MARK: - Inits

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        updateCornerRadius()
        updateGhostColor()
        updateBorderWidth()
    }

    // MARK: - Update methods

    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
    }

    private func updateGhostColor() {
        layer.borderColor = ghostColor.cgColor
        setTitleColor(ghostColor, for: .normal)
        setTitleColor(ghostColor, for: .selected)
        setTitleColor(ghostColor, for: .highlighted)
        titleLabel?.font = UIFont(name: "Avenir-Medium", size: 16)
    }

    private func updateBorderWidth() {
        layer.borderWidth = borderWidth
    }
}
