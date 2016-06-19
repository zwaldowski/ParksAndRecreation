import Dispatch

/// A set of flags describing a group of opterations that can be performed in a
/// single invocation of a debounce.
///
/// Define these using the Swift `OptionSetType` syntax, i.e., for a bit-wise
/// options set with a raw value.
///
/// - seealso: MultiDebounce
/// - seealso: OptionSetType
public protocol DebounceEvent: OptionSet {
    associatedtype RawValue: UnsignedInteger = UInt
    static var Cancelled: Self { get }
}

public final class MultiDebounce<Event: DebounceEvent, Context> {

    public typealias Handler = (Event, Context) -> Void
    private typealias ValidatingHandler = (Event, Context) -> Bool

    private let handler: ValidatingHandler

    // The handler will be called once-and-only-once per tick of the main
    // run loop by bitwise ORing all values sent to `schedule` between
    // invocations.
    private let source = DispatchSource.userDataOr(queue: .main)

    private var contextLock = pthread_mutex_t()
    private var _context: Context?

    private init(validatingHandler: ValidatingHandler) {
        self.handler = validatingHandler
        pthread_mutex_init(&contextLock, nil)

        source.setEventHandler {
            let event = Event(rawValue: numericCast(self.source.data))
            guard event.intersection(.Cancelled) != .Cancelled else { return }
            self.invokeHandler(for: event)
        }

        source.setCancelHandler {
            self.context = nil
        }

        source.resume()
    }

    /// Create a debounce with a `handler`. The `handler` is passed the combined
    /// set of events and the context data most recently scheduled.
    ///
    /// - note: Anything captured strongly in the handler will be retained
    /// until `invalidate()` is called.
    public convenience init(handler: Handler) {
        self.init(validatingHandler: {
            handler($0, $1)
            return true
        })
    }

    /// For debounces owned by an object and used to call instance methods on
    /// the object, use this constructor to capture the owner.
    public convenience init<Owner: AnyObject>(owner: Owner, action: (Owner) -> Handler) {
        self.init { [weak owner] (event, context) -> Bool in
            guard let owner = owner else { return false }
            action(owner)(event, context)
            return true
        }
    }

    private var context: Context! {
        get {
            pthread_mutex_lock(&contextLock)
            defer { pthread_mutex_unlock(&contextLock) }
            return _context
        }
        set {
            pthread_mutex_lock(&contextLock)
            defer { pthread_mutex_unlock(&contextLock) }
            _context = newValue
        }
    }

    private func invokeHandler(for event: Event, with context: Context? = nil) {
        if !handler(event, context ?? self.context) {
            invalidate()
        }
    }

    /// Schedule a debounced call to the handler.
    ///
    /// Repeated calls that occur before the handler is called are cancelled,
    /// replaced with the latest `context`.
    ///
    /// - parameter event: An event flag that will be combined with any running
    ///   flags.
    public func schedule(for event: Event, with context: Context) {
        self.context = context

        source.mergeData(value: numericCast(event.rawValue))
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
        source.mergeData(value: numericCast(Event.Cancelled.rawValue))
    }

    /// Unregister the debounce, releasing any captured context.
    public func invalidate() {
        source.cancel()
    }

}

private struct UnitEvent: DebounceEvent {
    let rawValue: UInt
    init(rawValue: UInt) { self.rawValue = rawValue }

    static let Scheduled = UnitEvent(rawValue: 1)
    static let Cancelled = UnitEvent(rawValue: 2)
}

/// A "debounce" is a threading primitive for coalescing some event across
/// drains of the main queue so it isn't called more often than necessary.
///
/// This is intended for triggering some kind of UI update, much in the spirit
/// of setNeedsLayout() in UIKit.
///
/// - seealso: MultiDebounce
public struct Debounce<Context> {

    public typealias Handler = (Context) -> Void
    private typealias Base = MultiDebounce<UnitEvent, Context>

    private let base: Base

    /// Create a debounce with a `handler`. The `handler` is passed the context
    /// data most recently scheduled.
    ///
    /// - note: Anything captured strongly in this handler will be retained
    /// until the invalidate() method is called.
    public init(handler: Handler) {
        base = Base { (_, context) in
            handler(context)
        }
    }

    /// For debounces owned by an object and used to call instance methods on
    /// the object, use this constructor to capture the owner.
    public init<Owner: AnyObject>(owner: Owner, action: (Owner) -> Handler) {
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
        base.schedule(for: .Scheduled, with: context)
    }

    /// Cancels prior schedules and calls the handler immediately.
    public func invoke(with context: Context) {
        base.invoke(for: .Scheduled, with: context)
    }

    /// Cancel the next scheduled handler call.
    public func skipNext() {
        base.skipNext()
    }

    /// Unregister the debounce, releasing any captured context.
    public func invalidate() {
        base.invalidate()
    }
    
}
