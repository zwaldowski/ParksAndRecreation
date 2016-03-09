import Foundation

@available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
public protocol ValueCodable {
    func encode(with aCoder: NSCoder)
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

    func byDecodingBox<Value>(@noescape body: NSKeyedUnarchiver throws -> CodingBox<Value>?) rethrows -> Value? {
        assert(allowsKeyedCoding)

        guard let archiver = self as? NSKeyedUnarchiver else { return nil }
        archiver.setClass(CodingBox<Value>.self, forClassName: String(CodingBox<Value>.self))

        guard let boxed = try body(archiver) else { return nil }
        return boxed.value
    }

    func encodeBox<Value>(@autoclosure withValue getValue: () -> Value, @noescape body: (NSKeyedArchiver, CodingBox<Value>) throws -> Void) rethrows {
        assert(allowsKeyedCoding)

        guard let archiver = self as? NSKeyedArchiver else { return }
        archiver.setClassName(String(CodingBox<Value>.self), forClass: CodingBox<Value>.self)

        return try body(archiver, .init(getValue()))
    }

}

extension NSCoder {

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public func decodeRootValue<Value: ValueCodable>(ofType type: Value.Type = Value.self) -> Value? {
        return byDecodingBox {
            $0.decodeObject() as? CodingBox<Value>
        }
    }

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public func decodeTopLevelRootValue<Value: ValueCodable>(ofType type: Value.Type = Value.self) throws -> Value? {
        return try byDecodingBox {
            try $0.decodeTopLevelObject() as? CodingBox<Value>
        }
    }

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public func decodeValue<Value: ValueCodable>(ofType type: Value.Type = Value.self, forKey key: String) -> Value? {
        return byDecodingBox {
            $0.decodeObjectOfClass(CodingBox<Value>.self, forKey: key)
        }
    }

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public func decodeTopLevelValue<Value: ValueCodable>(ofType type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        return try byDecodingBox {
            try $0.decodeTopLevelObjectOfClass(CodingBox<Value>.self, forKey: key)
        }
    }

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public func encodeRootValue<Value: ValueCodable>(value: Value) {
        encodeBox(withValue: value) {
            $0.encodeRootObject($1)
        }
    }

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public func encodeValue<Value: ValueCodable>(value: Value, forKey key: String) {
        encodeBox(withValue: value) {
            $0.encodeObject($1, forKey: key)
        }
    }

}

extension NSKeyedUnarchiver {

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public class func unarchivedRootValue<Value: ValueCodable>(ofType type: Value.Type = Value.self, withData data: NSData) throws -> Value? {
        let unarchiver = self.init(forReadingWithData: data)
        return try unarchiver.decodeTopLevelRootValue()
    }

}

extension NSKeyedArchiver {

    @available(iOS, introduced=8.0, obsoleted=10.0, message="There should be a better way.")
    public class func archivedData<Value: ValueCodable>(withRootValue rootValue: Value) -> NSData {
        let data = NSMutableData()

        autoreleasepool {
            let archiver = self.init(forWritingWithMutableData: data)
            archiver.encodeRootValue(rootValue)
            archiver.finishEncoding()
        }
        
        return data
    }
    
}
