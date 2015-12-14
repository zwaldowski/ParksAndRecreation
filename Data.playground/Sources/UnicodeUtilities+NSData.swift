import Foundation

extension NSData {
    
    public convenience init<T: IntegerType>(bytes: UnsafeBufferPointer<T>) {
        self.init(bytes: UnsafePointer(bytes.baseAddress), length: bytes.count * sizeof(T))
    }
    
    public func decode<Encoding: UnicodeCodecType where Encoding.CodeUnit: IntegerType>(codec: Encoding.Type) -> String? {
        return withExtendedLifetime(self) {
            let buf = UnsafeBufferPointer<Encoding.CodeUnit>(start: UnsafePointer(bytes), count: length / sizeof(Encoding.CodeUnit.self))
            return buf.decode(codec)
        }
    }
    
}
