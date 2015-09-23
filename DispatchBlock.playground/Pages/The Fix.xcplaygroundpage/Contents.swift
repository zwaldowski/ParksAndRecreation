//: [Previous](@previous)

import XCPlayground
import Dispatch

XCPSetExecutionShouldContinueIndefinitely(true)

//: C functions are "safely" casted as long as their calling convention is the same. For better or worse, this is also true in C. Using this trick, you can redeclare C functions with better types. You could also do this in Swift 1.2 using `@asmname`, but that attribute was never documented, whereas `@convention(c)` is.

typealias GoodBlock = @convention(block) () -> Void

let blockCreate:   @convention(c) (dispatch_block_flags_t, dispatch_block_t) -> GoodBlock! = dispatch_block_create
let blockNotify:   @convention(c) (GoodBlock, dispatch_queue_t, dispatch_block_t) -> Void = dispatch_block_notify
let blockCancel:   @convention(c) (GoodBlock) -> Void = dispatch_block_cancel
let blockAfter:    @convention(c) (dispatch_time_t, dispatch_queue_t, GoodBlock) -> Void = dispatch_after

//: And now our example from the previous page works again:

let justARegularLookingClosure = { () -> () in
    print("Hey, I'm Swift!")
}

let wrapperBlock = blockCreate(DISPATCH_BLOCK_ASSIGN_CURRENT, justARegularLookingClosure)

blockNotify(wrapperBlock, dispatch_get_main_queue()) {
    print("I'm a notification handler!")
}

let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
blockAfter(time, dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), wrapperBlock)

blockCancel(wrapperBlock)

//: [Next](@next)
