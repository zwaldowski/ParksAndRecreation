// Derived from http://blog.krzyzanowskim.com/2015/10/24/chunksequence-have-cake-and-eat-it/

public struct ChunkSequence<Base: Collection>: Sequence, IteratorProtocol {

    private let base: Base
    private let stride: Int
    private var start: Base.Index

    fileprivate init(stride: Int, in base: Base) {
        precondition(stride > 0)
        self.base = base
        self.stride = stride
        self.start = base.startIndex
    }

    public mutating func next() -> Base.SubSequence? {
        guard start != base.endIndex else { return nil }
        let slice = base.suffix(from: start).prefix(stride)
        start = slice.endIndex
        return slice
    }

}

extension Collection {

    public func slice(every maxLength: Int) -> ChunkSequence<Self> {
        return ChunkSequence(stride: maxLength, in: self)
    }

}
