import Foundation

public enum Delimiter: ExpressibleByUnicodeScalarLiteral {
    case comma, tab, custom(UnicodeScalar)

    fileprivate func checkedCharacterSet() -> CharacterSet {
        switch self {
        case .comma:
            return [ "," ]
        case .tab:
            return [ "\t" ]
        case .custom(let scalar):
            precondition(scalar != "\"", "Separator cannot be '\(scalar)'")
            return [ scalar ]
        }
    }

    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = .custom(value)
    }
}

public enum Separator: ExpressibleByUnicodeScalarLiteral {
    case newlines, custom(UnicodeScalar)

    fileprivate func checkedCharacterSet() -> CharacterSet {
        switch self {
        case .newlines:
            return .newlines
        case .custom(let scalar):
            precondition(scalar != "\"", "Separator cannot be '\(scalar)'")
            return [ scalar ]
        }
    }

    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = .custom(value)
    }
}

/// A lazy parser for tabular data stored in plain text, separated by newlines
/// and delimited by some string.
///
/// Neither a reverse solidus nor any newline character may be used as the
/// delimiter.
public struct Delimited<Columns: CaseIterable>: Sequence, IteratorProtocol where Columns.List.Iterator.Element == Columns {

    private let string: String
    private let backingData: Data?
    private let endDelimiter: CharacterSet
    private let endSeparator: CharacterSet
    private let endString: CharacterSet

    private var scanOffset: String.Index

    private init(string: String, backedBy backingData: Data?, delimiter uncheckedDelimiter: Delimiter, separator uncheckedSeparator: Separator) {
        let delimiter = uncheckedDelimiter.checkedCharacterSet()
        let separator = uncheckedSeparator.checkedCharacterSet()
        precondition(!separator.isSuperset(of: delimiter), "Separator cannot be '\(delimiter)'")

        self.string = string
        self.endDelimiter = delimiter.inverted
        self.endSeparator = separator.inverted
        self.endString = {
            var endTextCharacters = CharacterSet()
            endTextCharacters.formUnion(delimiter)
            endTextCharacters.formUnion(separator)
            endTextCharacters.insert(charactersIn: "\"")
            return endTextCharacters
        }()
        self.backingData = backingData
        self.scanOffset = string.startIndex
    }

    public init(data: Data, fieldsBy delimiter: Delimiter = .comma, of _: Columns.Type = Columns.self, recordsBy separator: Separator = .newlines) {
        let detectedEncoding = NSString.stringEncoding(for: data, encodingOptions: [
            .suggestedEncodingsKey: [ String.Encoding.utf8 ]
            ], convertedString: nil, usedLossyConversion: nil)

        if detectedEncoding != 0, let string = data.withUnsafeBytes({ String(bytesNoCopy: UnsafeMutableRawPointer(mutating: $0), length: data.count, encoding: String.Encoding(rawValue: detectedEncoding), freeWhenDone: false) }) {
            self.init(string: string, backedBy: data, delimiter: delimiter, separator: separator)
        } else {
            self.init(string: "", backedBy: nil, delimiter: delimiter, separator: separator)
        }
    }

    public init(string: String, fieldsBy delimiter: Delimiter = .comma, of _: Columns.Type = Columns.self, recordsBy separator: Separator = .newlines) {
        self.init(string: string, backedBy: nil, delimiter: delimiter, separator: separator)
    }

    // MARK: - Scanning

    private mutating func scan(_ match: String) -> String? {
        guard let match = string.range(of: match, options: .anchored, range: scanOffset ..< string.endIndex) else { return nil }
        scanOffset = match.upperBound
        return string[match]
    }

    private mutating func scan(upTo limit: Int = .max, charactersBefore set: CharacterSet) -> String? {
        let lowerBound = scanOffset
        let upperBound = string.endIndex

        let match = string.rangeOfCharacter(from: set, range: lowerBound ..< upperBound)?.lowerBound ?? upperBound
        guard match != lowerBound else { return nil }

        let scanEnd = Swift.min(string.index(lowerBound, offsetBy: limit, limitedBy: upperBound) ?? upperBound, match)
        scanOffset = scanEnd
        return string[lowerBound ..< scanEnd]
    }

    private var isAtEnd: Bool {
        return scanOffset == string.endIndex
    }

    // MARK: - Parsing

    private let fields = Array(Columns.all)
    private var recordTemplate = [Columns: String]()

    private mutating func parseDoubleQuote() -> String? {
        return scan("\"")
    }

    private mutating func parseTwoDoubleQuotes() -> String? {
        return scan("\"\"")
    }

    private mutating func parseDelimiter() -> String? {
        return scan(upTo: 1, charactersBefore: endDelimiter)
    }

    private mutating func parseSeparator() -> String? {
        return scan(charactersBefore: endSeparator)
    }

    private mutating func parseField() -> String? {
        if let escapedString = parseEscapedString() {
            return escapedString
        }

        if let nonEscapedString = parseString() {
            return nonEscapedString
        }

        let previousOffset = scanOffset
        if parseDelimiter() != nil || parseSeparator() != nil || isAtEnd {
            scanOffset = previousOffset
            return ""
        }

        return nil
    }

    private mutating func parseString() -> String? {
        return scan(charactersBefore: endString)
    }

    private mutating func parseEscapedString() -> String? {
        guard parseDoubleQuote() != nil else { return nil }

        var accumulated = ""
        while let fragment = parseString() ?? parseDelimiter() ?? parseSeparator() ?? parseTwoDoubleQuotes().map({ _ in "\"" }) {
            accumulated.append(fragment)
        }

        guard parseDoubleQuote() != nil else { return nil }
        return accumulated
    }

    private mutating func parseRecord() -> [Columns: String]? {
        guard parseSeparator() == nil && !isAtEnd else { return nil }

        var columns = fields.makeIterator()
        recordTemplate.removeAll(keepingCapacity: true)

        while let column = columns.next(), let field = parseField() {
            recordTemplate[column] = field

            guard parseDelimiter() != nil else {
                break
            }
        }

        return recordTemplate
    }
    
    // MARK: -
    
    public mutating func next() -> [Columns: String]? {
        defer { _ = parseSeparator() }
        return parseRecord()
    }
    
}
