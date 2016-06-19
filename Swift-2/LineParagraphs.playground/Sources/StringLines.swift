import Foundation

extension String {

    public struct Lines {
        private let source: String

        private init(_ source: String) {
            self.source = source
        }

        public struct Index {
            private let source: String
            private let location: String.Index

            private init(_ source: String, location: String.Index) {
                self.source = source
                self.location = location
            }
        }
    }

    public typealias LineIndex = Lines.Index

    public var lines: Lines {
        return .init(self)
    }

}

extension String.Lines {

    public var substrings: LazyMapCollection<String.Lines, String> {
        return lazy.map { self.source[$0] }
    }

}

extension String.Lines: CollectionType {

    public var startIndex: Index {
        return .init(source, location: source.startIndex)
    }

    public var endIndex: Index {
        return .init(source, location: source.endIndex)
    }

    public subscript(i: Index) -> Range<String.Index> {
        guard i.location != source.endIndex else { return source.endIndex...source.endIndex }

        var start = source.startIndex
        var end = source.endIndex
        source.getLineStart(&start, end: nil, contentsEnd: &end, forRange: i.location ..< i.location)
        return start ..< end
    }

}

extension String.LineIndex: BidirectionalIndexType {

    public func predecessor() -> String.LineIndex {
        guard location != source.startIndex else { return self }

        var next = location.predecessor()
        source.getLineStart(&next, end: nil, contentsEnd: nil, forRange: next ..< next)
        return .init(source, location: next)
    }

    public func successor() -> String.LineIndex {
        guard location != source.endIndex else { return self }

        var next = location
        source.getLineStart(nil, end: &next, contentsEnd: nil, forRange: next ..< next)
        return .init(source, location: next)
    }

}

public func == (lhs: String.LineIndex, rhs: String.LineIndex) -> Bool {
    return lhs.location == rhs.location
}
