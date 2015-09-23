//: [Previous](@previous)

import XCPlayground
import Dispatch

XCPSetExecutionShouldContinueIndefinitely(true)

//: A wrapper block isn't truly compatible with the idea of closures in Swift. Sneaky side-table data aside, it doesn't make sense to "cancel" a function, because a function isn't an object. It doesn't have identity.
//:
//: Thus, to make the workaround cleaner, and more rational in Swift, let's wrap up all the `dispatch_block_*` functions in a single type.

let block = DispatchBlock(flags: .CurrentContext) {
    print("Hey, I shouldn't be called!")
}

block.upon(dispatch_get_main_queue()) {
    print("I'm a notification handler!")
}

block.callUponQueue(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), afterDelay: 0.5)

block.cancel()
