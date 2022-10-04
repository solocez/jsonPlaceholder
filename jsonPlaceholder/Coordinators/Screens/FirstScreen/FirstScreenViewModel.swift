import RxCocoa
import RxSwift

protocol FirstScreenViewModelInterface: Loadable {
    // In
    var lowerBound: PublishRelay<Int> { get }
    var upperBound: PublishRelay<Int> { get }
    var onContinue: PublishSubject<Void> { get }
    var onCancel: PublishSubject<Void> { get }

    // Out
    var maxComments: BehaviorRelay<Int> { get }
}

final class FirstScreenViewModel: FirstScreenViewModelInterface, ViewModelBase {
    typealias ViewModelResultType = (Int/*lower bound*/, Int/*upper bound*/, [CommentEntity])

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
                self.fetchComments()
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
            var observables: [Observable<Data>] = []
            for idx in self.lower...self.upper {
                let idxObs = self.api.execute(RestRequest(path: "comments/\(idx)", method: .get)).asObservable()
                observables.append(idxObs)
            }
            Observable.combineLatest(observables)
                .subscribe(onNext: { [unowned self] jsons in
                    let entities = jsons
                        .map { CommentFactory().dematerialiseComment(from: $0) }
                        .compactMap { $0 }
                    single(.success((self.lower, self.upper, entities)))
                }, onError: { error in
                    single(.failure(error))
                })
                .disposed(by: self.bagForFetch)
            return Disposables.create()
        }
    }
}
