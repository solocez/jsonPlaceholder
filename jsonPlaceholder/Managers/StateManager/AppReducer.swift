import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    switch action {
    default:
        return AppState(commentsState: CommentsState.commentsStateReducer(action: action, state: state?.commentsState))
    }
}
