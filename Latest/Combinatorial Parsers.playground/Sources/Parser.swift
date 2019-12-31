public protocol Parser {

    associatedtype Output

    func run(_ input: inout Substring) -> Output?

}

public extension Parser {

    func match<Input>(_ input: Input) -> Output? where Input: StringProtocol, Input.SubSequence == Substring {
        var input = input[...]
        return run(&input)
    }

}
