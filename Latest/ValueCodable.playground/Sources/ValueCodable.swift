import Foundation

/// Methods that a type must implement such that instances can be encoded and
/// decoded. This capability provides the basis for archiving and distribution.
///
/// In keeping with object-oriented design principles, a type being encoded
///  or decoded is responsible for encoding and decoding its storied properties.
///
/// - seealso: NSCoding
public protocol ValueCodable {
    /// Encodes `self` using a given archiver.
    func encode(with aCoder: NSCoder)
    /// Creates an instance from from data in a given unarchiver.
    init?(coder aDecoder: NSCoder)
}

@available(swift, obsoleted: 4, message: "There is a better way now.")
extension NSCoder {

    private func valueByTopLevelDecoding<Value: ValueCodable>(_ data: Data) throws -> Value? {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.decodingFailurePolicy = .setErrorAndReturn

        if let value = Value(coder: unarchiver) {
            return value
        } else if let error = unarchiver.error {
            throw error
        }
        return nil
    }

    /// Decode a Swift type that was previously encoded with `encode(_:)`.
    public func decodeValue<Value: ValueCodable>(of type: Value.Type = Value.self) -> Value? {
        guard let data = decodeObject() as? Data else {
            return nil
        }

        do {
            return try valueByTopLevelDecoding(data)
        } catch {
            failWithError(error)
            return nil
        }
    }

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:forKey:)`.
    public func decodeValue<Value: ValueCodable>(of type: Value.Type = Value.self, forKey key: String) -> Value? {
        guard let data = decodeObject(of: NSData.self, forKey: key) as Data? else {
            return nil
        }

        do {
            return try valueByTopLevelDecoding(data)
        } catch {
            failWithError(error)
            return nil
        }
    }

    /// Decode a Swift type at the root of a hierarchy that was previously
    /// encoded with `encode(_:)`.
    ///
    /// The top-level distinction is important, as `NSCoder` uses Objective-C
    /// exceptions internally to communicate failure; here they are translated
    /// into Swift error-handling.
    public func decodeTopLevelValue<Value: ValueCodable>(of type: Value.Type = Value.self) throws -> Value? {
        guard let data = try decodeTopLevelObject() as? Data else {
            return nil
        }

        return try valueByTopLevelDecoding(data)
    }

    /// Decode a Swift type at the root of a hierarchy that was previously
    /// encoded with `encode(_:forKey:)`.
    ///
    /// The top-level distinction is important, as `NSCoder` uses Objective-C
    /// exceptions internally to communicate failure; here they are translated
    /// into Swift error-handling.
    public func decodeTopLevelValue<Value: ValueCodable>(of type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        guard let data = try decodeTopLevelObject(of: NSData.self, forKey: key) as Data? else {
            return nil
        }

        return try valueByTopLevelDecoding(data)
    }

    private func dataByTopLevelEncoding(for value: ValueCodable?) throws -> Data {
        let encoder = NSKeyedArchiver()
        value?.encode(with: encoder)

        if let error = encoder.error {
            throw error
        } else {
            return encoder.encodedData
        }
    }

    /// Encodes a `value` and associates it with a given `key`.
    public func encode(_ value: ValueCodable?) {
        do {
            try encode(dataByTopLevelEncoding(for: value))
        } catch {
            failWithError(error)
        }
    }

    /// Encodes a `value` and associates it with a given `key`.
    public func encode(_ value: ValueCodable?, forKey key: String) {
        do {
            try encode(dataByTopLevelEncoding(for: value), forKey: key)
        } catch {
            failWithError(error)
        }
    }

}

@available(swift, obsoleted: 4, message: "There is a better way now.")
extension NSKeyedUnarchiver {

    /// Decodes and returns the tree of values previously encoded into `data`.
    public class func unarchivedValue<Value: ValueCodable>(of type: Value.Type = Value.self, with data: Data) -> Value? {
        let unarchiver = self.init(forReadingWith: data)
        defer { unarchiver.finishDecoding() }
        return unarchiver.decodeValue(forKey: NSKeyedArchiveRootObjectKey)
    }

    /// Decodes and returns the tree of values previously encoded into `data`.
    public class func unarchivedTopLevelValue<Value: ValueCodable>(of type: Value.Type = Value.self, with data: Data) throws -> Value? {
        let unarchiver = self.init(forReadingWith: data)
        defer { unarchiver.finishDecoding() }
        return try unarchiver.decodeTopLevelValue(forKey: NSKeyedArchiveRootObjectKey)
    }

}

@available(swift, obsoleted: 4, message: "There is a better way now.")
extension NSKeyedArchiver {

    /// Returns a data object containing the encoded form of the instances whose
    /// root `value` is given.
    public class func archivedData(withRoot value: ValueCodable?) -> Data {
        let data = NSMutableData()

        autoreleasepool {
            let archiver = self.init(forWritingWith: data)
            archiver.encode(value, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
        }

        return data as Data
    }

}
