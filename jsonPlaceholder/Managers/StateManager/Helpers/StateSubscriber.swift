import RxSwift

final class StateSubscriber<S: Equatable> {
    var state = PublishSubject<S>()

    private lazy var stateSubscriber: BlockSubscriber<S> = BlockSubscriber(block: { [weak self] freshState in
        self?.state.onNext(freshState)
    })

    init(statePicker: @escaping (AppState) -> S ) {
        StateManager.shared.store.subscribe(stateSubscriber) { subscription in
            subscription.select { statePicker($0) }.skip(when: ==)
        }
    }

    deinit {
        StateManager.shared.store.unsubscribe(stateSubscriber)
    }
}
