import Foundation
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD)
    import Glibc
#endif

private enum Result<SuccessValue> {
    case success(SuccessValue)
    case failure(Error)
}

private class Runner {
    /// Execute the block, and return a raw pointer to memory containing the
    /// result of the data.
    func runAndReturnContext() -> UnsafeMutableRawPointer? { fatalError() }
}

private final class Function<Return>: Runner {

    let body: () throws -> Return
    init(body: @escaping() throws -> Return) {
        self.body = body
        super.init()
    }

    override func runAndReturnContext() -> UnsafeMutableRawPointer? {
        let result = UnsafeMutablePointer<Result<Return>>.allocate(capacity: 1)
        do {
            try result.initialize(to: .success(body()))
        } catch {
            result.initialize(to: .failure(error))
        }
        return UnsafeMutableRawPointer(result)
    }
}

#if os(FreeBSD)
    public typealias _pthread_attr_p = UnsafePointer<pthread_attr_t?>
#else
    public typealias _pthread_attr_p = UnsafePointer<pthread_attr_t>
#endif

public func pthread_create_closure_np<Return>(attributes: _pthread_attr_p? = nil, body: @escaping() throws -> Return) -> pthread_t {
    let runner = Function<Return>(body: body)
    let runnerAsRawPointer = Unmanaged.passRetained(runner).toOpaque()

    #if os(Linux) || os(Android)
        var threadID: pthread_t? = pthread_t()
    #else
        var threadID: pthread_t?
    #endif
    let result = pthread_create(&threadID, attributes, { (runnerAsRawPointer) -> UnsafeMutableRawPointer? in
        let runner = Unmanaged<Runner>.fromOpaque(runnerAsRawPointer).takeRetainedValue()
        return runner.runAndReturnContext()
    }, runnerAsRawPointer)

    guard result == 0 else {
        Unmanaged<Runner>.fromOpaque(runnerAsRawPointer).release()
        preconditionFailure("Unable to create thread")
    }

    return threadID!
}

public func pthread_join_closure_np<Return>(_ thread: pthread_t, ofType _: Return.Type = Return.self) throws -> Return {
    var resultAsRawPointer: UnsafeMutableRawPointer?
    let resultCode = pthread_join(thread, &resultAsRawPointer)
    guard resultCode == 0 else {
        throw POSIXError(POSIXErrorCode(rawValue: resultCode)!)
    }

    let resultAsPointer = resultAsRawPointer!.assumingMemoryBound(to: Result<Return>.self)
    defer { resultAsPointer.deallocate(capacity: 1) }

    switch resultAsPointer.move() {
    case .success(let value):
        return value
    case .failure(let error):
        throw error
    }
}
