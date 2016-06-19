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

private extension Data {
    
    static func toBytes(i: Int) -> Int {
        return i / sizeof(T)
    }
    
    static func fromBytes(i: Int) -> Int {
        return i * sizeof(T)
    }
    
    var startByte: Int {
        return 0
    }
    
    var endByte: Int {
        return dispatch_data_get_size(data)
    }
    
}

// MARK: Slicing

extension Data {
    
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
    
    public subscript (bounds: Range<Int>) -> Data<T> {
        let offset = Data.toBytes(bounds.startIndex)
        let length = Data.toBytes(bounds.endIndex - bounds.startIndex)
        return Data(unsafe: dispatch_data_create_subrange(data, offset, length))
    }
    
}

// MARK: Concatenation

extension Data {
    
    /// Combine the recieving data with the given data in constant time.
    public mutating func appendContentsOf(newData: Data<T>) {
        self += newData
    }
    
}

/// Combine `lhs` and `rhs` into a new buffer in constant time.
public func +<T: UnsignedIntegerType>(lhs: Data<T>, rhs: Data<T>) -> Data<T> {
    return Data(unsafe: dispatch_data_create_concat(lhs.data, rhs.data))
}

/// Operator form of `Data<T>.appendContentsOf`.
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
