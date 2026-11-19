# SklvObserver

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

A lightweight, modern, and thread-safe Swift library for reactive state observation and system notifications. Built specifically for Swift 6 Strict Concurrency, it provides a simpler, safer alternative to Combine's `CurrentValueSubject` and legacy `@objc` NotificationCenter APIs.

## Features

- 🚀 **Swift 6 Ready:** Fully strictly typed and `Sendable` compliant. No data races.
- ⚡️ **Lightweight State Observation:** Replace heavy Combine pipelines with simple `@MainActor`-isolated wrappers.
- 📡 **Modern Notifications:** Uses under-the-hood `AsyncSequence` for observing `NotificationCenter` without `@objc` selectors or legacy blocks.
- 🧹 **Memory Safe:** Automatic subscription cleanup via Swift's modern `isolated deinit` and RAII principles.

## Requirements

- **iOS** 15.0+
- **Xcode** 26.0+
- **Swift** 6.3+

## Installation

### Swift Package Manager

1. Inside Xcode, navigate to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/SklvPackages/SklvObserver.git`
3. Define the dependency rules to **Up to Next Major** starting with `1.0.0`.

## Usage

### 1. Reactive State Observation
`ObservedValue` and `ValueObserver` provide a thread-safe, `@MainActor`-isolated way to bind data to your UI. It completely removes the need for `Combine` or `RxSwift` for simple UI state management.

```swift
import SklvObserver

@MainActor
class ViewModel {
    // Create an observed value
    let username = ObservedValue("Guest")
}

@MainActor
class ViewController: UIViewController {
    let viewModel = ViewModel()
    var observer: ValueObserver<String>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Start observing. The subscription lives as long as the `observer` token.
        observer = ValueObserver(viewModel.username) { [weak self] newName in
            self?.title = "Welcome, \(newName)"
        }
        
        // Changing the value automatically triggers the closure
        viewModel.username.value = "Alice" 
    }
}
```

### 2. Sending Notifications
`NotificationDispatcher` is a lightweight `Sendable` struct that provides a type-safe API for posting data.

```swift
let loginNotification = Notification.Name("UserDidLogin")
let dispatcher = NotificationDispatcher(loginNotification)

// Safely post a specific Sendable value
dispatcher.post(value: "JohnDoe", forKey: "username")

// Or post a standard userInfo dictionary
// dispatcher.post(["id": 123, "isActive": true])
```

### 3. Receiving Notifications
`NotificationWatcher` handles the lifecycle of an `AsyncSequence` notification stream. It cleans up automatically when deallocated.

```swift
class SessionManager {
    var watcher: NotificationWatcher?

    init() {
        let loginNotification = Notification.Name("UserDidLogin")
        
        // Starts an internal Task listening to the Notification AsyncSequence
        watcher = NotificationWatcher(loginNotification) { notification in
            // Safely extract your data
            if let username = notification.userInfo?["username"] as? String {
                print("User logged in: \(username)")
            }
        }
    }
    
    // No need to call `removeObserver`. 
    // When `watcher` is deallocated, the async task is automatically cancelled.
}
```

## License

`SklvObserver` is released under the MIT license. See [LICENSE](LICENSE) for details.
