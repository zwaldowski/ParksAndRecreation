import Foundation

public struct StringLinesView<Base: StringProtocol> where Base.Index == String.Index {

    fileprivate let base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }

}

extension StringLinesView: BidirectionalCollection {

    public typealias Index = Base.Index

    public var startIndex: Index {
        return base.startIndex
    }

    public var endIndex: Index {
        return base.endIndex
    }

    public func index(after i: Index) -> Index {
        var i = i
        formIndex(after: &i)
        return i
    }

    public func formIndex(after i: inout Index) {
        guard i != base.endIndex else { return }

        var unused1 = base.startIndex, unused2 = base.startIndex
        base.getLineStart(&unused1, end: &i, contentsEnd: &unused2, for: i ..< i)
    }

    public func index(before i: Index) -> Index {
        var i = i
        formIndex(before: &i)
        return i
    }

    public func formIndex(before i: inout Index) {
        guard i != base.startIndex else { return }
        base.formIndex(before: &i)
        var unused1 = base.startIndex, unused2 = base.startIndex
        base.getLineStart(&i, end: &unused1, contentsEnd: &unused2, for: i ..< i)
    }

    public subscript(i: Index) -> Base.SubSequence {
        guard i != base.endIndex else { preconditionFailure("Out of bounds") }
        var start = base.startIndex, unused1 = base.startIndex, end = base.endIndex
        base.getLineStart(&start, end: &unused1, contentsEnd: &end, for: i ..< i)
        return base[start ..< end]
    }

}

public struct StringParagraphsView<Base: StringProtocol> where Base.Index == String.Index {

    fileprivate let base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }

}

extension StringParagraphsView: BidirectionalCollection {

    public typealias Index = Base.Index

    public var startIndex: Index {
        return base.startIndex
    }

    public var endIndex: Index {
        return base.endIndex
    }

    public func index(after i: Index) -> Index {
        var i = i
        formIndex(after: &i)
        return i
    }

    public func formIndex(after i: inout Index) {
        guard i != base.endIndex else { return }

        var unused1 = base.startIndex, unused2 = base.startIndex
        base.getParagraphStart(&unused1, end: &i, contentsEnd: &unused2, for: i ..< i)
    }

    public func index(before i: Index) -> Index {
        var i = i
        formIndex(before: &i)
        return i
    }

    public func formIndex(before i: inout Index) {
        guard i != base.startIndex else { return }
        base.formIndex(before: &i)
        var unused1 = base.startIndex, unused2 = base.startIndex
        base.getParagraphStart(&i, end: &unused1, contentsEnd: &unused2, for: i ..< i)
    }

    public subscript(i: Index) -> Base.SubSequence {
        guard i != base.endIndex else { preconditionFailure("Out of bounds") }
        var start = base.startIndex, unused1 = base.startIndex, end = base.endIndex
        base.getParagraphStart(&start, end: &unused1, contentsEnd: &end, for: i ..< i)
        return base[start ..< end]
    }

}

extension StringProtocol where Index == String.Index {

    public typealias LinesView = StringLinesView<Self>

    public var lines: LinesView {
        return LinesView(self)
    }

    public typealias ParagraphsView = StringParagraphsView<Self>

    public var paragraphs: ParagraphsView {
        return ParagraphsView(self)
    }

}
