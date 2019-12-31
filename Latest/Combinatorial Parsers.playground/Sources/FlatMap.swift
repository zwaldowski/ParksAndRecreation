public extension Parsers {

    struct FlatMap<NewParser, Original>: Parser where NewParser: Parser, Original: Parser {
        let original: Original
        let transform: (Original.Output) -> NewParser
        public init(original: Original, transform: @escaping(Original.Output) -> NewParser) {
            self.original = original
            self.transform = transform
        }

        public func run(_ input: inout Substring) -> NewParser.Output? {
            let start = input
            guard let match = original.run(&input).flatMap(transform)?.run(&input) else {
                input = start
                return nil
            }
            return match
        }
    }

}

public extension Parser {

    func flatMap<P>(_ transform: @escaping(Output) -> P) -> Parsers.FlatMap<P, Self> {
        Parsers.FlatMap(original: self, transform: transform)
    }

}
