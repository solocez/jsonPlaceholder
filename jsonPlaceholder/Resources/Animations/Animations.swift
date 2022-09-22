import Foundation
import Lottie

public enum Animation: String {
    case appTour1 = "apptour_1"
    case appTour2 = "apptour_2"
    case appTour3 = "apptour_3"
    case sandglass
    case babybottle
    case cat
    case collar
    case doll
    case loader = "loader"
    case legoLoader = "lego_loader"
    case loaderInfinite = "loader_infinite"
    case loaderRing = "loader_ring"
    case logoAnimation = "logo_animation"
    case paws
    case teddybear
    case tetine
    case yoopiesLoader = "YoopiesLoader"
    case worklifeLoader = "WorklifeLoader"
    case loadingDots

    public var animationView: AnimationView {
        AnimationView(name: self.rawValue, bundle: Bundle(for: GhostButton.self))
    }

    public var name: String {
        self.rawValue
    }
}
