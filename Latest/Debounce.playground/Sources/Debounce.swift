import Dispatch

/// A set of flags describing a group of opterations that can be performed in a
/// single invocation of a debounce.
///
/// Define these using the Swift `OptionSetType` syntax, i.e., for a bit-wise
/// options set with a raw value.
///
/// - seealso: Debounce
/// - seealso: OptionSetType
public protocol DebounceEvent: OptionSet {
    associatedtype RawValue: UnsignedInteger = UInt
    static var cancelled: Self { get }
}

public final class Debounce<Event: DebounceEvent, Context> {

    public typealias Handler = (Event, Context) -> Void

    private typealias ValidatingHandler = (Event, Context) -> Bool
    private let handler: ValidatingHandler
    private let queue: DispatchQueue
    private let key = DispatchSpecificKey<Context>()
    private let source: DispatchSourceUserDataOr

    private init(validatingHandler: @escaping ValidatingHandler) {
        self.handler = validatingHandler
        self.queue = DispatchQueue(label: "com.bignerdranch.debounce", target: .main)
        self.source = DispatchSource.makeUserDataOrSource(queue: queue)

        source.setEventHandler { [source, unowned self] in
            let event = Event(rawValue: numericCast(source.data))
            guard event.intersection(.cancelled) != .cancelled else { return }
            self.invokeHandler(for: event)
        }

        source.activate()
    }

    /// Create a debounce with a `handler`. The `handler` is passed the combined
    /// set of events and the context data most recently scheduled.
    ///
    /// - note: Anything captured strongly in the handler will be retained
    /// until `invalidate()` is called.
    public convenience init(handler: @escaping Handler) {
        self.init(validatingHandler: {
            handler($0, $1)
            return true
        })
    }

    /// For debounces owned by an object and used to call instance methods on
    /// the object, use this constructor to capture the owner.
    public convenience init<Owner: AnyObject>(owner: Owner, action: @escaping(Owner) -> Handler) {
        self.init { [weak owner] (event, context) -> Bool in
            guard let owner = owner else { return false }
            action(owner)(event, context)
            return true
        }
    }

    deinit {
        source.cancel()
    }

    private func invokeHandler(for event: Event, with context: Context? = nil) {
        guard let context = context ?? DispatchQueue.getSpecific(key: key) else {
            return source.cancel()
        }

        if !handler(event, context) {
            source.cancel()
        }
    }

    /// Schedule a debounced call to the handler.
    ///
    /// Repeated calls that occur before the handler is called are cancelled,
    /// replaced with the latest `context`.
    ///
    /// - parameter event: An event flag that will be combined with any running
    ///   flags.
    /// - parameter immediately: If `true`, coalescing still occurs but the
    ///   handler is synchronously executed.
    public func schedule(for event: Event, with context: Context) {
        queue.setSpecific(key: key, value: context)

        source.or(data: numericCast(event.rawValue))
    }

    /// Synchronously execute a debounced call to the handler.
    ///
    /// Repeated calls that occur before the handler is called are cancelled,
    /// replaced with the latest `context`.
    public func scheduleImmediately(for event: Event, with context: Context) {
        skipNext()

        if pthread_main_np() == 1 {
            _ = handler(event, context)
        } else {
            queue.sync {
                _ = handler(event, context)
            }
        }
    }

    /// Cancels prior schedules and calls the handler for the `event` immediately.
    public func invoke(for event: Event, with context: Context) {
        guard pthread_main_np() == 1 else {
            return schedule(for: event, with: context)
        }

        invokeHandler(for: event, with: context)

        skipNext()
    }

    /// Cancel the next scheduled handler call.
    public func skipNext() {
        source.or(data: numericCast(Event.cancelled.rawValue))
    }

}

private struct UnitEvent: DebounceEvent {
    let rawValue: UInt
    init(rawValue: UInt) { self.rawValue = rawValue }

    static let scheduled = UnitEvent(rawValue: 1)
    static let cancelled = UnitEvent(rawValue: 2)
}

/// A "debounce" is a threading primitive for coalescing some event across
/// drains of the main queue so it isn't called more often than necessary.
///
/// This is intended for triggering some kind of UI update, much in the spirit
/// of setNeedsLayout() in UIKit.
///
/// - seealso: Debounce
public struct SimpleDebounce<Context> {

    public typealias Handler = (Context) -> Void
    private typealias Base = Debounce<UnitEvent, Context>

    private let base: Base

    /// Create a debounce with a `handler`. The `handler` is passed the context
    /// data most recently scheduled.
    ///
    /// - note: Anything captured strongly in this handler will be retained
    /// until the invalidate() method is called.
    public init(handler: @escaping Handler) {
        base = Base { (_, context) in
            handler(context)
        }
    }

    /// For debounces owned by an object and used to call instance methods on
    /// the object, use this constructor to capture the owner.
    public init<Owner: AnyObject>(owner: Owner, action: @escaping(Owner) -> Handler) {
        base = Base(owner: owner, action: { owner in
            let fn = action(owner)
            return { fn($1) }
        })
    }

    /// Schedule a debounced call to the handler.
    ///
    /// Repeated calls that occur before the handler is called are cancelled,
    /// replaced with the latest `context`.
    public func schedule(with context: Context) {
        base.schedule(for: .scheduled, with: context)
    }

    /// Synchronously execute a debounced call to the handler.
    ///
    /// Repeated calls that occur before the handler is called are cancelled,
    /// replaced with the latest `context`.
    public func scheduleImmediately(with context: Context) {
        base.scheduleImmediately(for: .scheduled, with: context)
    }

    /// Cancels prior schedules and calls the handler immediately.
    public func invoke(with context: Context) {
        base.invoke(for: .scheduled, with: context)
    }

    /// Cancel the next scheduled handler call.
    public func skipNext() {
        base.skipNext()
    }

}
