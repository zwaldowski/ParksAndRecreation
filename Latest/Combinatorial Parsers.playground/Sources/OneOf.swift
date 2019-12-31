public extension Parsers {

    struct OneOf<A, B>: Parser where A: Parser, B: Parser, A.Output == B.Output {
        let a: A
        let b: B
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        public func run(_ input: inout Substring) -> A.Output? {
            a.run(&input) ?? b.run(&input)
        }
    }

    struct OneOf3<A, B, C>: Parser where A: Parser, B: Parser, C: Parser, A.Output == B.Output, B.Output == C.Output {
        let a: A
        let b: B
        let c: C
        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }

        public func run(_ input: inout Substring) -> A.Output? {
            a.run(&input) ?? b.run(&input) ?? c.run(&input)
        }
    }

    struct OneOf4<A, B, C, D>: Parser where A: Parser, B: Parser, C: Parser, D: Parser, A.Output == B.Output, B.Output == C.Output, C.Output == D.Output {
        let a: A
        let b: B
        let c: C
        let d: D
        public init(_ a: A, _ b: B, _ c: C, _ d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }

        public func run(_ input: inout Substring) -> A.Output? {
            a.run(&input) ?? b.run(&input) ?? c.run(&input) ?? d.run(&input)
        }
    }

    struct OneOf5<A, B, C, D, E>: Parser where A: Parser, B: Parser, C: Parser, D: Parser, E: Parser, A.Output == B.Output, B.Output == C.Output, C.Output == D.Output, D.Output == E.Output {
        let a: A
        let b: B
        let c: C
        let d: D
        let e: E
        public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
        }

        public func run(_ input: inout Substring) -> A.Output? {
            a.run(&input) ?? b.run(&input) ?? c.run(&input) ?? d.run(&input) ?? e.run(&input)
        }
    }

    struct OneOf6<A, B, C, D, E, F>: Parser where A: Parser, B: Parser, C: Parser, D: Parser, E: Parser, F: Parser, A.Output == B.Output, B.Output == C.Output, C.Output == D.Output, D.Output == E.Output, E.Output == F.Output {
        let a: A
        let b: B
        let c: C
        let d: D
        let e: E
        let f: F
        public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
        }

        public func run(_ input: inout Substring) -> A.Output? {
            a.run(&input) ?? b.run(&input) ?? c.run(&input) ?? d.run(&input) ?? e.run(&input) ?? f.run(&input)
        }
    }

    struct OneOf7<A, B, C, D, E, F, G>: Parser where A: Parser, B: Parser, C: Parser, D: Parser, E: Parser, F: Parser, G: Parser, A.Output == B.Output, B.Output == C.Output, C.Output == D.Output, D.Output == E.Output, E.Output == F.Output, F.Output == G.Output {
        let a: A
        let b: B
        let c: C
        let d: D
        let e: E
        let f: F
        let g: G
        public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
            self.g = g
        }

        public func run(_ input: inout Substring) -> A.Output? {
            a.run(&input) ?? b.run(&input) ?? c.run(&input) ?? d.run(&input) ?? e.run(&input) ?? f.run(&input) ?? g.run(&input)
        }
    }

}

public extension Parser {

    func or<P>(_ parser: P) -> Parsers.OneOf<Self, P> {
        Parsers.OneOf(self, parser)
    }

    func or<P, Q>(_ parser1: P, _ parser2: Q) -> Parsers.OneOf3<Self, P, Q> {
        Parsers.OneOf3(self, parser1, parser2)
    }

    func or<P, Q, R>(_ parser1: P, _ parser2: Q, _ parser3: R) -> Parsers.OneOf4<Self, P, Q, R> {
        Parsers.OneOf4(self, parser1, parser2, parser3)
    }

    func or<P, Q, R, S>(_ parser1: P, _ parser2: Q, _ parser3: R, _ parser4: S) -> Parsers.OneOf5<Self, P, Q, R, S> {
        Parsers.OneOf5(self, parser1, parser2, parser3, parser4)
    }

    func or<P, Q, R, S, T>(_ parser1: P, _ parser2: Q, _ parser3: R, _ parser4: S, _ parser5: T) -> Parsers.OneOf6<Self, P, Q, R, S, T> {
        Parsers.OneOf6(self, parser1, parser2, parser3, parser4, parser5)
    }

    func or<P, Q, R, S, T, U>(_ parser1: P, _ parser2: Q, _ parser3: R, _ parser4: S, _ parser5: T, _ parser6: U) -> Parsers.OneOf7<Self, P, Q, R, S, T, U> {
        Parsers.OneOf7(self, parser1, parser2, parser3, parser4, parser5, parser6)
    }

}
