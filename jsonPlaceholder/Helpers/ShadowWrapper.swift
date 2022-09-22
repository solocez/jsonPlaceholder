import UIKit

public struct ShadowConfiguration {
    let color: CGColor
    let opacity: Float
    let offset: CGSize
    let radius: CGFloat

    init(offsetY: CGFloat = 0,
         offsetX: CGFloat = 0,
         opacity: Float = 1,
         radius: CGFloat = 7,
         color: UIColor = ThemeColors.grayShadow,
         colorAlpha: CGFloat = 0.1) {
        self.color = color.withAlphaComponent(colorAlpha).cgColor
        self.opacity = opacity
        self.offset = CGSize(width: offsetX, height: offsetY)
        self.radius = radius
    }
}

public enum ShadowType {
    case dashboardAdCard
    case searchCard
    case menuItem
    case floatingTop
    case floatingBottom
    case loader
    case innerShadow

    var config: ShadowConfiguration {
        switch self {
        case .dashboardAdCard: return ShadowConfiguration(offsetY: 3, radius: 7)
        case .searchCard: return ShadowConfiguration(offsetY: 2)
        case .menuItem: return ShadowConfiguration(radius: 3)
        case .floatingTop: return ShadowConfiguration(offsetY: 2, radius: 4)
        case .floatingBottom: return ShadowConfiguration(offsetY: -2, radius: 4)
        case .loader: return ShadowConfiguration()
        case .innerShadow: return ShadowConfiguration(radius: 5)
        }
    }
}

public extension CALayer {
    func setShadow(for type: ShadowType) {
        shadowColor = type.config.color
        shadowOffset = type.config.offset
        shadowOpacity = type.config.opacity
        shadowRadius = type.config.radius
    }
}
