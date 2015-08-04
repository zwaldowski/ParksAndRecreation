import Foundation

private extension NSData {
    
    private func wrapToDispatchData(copy copy: Bool) -> dispatch_data_t {
        var ret = dispatch_data_empty
        enumerateByteRangesUsingBlock { (bytes, byteRange, _) in
            let chunk: dispatch_data_t
            if copy {
                chunk = dispatch_data_create(bytes, byteRange.length, nil, nil)
            } else {
                let innerData = Unmanaged.passRetained(self)
                chunk = dispatch_data_create(bytes, byteRange.length, nil) {
                    innerData.release()
                }
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
            return wrapToDispatchData(copy: true)
        } else {
            let copied: NSData = unsafeDowncast(copy())
            return copied.wrapToDispatchData(copy: copied !== self)
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
    
}

// MARK: AnyObject bridging

/// Swift standard library trickiness for `as AnyObject`. This API is not
/// expected to stick around forever, but for now it's nice.
extension Data: _ObjectiveCBridgeable {
    
    /// Return true iff instances of `Self` can be converted to
    /// Objective-C.
    public static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    /// The class type used in Objective-C.
    public static func _getObjectiveCType() -> Any.Type {
        return NSData.self
    }
    
    /// Convert `self` to Objective-C.
    public func _bridgeToObjectiveC() -> NSData {
        return data as! NSData
    }
    
    /// Bridge from an Objective-C object of the bridged class type to a
    /// value of `Self`, used for forced downcasting.
    ///
    /// :param: result The location where the result is written. The optional
    /// will always contain a value.
    public static func _forceBridgeFromObjectiveC(source: NSData, inout result: Data?) {
        result = try! Data(source)
    }
    
    /// Try to bridge from an Objective-C object of the bridged class
    /// type to a value of `Self`, used for conditional downcasting.
    ///
    /// :param: result The location where the result is written.
    ///
    /// :returns: true if bridging succeeded, false otherwise. This redundant
    /// information is provided for the convenience of the runtime.
    public static func _conditionallyBridgeFromObjectiveC(source: NSData, inout result: Data?) -> Bool {
        do {
            result = try Data(source)
            return true
        } catch {
            result = nil
            return false
        }
    }
    
}
