
public struct ChunkGenerator<Collection: CollectionType>: GeneratorType {
    
    private let collection: Collection
    private let stride: Collection.Index.Distance
    private lazy var range: Range<Collection.Index> = {
        self.nextRangeFrom(nil)
    }()
    
    public init(collection: Collection, stride: Collection.Index.Distance) {
        self.collection = collection
        self.stride = stride
    }
    
    private func nextRangeFrom(inLastEnd: Collection.Index?) -> Range<Collection.Index> {
        let lastEnd = inLastEnd ?? collection.startIndex
        return lastEnd..<lastEnd.advancedBy(stride, limit: collection.endIndex)
    }
    
    public mutating func next() -> Collection.SubSequence? {
        guard range.startIndex != collection.endIndex else { return nil }
        let toFetch = range
        range = nextRangeFrom(range.endIndex)
        return collection[toFetch]
    }
    
}

extension CollectionType {
    
    public func chunks(eachSlice: Index.Distance) -> AnySequence<SubSequence> {
        precondition(eachSlice > 0)
        return AnySequence {
            ChunkGenerator(collection: self, stride: eachSlice)
        }
    }
    
}
