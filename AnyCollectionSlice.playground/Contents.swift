// Derived from http://blog.krzyzanowskim.com/2015/10/24/chunksequence-have-cake-and-eat-it/

struct ChunkSequence<Element>: SequenceType {
    typealias Collection = AnyForwardCollection<Element>
    let collection: Collection
    let chunkSize: Collection.Index.Distance
    
    private init<C: CollectionType where C.Index: ForwardIndexType, C.Generator.Element == Element>(_ base: C, chunkSize: C.Index.Distance) {
        self.collection = AnyForwardCollection(base)
        self.chunkSize = chunkSize.toIntMax()
    }
    
    func generate() -> AnyGenerator<Collection.SubSequence> {
        var start = collection.startIndex
        let end = collection.endIndex
        return anyGenerator {
            let offset = start.advancedBy(self.chunkSize, limit: end)
            let slice = self.collection[start..<offset]
            start = offset
            return slice.isEmpty ? nil : slice
        }
    }
}

extension CollectionType {
    
    func slice(every chunkSize: Index.Distance) -> ChunkSequence<Generator.Element> {
        return ChunkSequence(self, chunkSize: chunkSize)
    }
    
}

var 🎂 = ["🍰","🍰","🍰","🍰","🍰"]
for 🍰 in 🎂.slice(every: 2) {
    print(🍰)
}

var array:Array<Int> = [1,2,3,4,5]
for slice in array.slice(every: 2) {
    print(slice)
}

let lazyArray = array.lazy.map(String.init)
for slice in lazyArray.slice(every: 2) {
    print(slice)
}