import Foundation

let thread = pthread_create_closure_np { () -> String in
    Thread.sleep(forTimeInterval: 3)
    return "String with captured context: \(42)"
}

let value = try! pthread_join_closure_np(thread, ofType: String.self)
print(value)
