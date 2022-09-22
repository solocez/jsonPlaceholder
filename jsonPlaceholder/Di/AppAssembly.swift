import Foundation
import Swinject

class AppAssembly: Assembly {
    func assemble(container: Container) {
        container.register(RestAPI.self) { _ in
            RestManager()
        }
    }
}
