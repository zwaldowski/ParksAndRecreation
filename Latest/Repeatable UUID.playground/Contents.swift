import XCTest

class UUIDAdditionsTests: XCTestCase {

    func testSameValueSameNamespaceYieldSameUUIDs() {
        let any = UUID()
        let a = UUID(hashing: "hello", inNamespace: any)
        let b = UUID(hashing: "hello", inNamespace: any)
        let c = UUID(hashing: "hello", inNamespace: any)
        XCTAssertEqual(a, b)
        XCTAssertEqual(a, c)
        XCTAssertEqual(b, c)
    }

    func testSameValueDifferentNamespaceYieldDifferentUUIDs() {
        let one = UUID()
        let two = UUID()
        let a = UUID(hashing: "hello", inNamespace: one)
        let b = UUID(hashing: "hello", inNamespace: two)
        XCTAssertNotEqual(a, b)
    }

    func testDifferentValueSameNamespaceYieldDifferentUUIDs() {
        let any = UUID()
        let a = UUID(hashing: "hello", inNamespace: any)
        let b = UUID(hashing: "world", inNamespace: any)
        XCTAssertNotEqual(a, b)
    }

    func testKnownValueKnownNamespaceYieldKnownUUIDs() {
        let known = UUID(uuidString: "DC9ECDB8-3840-4112-91AE-44AD42B6C3A3")!
        XCTAssertEqual(UUID(hashing: "hello", inNamespace: known), UUID(uuidString: "1ED3D65F-7524-5647-A754-25E513E0070D"))
        XCTAssertEqual(UUID(hashing: "world", inNamespace: known), UUID(uuidString: "E1DE7E32-78F7-518B-8481-1F2B20E95CAA"))
    }

}

UUIDAdditionsTests.defaultTestSuite.run()
