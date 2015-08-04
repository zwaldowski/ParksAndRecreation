import Dispatch

public enum DataError: ErrorType {
    case PartialData
}

/// A read-only construct that conceptually models a buffer of numeric units.
public struct Data<T: UnsignedIntegerType> {
    
    /// The `dispatch_data_t` byte buffer representation.
    public let data: dispatch_data_t
    
    init(unsafe data: dispatch_data_t) {
        self.data = data
    }
    
    init(safe data: dispatch_data_t, @noescape withPartialData: Data<UInt8> throws -> ()) rethrows {
        let size = dispatch_data_get_size(data)
        let remainder = size % sizeof(T)
        if remainder == 0 {
            self.init(unsafe: data)
        } else {
            let wholeData = dispatch_data_create_subrange(data, 0, size - remainder)
            let partialData = dispatch_data_create_subrange(data, size - remainder, remainder)
            let partial = Data<UInt8>(unsafe: partialData)
            try withPartialData(partial)
            self.init(unsafe: wholeData)
        }
    }
    
    /// Create an empty data.
    public init() {
        self.init(unsafe: dispatch_data_empty)
    }
    
    /// Create data from `dispatch_data_t`. If the bytes cannot be represented
    /// by a whole number of elements, the given buffer will be replaced
    /// with the leftover amount. Any partial data will be combined with the
    /// given data.
    public init(_ data: dispatch_data_t, inout partial: Data<UInt8>) {
        let combined = dispatch_data_create_concat(partial.data, data)
        try! self.init(safe: combined) { data in
            partial = data
        }
    }
    
    /// Create data from `dispatch_data_t`. If the bytes cannot be represented
    /// by a whole number of elements, the initializer will throw.
    public init(_ data: dispatch_data_t) throws {
        try self.init(safe: data) { _ in
            throw DataError.PartialData
        }
    }
    
}

// MARK: Internal

extension Data {
    
    static func toBytes(i: Int) -> Int {
        return i / sizeof(T)
    }
    
    static func fromBytes(i: Int) -> Int {
        return i * sizeof(T)
    }
    
    private typealias Bytes = UnsafeBufferPointer<UInt8>
    
    private var startByte: Int {
        return 0
    }
    
    private var endByte: Int {
        return dispatch_data_get_size(data)
    }
    
    private func apply(function: (data: dispatch_data_t, range: HalfOpenInterval<Int>, buffer: Bytes) -> Bool) {
        dispatch_data_apply(data) { (data, offset, ptr, count) -> Bool in
            let buffer = Bytes(start: UnsafePointer(ptr), count: count)
            return function(data: data, range: offset..<offset+count, buffer: buffer)
        }
    }
    
    private func byteRangeForIndex(i: Int) -> HalfOpenInterval<Int> {
        let byteStart = Data.fromBytes(i)
        let byteEnd = byteStart + sizeof(T)
        return byteStart ..< byteEnd
    }
    
}

// MARK: Collection conformances

extension Data: SequenceType {
    
    /// A collection view representing the underlying contiguous byte buffers
    /// making up the data. Enumerating through this collection is useful
    /// for feeding an iterative API, such as crypto routines.
    public var byteRegions: DataRegions {
        return DataRegions(data: data)
    }
    
    /// Return a *generator* over the `T`s that comprise this *data*.
    public func generate() -> DataGenerator<T> {
        return DataGenerator(regions: byteRegions.generate())
    }
    
}

extension Data: Indexable {
    
    /// The position of the first element in the data.
    ///
    /// In empty data, `startIndex == endIndex`.
    public var startIndex: Int {
        return Data.toBytes(startByte)
    }
    
    /// The data's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    public var endIndex: Int {
        return Data.toBytes(endByte)
    }
    
    /// This subscript is not performance-friendly, and will always underperform
    /// enumeration of the `Data` or application accross its `byteRegions`.
    public subscript(i: Int) -> T {
        let byteRange = byteRangeForIndex(i)
        assert(byteRange.end < endByte, "Data index out of range")
        
        var ret = T.allZeros
        withUnsafeMutablePointer(&ret) { retPtrIn -> () in
            var retPtr = UnsafeMutablePointer<UInt8>(retPtrIn)
            apply { (_, chunkRange, buffer) -> Bool in
                let copyRange = chunkRange.clamp(byteRange)
                if !copyRange.isEmpty {
                    let size = copyRange.end - copyRange.start
                    memmove(retPtr, buffer.baseAddress + copyRange.start, size)
                    retPtr += size
                }
                return chunkRange.end < byteRange.end
            }
        }
        return ret
    }
    
}

extension Data: CollectionType {
    
    public subscript (bounds: Range<Int>) -> Data<T> {
        let offset = Data.toBytes(bounds.startIndex)
        let length = Data.toBytes(bounds.endIndex - bounds.startIndex)
        return Data(unsafe: dispatch_data_create_subrange(data, offset, length))
    }
    
}

// MARK: Concatenation

extension Data {
    
    /// Combine the recieving data with the given data in constant time.
    public mutating func extend(newData: Data<T>) {
        self += newData
    }
    
}

/// Combine `lhs` and `rhs` into a new buffer in constant time.
public func +<T: UnsignedIntegerType>(lhs: Data<T>, rhs: Data<T>) -> Data<T> {
    return Data(unsafe: dispatch_data_create_concat(lhs.data, rhs.data))
}

/// Operator form of `Data<T>.extend`.
public func +=<T: UnsignedIntegerType>(inout lhs: Data<T>, rhs: Data<T>) {
    lhs = lhs + rhs
}

// MARK: Mapped access

extension Data {
    
    /// Call `body(p)`, where `p` is a pointer to the data represented as
    /// contiguous storage. If the data is non-contiguous, this will trigger
    /// a copy of all buffers.
    public func withUnsafeBufferPointer<R>(@noescape body: UnsafeBufferPointer<T> -> R) -> R {
        var ptr: UnsafePointer<Void> = nil
        var byteCount = 0
        let map = dispatch_data_create_map(data, &ptr, &byteCount)
        let count = Data.fromBytes(byteCount)
        return withExtendedLifetime(map) {
            let buffer = UnsafeBufferPointer<T>(start: UnsafePointer(ptr), count: count)
            return body(buffer)
        }
    }
    
}

// MARK: Generators

/// The `SequenceType` returned by `Data.byteBuffers`.  `DataRegions`
/// is a sequence of byte buffers, represented in Swift as
/// `UnsafeBufferPointer<UInt8>`.
public struct DataRegions: SequenceType {
    
    private let data: dispatch_data_t
    
    private init(data: dispatch_data_t) {
        self.data = data
    }
    
    /// Start enumeration of byte buffers.
    public func generate() -> DataRegionsGenerator {
        return DataRegionsGenerator(data: data)
    }
    
}

/// A generator over the underlying contiguous storage of a `Data<T>`.
public struct DataRegionsGenerator: GeneratorType, SequenceType {
    
    private let data: dispatch_data_t
    private var region = dispatch_data_empty
    private var nextByteOffset = 0
    
    private init(data: dispatch_data_t) {
        self.data = data
    }
    
    /// Advance to the next buffer and return it, or `nil` if no more buffers
    /// exist.
    ///
    /// - Requires: No preceding call to `self.next()` has returned `nil`.
    public mutating func next() -> UnsafeBufferPointer<UInt8>? {
        if nextByteOffset >= dispatch_data_get_size(data) {
            return nil
        }
        
        let nextRegion = dispatch_data_copy_region(data, nextByteOffset, &nextByteOffset)
        
        // This won't remap the buffer because the region will be a leaf,
        // so it just returns the buffer
        var mapPtr = UnsafePointer<Void>()
        var mapSize = 0
        region = dispatch_data_create_map(nextRegion, &mapPtr, &mapSize)
        nextByteOffset += mapSize
        
        return UnsafeBufferPointer(start: UnsafePointer(mapPtr), count: mapSize)
    }
    
    /// Restart enumeration of byte buffers.
    public func generate() -> DataRegionsGenerator {
        return DataRegionsGenerator(data: data)
    }
    
}

public struct DataGenerator<T: UnsignedIntegerType>: GeneratorType, SequenceType {
    
    private var regions: DataRegionsGenerator
    private var buffer: UnsafeBufferPointerGenerator<UInt8>?
    
    private init(regions: DataRegionsGenerator) {
        self.regions = regions
    }
    
    private mutating func nextByte() -> UInt8? {
        // continue through existing region
        if let next = buffer?.next() { return next }
        
        // get next region
        guard let nextRegion = regions.next() else { return nil }
        
        // start generating
        var nextBuffer = nextRegion.generate()
        guard let byte = nextBuffer.next() else {
            buffer = nil
            return nil
        }
        buffer = nextBuffer
        return byte
    }
    
    /// Advance to the next element and return it, or `nil` if no next
    /// element exists.
    ///
    /// - Requires: No preceding call to `self.next()` has returned `nil`.
    public mutating func next() -> T? {
        return (0 ..< sizeof(T)).reduce(T.allZeros) { (current, byteIdx) -> T? in
            guard let current = current, byte = nextByte() else { return nil }
            return current | numericCast(byte << UInt8(byteIdx * 8))
        }
    }
    
    /// Restart enumeration of the data.
    public func generate() -> DataGenerator<T> {
        return DataGenerator(regions: regions.generate())
    }
    
}

// MARK: Introspection

extension Data: CustomStringConvertible {
    
    /// A textual representation of `self`.
    public var description: String {
        return data.description
    }
    
}

extension Data: CustomReflectable {
    
    /// Return the `Mirror` for `self`.
    public func customMirror() -> Mirror {
        // Appears as an array of the integer type, as suggested in the docs
        // for Mirror.init(_:unlabeledChildren:displayStyle:ancestorRepresentation:).
        // An improved version might show regions and/or segmented hex values.
        return Mirror(self, unlabeledChildren: self, displayStyle: .Collection)
    }
    
}
