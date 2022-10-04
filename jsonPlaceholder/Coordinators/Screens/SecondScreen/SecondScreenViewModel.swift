import RxCocoa
import RxSwift

protocol SecondScreenViewModelInterface: Loadable {
    // In
    var lowerBound: PublishRelay<Int> { get }
    var upperBound: PublishRelay<Int> { get }
    var onContinue: PublishSubject<Void> { get }

    // Out
    var commentsNumber: Int { get }

    func viewModelForComment(with idx: Int) -> CommentCellViewModel
}

final class SecondScreenViewModel: SecondScreenViewModelInterface {
    var modelResult = PublishSubject<Result<Void, Error>>()

    var lowerBound = PublishRelay<Int>()
    var upperBound = PublishRelay<Int>()
    var onContinue = PublishSubject<Void>()

    var commentsNumber: Int {
        Constants.maximumComments
    }

    var isLoading = BehaviorRelay<Bool>(value: false)
    let bag = DisposeBag()

    init(lowerBound: Int, upperBound: Int, comments: [CommentEntity]) {
        
    }

    func viewModelForComment(with idx: Int) -> CommentCellViewModel {
        
        return CommentCellViewModel()
    }
}
