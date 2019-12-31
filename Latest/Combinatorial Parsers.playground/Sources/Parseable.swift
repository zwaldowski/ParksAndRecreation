public protocol Parseable {

    associatedtype ParserType: Parser where ParserType.Output == Self

    static var parser: ParserType { get }

}

public extension Parseable {

    init?<Input>(parsing input: Input) where Input: StringProtocol, Input.SubSequence == Substring {
        guard let match = Self.parser.match(input) else { return nil }
        self = match
    }

}
