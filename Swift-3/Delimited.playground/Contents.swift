final class DelimitedTests: XCTestCase {

    private enum Fields: String, CaseIterable, CustomStringConvertible {

        case a, b, c, d

        static let all: [Fields] = [ .a, .b, .c, .d ]

        var description: String {
            return rawValue
        }

    }

    private enum Constants {
        static let field1 = "field1"
        static let field2 = "field2"
        static let field3 = "field3"
        static let field4 = "\u{1E1F}\u{012B}\u{1EC5}\u{0142}\u{0111}\u{2783}"
        static let multiLineField = "\(field1)\n\(field2)"
        static let comment = "# Secret: Field 1 is a jerk"
    }

    private func assertDelimited(_ string: @autoclosure() throws -> String, by delimiter: Delimiter = .comma, matches: @autoclosure() throws -> [[Fields: String]], file: StaticString = #file, line: UInt = #line) {
        do {
            let (value1, value2) = (try string(), try matches())
            let parsed = Array(Delimited(string: value1, fieldsBy: delimiter, of: Fields.self))
            XCTAssert(parsed.elementsEqual(value2, by: ==), "(\"\(parsed)\") is not equal to (\"\(value2)\")", file: file, line: line)
        } catch {
            XCTFail("threw error \"\(error)\"", file: file, line: line)
        }
    }

    func testSimple() {
        assertDelimited("\(Constants.field1),\(Constants.field2),\(Constants.field3),\(Constants.field4)", matches: [
            [ Fields.a: Constants.field1, Fields.b: Constants.field2, Fields.c: Constants.field3, Fields.d: Constants.field4 ]
        ])
    }

    func testEmptyFields() {
        assertDelimited("a\t\tc\td", by: .tab, matches: [
            [ Fields.a: "a", Fields.b: "", Fields.c: "c", Fields.d: "d" ]
        ])
    }

    func testSimpleWithMismatchedInnerQuote() {
        assertDelimited("\(Constants.field1),\(Constants.field2),\"\(Constants.field3),\(Constants.field4)", matches: [
            [ Fields.a: Constants.field1, Fields.b: Constants.field2, Fields.c: "" ]
        ])
    }

    func testSimpleWithDoubledInnerQuote() {
        assertDelimited("\(Constants.field1),\(Constants.field2),\"\(Constants.field3)\",\(Constants.field4)", matches: [
            [ Fields.a: Constants.field1, Fields.b: Constants.field2, Fields.c: Constants.field3, Fields.d: Constants.field4 ]
        ])
    }

    func testSimpleMultiline() {
        assertDelimited([
            "\(Constants.field1),\(Constants.field2),\(Constants.field3),\(Constants.field4)",
            "\(Constants.field1),\(Constants.field2),\(Constants.field3),\(Constants.field4)"
        ].joined(separator: "\n"), matches: [
            [ Fields.a: Constants.field1, Fields.b: Constants.field2, Fields.c: Constants.field3, Fields.d: Constants.field4 ],
            [ Fields.a: Constants.field1, Fields.b: Constants.field2, Fields.c: Constants.field3, Fields.d: Constants.field4 ]
        ])
    }

    func testQuotedDelimiter() {
        assertDelimited("\(Constants.field1),\"\(Constants.field2),\(Constants.field3)\"", matches: [
            [ Fields.a: Constants.field1, Fields.b: "\(Constants.field2),\(Constants.field3)" ]
        ])
    }

    func testQuotedMultiline() {
        assertDelimited([
            "\(Constants.field1),\"\(Constants.multiLineField)\"",
            Constants.field2
        ].joined(separator: "\n"), matches: [
            [ Fields.a: Constants.field1, Fields.b: Constants.multiLineField ],
            [ Fields.a: Constants.field2 ]
        ])
    }

    func testWhitespace() {
        assertDelimited("\(Constants.field1),   \(Constants.field2),\(Constants.field3)   ", matches: [
            [ Fields.a: Constants.field1, Fields.b: "   \(Constants.field2)", Fields.c: "\(Constants.field3)   " ]
        ])
    }

    func testCommentsNotSupported() {
        assertDelimited([
            Constants.field1,
            Constants.comment
        ].joined(separator: "\n"), matches: [
            [ Fields.a: Constants.field1 ],
            [ Fields.a: Constants.comment ]
        ])
    }

    func testTrailingNewline() {
        assertDelimited("\(Constants.field1),\(Constants.field2)\n", matches: [
            [ Fields.a: Constants.field1, Fields.b: Constants.field2 ]
        ])
    }

    func testTrailingSpace() {
        assertDelimited("\(Constants.field1),\(Constants.field2)\n ", matches: [
            [ Fields.a: Constants.field1, Fields.b: Constants.field2 ],
            [ Fields.a: " " ]
        ])
    }

    func testSimpleTabbed() {
        assertDelimited([
            "1,a\t1,b\t1,c\t1,d",
            "2,a\t2,b\t2,c\t2,d",
            "3,a\t3,b\t3,c\t3,d",
            "4,a\t4,b\t4,c\t4,d",
            "5,a\t5,b\t5,c\t5,d"
        ].joined(separator: "\n"), by: "\t", matches: [
            [ Fields.a: "1,a", Fields.b: "1,b", Fields.c: "1,c", Fields.d: "1,d" ],
            [ Fields.a: "2,a", Fields.b: "2,b", Fields.c: "2,c", Fields.d: "2,d" ],
            [ Fields.a: "3,a", Fields.b: "3,b", Fields.c: "3,c", Fields.d: "3,d" ],
            [ Fields.a: "4,a", Fields.b: "4,b", Fields.c: "4,c", Fields.d: "4,d" ],
            [ Fields.a: "5,a", Fields.b: "5,b", Fields.c: "5,c", Fields.d: "5,d" ]
        ])
    }

    func testAbitraryDelimiter() {
        assertDelimited([
            "1,a-1,b-1,c-1,d",
            "2,a-2,b-2,c-2,d",
            "3,a-3,b-3,c-3,d",
            "4,a-4,b-4,c-4,d",
            "5,a-5,b-5,c-5,d"
        ].joined(separator: "\n"), by: "-", matches: [
            [ Fields.a: "1,a", Fields.b: "1,b", Fields.c: "1,c", Fields.d: "1,d" ],
            [ Fields.a: "2,a", Fields.b: "2,b", Fields.c: "2,c", Fields.d: "2,d" ],
            [ Fields.a: "3,a", Fields.b: "3,b", Fields.c: "3,c", Fields.d: "3,d" ],
            [ Fields.a: "4,a", Fields.b: "4,b", Fields.c: "4,c", Fields.d: "4,d" ],
            [ Fields.a: "5,a", Fields.b: "5,b", Fields.c: "5,c", Fields.d: "5,d" ]
        ])
    }

    func testArbitraryDelimiterRepeated() {
        assertDelimited("1,a-1,b--1,d", by: "-", matches: [
            [ Fields.a: "1,a", Fields.b: "1,b", Fields.c: "", Fields.d: "1,d" ],
        ])
    }

    func testMixedQuotedStrings() {
        assertDelimited([
            "F1,F2,F3,F4",
            "a,\"b, B\",c, d",
            "A,B,C,D",
            "1,2,3,4",
            "I,II,III,IV"
        ].joined(separator: "\n"), matches: [
            [ Fields.a: "F1", Fields.b: "F2",   Fields.c: "F3",  Fields.d: "F4" ],
            [ Fields.a: "a",  Fields.b: "b, B", Fields.c: "c",   Fields.d: " d" ],
            [ Fields.a: "A",  Fields.b: "B",    Fields.c: "C",   Fields.d: "D"  ],
            [ Fields.a: "1",  Fields.b: "2",    Fields.c: "3",   Fields.d: "4"  ],
            [ Fields.a: "I",  Fields.b: "II",   Fields.c: "III", Fields.d: "IV" ]
        ])
    }

}

TestRunner().runTests(from: DelimitedTests.self)
