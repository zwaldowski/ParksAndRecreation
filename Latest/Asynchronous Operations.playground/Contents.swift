import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum FakeCompletionHandlerAPI {

    static func doVeryImportantThing(completion handler: @escaping() -> Void) {
        dispatchPrecondition(condition: .onQueue(.main))
        let time = DispatchTime.now() + .random(in: 0 ..< 5)
        DispatchQueue.main.asyncAfter(deadline: time, execute: handler)
    }

}

var op1Config = AnyAsynchronousOperation.Configuration()
op1Config.queue = .main
for _ in 0 ..< 10 {
    op1Config.addHandler(FakeCompletionHandlerAPI.doVeryImportantThing)
}

let op1 = AnyAsynchronousOperation(configuration: op1Config)

op1.addCompletionHandler {
    print("[ASYNC] I finished!")
}

op1.addCompletionHandler {
    print("[ASYNC] I finished too!")
}

let task = URLSession.shared.dataTask(with: URL(string: "https://support.apple.com/en-us/ht201419")!)
let op2 = URLSessionOperation(task)
op2.addCompletionHandler {
    print("[NETWORK] Me three!")
}
op2.addDependency(op1)

let op3 = BlockOperation {
    print("[REGULAR] I'm an operation!")
}

op3.addCompletionHandler {
    PlaygroundPage.current.finishExecution()
}

op3.addDependency(op1)
op3.addDependency(op2)

let operationQueue = OperationQueue()
operationQueue.addOperation(op1)
operationQueue.addOperation(op2)
operationQueue.addOperation(op3)
print("Kicked off some operations...")
