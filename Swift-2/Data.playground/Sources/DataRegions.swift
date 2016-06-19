import Dispatch

private extension dispatch_data_t {
    
    /// This won't remap the buffer because the region will be a leaf,
    /// so it just returns the buffer.
    /// - precondition: The recieving buffer is a leaf returned from 
    ///   dispatch_data_apply(2) or dispatch_data_copy_region(3).
    func mapLeaf() -> UnsafeBufferPointer<UInt8> {
        var mapPtr = UnsafePointer<Void>()
        var mapSize = 0
        _ = dispatch_data_create_map(self, &mapPtr, &mapSize)
        return UnsafeBufferPointer(start: UnsafePointer(mapPtr), count: mapSize)
    }
    
}

/// The `CollectionType` returned by `Data.byteRegions`.  `DataRegions`
/// is a forward collection of byte buffers, represented in Swift as
/// `UnsafeBufferPointer<UInt8>`.
public struct DataRegions {
    
    private let data: dispatch_data_t
    
    private init(_ data: dispatch_data_t) {
        self.data = data
    }
    
}

extension DataRegions: SequenceType {
    
    /// A generator over the underlying contiguous storage of a `Data<T>`.
    public struct Generator: GeneratorType, SequenceType {
        
        private let data: dispatch_data_t
        private var nextByteOffset = 0
        
        private init(data: dispatch_data_t) {
            self.data = data
        }
        
        /// Advance to the next buffer and return it, or `nil` if no more buffers
        /// exist.
        ///
        /// - Requires: No preceding call to `self.next()` has returned `nil`.
        public mutating func next() -> UnsafeBufferPointer<UInt8>? {
            guard nextByteOffset != dispatch_data_get_size(data) else { return nil }
            let nextRegion = dispatch_data_copy_region(data, nextByteOffset, &nextByteOffset)
            let buffer = nextRegion.mapLeaf()
            nextByteOffset += buffer.count
            return buffer
        }
        
        /// Restart enumeration of byte buffers.
        public func generate() -> Generator {
            return Generator(data: data)
        }
        
    }

    /// Start enumeration of byte buffers.
    public func generate() -> Generator {
        return Generator(data: data)
    }
    
}

extension DataRegions: CollectionType {
    
    /// A type that represents a valid region in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript.
    public struct Index: ForwardIndexType {
        
        private let data: dispatch_data_t
        private let startOffset: Int
        
        private init(data: dispatch_data_t, startOffset: Int) {
            self.data = data
            self.startOffset = startOffset
        }
        
        /// Return the next consecutive value in a discrete sequence of
        /// `DataRegions.Index` values.
        public func successor() -> Index {
            var nextStartOffset = 0
            let region = dispatch_data_copy_region(data, startOffset, &nextStartOffset)
            nextStartOffset += dispatch_data_get_size(region)
            return Index(data: data, startOffset: nextStartOffset)
        }
        
    }
    
    /// The first region if the `Data` is non-empty; identical to `endIndex` otherwise.
    public var startIndex: Index {
        return Index(data: data, startOffset: 0)
    }
    
    /// The "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    public var endIndex: Index {
        return Index(data: data, startOffset: dispatch_data_get_size(data))
    }
    
    /// Returns the region at the given `position`.
    public subscript(position: Index) -> UnsafeBufferPointer<UInt8> {
        precondition(position.data === data, "Invalid Index for this DataRegions view")
        precondition(position.startOffset < dispatch_data_get_size(data), "can not subscript using an endIndex")
        var unused = 0
        return dispatch_data_copy_region(data, position.startOffset, &unused).mapLeaf()
    }
    
    /// Returns `true` iff `self` is empty.
    public var isEmpty: Bool {
        return dispatch_data_get_size(data) == 0
    }
    
}

/// Returns true iff `lhs` and `rhs` store the same underlying collection.
public func ==(lhs: DataRegions.Index, rhs: DataRegions.Index) -> Bool {
    return lhs.data === rhs.data && lhs.startOffset == rhs.startOffset
}

extension Data {
    
    /// A collection view representing the underlying contiguous byte buffers
    /// making up the data. Enumerating through this collection is useful
    /// for feeding an iterative API, such as crypto routines.
    public var byteRegions: DataRegions {
        return DataRegions(data)
    }
    
    /// A collection view representing the byte stream making up the data.
    public typealias Bytes = FlattenCollection<DataRegions>
    
    /// A collection view representing the actual bytes making up the data.
    /// Enumerating through this collection, though with a performance cost,
    /// is good for presentation and debugging.
    public var bytes: Bytes {
        return byteRegions.flatten()
    }
    
}

// MARK: Introspection

private extension Data {
    
    func toHex64Strings(byteLimit limit: Int? = nil) -> JoinSequence<[LazyMapSequence<ChunkSequence<Bytes.SubSequence>, String>]> {
        let slices: [FlattenCollection<DataRegions>.SubSequence]
        if let limit = limit where bytes.count > limit {
            let prefixLength = (limit + 1) / 2
            let suffixLength = limit - prefixLength
            slices = [ bytes.prefix(prefixLength), bytes.suffix(suffixLength) ]
        } else {
            slices = [ bytes[bytes.startIndex..<bytes.endIndex] ]
        }
        
        return slices.lazy.map { bytes in
            bytes.slice(every: 4).lazy.map { fourBytes in
                fourBytes.lazy.map { byte -> String in
                    let string = String(byte, radix: 16, uppercase: false)
                    guard byte > 0xF else { return "0\(string)" }
                    return string
                }.joinWithSeparator("")
            }
        }.joinWithSeparator([ "... " ])
    }
    
    func describeBytes(limit limit: Int? = nil) -> String {
        return toHex64Strings(byteLimit: limit).joinWithSeparator(" ")
    }
    
}

extension Data: CustomReflectable {
    
    /// Return the `Mirror` for `self`.
    public func customMirror() -> Mirror {
        // Appears as an array of the integer type, as suggested in the docs
        // for Mirror.init(_:unlabeledChildren:displayStyle:ancestorRepresentation:).
        // An improved version might show segmented hex values.
        return Mirror(self, unlabeledChildren: Array(toHex64Strings()), displayStyle: .Collection)
    }
    
}

extension Data: CustomStringConvertible, CustomDebugStringConvertible {
    
    /// A textual representation of `self`.
    public var description: String {
        return "<\(describeBytes())>"
    }
    
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return "<\(describeBytes(limit: 1024))>"
    }

}
