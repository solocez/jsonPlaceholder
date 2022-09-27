import Foundation
import SwiftyJSON

final class CommentFactory {
    init() {}

    func dematerialiseComment(from: Data) -> CommentEntity? {
        do {
            let json = try JSON(data: from)
            return CommentEntity(from: json)
        } catch {
            log.warning("FAILED TO PARSE ENTITY FROM DATA:\(from)")
            return nil
        }
    }
}
