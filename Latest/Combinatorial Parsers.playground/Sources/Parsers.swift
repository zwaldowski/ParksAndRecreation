public enum Parsers {}

// MARK: -

public extension Parsers {

    struct First: Parser {

        public init() {}

        public func run(_ input: inout Substring) -> Swift.Character? {
            input.popFirst()
        }

    }

    struct Literal: Parser {

        let prefix: String
        public init(_ prefix: String) {
            self.prefix = prefix
        }

        public func run(_ input: inout Substring) -> Void? {
            guard input.hasPrefix(prefix) else { return nil }
            input.removeFirst(prefix.count)
            return ()
        }
    
    }

}
