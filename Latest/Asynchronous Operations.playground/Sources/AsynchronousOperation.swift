import Foundation

/// An operation that performs work without respect to the queue it is enqueued
/// on.
///
/// `AsynchronousOperation` is meant as a base class for doing your own
/// asynchronous work, such as waiting on the completion handler call of a
/// system API. To avoid subclassing, consider `AsynchronousBlockOperation`.
public class AsynchronousOperation: Operation {

    // MARK: - Required Methods for Subclasses

    /// A handler to be called when your work has finished.
    public typealias Continuation = () -> Void

    /// Begins execution of the asynchronous work.
    ///
    /// The default implementation of this method does nothing. You should
    /// override this method to kick off the desired operations. In your
    /// implementation, do not invoke `super`.
    ///
    /// - warning: Subclass implementations must invoke `finish` when done. If
    /// you do not invoke `finish`, the operation will remain in its executing
    /// state indefinitely.
    open func execute(finish: @escaping Continuation) {
        assertionFailure("Subclasses must override without calling super.")
    }

    // MARK: - Operation

    fileprivate func finish() {
        willChangeValue(for: \.isFinished)
        willChangeValue(for: \.isExecuting)
        isFinishedAsynchronous = true
        isExecutingAsynchronous = false
        didChangeValue(for: \.isExecuting)
        didChangeValue(for: \.isFinished)
    }

    /// Begins execution of the operation.
    ///
    /// Updates the execution state of the operation and calls the
    /// `execute(finish:)` method.
    override public final func start() {
        guard !isCancelled else {
            willChangeValue(for: \.isFinished)
            isFinishedAsynchronous = true
            didChangeValue(for: \.isFinished)
            return
        }

        willChangeValue(for: \.isExecuting)
        isExecutingAsynchronous = true
        didChangeValue(for: \.isExecuting)

        autoreleasepool {
            execute(finish: finish)
        }
    }

    private var isExecutingAsynchronous = false

    /// `true` if `execute` has been entered.
    override public final var isExecuting: Bool {
        return isExecutingAsynchronous
    }

    private var isFinishedAsynchronous = false

    /// `true` if `execute` has executed its `finish` handler.
    override public final var isFinished: Bool {
        return isFinishedAsynchronous
    }

    /// Always `true`, as this operation does not perform work relative to
    /// the operation queue's execution context.
    override public final var isAsynchronous: Bool {
        return true
    }

}

// MARK: -

private extension DispatchQueue {

    /// A generic catch-all work queue for when you just want to throw some work
    /// onto the concurrent pile. As an alternative to the `.utility` global
    /// queue, work dispatched onto this queue will match the QoS of the caller.
    static func any() -> DispatchQueue {
        // Cribbed from: https://github.com/bignerdranch/Deferred/blob/master/Sources/Deferred/Executor.swift#L74-L89
        //
        // The technique is explained better than I can in Core Foundation:
        // http://opensource.apple.com/source/CF/CF-1153.18/CFInternal.h
        // https://github.com/apple/swift-corelibs-foundation/blob/master/CoreFoundation/Base.subproj/CFInternal.h#L869-L889
        let qosClass = DispatchQoS.QoSClass(rawValue: qos_class_self()) ?? .utility
        return .global(qos: qosClass)
    }

}

/// An operation that manages the asynchronous execution of one or more handler
/// closures.
public final class AnyAsynchronousOperation: AsynchronousOperation {

    /// Code to be executed outside of the operation queue's context.
    public typealias Handler = (_ finish: @escaping Continuation) -> Void

    /// Mutable setup information that the operation is set up with.
    public struct Configuration {

        /// The queue to invoke all handlers on.
        ///
        /// If `nil`, the operation will choose an appropriate background queue.
        public var queue: DispatchQueue?

        /// Should be obvious.
        fileprivate var handlers = [Handler]()

        /// Creates the default configuration with no handlers.
        public init() {}

        /// Adds to to the list of handlers to execute.
        ///
        /// - warning: You must invoke the `finish` continuation passed to `handler`
        ///   when your work is done. If you do not invoke `finish`, the operation
        ///   will remain in its executing state indefinitely.
        mutating public func addHandler(_ handler: @escaping Handler) {
            handlers.append(handler)
        }

    }

    /// The queue to invoke `handlers` on.
    private let queue: DispatchQueue

    /// Should be obvious.
    private var handlers: [Handler]

    /// Creates the asynchronous operation for executing using the
    /// `configuration`.
    public init(configuration: Configuration) {
        self.queue = configuration.queue ?? .any()
        self.handlers = configuration.handlers
    }

    /// Executes the `handler`, calling `finish` when is it done.
    override public final func execute(finish: @escaping () -> Void) {
        let group = DispatchGroup()
        for handler in handlers {
            group.enter()
            queue.async {
                handler(group.leave)
            }
        }
        group.notify(queue: queue, execute: finish)
    }
    
    override func finish() {
        super.finish()
        
        handlers.removeAll()
    }

}

// MARK: - Conveniences

extension Operation {

    /// Combines a completion handler with the Operation's existing one.
    ///
    /// - note: The passed-in handler will be strongly referenced, including its
    ///   captures, until the operation is finished or it deallocates, whichever
    ///   comes first.
    /// - warning: Completion handlers should generally only be set before the
    ///   operation is enqueued. Breaking this expectation may appear to work
    ///   fine, but have unexpected subtleties.
    public func addCompletionHandler(_ handler: @escaping() -> Void) {
        completionBlock = { [existing = completionBlock] in
            existing?()
            handler()
        }
    }

}

extension AnyAsynchronousOperation {

    /// Creates an asynchronous operation for executing `handler` on `queue`.
    ///
    /// - warning: You must invoke the `finish` continuation passed to `handler`
    ///   when your work is done. If you do not invoke `finish`, the operation
    ///   will remain in its executing state indefinitely.
    public convenience init(upon queue: DispatchQueue? = nil, execute handler: @escaping Handler) {
        var configuration = Configuration()
        configuration.queue = queue
        configuration.addHandler(handler)
        self.init(configuration: configuration)
    }

}

extension OperationQueue {

    /// Wraps `handler` in an asynchronous operation and adds it to `self`.
    ///
    /// - warning: You must invoke the `finish` continuation passed to `handler`
    ///   when your work is done. If you do not invoke `finish`, the operation
    ///   will remain in its executing state indefinitely.
    public func addAsyncOperation(upon queue: DispatchQueue? = nil, execute handler: @escaping AnyAsynchronousOperation.Handler) {
        addOperation(AnyAsynchronousOperation(upon: queue, execute: handler))
    }

}
