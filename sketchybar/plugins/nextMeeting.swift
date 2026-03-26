import EventKit

let store = EKEventStore()

// Request access to the Calendar
store.requestFullAccessToEvents { granted, error in
    guard granted else {
        print("No Access")
        exit(1)
    }

    let now = Date()
    let later = Date(timeIntervalSinceNow: 86400) // Look ahead 24 hours

    // Fetch events from all calendars
    let predicate = store.predicateForEvents(withStart: now, end: later, calendars: nil)

    // Filter out all-day events and sort by start time
    let events = store.events(matching: predicate)
        .filter { !$0.isAllDay }
        .sorted { $0.startDate < $1.startDate }

    if let next = events.first {
        let formatter = DateFormatter()
        // 'h:mm a' gives you "1:30 PM" format
        formatter.dateFormat = "h:mm a"

        let title = next.title ?? "Meeting"
        let time = formatter.string(from: next.startDate)

        print("\(title) at \(time)")
    } else {
        print("No upcoming meetings")
    }
    exit(0)
}

// Keep the script alive until the async request returns
dispatchMain()
