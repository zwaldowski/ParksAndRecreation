/// Multicast notifier for an Event type, like `UIControl`. Weakly holds
/// objects. Not thread-safe.
///
/// Inspired by this blog post by Ole Begemann (@oleb):
///  - http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
public struct Notifier<Event: Hashable, UserInfo> {
    
    private typealias Notification = UserInfo -> Bool
    
    private var notifications: [Event: [ObjectIdentifier: Notification]]
    
    public init() {
        self.notifications = [:]
    }
    
    private mutating func addActionForEvent(event: Event, key: ObjectIdentifier, body: Notification) {
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
    public mutating func addObserver<T: AnyObject>(owner: T, forEvent event: Event, body inBody: T -> () -> ()) {
        addActionForEvent(event, key: ObjectIdentifier(owner)) { [weak owner] _ in
            guard let strongOwner = owner else { return false }
            inBody(strongOwner)()
            return true
        }
    }
    
    /// Add an observer for the given action, recieving side data.
    ///
    /// @warning Only one `body` is kept for any given `owner`/`action` pair. If you
    /// add the same owner/action pair multiple times, only the newest `body` is kept.
    public mutating func addObserver<T: AnyObject>(owner: T, forEvent event: Event, body inBody: T -> UserInfo -> ()) {
        addActionForEvent(event, key: ObjectIdentifier(owner)) { [weak owner] info in
            guard let strongOwner = owner else { return false }
            inBody(strongOwner)(info)
            return true
        }
    }
    
    public mutating func removeObserver<T: AnyObject>(owner: T, forEvent event: Event) {
        let key = ObjectIdentifier(owner)
        let removedValue = notifications[event]?.removeValueForKey(key)
        assert(removedValue != nil, "Unexpected observation removal - object \(owner) was not registered for \(event).")
    }
    
    public mutating func sendNotificationsForEvent(event: Event, info: UserInfo) {
        if var list = notifications[event] {
            for (key, notification) in list {
                if !notification(info) {
                    list.removeValueForKey(key)
                }
            }
            notifications[event] = list
        }
    }
    
}
