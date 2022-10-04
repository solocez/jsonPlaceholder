import RxCocoa
import RxSwift

protocol FirstScreenViewModelInterface: Loadable {
    var lowerBound: PublishRelay<Int> { get }
    var upperBound: PublishRelay<Int> { get }
    var maxComments: BehaviorRelay<Int> { get }

    var onContinue: PublishSubject<Void> { get }
    var onCancel: PublishSubject<Void> { get }
}

final class FirstScreenViewModel: FirstScreenViewModelInterface, ViewModelBase {
    typealias ViewModelResultType = (Int/*lower bound*/, Int/*upper bound*/)

    var modelResult = PublishRelay<Result<ViewModelResultType, APIError>>()

    var lowerBound = PublishRelay<Int>()
    var upperBound = PublishRelay<Int>()
    var onContinue = PublishSubject<Void>()
    var onCancel = PublishSubject<Void>()

    var maxComments = BehaviorRelay<Int>(value: Constants.maximumComments)

    var isLoading = BehaviorRelay<Bool>(value: false)

    private var lower = -1
    private var upper = -1
    private var bag = DisposeBag()
    private var bagForFetch = DisposeBag()
    @Inject private var api: RestAPI
    private var isCancelled = false

    init() {
        lowerBound
            .subscribe(onNext: { [unowned self] val in
                self.lower = val
            })
            .disposed(by: bag)
        upperBound
            .subscribe(onNext: { [unowned self] val in
                self.upper = val
            })
            .disposed(by: bag)
        onContinue
            .asObservable()
            .map { true }
            .bind(to: isLoading)
            .disposed(by: bag)

        let fetchedObs = onContinue
            .flatMap { [unowned self] in
                self.isCancelled = false
                return self.fetchComments()
            }.share()

        fetchedObs
            .map { _ in false }
            .bind(to: isLoading)
            .disposed(by: bag)

        fetchedObs
            .map { Result<ViewModelResultType, APIError>.success($0) }
            .bind(to: modelResult)
            .disposed(by: bag)

        onCancel
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                self.isCancelled = true
                self.bagForFetch = DisposeBag()
            })
            .disposed(by: bag)
    }
}

extension FirstScreenViewModel {
    func simulateDelayInterval() -> Observable<Void> {
        Observable.just(()).delay(.seconds(Constants.intervalToWaitBeforeResult), scheduler: MainScheduler.asyncInstance)
    }

    func fetchComments() -> Single<ViewModelResultType> {
        Observable.combineLatest(simulateDelayInterval(), _fetchComments().asObservable())
            .map { $0.1 }
            .asSingle()
    }

    func _fetchComments() -> Single<ViewModelResultType> {
        Single<ViewModelResultType>.create { [unowned self]  single in
            for idx in self.lower...self.upper {
                if self.isCancelled { break }
                StateManager.shared.store.dispatch(CommentsState.fetchComment(commentId: idx, restApi: self.api, bag: self.bagForFetch))
            }
            single(.success((self.lower, self.upper)))
            return Disposables.create()
        }
    }
}
