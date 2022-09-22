import Foundation

enum Constants {
    enum Host {
        static let prod = "https://randomuser.me/api/"
        static let preprod = "https://randomuser.me/api/"
    }
}


protocol AppConfigurable {
    var host: String { get }
}

class AppConfiguration: AppConfigurable {

    static var shared = AppConfiguration(host: Constants.Host.preprod)

    let host: String

    init(host: String) {
        self.host = host
    }
}
