//: [Previous](@previous)

import Foundation
import XCPlayground

// MARK: -

[ 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21 ].decode(UTF8.self)

// MARK: -

let XCPlaygroundTemporaryDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

let string = "Hello, playground\n🤗"
let dataURL = XCPlaygroundTemporaryDirectoryURL.URLByAppendingPathComponent("hello-U16B.txt")

try! string.writeToURL(dataURL, atomically: false, encoding: NSUTF16BigEndianStringEncoding)

// MARK: - Test encoding

let data1 = string.dataUsingEncoding(NSUTF16BigEndianStringEncoding)!
let data2 = string.unicodeScalars.encode(UTF16BE.self).withUnsafeBufferPointer(NSData.init)
data1 == data2

// MARK: - Test decoding

let finalString = data2.decode(UTF16BE.self)
finalString == string

//: [Next](@next)
