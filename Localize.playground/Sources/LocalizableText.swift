import Foundation

public enum LocalizableText {
    case Tree([LocalizableText])
    case Segment(String)
    case Expression(String)
}

extension LocalizableText: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .Tree(let segments):
            return segments.reduce("") { $0 + String($1) }
        case .Segment(let segment):
            return String(segment)
        case .Expression(let value):
            return String(value)
        }
    }
    
}

extension LocalizableText: StringInterpolationConvertible {
    
    public init(stringInterpolation elements: LocalizableText...) {
        self = .Tree(elements)
    }
    
    public init<T>(stringInterpolationSegment expression: T) {
        if let expression = expression as? String {
            self = .Segment(expression)
        } else {
            self = .Expression(String(expression))
        }
    }
    
}

extension LocalizableText: StringLiteralConvertible {
    
    public init(stringLiteral value: String) {
        self = .Segment(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: Character) {
        self = .Segment(String(value))
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = .Segment(String(value))
    }
    
}
