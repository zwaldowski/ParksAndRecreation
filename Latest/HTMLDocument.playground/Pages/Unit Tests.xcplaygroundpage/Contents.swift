import XCTest

class HTMLDocumentTests: XCTestCase {

    private static var html: HTMLDocument.Node!

    override class func setUp() {
        super.setUp()

        let bundle = Bundle(for: HTMLDocumentTests.self)
        guard let url = bundle.url(forResource: "xml", withExtension: "html"),
            let htmlString = try? String(contentsOf: url) else {
                XCTFail("Unable to find test HTML document")
                return
        }

        html = HTMLDocument.parse(htmlString)
        XCTAssertNotNil(html)
    }

    override class func tearDown() {
        html = nil

        super.tearDown()
    }

    private var html: HTMLDocument.Node {
        return HTMLDocumentTests.html
    }

    func testDoesNotParseEmptyString() {
        let empty = HTMLDocument.parse("")
        XCTAssertNil(empty)
    }

    func testParsesTextFragment() {
        let fragment = HTMLDocument.parse("Lorem ipsum dolor amet")
        XCTAssertNotNil(fragment)
    }

    func testName() {
        XCTAssertEqual(html.name, "html")
    }

    func testKind() {
        XCTAssertEqual(html.kind, .element)
    }

    func testCollectionIsEmpty() {
        XCTAssertFalse(html.isEmpty)
        XCTAssertEqual(html.first?.isEmpty, false)
        XCTAssertEqual(HTMLDocument.parse("<html />")?.isEmpty, true)
    }

    func testCollectionCount() {
        XCTAssertEqual(html.count, 2)
        XCTAssertEqual(html.first?.count, 26)
        XCTAssertEqual(HTMLDocument.parse("<html />")?.count, 0)
    }

    func testCollectionFirst() {
        let head = html.first
        XCTAssertNotNil(head)
        XCTAssertEqual(head?.name, "head")
        XCTAssertEqual(head?.kind, .element)

        let title = head?.dropFirst().first
        XCTAssertEqual(title?.name, "title")
        XCTAssertEqual(title?.kind, .element)
        XCTAssertEqual(title?.content, "XML - Wikipedia")

        XCTAssertNil(head?.first?.first)

        let body = html.dropFirst().first
        XCTAssertNotNil(body)
        XCTAssertEqual(body?.name, "body")
        XCTAssertEqual(body?.kind, .element)

        let scriptContents = body?.dropFirst(11).first?.first
        XCTAssertEqual(scriptContents?.name, "")
        XCTAssertEqual(scriptContents?.kind, .characterDataSection)
        XCTAssertEqual(scriptContents?.content.isEmpty, false)

        let footer = body?.dropFirst(9).first
        XCTAssertEqual(footer?.name, "div")
        XCTAssertEqual(footer?.kind, .element)
        XCTAssertEqual(footer?.content.isEmpty, false)
        XCTAssertEqual(footer?["id"], "footer")

        XCTAssertNil(footer?.dropFirst(5).first?.first)
    }

    func testAttributes() {
        XCTAssertEqual(html["class"], "client-nojs")
        XCTAssertEqual(html["lang"], "en")
        XCTAssertEqual(html["dir"], "ltr")
        XCTAssertNil(html[""])
        XCTAssertNil(html["data:does-not-exist"])
    }

    func testContentForEmptyElement() {
        let fragment = HTMLDocument.parse("<img />")
        XCTAssertNotNil(fragment)
        XCTAssertEqual(fragment?.content.isEmpty, true)
    }

    func testDebugDescription() {
        let description = String(reflecting: html)
        XCTAssert(description.hasPrefix("<html"))
        XCTAssert(description.hasSuffix("</html>"))

        let fragment = HTMLDocument.parse("Lorem ipsum dolor amet")
        let fragmentDescription = fragment.map(String.init(reflecting:)) ?? ""
        XCTAssertNotNil(fragment)
        XCTAssert(fragmentDescription.hasPrefix("<p"))
        XCTAssert(fragmentDescription.hasSuffix("</p>"))
    }

    func testReflection() {
        let magicMirror = Mirror(reflecting: html)
        XCTAssertEqual(magicMirror.displayStyle, .struct)
        XCTAssertNil(magicMirror.superclassMirror)
        XCTAssertNil(magicMirror.descendant(0, 0, 2, 0))
    }

    func testDocumentReflection() {
        let magicMirror = Mirror(reflecting: html.document)
        XCTAssertEqual(magicMirror.displayStyle, .class)
        XCTAssertNil(magicMirror.superclassMirror)
        XCTAssertNil(magicMirror.descendant(0, 0, 2, 0))
    }

}

HTMLDocumentTests.defaultTestSuite.run()
