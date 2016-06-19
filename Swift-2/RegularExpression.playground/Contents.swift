//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

// MARK: - Ranges

extension NSRange: CustomStringConvertible {
    
    private func nonNull() -> NSRange? {
        guard location != NSNotFound else { return nil }
        return self
    }
    
    public var description: String {
        return toRange()?.description ?? ""
    }
    
}

let simpleString = "this is a test"
let simpleTestRange = simpleString.rangeOfString("test")!
let simpleTestNSRange = (simpleString as NSString).rangeOfString("test").nonNull()!

let complexString = "🇺🇸 ce ne est pas un test"
let complexTestRange = complexString.rangeOfString("test")!
let complexTestNSRange = (complexString as NSString).rangeOfString("test").nonNull()!

let simpleNativeToCocoa = NSRange(simpleTestRange, within: simpleString)
NSEqualRanges(simpleNativeToCocoa, simpleTestNSRange)

let simpleCocoaToNative = simpleTestNSRange.sameRangeIn(simpleString)!
simpleCocoaToNative == simpleTestRange

let complexNativeToCocoa = complexTestNSRange.sameRangeIn(complexString)!
complexNativeToCocoa == complexTestRange

let complexCocoaToNative = NSRange(complexTestRange, within: complexString)
NSEqualRanges(complexCocoaToNative, complexTestNSRange)

// MARK: - Regexes

let s = "👹👀🐼📱"
let regex = try! NSRegularExpression(pattern: "🐼", options: [])

// MARK: NSString

let nsRangeWhole = NSRange(s.characters.indices, within: s)
let nsRange = regex.rangeOfFirstMatchInString(s, options: [], range: nsRangeWhole)
let range = nsRange.sameRangeIn(s)!
s[range]

// MARK: Swift String

if let match = s.match(regex) {
    match.range
    String(match)
}
