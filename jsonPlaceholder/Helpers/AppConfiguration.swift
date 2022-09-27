import Foundation

enum Constants {
    enum Host {
        static let prod = "https://jsonplaceholder.typicode.com/"
        static let preprod = "https://jsonplaceholder.typicode.com/"
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
