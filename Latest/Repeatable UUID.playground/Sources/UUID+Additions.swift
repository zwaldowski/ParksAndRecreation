import Foundation
import CryptoKit

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
        var context = Insecure.SHA1()

        withUnsafeBytes(of: namespace.uuid) { bufferPointer in
            context.update(bufferPointer: bufferPointer)
        }

        context.update(data: Data(value.utf8))

        // truncate to first 16
        var uuid = context.finalize().withUnsafeBytes {
            ($0[0], $0[1], $0[2], $0[3],
             $0[4], $0[5], $0[6], $0[7],
             $0[8], $0[9], $0[10], $0[11],
             $0[12], $0[13], $0[14], $0[15])
        }

        uuid.6 = (uuid.6 & 0x0F) | 0x50 // set version number nibble to 5
        uuid.8 = (uuid.8 & 0x3F) | 0x80 // reset clock nibbles

        self.init(uuid: uuid)
    }

}
