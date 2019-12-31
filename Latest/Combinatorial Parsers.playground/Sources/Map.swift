public extension Parsers {

    struct Map<Original, Output>: Parser where Original: Parser {
        let original: Original
        let transform: (Original.Output) -> Output?
        public init(original: Original, transform: @escaping(Original.Output) -> Output?) {
            self.original = original
            self.transform = transform
        }

        public func run(_ input: inout Substring) -> Output? {
            let start = input
            guard let match = original.run(&input).flatMap(transform) else {
                input = start
                return nil
            }
            return match
        }
    }

}

public extension Parser {

    func map<T>(_ transform: @escaping(Output) -> T?) -> Parsers.Map<Self, T> {
        Parsers.Map(original: self, transform: transform)
    }

    func ignoreOutput() -> Parsers.Map<Self, Void> {
        map { _ in }
    }

    func filter(_ predicate: @escaping(Output) -> Bool) -> Parsers.Map<Self, Output> {
        map { predicate($0) ? $0 : nil }
    }

}

public extension Parser where Output == Void {

    func map<T>(_ transform: @autoclosure @escaping () -> T) -> Parsers.Map<Self, T> {
        Parsers.Map(original: self, transform: transform)
    }

}
