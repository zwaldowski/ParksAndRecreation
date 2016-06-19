import Dispatch
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let debounce = Debounce<Int> {
    print("Got value \($0)!")
}

debounce.schedule(with: 4)
debounce.schedule(with: 3)
debounce.schedule(with: 2)
debounce.schedule(with: 1)

DispatchQueue.main.after(when: .now() + 1.0) {
    PlaygroundPage.current.finishExecution()
}
