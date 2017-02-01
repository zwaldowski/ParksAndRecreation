import Foundation

/// Methods that a type must implement such that instances can be encoded and
/// decoded. This capability provides the basis for archiving and distribution.
///
/// In keeping with object-oriented design principles, a type being encoded
///  or decoded is responsible for encoding and decoding its storied properties.
///
/// - seealso: NSCoding
@available(iOS, introduced: 7.0, obsoleted: 11.0, message: "There should be a better way now.")
@available(macOS, introduced: 10.9, obsoleted: 10.13, message: "There should be a better way now.")
@available(watchOS, introduced: 2.0, obsoleted: 4.0, message: "There should be a better way now.")
@available(tvOS, introduced: 9.0, obsoleted: 11.0, message: "There should be a better way now.")
public protocol ValueCodable {
    /// Encodes `self` using a given archiver.
    func encode(with aCoder: NSCoder)
    /// Creates an instance from from data in a given unarchiver.
    init?(coder aDecoder: NSCoder)
}

private final class EncodingBox: NSObject, NSCoding {

    let value: ValueCodable
    
    init(_ value: ValueCodable) {
        self.value = value
        super.init()
    }
    
    init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func encode(with aCoder: NSCoder) {
        guard aCoder.allowsKeyedCoding, let archiver = aCoder as? NSKeyedArchiver else {
            preconditionFailure()
        }
        let className = aCoder.markerClassName(for: type(of: value))
        archiver.setClassName(className, for: type(of: self))
        value.encode(with: archiver)
        archiver.setClassName(className, for: type(of: self))
    }

}

private final class DecodingBox<Value: ValueCodable>: NSObject, NSCoding {
    
    let value: Value
    
    init?(coder aDecoder: NSCoder) {
        guard let value = Value(coder: aDecoder) else { return nil }
        self.value = value
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        fatalError()
    }

}

private extension NSCoder {
    
    func markerClassName(for type: ValueCodable.Type) -> String {
        return markerClassName(forName: String(describing: type))
    }
    
    func markerClassName(forName name: String) -> String {
        return "Encoded<\(name)>"
    }

}

@available(iOS, introduced: 7.0, obsoleted: 11.0, message: "There should be a better way now.")
@available(macOS, introduced: 10.9, obsoleted: 10.13, message: "There should be a better way now.")
@available(watchOS, introduced: 2.0, obsoleted: 4.0, message: "There should be a better way now.")
@available(tvOS, introduced: 9.0, obsoleted: 11.0, message: "There should be a better way now.")
extension NSCoder {

    private func valueByDecodingBox<Value: ValueCodable>(_ body: (NSKeyedUnarchiver) throws -> DecodingBox<Value>?) rethrows -> Value? {
        assert(allowsKeyedCoding)
        guard let archiver = self as? NSKeyedUnarchiver else { return nil }
        
        let className = markerClassName(for: Value.self)
        if archiver.class(forClassName: className) == nil {
            archiver.setClass(DecodingBox<Value>.self, forClassName: className)
        }

        guard let boxed = try body(archiver) else { return nil }
        return boxed.value
    }

    /// Decode a Swift type that was previously encoded with `encode(_:)`.
    public func decodeValue<Value: ValueCodable>(of type: Value.Type = Value.self) -> Value? {
        return valueByDecodingBox {
            $0.decodeObject() as? DecodingBox<Value>
        }
    }

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:forKey:)`.
    public func decodeValue<Value: ValueCodable>(of type: Value.Type = Value.self, forKey key: String) -> Value? {
        return valueByDecodingBox {
            $0.decodeObject(of: DecodingBox<Value>.self, forKey: key)
        }
    }

    /// Decode a Swift type at the root of a hierarchy that was previously
    /// encoded with `encode(_:)`.
    ///
    /// The top-level distinction is important, as `NSCoder` uses Objective-C
    /// exceptions internally to communicate failure; here they are translated
    /// into Swift error-handling.
    public func decodeTopLevelValue<Value: ValueCodable>(of type: Value.Type = Value.self) throws -> Value? {
        return try valueByDecodingBox {
            try $0.decodeTopLevelObject() as? DecodingBox<Value>
        }
    }

    /// Decode a Swift type at the root of a hierarchy that was previously
    /// encoded with `encode(_:forKey:)`.
    ///
    /// The top-level distinction is important, as `NSCoder` uses Objective-C
    /// exceptions internally to communicate failure; here they are translated
    /// into Swift error-handling.
    public func decodeTopLevelValue<Value: ValueCodable>(of type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        return try valueByDecodingBox {
            try $0.decodeTopLevelObject(of: DecodingBox<Value>.self, forKey: key)
        }
    }

    /// Encodes a `value` and associates it with a given `key`.
    public func encode(_ value: ValueCodable?) {
        encode(value.map(EncodingBox.init))
    }

    /// Encodes a `value` and associates it with a given `key`.
    public func encode(_ value: ValueCodable?, forKey key: String) {
        encode(value.map(EncodingBox.init), forKey: key)
    }

}

@available(iOS, introduced: 7.0, obsoleted: 11.0, message: "There should be a better way now.")
@available(macOS, introduced: 10.9, obsoleted: 10.13, message: "There should be a better way now.")
@available(watchOS, introduced: 2.0, obsoleted: 4.0, message: "There should be a better way now.")
@available(tvOS, introduced: 9.0, obsoleted: 11.0, message: "There should be a better way now.")
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

    /// Adds a type translation mapping to the receiver whereby values encoded
    /// with `name` are decoded as instances of `type` instead.
    public func setType<Value: ValueCodable>(_: Value.Type, forDecodingTypeNamed name: String) {
        setClass(DecodingBox<Value>.self, forClassName: markerClassName(forName: name))
    }

}

@available(iOS, introduced: 7.0, obsoleted: 11.0, message: "There should be a better way now.")
@available(macOS, introduced: 10.9, obsoleted: 10.13, message: "There should be a better way now.")
@available(watchOS, introduced: 2.0, obsoleted: 4.0, message: "There should be a better way now.")
@available(tvOS, introduced: 9.0, obsoleted: 11.0, message: "There should be a better way now.")
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
