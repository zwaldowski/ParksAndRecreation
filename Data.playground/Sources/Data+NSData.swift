import Foundation

private extension NSData {
    
    func wrapToDispatchDataByCopy(copy: Bool) -> dispatch_data_t {
        var ret = dispatch_data_empty
        enumerateByteRangesUsingBlock { (bytes, byteRange, _) in
            let chunk: dispatch_data_t
            if copy {
                chunk = dispatch_data_create(bytes, byteRange.length, nil, nil)
            } else {
                let innerData = Unmanaged.passRetained(self)
                chunk = dispatch_data_create(bytes, byteRange.length, nil, innerData.release)
            }
            ret = dispatch_data_create_concat(ret, chunk)
        }
        return ret
    }
    
    @nonobjc var dispatchValue: dispatch_data_t {
        if length == 0 {
            return dispatch_data_empty
        } else if let dd = self as? dispatch_data_t {
            return dd
        } else if self is NSMutableData {
            return wrapToDispatchDataByCopy(true)
        } else {
            let copied: NSData = unsafeDowncast(copy())
            return copied.wrapToDispatchDataByCopy(copied !== self)
        }
    }
    
}

extension Data {
    
    /// Create a `Data` backed by `NSData`, only copying if necessary. If the
    /// bytes cannot be represented by a whole number of elements, the
    /// initializer will throw.
    public init(_ data: NSData) throws {
        try self.init(data.dispatchValue)
    }
    
    #if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    
    /// Convert `self` to Objective-C.
    public var objectValue: NSData {
        return data as! NSData
    }
    
    #endif
    
}
