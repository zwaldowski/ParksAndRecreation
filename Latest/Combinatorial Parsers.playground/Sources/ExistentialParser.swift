public struct AnyParser<Output> {

    let runner: (inout Substring) -> Output?
    public init(_ runner: @escaping(inout Substring) -> Output?) {
        self.runner = runner
    }

    public func run(_ input: inout Substring) -> Output? {
        runner(&input)
    }

}

public extension Parser {

    func eraseToAnyParser() -> AnyParser<Output> {
        AnyParser(run)
    }

}
