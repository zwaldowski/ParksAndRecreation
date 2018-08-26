import XCTest

class HaitchTeeTests: XCTestCase {

    private static var document: HTMLTree!

    override class func setUp() {
        super.setUp()

        let bundle = Bundle(for: HaitchTeeTests.self)
        guard let url = bundle.url(forResource: "xml", withExtension: "html"),
            let htmlString = try? String(contentsOf: url) else {
                XCTFail("Unable to find test HTML document")
                return
        }

        document = HTMLTree(parsedFrom: htmlString, options: [ .noBlankNodes, .relaxed, .noWarnings, .noErrors, .noNetworkAccess ])
    }

    override class func tearDown() {
        document = nil

        super.tearDown()
    }

    private var document: HTMLTree {
        return HaitchTeeTests.document
    }

    func testEmptyString() {
        let document = HTMLTree(parsedFrom: "")
        XCTAssertNil(document.root)
    }

    func testRootNodeExists() {
        XCTAssertNotNil(document.root)
    }

    func testRootNodeName() {
        XCTAssertEqual(document.root?.name, "html")
    }

    func testRootNodeKind() {
        XCTAssertEqual(document.root?.kind, .element)
    }

    func testIsEmpty() {
        XCTAssertEqual(document.root?.isEmpty, false)
        XCTAssertEqual(document.root?.first?.isEmpty, false)
    }

    func testCount() {
        XCTAssertEqual(document.root?.count, 2)
        XCTAssertEqual(document.root?.first?.count, 26)
    }

    func testFirst() {
        let head = document.root?.first
        XCTAssertNotNil(head)
        XCTAssertEqual(head?.name, "head")
        XCTAssertEqual(head?.kind, .element)

        let title = head?.dropFirst().first
        XCTAssertEqual(title?.name, "title")
        XCTAssertEqual(title?.kind, .element)
        XCTAssertEqual(title?.content, "XML - Wikipedia")

        XCTAssertNil(head?.first?.first)
    }

    func testLast() {
        let body = document.root?.last
        XCTAssertNotNil(body)
        XCTAssertEqual(body?.name, "body")
        XCTAssertEqual(body?.kind, .element)

        let script = body?.last
        XCTAssertEqual(script?.name, "script")
        XCTAssertEqual(script?.kind, .element)
        XCTAssertEqual(script?.content.isEmpty, false)

        XCTAssertNil(script?.last?.last)
    }

    func testAttributes() {
        XCTAssertEqual(document.root?["class"], "client-nojs")
        XCTAssertEqual(document.root?["lang"], "en")
        XCTAssertEqual(document.root?["dir"], "ltr")
        XCTAssertNil(document.root?[""])
        XCTAssertNil(document.root?["data:does-not-exist"])
    }

    func testReflection() {
        let magicMirror = Mirror(reflecting: document)
        XCTAssertEqual(magicMirror.displayStyle, .class)
        XCTAssertNil(magicMirror.superclassMirror)
        XCTAssertNotNil(magicMirror.descendant("root", 0, 0, 2, 0) as? HTMLTree.Node)
    }

}

HaitchTeeTests.defaultTestSuite.run()
