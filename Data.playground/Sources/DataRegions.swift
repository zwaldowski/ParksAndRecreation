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

/// The `CollectionType` returned by `Data.byteRegionsView`.  `DataRegionsView`
/// is a forward collection of byte buffers, represented in Swift as
/// `UnsafeBufferPointer<UInt8>`.
public struct DataRegionsView {
    
    private let data: dispatch_data_t
    
    private init(_ data: dispatch_data_t) {
        self.data = data
    }
    
}

extension DataRegionsView: SequenceType {
    
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

extension DataRegionsView: CollectionType {
    
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
        /// `DataRegionsView.Index` values.
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
        precondition(position.data === data, "Invalid Index for this DataRegionsViewNew view")
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
public func ==(lhs: DataRegionsView.Index, rhs: DataRegionsView.Index) -> Bool {
    return lhs.data === rhs.data && lhs.startOffset == rhs.startOffset
}

extension Data {
    
    /// A collection view representing the underlying contiguous byte buffers
    /// making up the data. Enumerating through this collection is useful
    /// for feeding an iterative API, such as crypto routines.
    public var byteRegionsView: DataRegionsView {
        return DataRegionsView(data)
    }
    
    /// A collection view representing the actual bytes making up the data.
    /// Enumerating through this collection, though with a performance cost,
    /// is good for presentation and debugging.
    public var bytesView: FlattenCollection<DataRegionsView> {
        return byteRegionsView.flatten()
    }
    
}

// MARK: Introspection

extension Data: CustomReflectable {
    
    /// Return the `Mirror` for `self`.
    public func customMirror() -> Mirror {
        // Appears as an array of the integer type, as suggested in the docs
        // for Mirror.init(_:unlabeledChildren:displayStyle:ancestorRepresentation:).
        // An improved version might show segmented hex values.
        let hexBytes = bytesView.lazy.map { "0x" + String($0, radix: 16) }
        return Mirror(self, unlabeledChildren: hexBytes, displayStyle: .Collection)
    }
    
}
