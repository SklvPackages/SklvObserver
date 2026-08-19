//
//  Copyright (c) 2026 Andrew Sokolov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

/// A modern, concurrency-friendly watcher that observes notifications using `AsyncSequence`.
public final class NotificationWatcher: Sendable {
    private let task: Task<Void, Never>

    /// Initializes the watcher to observe multiple notifications.
    /// - Parameters:
    ///   - names: An array of notification names to observe.
    ///   - action: A thread-safe closure to execute upon receiving a notification.
    public init(
        _ names: [Notification.Name],
        action: @escaping @Sendable (Notification) -> Void
    ) {
        self.task = Task {
            // Use a task group to listen to multiple notification streams concurrently
            await withTaskGroup(of: Void.self) { group in
                for name in names {
                    group.addTask {
                        let stream = NotificationCenter.default.notifications(named: name)
                        for await notification in stream {
                            // Pass the entire Sendable Notification object directly
                            action(notification)
                        }
                    }
                }
            }
        }
    }

    /// Initializes the watcher to observe a single notification.
    /// - Parameters:
    ///   - name: The notification name to observe.
    ///   - action: A thread-safe closure to execute upon receiving the notification.
    public convenience init(
        _ name: Notification.Name,
        action: @escaping @Sendable (Notification) -> Void
    ) {
        self.init([name], action: action)
    }

    deinit {
        // Automatically stops observing when the watcher instance is deallocated
        task.cancel()
    }
}
