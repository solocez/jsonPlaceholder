import SwiftyJSON

struct CommentEntity: Identifiable, Hashable, Equatable {

    static let empty = CommentEntity(postId: -1, id: -1, name: "", email: "", body: "")

    var inProgress: Bool {
        postId == -1 && id == -1 && name == "" && email == "" && body == ""
    }

    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String

    init?(from json: JSON) {
        self.postId = json["postId"].intValue
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.email = json["email"].stringValue
        self.body = json["body"].stringValue
    }

    init(postId: Int, id: Int, name: String, email: String, body: String) {
        self.postId = postId
        self.id = id
        self.name = name
        self.email = email
        self.body = body
    }
}

extension CommentEntity {
    static func == (lhs: CommentEntity, rhs: CommentEntity) -> Bool {
        lhs.id == rhs.id
    }
}

extension CommentEntity {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
