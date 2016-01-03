// Derived from http://blog.krzyzanowskim.com/2015/10/24/chunksequence-have-cake-and-eat-it/

public struct ChunkGenerator<Collection: CollectionType>: GeneratorType, SequenceType {

    private let collection: Collection
    private let stride: Collection.Index.Distance
    private let limit: Collection.Index
    private var nextStart: Collection.Index

    private init(collection: Collection, stride: Collection.Index.Distance) {
        self.collection = collection
        self.stride = stride
        self.limit = collection.endIndex
        self.nextStart = collection.startIndex
    }

    public mutating func next() -> Collection.SubSequence? {
        guard nextStart != limit else { return nil }
        let nextEnd = nextStart.advancedBy(stride, limit: limit)
        defer { nextStart = nextEnd }
        return collection[nextStart..<nextEnd]
    }

    public func generate() -> ChunkGenerator<Collection> {
        return ChunkGenerator(collection: collection, stride: stride)
    }

}

public struct ChunkSequence<Collection: CollectionType>: SequenceType {

    private let collection: Collection
    private let stride: Collection.Index.Distance

    public init(collection: Collection, stride: Collection.Index.Distance) {
        precondition(stride > 0)
        self.collection = collection
        self.stride = stride
    }

    public func generate() -> ChunkGenerator<Collection> {
        return ChunkGenerator(collection: collection, stride: stride)
    }

}

extension CollectionType {

    public func slice(every eachSlice: Index.Distance) -> ChunkSequence<Self> {
        return ChunkSequence(collection: self, stride: eachSlice)
    }
    
}
