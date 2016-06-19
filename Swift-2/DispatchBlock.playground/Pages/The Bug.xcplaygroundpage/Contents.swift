//: [Previous](@previous)

import XCPlayground
import Dispatch

// Since we hop onto a background queue, the playground shouldn't finish running when it reaches the end of the file.
XCPSetExecutionShouldContinueIndefinitely(true)

//: OK, so how is this a bug? When is a block not a block? As it turns out - in Grand Central Dispatch, it does!
//:
//: In iOS 8, Apple introduced a bunch of `dispatch_block_*` functions:
//:  - dispatch_block_create
//:  - dispatch_block_create_with_qos_class
//:  - dispatch_block_perform
//:  - dispatch_block_wait
//:  - dispatch_block_notify
//:  - dispatch_block_cancel
//:  - dispatch_block_testcancel
//:
//: These interfaces all rely on `dispatch_block_t` being a no-paremter, no-return block, and use that assumption to make a "wrapper block" - it looks like
//: a block, and acts like a block, but contains extra data (you can think of them as instance variables) to do waits and notifications.
//:
//: So, this used to work:

let justARegularLookingClosure = { () -> () in
    print("Hey, I'm Swift!")
}

let wrapperBlock = dispatch_block_create(DISPATCH_BLOCK_ASSIGN_CURRENT, justARegularLookingClosure)

dispatch_block_notify(wrapperBlock, dispatch_get_main_queue()) {
    print("I'm a notification handler!")
}

let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
dispatch_after(time, dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), wrapperBlock)

dispatch_block_cancel(wrapperBlock)

//: The playground's stopped running again with another `EXC_BAD_INSTRUCTION`. But, if you looked at it in a project, it's within `dispatch_block_cancel` - C code
//: is trapping?
//:
//: GCD built in release mode has assertion logging disabled, but helpfully leaves the strings in the assembly right above the trap:
//: > BUG IN CLIENT OF LIBDISPATCH: Invalid block object passed to dispatch_block_cancel()
//:
//: But it's not invalid! We just created it with `dispatch_block_create` right there!
//:
//: The bug amounts to an incorrect audit: the above mentioned functions all continue to use `dispatch_block_t`, which Swift thinks is just a regular closure. Thus,
//: as soon as the result of `dispatch_block_create` gets touched by Swift ARC, the side-table data gets deleted.

//: [Next](@next)
