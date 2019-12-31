public extension Parsers {

    struct PrefixWhile: Parser {

        let predicate: (Swift.Character) -> Bool
        public init(predicate: @escaping(Swift.Character) -> Bool) {
            self.predicate = predicate
        }

        public func run(_ input: inout Substring) -> Substring? {
            let prefix = input.prefix(while: predicate)
            input.removeFirst(prefix.count)
            return prefix
        }

    }

}
