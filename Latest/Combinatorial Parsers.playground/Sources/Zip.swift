public extension Parsers {

    struct Zip<A, B>: Parser where A: Parser, B: Parser {

        let a: A
        let b: B
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        public func run(_ input: inout Substring) -> (A.Output, B.Output)? {
            let start = input
            guard let a = a.run(&input), let b = b.run(&input) else {
                input = start
                return nil
            }
            return (a, b)
        }
        
    }

    struct Zip3<A, B, C>: Parser where A: Parser, B: Parser, C: Parser {

        let a: A
        let b: B
        let c: C
        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }

        public func run(_ input: inout Substring) -> (A.Output, B.Output, C.Output)? {
            let start = input
            guard let a = a.run(&input), let b = b.run(&input), let c = c.run(&input) else {
                input = start
                return nil
            }
            return (a, b, c)
        }

    }

    struct Zip4<A, B, C, D>: Parser where A: Parser, B: Parser, C: Parser, D: Parser {

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

        public func run(_ input: inout Substring) -> (A.Output, B.Output, C.Output, D.Output)? {
            let start = input
            guard let a = a.run(&input), let b = b.run(&input), let c = c.run(&input), let d = d.run(&input) else {
                input = start
                return nil
            }
            return (a, b, c, d)
        }

    }

    struct Zip5<A, B, C, D, E>: Parser where A: Parser, B: Parser, C: Parser, D: Parser, E: Parser {

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

        public func run(_ input: inout Substring) -> (A.Output, B.Output, C.Output, D.Output, E.Output)? {
            let start = input
            guard let a = a.run(&input), let b = b.run(&input), let c = c.run(&input), let d = d.run(&input), let e = e.run(&input) else {
                input = start
                return nil
            }
            return (a, b, c, d, e)
        }

    }

    struct Zip6<A, B, C, D, E, F>: Parser where A: Parser, B: Parser, C: Parser, D: Parser, E: Parser, F: Parser {

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

        public func run(_ input: inout Substring) -> (A.Output, B.Output, C.Output, D.Output, E.Output, F.Output)? {
            let start = input
            guard let a = a.run(&input), let b = b.run(&input), let c = c.run(&input), let d = d.run(&input), let e = e.run(&input), let f = f.run(&input) else {
                input = start
                return nil
            }
            return (a, b, c, d, e, f)
        }

    }

    struct Zip7<A, B, C, D, E, F, G>: Parser where A: Parser, B: Parser, C: Parser, D: Parser, E: Parser, F: Parser, G: Parser {

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

        public func run(_ input: inout Substring) -> (A.Output, B.Output, C.Output, D.Output, E.Output, F.Output, G.Output)? {
            let start = input
            guard let a = a.run(&input), let b = b.run(&input), let c = c.run(&input), let d = d.run(&input), let e = e.run(&input), let f = f.run(&input), let g = g.run(&input) else {
                input = start
                return nil
            }
            return (a, b, c, d, e, f, g)
        }

    }

}

public extension Parser {

    func zip<P>(_ parser: P) -> Parsers.Zip<Self, P> {
        Parsers.Zip(self, parser)
    }

    func zip<P, Q>(_ parser1: P, _ parser2: Q) -> Parsers.Zip3<Self, P, Q> {
        Parsers.Zip3(self, parser1, parser2)
    }

    func zip<P, Q, R>(_ parser1: P, _ parser2: Q, _ parser3: R) -> Parsers.Zip4<Self, P, Q, R> {
        Parsers.Zip4(self, parser1, parser2, parser3)
    }

    func zip<P, Q, R, S>(_ parser1: P, _ parser2: Q, _ parser3: R, _ parser4: S) -> Parsers.Zip5<Self, P, Q, R, S> {
        Parsers.Zip5(self, parser1, parser2, parser3, parser4)
    }

    func zip<P, Q, R, S, T>(_ parser1: P, _ parser2: Q, _ parser3: R, _ parser4: S, _ parser5: T) -> Parsers.Zip6<Self, P, Q, R, S, T> {
        Parsers.Zip6(self, parser1, parser2, parser3, parser4, parser5)
    }

    func zip<P, Q, R, S, T, U>(_ parser1: P, _ parser2: Q, _ parser3: R, _ parser4: S, _ parser5: T, _ parser6: U) -> Parsers.Zip7<Self, P, Q, R, S, T, U> {
        Parsers.Zip7(self, parser1, parser2, parser3, parser4, parser5, parser6)
    }

}

public extension Parser {

    func surrounded<P, Q>(by prefix: P, _ suffix: Q) -> Parsers.Zip3<P, Self, Q> {
        prefix.zip(self, suffix)
    }

}
