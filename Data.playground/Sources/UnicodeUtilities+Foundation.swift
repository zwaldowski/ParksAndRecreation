import Foundation

extension NSData {

    public convenience init<T: UnsignedIntegerType>(_ bytes: UnsafeBufferPointer<T>) {
        self.init(bytes: UnsafePointer(bytes.baseAddress), length: bytes.count * sizeof(T))
    }

    public convenience init<T: UnsignedIntegerType>(noCopy bytes: UnsafeMutableBufferPointer<T>, freeWhenDone: Bool = true) {
        self.init(bytesNoCopy: UnsafeMutablePointer(bytes.baseAddress), length: bytes.count * sizeof(T), freeWhenDone: freeWhenDone)
    }

    public convenience init<T: UnsignedIntegerType>(noCopy bytes: UnsafeMutableBufferPointer<T>, deallocator inDeallocator: (UnsafeMutableBufferPointer<T> -> Void)? = nil) {
        let deallocator: ((UnsafeMutablePointer<Void>, Int) -> Void)? = inDeallocator.map { deallocator in {
            let buffer = UnsafeMutableBufferPointer<T>(start: UnsafeMutablePointer($0), count: $1)
            deallocator(buffer)
        }}
        self.init(bytesNoCopy: UnsafeMutablePointer(bytes.baseAddress), length: bytes.count * sizeof(T), deallocator: deallocator)
    }

    public func decode<Encoding: UnicodeCodecType where Encoding.CodeUnit: UnsignedIntegerType>(codec: Encoding.Type) -> String? {
        do {
            return try Data<Encoding.CodeUnit>(self).decode(codec)
        } catch {
            return nil
        }
    }
    
}
