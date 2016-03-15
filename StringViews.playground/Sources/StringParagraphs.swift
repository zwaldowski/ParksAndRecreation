import Foundation



extension String {

    public struct ParagraphsView {
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

    public typealias ParagraphIndex = ParagraphsView.Index

    public var paragraphs: ParagraphsView {
        return .init(self)
    }

}


extension String.ParagraphsView: CollectionType {

    public var startIndex: Index {
        return .init(source, location: source.startIndex)
    }

    public var endIndex: Index {
        return .init(source, location: source.endIndex)
    }

    public subscript(i: Index) -> String {
        guard i.location != source.endIndex else { return "" }
        var start = source.startIndex
        var end = source.endIndex
        source.getParagraphStart(&start, end: nil, contentsEnd: &end, forRange: i.location ..< i.location)
        return source[start ..< end]
    }

}

extension String.ParagraphIndex: BidirectionalIndexType {

    public func predecessor() -> String.ParagraphIndex {
        guard location != source.startIndex else { return self }

        var next = location.predecessor()
        source.getParagraphStart(&next, end: nil, contentsEnd: nil, forRange: next ..< next)
        return .init(source, location: next)
    }

    public func successor() -> String.ParagraphIndex {
        guard location != source.endIndex else { return self }

        var next = location
        source.getParagraphStart(nil, end: &next, contentsEnd: nil, forRange: next ..< next)
        return .init(source, location: next)
    }

}

public func == (lhs: String.ParagraphIndex, rhs: String.ParagraphIndex) -> Bool {
    return lhs.location == rhs.location
}
