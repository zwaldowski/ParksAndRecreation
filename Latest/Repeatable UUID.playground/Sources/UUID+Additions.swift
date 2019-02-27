import Foundation
import CommonCrypto

extension UUID {

    /// Generates a repeatable, hash-based identifier for some `value` inside
    /// a `namespace`.
    ///
    /// A hash-based UUID is derived using the [v5 UUID algorithm](http://tools.ietf.org/html/4122).
    /// It holds the characteristic of all UUIDs that chance of collision is
    /// negligible, allowing you to combine down input data (such as a long
    /// string combined from many sources) without having to pay the cost of
    /// storing and comparing that input data.
    public init(hashing value: String, inNamespace namespace: UUID) {
        var context = CC_SHA1_CTX()
        CC_SHA1_Init(&context)

        _ = withUnsafeBytes(of: namespace.uuid) { (buffer) in
            CC_SHA1_Update(&context, buffer.baseAddress, CC_LONG(buffer.count))
        }

        _ = value.withCString { (cString) in
            CC_SHA1_Update(&context, cString, CC_LONG(strlen(cString)))
        }

        var array = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1_Final(&array, &context)

        array[6] = (array[6] & 0x0F) | 0x50 // set version number nibble to 5
        array[8] = (array[8] & 0x3F) | 0x80 // reset clock nibbles

        // truncate to first 16
        self.init(uuid: (array[0], array[1], array[2], array[3],
                         array[4], array[5], array[6], array[7],
                         array[8], array[9], array[10], array[11],
                         array[12], array[13], array[14], array[15]))
    }

}
