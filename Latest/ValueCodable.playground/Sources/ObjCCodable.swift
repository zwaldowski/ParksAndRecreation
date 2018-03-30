import Foundation

extension NSCoder {

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:)`.
    public final func decodeValue<Value: NSCoding>(of _: Value.Type) -> Value? {
        return decodeObject() as? Value
    }

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:)`.
    public final func decodeValue<Value: _ObjectiveCBridgeable>(of _: Value.Type) -> Value? where Value._ObjectiveCType: NSCoding {
        return decodeObject() as? Value
    }

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:forKey:)`.
    public final func decodeValue<Value: NSCoding>(of type: Value.Type, forKey key: String) -> Value? where Value: NSObject {
        return decodeObject(of: type, forKey: key)
    }

    /// Decode a Swift type that was previously encoded with
    /// `encode(_:forKey:)`.
    public final func decodeValue<Value: _ObjectiveCBridgeable>(of type: Value.Type, forKey key: String) -> Value? where Value._ObjectiveCType: NSCoding, Value._ObjectiveCType: NSObject {
        return decodeObject(of: Value._ObjectiveCType.self, forKey: key).map(Value._unconditionallyBridgeFromObjectiveC)
    }

    /// Encodes `value` and associates it with the current position.
    public final func encode<Value: _ObjectiveCBridgeable>(_ value: Value?) where Value._ObjectiveCType: NSCoding {
        encode(value?._bridgeToObjectiveC())
    }

    /// Encodes a `value` and associates it with a given `key`.
    public final func encode<Value: _ObjectiveCBridgeable>(_ value: Value?, forKey key: String) where Value._ObjectiveCType: NSCoding {
        encode(value?._bridgeToObjectiveC(), forKey: key)
    }

}

extension NSKeyedUnarchiver {

    /// Decodes and returns the tree of values previously encoded into `data`.
    public static func unarchivedValue<Value: _ObjectiveCBridgeable>(of type: Value.Type, with data: Data) -> Value? where Value._ObjectiveCType: NSCoding {
        return unarchiveObject(with: data) as? Value
    }

}

extension NSKeyedArchiver {

    /// Returns a data object containing the encoded form of the instances whose
    /// root `value` is given.
    public static func archivedData<Value: _ObjectiveCBridgeable>(withRoot value: Value) -> Data where Value._ObjectiveCType: NSCoding {
        return archivedData(withRootObject: value._bridgeToObjectiveC())
    }

}
