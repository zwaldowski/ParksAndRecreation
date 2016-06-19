import Dispatch

/// A view of a byte buffer of a numeric values.
///
/// The elements generated are the concatenation of the bytes in the base 
/// buffer.
public struct DataGenerator<T: UnsignedIntegerType>: GeneratorType {
    
    private var bytes: FlattenGenerator<DataRegions.Generator>
    
    private init(_ bytes: FlattenCollection<DataRegions>) {
        self.bytes = bytes.generate()
    }
    
    private init(_ bytes: FlattenGenerator<DataRegions.Generator>) {
        self.bytes = bytes.generate()
    }
    
    private mutating func nextByte() -> UInt8? {
        return bytes.next()
    }
    
    /// Advance to the next element and return it, or `nil` if no next
    /// element exists.
    ///
    /// - Requires: No preceding call to `self.next()` has returned `nil`.
    public mutating func next() -> T? {
        return (0 ..< sizeof(T)).reduce(T.allZeros) { (current, byteIdx) -> T? in
            guard let current = current, byte = nextByte() else { return nil }
            return current | numericCast(byte.toUIntMax() << UIntMax(byteIdx * 8))
        }
    }
    
}

extension DataGenerator: SequenceType {
    
    /// Restart enumeration of the data.
    public func generate() -> DataGenerator<T> {
        return DataGenerator(bytes)
    }
    
}

extension Data: SequenceType {
    
    /// Return a *generator* over the `T`s that comprise this *data*.
    public func generate() -> DataGenerator<T> {
        return DataGenerator(bytes)
    }
    
}
