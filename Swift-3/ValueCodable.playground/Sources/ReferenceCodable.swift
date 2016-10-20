
import Foundation

extension NSCoder {

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:forKey:)`.
    public func decodeValue<Value: ReferenceConvertible>(of type: Value.Type = Value.self, forKey key: String? = nil) -> Value? where Value.ReferenceType: NSCoding, Value.ReferenceType: NSObject {
        if let key = key {
            return decodeObject(of: Value.ReferenceType.self, forKey: key) as? Value
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
    @available(macOS 10.11, iOS 9.0, watchOS 2.0, tvOS 9.0, *)
    public func decodeTopLevelValue<Value: ReferenceConvertible>(of type: Value.Type = Value.self, forKey key: String? = nil) throws -> Value? where Value.ReferenceType: NSCoding, Value.ReferenceType: NSObject {
        if let key = key {
            return try decodeTopLevelObject(of: Value.ReferenceType.self, forKey: key) as? Value
        } else {
            return try decodeTopLevelObject() as? Value
        }
    }

}

extension NSKeyedArchiver {

    /// Returns a data object containing the encoded form of the instances whose
    /// root `value` is given.
    public static func archivedData<Value: ReferenceConvertible>(withRoot value: Value) -> Data where Value.ReferenceType: NSCoding {
        let data = NSMutableData()

        autoreleasepool {
            let archiver = self.init(forWritingWith: data)
            defer { archiver.finishEncoding() }
            archiver.encode(value as AnyObject, forKey: NSKeyedArchiveRootObjectKey)
        }

        return data as Data
    }
    
}
