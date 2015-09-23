//: [Previous](@previous)

//: Late builds of Swift 2.0 (including the final) made the following change:
//:
//: > C typedefs of block types are imported as typealiases for Swift closures.
//: > The primary result of this is that typedefs for blocks with a parameter of type `BOOL` are imported as closures with a parameter of type `Bool` (rather than `ObjCBool` as in the previous release). This matches the behavior of block parameters to imported Objective-C methods. (22013912)
//:
//: In code terms, the old one looks like this:

typealias OldBlock = @convention(block) () -> ()

//: And the new one is like this:

typealias NewBlock = () -> ()

//: Overall, this is an improvement as advertised. Objective-C blocks are generally compatible with Swift closures.
//:
//: But there's one important distinction: Swift closures are not objects.

let objCBlock: OldBlock = { print("Hey!") }
unsafeBitCast(objCBlock, AnyObject.self)

let swiftBlock: NewBlock = { print("Yo!") }

// This line would crash. Uncomment to see for yourself!
// unsafeBitCast(swiftBlock, AnyObject.self)

// The crash is an EXC_BAD_INSTRUCTION — a Swift `preconditionFailure`.

//: The playground's stopped running, so go to the [Next](@next) page.
