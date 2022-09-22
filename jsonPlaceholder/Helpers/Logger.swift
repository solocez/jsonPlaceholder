import Foundation
import SwiftyBeaver

public let log = SwiftyBeaver.self

public class Logger {
    public static let shared = Logger()

    public func setupSwiftyBeaver() {
        let console = ConsoleDestination()
        console.asynchronously = false
        log.addDestination(console)
    }
}
