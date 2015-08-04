/*:
# Data

## Low-Level Byte Management in Swift

`dispatch_data_t` is a low-level storage type in Grand Central Dispatch modelling opaque containers of bytes that may potentially be represented discontiguously. `Data` provides a high-level API resembling that of `NSData`, but with Swift niceties like type safety, collection enumeration, indexing, slicing, and zero-cost abstraction.
*/

//: One example use case of the `Data` type is low-level string parsing.

/*:
Create a sample data store. This initializer is an example of `Data` that
captures a Swift collection, like an `Array`.
*/
let data = Data<UInt8>(array: [ 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21 ])

/*:
The `Data` type is most efficiently used through enumeration rather than
indexing. This generator goes through each element in sequence — even if the
data is discontiguous.
*/
var generator = data.generate()

//: Use Swift's UTF-8 decoding mechanism to append scalars to a string.
var string = ""
var encoder = UTF8()

loop: while true {
    let result = encoder.decode(&generator)
    switch result {
    case .Result(let scalar):
        string.append(scalar)
    case .EmptyInput:
        break loop
    case .Error:
        string.append("\u{FFFD}" as UnicodeScalar)
    }
}

//: The resulting string:
string
