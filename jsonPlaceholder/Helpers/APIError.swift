import Alamofire
import SwiftyJSON

// keys of WS response payload
private enum JsonKey {
    static let type = "type"
    static let code = "code"
    static let message = "message"
    static let errors = "errors"
    static let content = "content"
}

public protocol APIErrorData {
    var code: Int { get }
    var message: String { get }
    var payload: [String: Any] { get }
    var traceId: Any? { get }
}

open class APIError: LocalizedError, CustomDebugStringConvertible {

    public var code: Int = -1
    public var message: String = ""
    public var payload = [String: Any]()

    public var debugDescription: String {
        "\(JsonKey.type): \(JsonKey.code): \(code)\n\(JsonKey.message): \(message)"
    }

    init(with message: String) {
        self.code = 1
        self.message = message
    }

    init(json: JSON) {
        let code = json[JsonKey.code].int ?? -1

        let message = json["message"].string ?? "Unspecified message"

        // Pull errors from response JSON
        var errorMessages: [String] = []
        json[JsonKey.errors].forEach { item in
            item.1.dictionary?.forEach({ key, json in
                if let tmp = (json[JsonKey.errors].arrayObject as? [String])?.joined(separator: ", ") {
                    errorMessages.append("\(key): \(tmp)")
                }
            })
        }

        self.code = code
        self.message = message + (errorMessages.isEmpty ? "" : ("\n" + errorMessages.joined(separator: "; ")))
        self.payload = json.dictionaryValue
    }
}
