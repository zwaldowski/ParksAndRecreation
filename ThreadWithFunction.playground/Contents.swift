import Darwin

let thread = try! pthread_create_closure_np(context: 42) { (value: Int) throws -> String in
    sleep(3)
    return "String with context: \(value)"
}

let value = try! pthread_join_closure_np(thread, ofType: String.self)
print(value)
