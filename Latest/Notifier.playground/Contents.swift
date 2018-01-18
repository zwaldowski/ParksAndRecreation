class MyClass {
    
    func respondToEvent(count: Int) {
        print("I recieved \(count)!")
    }
    
}

enum WookieeEvent {
    case growl
}

// MARK: -

let instance = MyClass()

var notifier = Notifier<WookieeEvent, Int>()

notifier.addObserver(instance, for: .growl, handler: MyClass.respondToEvent)

notifier.sendNotifications(for: .growl, info: 42)

// Expand the console log to see the dispatched event.
