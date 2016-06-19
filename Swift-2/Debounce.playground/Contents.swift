import Dispatch
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let debounce = Debounce<Int> {
    print("Got value \($0)!")
}

debounce.schedule(with: 4)
debounce.schedule(with: 3)
debounce.schedule(with: 2)
debounce.schedule(with: 1)

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue(), XCPlaygroundPage.currentPage.finishExecution)
