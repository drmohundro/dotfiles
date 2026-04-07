import EventKit

let store = EKEventStore()

store.requestFullAccessToEvents { granted, error in
    guard granted else {
        print("")
        exit(0)
    }

    let now = Date()
    let later = Date(timeIntervalSinceNow: 86400)

    let predicate = store.predicateForEvents(withStart: now, end: later, calendars: nil)

    let events = store.events(matching: predicate)
        .filter { !$0.isAllDay }
        .sorted { $0.startDate < $1.startDate }

    if let next = events.first {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let title = next.title ?? "Meeting"
        let time = formatter.string(from: next.startDate)

        print("\(title) at \(time)")
    } else {
        print("")
    }
    exit(0)
}

dispatchMain()
