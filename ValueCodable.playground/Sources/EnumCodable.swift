import Foundation

extension RawRepresentable where RawValue: NSCoding {

    public func encode(with coder: NSCoder) {
        rawValue.encodeWithCoder(coder)
    }

    public init?(coder: NSCoder) {
        guard let raw = RawValue(coder: coder) else { return nil }
        self.init(rawValue: raw)
    }

}

extension RawRepresentable where RawValue: ValueCodable {

    public func encode(with coder: NSCoder) {
        coder.encodeRootValue(rawValue)
    }

    public init?(coder: NSCoder) {
        guard let raw = coder.decodeRootValue(ofType: RawValue.self) else { return nil }
        self.init(rawValue: raw)
    }
    
}

extension RawRepresentable where RawValue: SignedIntegerType {

    public func encode(with coder: NSCoder) {
        coder.encodeInt64(numericCast(rawValue), forKey: NSKeyedArchiveRootObjectKey)
    }

    public init?(coder: NSCoder) {
        self.init(rawValue: numericCast(coder.decodeInt64ForKey(NSKeyedArchiveRootObjectKey)))
    }
    
}

extension RawRepresentable where RawValue == String {

    public func encode(with coder: NSCoder) {
        coder.encodeRootObject(rawValue)
    }

    public init?(coder: NSCoder) {
        guard let raw = coder.decodeObject() as? String else { return nil }
        self.init(rawValue: raw)
    }
    
}
