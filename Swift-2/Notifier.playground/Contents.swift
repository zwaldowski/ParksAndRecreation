class MyClass {
    
    func respondToEvent(count: Int) {
        print("I recieved \(count)!")
    }
    
}

enum WookieeEvent {
    case Growl
}

// MARK: -

let instance = MyClass()

var notifier = Notifier<WookieeEvent, Int>()

notifier.addObserver(instance, forEvent: .Growl, body: MyClass.respondToEvent)

notifier.sendNotificationsForEvent(.Growl, info: 42)

// Expand the console log to see the dispatched event.
