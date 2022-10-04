import XCTest
import RxSwift

@testable import jsonPlaceholder

final class jsonStateTests: XCTestCase {

    let bag = DisposeBag()

    @Inject var api: RestAPI
    var commentsStateSubscriber = StateSubscriber(statePicker: { $0.commentsState })
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testFetchCommentViaState() throws {
        let stateExp = expectation(description: "stateExp")

        commentsStateSubscriber.state
            .asObservable()
            .subscribe(onNext: { freshState in
                stateExp.fulfill()
            }, onError: { error in
                XCTFail("Failed: \(error.localizedDescription)")
            })
            .disposed(by: bag)
        
        StateManager.shared.store.dispatch(CommentsState.fetchComment(commentId: 1, restApi: api, bag: bag))
        
        wait(for: [stateExp], timeout: 3)
    }
}
