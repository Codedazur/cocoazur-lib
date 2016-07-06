import UIKit
import XCTest
import Cocoazur_Dropbox

class Tests: XCTestCase {
    
    var sut:DropboxProxy = DropboxProxy()
    override func setUp() {
        sut = DropboxProxy()
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let expectation = expectationWithDescription("Swift Expectations")
        
        guard let path = NSBundle.mainBundle().pathForResource("code-dazur-logo", ofType: "svg") else {return}
        
        let f = DropboxFile()
        f.path = path
        f.reupload = true
        
        sut.upload([f], using: UIViewController(), to: "", returning: DropBoxResultType.None) { (shareableLinks) in
            expectation.fulfill()
            XCTAssert(true)
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            
        }
    }
}
