public extension Parsers {

    struct ZeroOrMore<Original, Separator>: Parser where Original: Parser, Separator: Parser {
        let original: Original
        let separator: Separator
        public init(_ original: Original, separatedBy separator: Separator) {
            self.original = original
            self.separator = separator
        }

        public func run(_ input: inout Substring) -> [Original.Output]? {
            var rest = input
            var matches = [Original.Output]()
            while let match = original.run(&input) {
                matches.append(match)
                guard separator.run(&input) != nil else { return matches }
                rest = input
            }
            input = rest
            return matches
        }
    }

}

public extension Parser {

    func zeroOrMore<P>(separatedBy separator: P) -> Parsers.ZeroOrMore<Self, P> {
        Parsers.ZeroOrMore(self, separatedBy: separator)
    }

    func zeroOrMore(separatedBy separator: String) -> Parsers.ZeroOrMore<Self, Parsers.Literal> {
        zeroOrMore(separatedBy: Parsers.Literal(separator))
    }

}
