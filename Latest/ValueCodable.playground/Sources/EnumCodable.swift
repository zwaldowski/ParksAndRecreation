import Foundation

@available(swift, obsoleted: 4, message: "There is a better way now.")
extension RawRepresentable where Self: ValueCodable, RawValue: ValueCodable {

    /// Encodes `self` using a given archiver.
    public func encode(with coder: NSCoder) {
        coder.encode(rawValue)
    }

    /// Creates an instance from from data in a given unarchiver.
    public init?(coder: NSCoder) {
        guard let raw = coder.decodeValue(of: RawValue.self) else { return nil }
        self.init(rawValue: raw)
    }

}

@available(swift, obsoleted: 4, message: "There is a better way now.")
extension RawRepresentable where Self: ValueCodable, RawValue: _ObjectiveCBridgeable, RawValue._ObjectiveCType: NSCoding {

    /// Encodes `self` using a given archiver.
    public func encode(with coder: NSCoder) {
        coder.encode(rawValue._bridgeToObjectiveC())
    }

    /// Creates an instance from from data in a given unarchiver.
    public init?(coder: NSCoder) {
        guard let raw = coder.decodeObject() as? RawValue else { return nil }
        self.init(rawValue: raw)
    }

}
