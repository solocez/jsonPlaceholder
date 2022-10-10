import RxCocoa
import RxSwift

protocol SecondScreenViewModelInterface: Loadable {
    // In
    var lowerBound: Int { get }
    var upperBound: Int { get }
    var commentsNumber: Int { get }

    // Out
    var freshDataArrived: PublishSubject<CommentsState> { get }

    func entityFor(index idx: Int) -> CommentEntity?
}

final class SecondScreenViewModel: SecondScreenViewModelInterface {
    var lowerBound: Int
    var upperBound: Int

    var commentsNumber: Int {
        Constants.maximumComments
    }
    var freshDataArrived = PublishSubject<CommentsState>()

    var isLoading = BehaviorRelay<Bool>(value: false)
    let bag = DisposeBag()

    @Inject private var api: RestAPI
    private var commentsStateSubscriber = StateSubscriber(statePicker: { $0.commentsState })

    init(lowerBound: Int, upperBound: Int) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound

        commentsStateSubscriber
            .state
            .bind(to: freshDataArrived)
            .disposed(by: bag)
    }

    func entityFor(index idx: Int) -> CommentEntity? {
        if let entity = StateManager.shared.store.state.commentsState.comments[idx], !entity.inProgress {
            return entity
        }
        StateManager.shared.store.dispatch(CommentsState.fetchComment(commentId: idx, restApi: api, bag: bag))
        return nil
    }
}
