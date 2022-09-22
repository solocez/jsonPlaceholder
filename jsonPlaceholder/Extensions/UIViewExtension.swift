import RxCocoa
import RxSwift

enum ContraintsSet {
    case top(value: CGFloat = 0, safeArea: Bool = false)
    case bottom(value: CGFloat = 0, safeArea: Bool = false)
    case leading(value: CGFloat = 0)
    case trailing(value: CGFloat = 0)
    case centerX(value: CGFloat)
    case centerY(value: CGFloat)
    case height(value: CGFloat, isEqual: Bool)
    case width(value: CGFloat, isEqual: Bool)
    
    public static var allAround: [ContraintsSet] {
        [.top(), .bottom(), .leading(), .trailing()]
    }
}

extension UIRectCorner {
    func mask() -> CACornerMask {
        var result = CACornerMask()
        if self.contains(.topLeft) {
            result.insert(.layerMinXMinYCorner)
        }
        if self.contains(.topRight) {
            result.insert(.layerMaxXMinYCorner)
        }
        if self.contains(.bottomLeft) {
            result.insert(.layerMinXMaxYCorner)
        }
        if self.contains(.bottomRight) {
            result.insert(.layerMaxXMaxYCorner)
        }
        if self.contains(.allCorners) {
            result = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return result
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.parentViewController
        } else {
            return nil
        }
    }

    var currentRotationAngle: CGFloat {
        atan2(self.transform.b, self.transform.a)
    }

    func place(in view: UIView, withVerticalConstraint vert: CGFloat = 0, andHorizontalConstraints hoz: CGFloat = 0) {
        view.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor, constant: vert).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: vert).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hoz).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: hoz).isActive = true
    }
    
    /// Places self into 'view' with a given 'constraints'
    /// - Parameters:
    ///   - view: parent view
    ///   - constraints: set of contraints. By default used basic to satisfy best position
    func place(in view: UIView, constraints: [ContraintsSet] = ContraintsSet.allAround) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        for constraint in constraints {
            switch constraint {
            case let .top(value, safeArea):
                if safeArea {
                    topAnchor.constraint(equalTo: view.safeTopAnchor, constant: value).isActive = true
                } else {
                    topAnchor.constraint(equalTo: view.topAnchor, constant: value).isActive = true
                }
            case let .bottom(value, safeArea):
                if safeArea {
                    bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -value).isActive = true
                } else {
                    bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -value).isActive = true
                }
            case .leading(let value):
                leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: value).isActive = true
            case .trailing(let value):
                trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -value).isActive = true
            case .centerX(let value):
                centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: value).isActive = true
            case .centerY(let value):
                centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: value).isActive = true
            case let .height(value, isEqual):
                if isEqual {
                    heightAnchor.constraint(equalTo: view.heightAnchor, constant: value).isActive = true
                } else {
                    heightAnchor.constraint(equalToConstant: value).isActive = true
                }
            case let .width(value, isEqual):
                if isEqual {
                    widthAnchor.constraint(equalTo: view.widthAnchor, constant: value).isActive = true
                } else {
                    widthAnchor.constraint(equalToConstant: value).isActive = true
                }
            }
        }
    }

    /// With absoluteAngle in radian
    func rotate(to absoluteAngle: CGFloat) {
        self.transform = self.transform.rotated(by: -currentRotationAngle + absoluteAngle)
    }

    /**
     * Aplly a round shape on the view. Width and height must be equal for a perfect result
     */
    func round(inset: CGFloat = 0) {
        layer.cornerRadius = (frame.height - inset) / 2
        clipsToBounds = true
    }
    
    func round(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    /**
     * Apply a border arround the view.
     *
     * - Parameter thickness: value of the thickness of the border
     * - Parameter color: value of the border's color
     */
    func addBorder(thickness: CGFloat, color: UIColor) {
        self.layer.borderWidth = thickness
        self.layer.borderColor = color.cgColor
    }

    /**
     * Apply a gradient border arround the view.
     *
     * - Parameter thickness: value of the thickness of the border
     * - Parameter colors: values of the border's color
     */
    func addGradientBorder(thickness: CGFloat, gradientColors: [UIColor]) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: frame.size)
        gradient.colors = gradientColors.map { $0.cgColor }

        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.layer.addSublayer(gradient)
    }
    
    /**
     * Round a Specific border
     *
     * - Parameter corners: The corners that need to be rounded
     * - Parameter radius: value of the radius border
     * - Parameter shadow: set of shadow settings. WARNING: View shouldn't has 'backgroundColor'
     */
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, shadow: ShadowSettings? = nil) {
        if #available(iOS 11, *) {
            layer.maskedCorners = corners.mask()
            layer.cornerRadius = radius
        } else {
            let path = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
        if let shadowSettings = shadow {
            layer.shadowRadius = shadowSettings.radius
            layer.shadowOffset = shadowSettings.offset
            layer.shadowOpacity = shadowSettings.opacity
            layer.cornerRadius = radius
        }
    }

    var safeFrame: CGRect {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.layoutFrame
        }
        return frame
    }

    func setBorders(toEdges edges: [UIRectEdge],
                    withColor color: UIColor,
                    thickness: CGFloat,
                    inset: CGFloat = 0) {
        subviews.forEach {
            if let borderView = $0 as? BorderView {
                borderView.removeFromSuperview()
            }
        }

        if edges.contains(.all) {
            addSidedBorder(toEdge: [.left, .right, .top, .bottom], withColor: color, thickness: thickness, inset: inset)
        }
        if edges.contains(.left) {
            addSidedBorder(toEdge: [.left], withColor: color, thickness: thickness, inset: inset)
        }
        if edges.contains(.right) {
            addSidedBorder(toEdge: [.right], withColor: color, thickness: thickness, inset: inset)
        }
        if edges.contains(.top) {
            addSidedBorder(toEdge: [.top], withColor: color, thickness: thickness, inset: inset)
        }
        if edges.contains(.bottom) {
            addSidedBorder(toEdge: [.bottom], withColor: color, thickness: thickness, inset: inset)
        }
    }

    private func addSidedBorder(toEdge edges: [RectangularEdges],
                                withColor color: UIColor,
                                thickness: CGFloat,
                                inset: CGFloat = 0) {
        for edge in edges {
            let border = BorderView(frame: .zero)
            border.backgroundColor = color
            addSubview(border)
            border.translatesAutoresizingMaskIntoConstraints = false
            switch edge {
            case .left:
                NSLayoutConstraint.activate([
                    border.leftAnchor.constraint(equalTo: self.leftAnchor, constant: inset),
                    border.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
                    border.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset),
                    NSLayoutConstraint(item: border,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .width,
                                       multiplier: 1,
                                       constant: thickness)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    border.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -inset),
                    border.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
                    border.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset),
                    NSLayoutConstraint(item: border,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .width,
                                       multiplier: 1,
                                       constant: thickness)
                ])
            case .top:
                NSLayoutConstraint.activate([
                    border.leftAnchor.constraint(equalTo: self.leftAnchor, constant: inset),
                    border.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -inset),
                    border.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
                    NSLayoutConstraint(item: border,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .height,
                                       multiplier: 1,
                                       constant: thickness)
                ])
            case .bottom:
                NSLayoutConstraint.activate([
                    border.leftAnchor.constraint(equalTo: self.leftAnchor, constant: inset),
                    border.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -inset),
                    border.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset),
                    NSLayoutConstraint(item: border,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .height,
                                       multiplier: 1,
                                       constant: thickness)
                ])
            }
        }
    }

    private enum RectangularEdges {
        case left
        case right
        case top
        case bottom
    }
}

// https://stackoverflow.com/questions/17355280/how-to-add-a-border-just-on-the-top-side-of-a-uiview
private class BorderView: UIView {} // dummy class to help us differentiate among border views and other views
// to enabling us to remove existing borders and place new ones

public extension UIView {
    func fadeIn(duration: Foundation.TimeInterval = 0.5, delay: Foundation.TimeInterval = 0.0,
                completion: @escaping ((Bool) -> Void) = { _ -> Void in }) {
        self.alpha = 0.0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }

    func fadeOut(duration: Foundation.TimeInterval = 0.5, delay: Foundation.TimeInterval = 0.0,
                 completion: @escaping (Bool) -> Void = { _ -> Void in }) {
        self.alpha = 1.0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }) { _ in
            self.isHidden = true
            completion(true)
        }
    }
}

extension UIView {
    func addShadow(offset: CGSize, color: UIColor = ThemeColors.grayShadow, opacity: Float = 0.3, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}

public extension UIView {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }

    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        }
        return self.leadingAnchor
    }

    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        }
        return self.trailingAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }

    var safeCenterYAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.centerYAnchor
        }
        return self.centerYAnchor
    }
}

public extension Reactive where Base: UIView {
    var sidedBorderColor: Binder<UIColor> {
        Binder(self.base) { ownView, color in
            ownView.subviews.forEach {
                if let borderView = $0 as? BorderView {
                    borderView.backgroundColor = color
                }
            }
        }
    }

    var borderColor: Binder<UIColor> {
        Binder(self.base) { ownView, color in
            ownView.layer.borderColor = color.cgColor
        }
    }
}

public struct ShadowSettings {
    let color: UIColor
    let offset: CGSize
    let opacity: Float
    let radius: CGFloat
    
    public init(radius: CGFloat, opacity: Float, color: UIColor = .black, offset: CGSize = .zero) {
        self.radius = radius
        self.opacity = opacity
        self.color = color
        self.offset = offset
    }
}
