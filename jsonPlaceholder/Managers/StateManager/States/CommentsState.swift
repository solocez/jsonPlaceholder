import ReSwift
import ReSwiftThunk
import RxSwift

protocol AppStateBase {
    /// - parameter changeId is to:
    /// - track State changing. Each time (sub)state changes - changeId should be incremented (by a reducer).
    /// - used in State Comparison. State structure has to conform Equatable protocol.
    /// Often implementing this protocol is difficult/tough/tricky.
    /// That's why it's much easier to track State changing (changeId incrementing) via changeId tracking.
    var changeId: Int { get set }
    var error: Error? { get set }
}

extension AppStateBase {
    var isFresh: Bool {
        changeId == 0 && error == nil
    }
}

class ErrorAction: Action {
    var error: Error
    
    init(error: Error) {
        self.error = error
    }
}

// MARK: - State
struct CommentsState: AppStateBase {
    var changeId: Int = 0
    var comments: [Int: CommentEntity] = [:]
    var error: Error?
}

// MARK: - Equatable
extension CommentsState: Equatable {
    public static func == (lhs: CommentsState, rhs: CommentsState) -> Bool {
        lhs.changeId == rhs.changeId
    }
}

// MARK: - Actions
extension CommentsState {
    struct FetchCommentAction: Action {
        var commentId: Int
        var comment: CommentEntity
    }

    final class CommentErrorAction: ErrorAction {}

    static func fetchComment(commentId: Int, restApi: RestAPI, bag: DisposeBag) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, _ in
            restApi.execute(RestRequest(path: "comments/\(commentId)", method: .get))
                .asObservable()
                .asSingle()
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { commentJson in
                    guard let entity = CommentFactory().dematerialiseComment(from: commentJson) else {
                        dispatch(CommentErrorAction(error: APIError(with: "Faile to dematerialise JSON from; \(commentJson.debugDescription)")))
                        return
                    }
                    dispatch(FetchCommentAction(commentId: commentId, comment: entity))
                }, onFailure: { error in
                    dispatch(CommentErrorAction(error: error))
                })
                .disposed(by: bag)
        }
    }
}

// MARK: - Reducer
extension CommentsState {
    static func commentsStateReducer(action: Action, state: CommentsState?) -> CommentsState {
        var state = state ?? CommentsState()
        state.error = nil
        
        switch action {
        case let action as FetchCommentAction:
            state.changeId += 1
            state.comments[action.commentId] = action.comment
        case let action as CommentErrorAction:
            state.changeId += 1
            state.error = action.error
        default:
            break
        }
        
        return state
    }
}
