import Foundation
@_exported import XCTest

private class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }
}

public struct TestRunner {

    public init() {}

    private static let setupObserver: Void = {
        let observer = PlaygroundTestObserver()
        let center = XCTestObservationCenter.shared()
        center.addTestObserver(observer)
    }()
    
    public func runTests(from testClass: XCTestCase.Type) {
        _ = TestRunner.setupObserver
        print("Running test suite \(testClass)")

        let testSuite = testClass.defaultTestSuite()
        testSuite.run()

        let run = testSuite.testRun as! XCTestSuiteRun
        print("Ran \(run.executionCount) tests in \(run.testDuration)s with \(run.totalFailureCount) failures")
    }
    
}
