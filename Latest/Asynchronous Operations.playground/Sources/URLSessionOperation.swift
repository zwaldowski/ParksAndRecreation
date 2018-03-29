import Foundation

private var observationContext = false

/// An asynchronous operation that manages the submission and completion of a
/// task associated with a `URLSession`.
public final class URLSessionOperation<Task: URLSessionTask>: Operation, ProgressReporting {

    /// The task managed by the operation.
    public let task: Task

    /// Creates the asynchronous operation for resuming a `task`.
    ///
    /// - precondition: The task must be in a suspended state. Do not call
    ///   `resume()` as you normally would, or if you are vended a task already
    ///   resumed balance it with a `suspend()`.
    public init(_ task: Task) {
        precondition(task.state == .suspended, "Task must be suspended")
        self.task = task
        super.init()
        task.addObserver(self, forKeyPath: #keyPath(URLSessionTask.state), options: .prior, context: &observationContext)
    }

    deinit {
        task.removeObserver(self, forKeyPath: #keyPath(URLSessionTask.state), context: &observationContext)
    }

    // MARK: - Operation

    override public func start() {
        task.resume()
    }

    override public func cancel() {
        super.cancel()
        task.cancel()
    }

    /// `true` if `task` is running.
    override public var isExecuting: Bool {
        return task.state == .running
    }

    /// `true` if `task` has completed.
    override public var isFinished: Bool {
        return task.state == .completed
    }

    /// Always `true`, as this operation does not perform work relative to
    /// the operation queue's execution context.
    override public var isAsynchronous: Bool {
        return true
    }

    // MARK: - ProgressReporting

    public var progress: Progress {
        return task.progress
    }

    // MARK: - NSObject

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observationContext else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        let isPrior = change?[.notificationIsPriorKey] as? Bool == true
        if isPrior {
            willChangeValue(for: \.isFinished)
            willChangeValue(for: \.isExecuting)
        } else {
            didChangeValue(for: \.isExecuting)
            didChangeValue(for: \.isFinished)
        }
    }

}
