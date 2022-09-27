import RxCocoa
import RxSwift

protocol SecondScreenViewModelInterface: Loadable {
    // In
    var lowerBound: PublishRelay<Int> { get }
    var upperBound: PublishRelay<Int> { get }
    var onContinue: PublishSubject<Void> { get }
}

class SecondScreenViewModel: SecondScreenViewModelInterface {
    public var modelResult = PublishSubject<Result<Void, Error>>()

    var lowerBound = PublishRelay<Int>()
    var upperBound = PublishRelay<Int>()
    var onContinue = PublishSubject<Void>()

    var isLoading = BehaviorRelay<Bool>(value: false)
    let bag = DisposeBag()

    init() {
    }
}
