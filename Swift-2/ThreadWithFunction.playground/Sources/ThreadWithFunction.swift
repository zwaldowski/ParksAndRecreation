import Foundation

// Adapted from: https://github.com/apple/swift/blob/master/stdlib/private/SwiftPrivatePthreadExtras/SwiftPrivatePthreadExtras.swift

private enum Result<SuccessValue> {
    case Success(SuccessValue)
    case Failure(ErrorType)
}

private class AnyContext {
    /// Execute the block, and return an `UnsafeMutablePointer` to memory
    /// allocated with `UnsafeMutablePointer.alloc` containing the result of the
    /// block.
    func run() -> UnsafeMutablePointer<Void> { fatalError() }
}

private final class FunctionContext<Argument, Return>: AnyContext {
    let body: Argument throws -> Return
    let argument: Argument

    init(body: Argument throws -> Return, argument: Argument) {
        self.body = body
        self.argument = argument
        super.init()
    }

    override func run() -> UnsafeMutablePointer<Void> {
        let result = UnsafeMutablePointer<Result<Return>>.alloc(1)
        do {
            try result.initialize(.Success(body(argument)))
        } catch {
            result.initialize(.Failure(error))
        }
        return UnsafeMutablePointer(result)
    }
}

public func pthread_create_closure_np<Argument, Return>(attributes attr: UnsafePointer<pthread_attr_t> = nil, context: Argument, body: Argument throws -> Return) throws -> pthread_t {
    typealias Context = FunctionContext<Argument, Return>
    let context = Context(body: body, argument: context)
    let contextAsPointer = Unmanaged.passRetained(context).toOpaque()

    var threadID: pthread_t
    #if os(Linux) || os(FreeBSD)
        threadID = pthread_t()
    #else
        threadID = nil
    #endif

    let result = pthread_create(&threadID, attr, { (contextAsVoidPointer) -> UnsafeMutablePointer<Void> in
        let context = Unmanaged<AnyContext>.fromOpaque(.init(contextAsVoidPointer)).takeRetainedValue()
        return context.run()
        }, UnsafeMutablePointer(contextAsPointer))

    guard result == 0 else {
        Unmanaged<Context>.fromOpaque(contextAsPointer).release()
        throw POSIXError(rawValue: result)!
    }

    return threadID
}

public func pthread_join_closure_np<Return>(thread: pthread_t, ofType _: Return.Type = Return.self) throws -> Return {
    var threadResultAsVoidPointer: UnsafeMutablePointer<Void> = nil
    let result = pthread_join(thread, &threadResultAsVoidPointer)
    guard result == 0 else {
        throw POSIXError(rawValue: result)!
    }

    let threadResultAsPointer = UnsafeMutablePointer<Result<Return>>(threadResultAsVoidPointer)
    defer { threadResultAsPointer.dealloc(1) }

    switch threadResultAsPointer.move() {
    case .Success(let value):
        return value
    case .Failure(let error):
        throw error
    }
}
