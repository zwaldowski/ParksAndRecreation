import Foundation

extension NSCoder {

    /// Decode a Swift type that was previously encoded with
    /// `encodeValue(_:forKey:)`.
    public func decodeValue<Value: _ObjectiveCBridgeable where Value._ObjectiveCType: NSCoding, Value._ObjectiveCType: NSObject>(ofType _: Value.Type = Value.self, forKey key: String? = nil) -> Value? {
        if let key = key {
            return decodeObjectOfClass(Value._ObjectiveCType.self, forKey: key) as? Value
        } else {
            return decodeObject() as? Value
        }
    }

    /// Decode a Swift type at the root of a hierarchy that was previously
    /// encoded with `encodeValue(_:forKey:)`.
    ///
    /// The top-level distinction is important, as `NSCoder` uses Objective-C
    /// exceptions internally to communicate failure; here they are translated
    /// into Swift error-handling.
    public func decodeTopLevelValue<Value: _ObjectiveCBridgeable where Value._ObjectiveCType: NSCoding, Value._ObjectiveCType: NSObject>(ofType _: Value.Type = Value.self, forKey key: String? = nil) throws -> Value? {
        if let key = key {
            return try decodeTopLevelObjectOfClass(Value._ObjectiveCType.self, forKey: key) as? Value
        } else {
            return try decodeTopLevelObject() as? Value
        }
    }

    /// Encodes a `value` and associates it with a given `key`.
    public func encodeValue<Value: _ObjectiveCBridgeable>(value: Value, forKey key: String? = nil) {
        let object = value as? AnyObject
        if let key = key {
            encodeObject(object, forKey: key)
        } else {
            encodeObject(object)
        }
    }

}

extension NSKeyedUnarchiver {

    /// Decodes and returns the tree of values previously encoded into `data`.
    public static func unarchivedValue<Value: _ObjectiveCBridgeable where Value._ObjectiveCType: NSCoding, Value._ObjectiveCType: NSObject>(ofType _: Value.Type = Value.self, withData data: NSData) throws -> Value? {
        return try unarchiveTopLevelObjectWithData(data) as? Value
    }

}

extension NSKeyedArchiver {

    /// Returns a data object containing the encoded form of the instances whose
    /// root `value` is given.
    public static func archivedData<Value: _ObjectiveCBridgeable>(withValue value: Value) -> NSData {
        let data = NSMutableData()

        autoreleasepool {
            let archiver = self.init(forWritingWithMutableData: data)
            archiver.encodeObject(value as? AnyObject, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
        }

        return data
    }

}
