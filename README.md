# SklvObserver

A lightweight, `@MainActor`-safe toolkit for observation in Swift. Simple, predictable, and memory-safe by design.

## Requirements

- iOS 15.0+
- Xcode 26.4+
- Swift 6.3+

## Installation

### Swift Package Manager

- File > Add Package Dependencies...
- Add `https://github.com/SklvPackages/SklvObserver.git`
- Select "Up to Next Major" with "1.0.0"

## Usage

### Notification

```swift
let loginName = Notification.Name("loginNotification")

let watcher = NotificationWatcher(name: loginName) { userInfo in
    print("User logged in: \(userInfo?["id"] ?? "unknown")")
}

let dispatcher = NotificationDispatcher(name: loginName)
dispatcher.post(["id": "user_123"])
```

### Observed Value

```swift
let batteryLevel = ObservedValue(100)

let observer = ValueObserver(batteryLevel) { newValue in
    print("Battery is now: \(newValue)%")
}

batteryLevel.value = 95
```

## License

SklvObserver is released under the MIT license. See LICENSE for details.
