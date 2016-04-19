import Foundation

// Extra inspiration from https://gist.github.com/brentdax/79fa038c0af0cafb52dd

public struct LocalizableText {
    private enum Storage {
        case Tree([LocalizableText])
        case Expression(() -> String)
        case Segment(String)
        case Formatted(CVarArgType, StaticString)
        case Literal(StaticString)
    }

    private let storage: Storage

    private init(_ storage: Storage) {
        self.storage = storage
    }
}

extension LocalizableText: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch storage {
        case .Tree(let elements):
            return String(elements)
        case .Literal(let literal):
            return String(reflecting: literal)
        case .Segment(let segment):
            return String(reflecting: segment)
        case .Formatted(let value, let format):
            return "(\(value.dynamicType) via \"\(format)\")"
        case .Expression:
            return "(unresolved)"
        }
    }
}

extension LocalizableText: StringInterpolationConvertible {
    public init(stringInterpolation elements: LocalizableText...) {
        self.storage = .Tree(elements)
    }

    public init<T>(stringInterpolationSegment expression: T) {
        self.storage = .Expression({
            String(expression)
        })
    }

    public init(stringInterpolationSegment expression: String) {
        self.storage = .Segment(expression)
    }

    public init<T: NSObject>(stringInterpolationSegment expression: T) {
        self.storage = .Formatted(expression, "%@")
    }

    public init(stringInterpolationSegment expression: LocalizableText) {
        self = expression
    }
}

extension LocalizableText: StringLiteralConvertible {
    public init(stringInterpolationSegment expression: StaticString) {
        self.storage = .Literal(expression)
    }

    public init(stringLiteral value: StaticString) {
        self.init(stringInterpolationSegment: value)
    }

    public init(extendedGraphemeClusterLiteral value: StaticString) {
        self.init(stringInterpolationSegment: value)
    }

    public init(unicodeScalarLiteral value: StaticString) {
        self.init(stringInterpolationSegment: value)
    }
}

extension CVarArgType {

    public func formatted(format: StaticString) -> LocalizableText {
        return LocalizableText(.Formatted(self, format))
    }

}

private extension LocalizableText {

    func withFormatSegments(@noescape eachSegment: String -> Void) {
        switch storage {
        case .Tree(let tree):
            for item in tree {
                item.withFormatSegments(eachSegment)
            }
        case .Expression:
            eachSegment("%@")
        case .Segment(let segment):
            eachSegment(segment)
        case .Formatted(_, let format):
            eachSegment(format.stringValue)
        case .Literal(let literal):
            eachSegment(literal.stringValue)
        }
    }

    var argumentCount: Int {
        switch storage {
        case .Tree(let tree):
            return tree.reduce(0) { $0 + $1.argumentCount }
        case .Expression, .Formatted:
            return 1
        case .Segment, .Literal:
            return 0
        }
    }

    func withArguments(@noescape eachArgument: CVarArgType -> Void) {
        switch storage {
        case .Tree(let tree):
            for item in tree {
                item.withArguments(eachArgument)
            }
        case .Expression(let getter):
            eachArgument(getter())
        case .Formatted(let value, _):
            eachArgument(value)
        case .Segment, .Literal:
            break
        }
    }

}

public func localized(text: LocalizableText, withTable tableName: String? = nil, inBundle bundle: NSBundle = NSBundle.mainBundle(), @autoclosure comment _: () -> String) -> String {
    var format = ""
    text.withFormatSegments { format += $0 }

    let localizedFormat = bundle.localizedStringForKey(format, value: format, table: tableName)

    var arguments = [CVarArgType]()
    arguments.reserveCapacity(text.argumentCount)
    text.withArguments { arguments.append($0) }
    
    return String(format: localizedFormat, arguments: arguments)
}
