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
    
    func testSingleFileUnderSizeLimit() {
        
        let expectation = expectationWithDescription("Swift Expectations")
        
        
        guard let path = NSBundle.mainBundle().pathForResource("code-dazur-logo", ofType: "svg") else {
            XCTAssert(false)
            return
        }
        
        let f = DropboxFile()
        f.path = path
        f.reupload = true
        
        sut.upload([f], using: UIViewController(), to: "", returning: DropBoxResultType.None) { (shareableLinks) in
            expectation.fulfill()
            XCTAssert(true)
        }
        
        waitForExpectationsWithTimeout(20.0) { (error) in
            
        }
    }
    func testSeveralFileUnderSizeLimit() {
        
        let expectation = expectationWithDescription("Swift Expectations")
        
        
        guard let path = NSBundle.mainBundle().pathForResource("code-dazur-logo", ofType: "svg") else {
            XCTAssert(false)
            return
        }
        guard let path2 = NSBundle.mainBundle().pathForResource("code-dazur-logo2", ofType: "svg") else {
            XCTAssert(false)
            return
        }
        
        let f = DropboxFile()
        f.path = path
        f.reupload = true
        
        let f2 = DropboxFile()
        f2.path = path2
        f2.reupload = true
        
        sut.upload([f,f2], using: UIViewController(), to: "", returning: DropBoxResultType.None) { (shareableLinks) in
            expectation.fulfill()
            XCTAssert(true)
        }
        
        waitForExpectationsWithTimeout(20.0) { (error) in
            
        }
    }
    
    func testSingleFileAboveSizeLimit() {
        
        let expectation = expectationWithDescription("Swift Expectations")
        
        
        guard let path = NSBundle.mainBundle().pathForResource("test-large-file", ofType: "pdf") else {
            XCTAssert(false)
            return
        }        
        let f = DropboxFile()
        f.path = path
        f.reupload = true
        
        let size:UInt64 = 10*1024*1024
        sut.chunkSize = size
        sut.maxFileSize = size
        sut.upload([f], using: UIViewController(), to: "", returning: DropBoxResultType.None) { (shareableLinks) in
            expectation.fulfill()
            XCTAssert(true)
        }
        
        waitForExpectationsWithTimeout(600.0) { (error) in
            
        }
    }
}
