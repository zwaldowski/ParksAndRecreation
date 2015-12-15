//: [Previous](@previous)

import XCPlayground
import Foundation

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

/*: Another use: Use `dispatch_io_t` to efficiently read files in
chunks from disk. Though this rather contrived sample has the same
memory impact as reading a whole file into memory, it respects system
I/O contention.
*/

let bundle = NSBundle.mainBundle()
let sampleFileU8 = bundle.URLForResource("hello-U8", withExtension: "txt")!
let sampleFileU16B = bundle.URLForResource("hello-U16B", withExtension: "txt")!

//: The strings as read by Cocoa.
let cocoaStringU8 = try! String(contentsOfURL: sampleFileU8, encoding: NSUTF8StringEncoding)
let cocoaStringU16B = try! String(contentsOfURL: sampleFileU16B, encoding: NSUTF16BigEndianStringEncoding)

let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)

let io8 = dispatch_io_create_with_path(DISPATCH_IO_STREAM, sampleFileU8.fileSystemRepresentation, O_RDONLY, 0, queue, nil)
var data8 = Data<UInt8>()
dispatch_io_read(io8, 0, Int.max, queue) { (finished, nextData, errno) in
    switch (finished, nextData, errno) {
    case (true, nil, let errno):
        print("Error \(errno)")
    case (false, let nextData, _):
        data8 += try! Data(nextData)
    case (true, let nextData, _):
        data8 += try! Data(nextData)
        
        print("Done! \(data8)")
    }
}

/*: Reading a UTF-16 file poses a different challenge, and exposes the power
of a generic Data<T>. A given `Data` parameterized for something greater
than a byte must store the extra bytes in a separate buffer, or throw.
*/
let io16B = dispatch_io_create_with_path(DISPATCH_IO_STREAM, sampleFileU16B.fileSystemRepresentation, O_RDONLY, 0, queue, nil)
var data16B = Data<UInt16>()
var leftover = Data<UInt8>()
dispatch_io_read(io16B, 0, Int.max, queue) { (finished, nextData, errno) -> Void in
    switch (finished, nextData, errno) {
    case (true, nil, let errno):
        print("Error \(errno)")
    case (false, let nextData, _):
        data16B += Data(nextData, partial: &leftover)
    case (true, let nextData, _):
        data16B += Data(nextData, partial: &leftover)
        
        print("Done! \(data16B)")
    }
}

//: [Next](@next)
