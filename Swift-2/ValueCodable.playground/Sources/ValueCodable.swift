import Foundation

/// Methods that a type must implement such that instances can be encoded and
/// decoded. This capability provides the basis for archiving and distribution.
///
/// In keeping with object-oriented design principles, a type being encoded
///  or decoded is responsible for encoding and decoding its storied properties.
///
/// - seealso: NSCoding
@available(iOS, introduced=7.0, obsoleted=10.0, message="There should be a better way.")
@available(OSX, introduced=10.9, obsoleted=10.12, message="There should be a better way.")
@available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
@available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
public protocol ValueCodable {
    /// Encodes `self` using a given archiver.
    func encode(with aCoder: NSCoder)
    /// Creates an instance from from data in a given unarchiver.
    init?(coder aDecoder: NSCoder)
}

private final class CodingBox<Value: ValueCodable>: NSObject, NSCoding {

    init(_ value: Value) {
        self.value = value
        super.init()
    }

    let value: Value!

    @objc func encodeWithCoder(aCoder: NSCoder) {
        value.encode(with: aCoder)
    }

    @objc init?(coder aDecoder: NSCoder) {
        guard let value = Value(coder: aDecoder) else {
            self.value = nil
            super.init()
            return nil
        }
        self.value = value
        super.init()
    }

}

private extension NSCoder {

    func boxedClassNameFor(name: String) -> String {
        return "Encoded<\(name)>"
    }

    func byDecodingBox<Value: ValueCodable>(@noescape body: NSKeyedUnarchiver throws -> CodingBox<Value>?) rethrows -> Value? {
        assert(allowsKeyedCoding)

        guard let archiver = self as? NSKeyedUnarchiver else { return nil }
        archiver.setType(Value.self, forTypeName: String(Value.self), force: false)

        guard let boxed = try body(archiver) else { return nil }
        return boxed.value
    }

    func encodeBox<Value: ValueCodable>(@autoclosure withValue getValue: () -> Value, @noescape body: (NSKeyedArchiver, CodingBox<Value>) throws -> Void) rethrows {
        assert(allowsKeyedCoding)

        guard let archiver = self as? NSKeyedArchiver else { return }
        archiver.setName(String(Value.self), forType: Value.self)

        return try body(archiver, .init(getValue()))
    }

}

extension NSCoder {

    /// Decode a Swift type that was previously encoded with
    /// `encodeValue(_:forKey:)`.
    @available(iOS, introduced=7.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.9, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public func decodeValue<Value: ValueCodable>(ofType _: Value.Type = Value.self, forKey key: String? = nil) -> Value? {
        return byDecodingBox {
            if let key = key {
                return $0.decodeObjectOfClass(CodingBox<Value>.self, forKey: key)
            } else {
                return $0.decodeObject() as? CodingBox<Value>
            }
        }
    }

    /// Decode a Swift type at the root of a hierarchy that was previously
    /// encoded with `encodeValue(_:forKey:)`.
    ///
    /// The top-level distinction is important, as `NSCoder` uses Objective-C
    /// exceptions internally to communicate failure; here they are translated
    /// into Swift error-handling.
    @available(iOS, introduced=9.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.10, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public func decodeTopLevelValue<Value: ValueCodable>(ofType _: Value.Type = Value.self, forKey key: String? = nil) throws -> Value? {
        return try byDecodingBox {
            if let key = key {
                return try $0.decodeTopLevelObjectOfClass(CodingBox<Value>.self, forKey: key)
            } else {
                return try $0.decodeTopLevelObject() as? CodingBox<Value>
            }
        }
    }

    /// Encodes a `value` and associates it with a given `key`.
    @available(iOS, introduced=7.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.9, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public func encodeValue<Value: ValueCodable>(value: Value, forKey key: String? = nil) {
        encodeBox(withValue: value) {
            if let key = key {
                $0.encodeObject($1, forKey: key)
            } else {
                $0.encodeRootObject($1)
            }
        }
    }

}

extension NSKeyedUnarchiver {

    /// Decodes and returns the tree of values previously encoded into `data`.
    @available(iOS, introduced=7.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.9, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public class func unarchivedValue<Value: ValueCodable>(ofType type: Value.Type = Value.self, withData data: NSData) -> Value? {
        let unarchiver = self.init(forReadingWithData: data)
        defer { unarchiver.finishDecoding() }
        return unarchiver.decodeValue(forKey: NSKeyedArchiveRootObjectKey)
    }

    /// Decodes and returns the tree of values previously encoded into `data`.
    @available(iOS, introduced=9.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.10, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public class func unarchivedTopLevelValue<Value: ValueCodable>(ofType type: Value.Type = Value.self, withData data: NSData) throws -> Value? {
        let unarchiver = self.init(forReadingWithData: data)
        defer { unarchiver.finishDecoding() }
        return try unarchiver.decodeTopLevelValue(forKey: NSKeyedArchiveRootObjectKey)
    }

    private func setType<Value: ValueCodable>(_: Value.Type, forTypeName name: String, force: Bool) {
        let className = boxedClassNameFor(name)
        guard force || classForClassName(className) == nil else { return }
        setClass(CodingBox<Value>.self, forClassName: className)
    }

    /// Adds a type translation mapping to the receiver whereby values encoded
    /// with `name` are decoded as instances of `type` instead.
    @available(iOS, introduced=7.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.9, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public func setType<Value: ValueCodable>(_: Value.Type, forTypeName name: String) {
        setType(Value.self, forTypeName: name, force: true)
    }

}

extension NSKeyedArchiver {

    /// Returns a data object containing the encoded form of the instances whose
    /// root `value` is given.
    @available(iOS, introduced=7.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.9, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public class func archivedData<Value: ValueCodable>(withValue value: Value) -> NSData {
        let data = NSMutableData()

        autoreleasepool {
            let archiver = self.init(forWritingWithMutableData: data)
            archiver.encodeValue(value, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
        }
        
        return data
    }

    /// Adds a type translation mapping to the receiver whereby instances of
    /// `type` are encoded with `name` instead of their type names.
    @available(iOS, introduced=7.0, obsoleted=10.0, message="There should be a better way.")
    @available(OSX, introduced=10.9, obsoleted=10.12, message="There should be a better way.")
    @available(watchOS, introduced=2.0, obsoleted=3.0, message="There should be a better way.")
    @available(tvOS, introduced=9.0, obsoleted=10.10, message="There should be a better way.")
    public func setName<Value: ValueCodable>(name: String, forType type: Value.Type = Value.self) {
        setClassName(boxedClassNameFor(String(type)), forClass: CodingBox<Value>.self)
    }
    
}
