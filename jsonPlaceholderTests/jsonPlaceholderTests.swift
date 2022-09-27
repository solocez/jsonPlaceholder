import Alamofire
import XCTest
import RxSwift

@testable import jsonPlaceholder

final class jsonPlaceholderTests: XCTestCase {

    let bag = DisposeBag()

    @Inject var api: RestAPI
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testUsersEndpointReachable() throws {
        let touchEndpointExp = expectation(description: "touch endpoint")
        api.execute(RestRequest(path: "", method: .get))
            .subscribe(onSuccess: { _ in
                touchEndpointExp.fulfill()
            }, onFailure: { error in
                XCTFail("Failed: \(error.localizedDescription)")
            })
            .disposed(by: bag)
            
        wait(for: [touchEndpointExp], timeout: 2)
    }

    func testParseResponse() throws {
        let touchEndpointExp = expectation(description: "touch endpoint")
        api.execute(RestRequest(path: "comments/1", method: .get))
            .subscribe(onSuccess: { jsonData in
                XCTAssertNotNil(CommentFactory().dematerialiseComment(from: jsonData))
                touchEndpointExp.fulfill()
            }, onFailure: { error in
                XCTFail("Failed: \(error.localizedDescription)")
            })
            .disposed(by: bag)
            
        wait(for: [touchEndpointExp], timeout: 2)
    }

    func testOutOfIndex() throws {
        let touchEndpointExp = expectation(description: "touch endpoint")
        api.execute(RestRequest(path: "comments/501", method: .get))
            .subscribe(onSuccess: { _ in
                touchEndpointExp.fulfill()
                XCTFail("Should have been failed")
            }, onFailure: { error in
                if let err = error as? APIError, err.code == 404 {
                    touchEndpointExp.fulfill()
                } else  {
                    XCTFail("Failed: \(error.localizedDescription)")
                }
            })
            .disposed(by: bag)
            
        wait(for: [touchEndpointExp], timeout: 2)
    }

    func testRestRequestFailes() throws {
        let endpointExp = expectation(description: "touch endpoint")
        let request = RestRequest(path: "",
                                  method: .get,
                                  parameters: RequestParameters.body(["some garbage":"garbage"]))
        api.execute(request)
            .subscribe(onSuccess: { _ in
                XCTFail("Incorrect outcome")
            }, onFailure: { error in
                endpointExp.fulfill()
            })
            .disposed(by: bag)
            
        wait(for: [endpointExp], timeout: 2)
    }

    func testFirstScreenViewModel() throws {
        let endpointExp = expectation(description: "FirstScreenViewModel")
        let vm = FirstScreenViewModel()
        vm.modelResult
            .subscribe(onNext: { modelResult  in
                switch modelResult {
                case .success(let entities):
                    XCTAssert(entities.count == 10)
                    endpointExp.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
            })
            .disposed(by: bag)
        vm.lowerBound.accept(1)
        vm.upperBound.accept(10)
        vm.onContinue.onNext(Void())
        wait(for: [endpointExp], timeout: 4)
    }
}
