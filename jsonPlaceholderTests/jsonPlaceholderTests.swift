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

    func testRestRequestFailes() throws {
        let endpointExp = expectation(description: "touch endpoint")
        let request = RestRequest(path: "",
                                  method: .get,
                                  parameters: RequestParameters.body(["some garbage":"garbage"]))
        api.execute(request)
            .subscribe(onSuccess: { _ in
                XCTFail("Incorrect outcome")
            }, onFailure: { error in
                if case AFError.urlRequestValidationFailed = error {
                    endpointExp.fulfill()
                } else {
                    XCTFail("Failed: \(error.localizedDescription)")
                }
            })
            .disposed(by: bag)
            
        wait(for: [endpointExp], timeout: 2)
    }
}
