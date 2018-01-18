/// Multicast notifier for an Event type, like `UIControl`. Weakly holds
/// objects. Not thread-safe.
///
/// Inspired by this blog post by Ole Begemann (@oleb):
///  - http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
public struct Notifier<Event: Hashable, UserInfo> {

    private typealias Notification = (UserInfo) -> Bool

    private var notifications = [Event: [ObjectIdentifier: Notification]]()

    public init() {}

    private mutating func addAction(for event: Event, key: ObjectIdentifier, body: @escaping Notification) {
        if var list = notifications[event] {
            list[key] = body
            notifications[event] = list
        } else {
            notifications[event] = [key: body]
        }
    }

    /// Add an observer for the given action.
    ///
    /// @warning Only one `body` is kept for any given `owner`/`action` pair. If you
    /// add the same owner/action pair multiple times, only the newest `body` is kept.
    public mutating func addObserver<T: AnyObject>(_ owner: T, for event: Event, handler: @escaping(T) -> () -> Void) {
        addAction(for: event, key: ObjectIdentifier(owner)) { [weak owner] _ in
            guard let owner = owner else { return false }
            handler(owner)()
            return true
        }
    }

    /// Add an observer for the given action, recieving side data.
    ///
    /// @warning Only one `body` is kept for any given `owner`/`action` pair. If you
    /// add the same owner/action pair multiple times, only the newest `body` is kept.
    public mutating func addObserver<T: AnyObject>(_ owner: T, for event: Event, handler: @escaping(T) -> (UserInfo) -> Void) {
        addAction(for: event, key: ObjectIdentifier(owner)) { [weak owner] info in
            guard let owner = owner else { return false }
            handler(owner)(info)
            return true
        }
    }

    public mutating func removeObserver<T: AnyObject>(_ owner: T, for event: Event) {
        let key = ObjectIdentifier(owner)
        let removedValue = notifications[event]?.removeValue(forKey: key)
        assert(removedValue != nil, "Unexpected observation removal - object \(owner) was not registered for \(event).")
    }

    private func sendNotifications(to list: inout [ObjectIdentifier: Notification], info: UserInfo) {
        list = list.filter { $0.value(info) }
    }

    public mutating func sendNotifications(for event: Event, info: UserInfo) {
        sendNotifications(to: &notifications[event, default: [:]], info: info)
    }

}
