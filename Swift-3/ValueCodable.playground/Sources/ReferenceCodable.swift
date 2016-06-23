
import Foundation

extension NSCoder {

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:forKey:)`.
    public func decodeValue<Value: ReferenceConvertible where Value.ReferenceType: NSCoding, Value.ReferenceType: NSObject>(of type: Value.Type = Value.self, forKey key: String? = nil) -> Value? {
        if let key = key {
            return decodeObjectOfClass(Value.ReferenceType.self, forKey: key) as? Value
        } else {
            return decodeObject() as? Value
        }
    }

    /// Decode a Swift type at the root of a hierarchy that was previously
    /// encoded with `encode(_:forKey:)`.
    ///
    /// The top-level distinction is important, as `NSCoder` uses Objective-C
    /// exceptions internally to communicate failure; here they are translated
    /// into Swift error-handling.
    @available(OSX 10.11, iOS 9.0, watchOS 2.0, tvOS 9.0, *)
    public func decodeTopLevelValue<Value: ReferenceConvertible where Value.ReferenceType: NSCoding, Value.ReferenceType: NSObject>(of type: Value.Type = Value.self, forKey key: String? = nil) throws -> Value? {
        if let key = key {
            return try decodeTopLevelObjectOfClass(Value.ReferenceType.self, forKey: key) as? Value
        } else {
            return try decodeTopLevelObject() as? Value
        }
    }

    /// Encodes a `value` and associates it with a given `key`.
    public func encode<Value: ReferenceConvertible where Value.ReferenceType: NSCoding>(_ value: Value, forKey key: String? = nil) {
        let object = value as? AnyObject
        if let key = key {
            encode(object, forKey: key)
        } else {
            encode(object)
        }
    }

}

extension NSKeyedArchiver {

    /// Returns a data object containing the encoded form of the instances whose
    /// root `value` is given.
    public static func archived<Value: ReferenceConvertible where Value.ReferenceType: NSCoding>(with value: Value) -> Data {
        let data = NSMutableData()

        autoreleasepool {
            let archiver = self.init(forWritingWith: data)
            defer { archiver.finishEncoding() }
            archiver.encode(value as? AnyObject, forKey: NSKeyedArchiveRootObjectKey)
        }

        return data as Data
    }
    
}
