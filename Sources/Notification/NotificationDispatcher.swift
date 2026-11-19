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

/// A lightweight, thread-safe dispatcher for posting notifications.
public struct NotificationDispatcher: Sendable {
    private let center = NotificationCenter.default
    private let name: Notification.Name

    /// Initializes the dispatcher with a specific notification name.
    /// - Parameter name: The name of the notification to be dispatched.
    public init(_ name: Notification.Name) {
        self.name = name
    }

    /// Posts the notification to the default notification center.
    /// - Parameter info: An optional dictionary containing `Sendable` data to pass alongside the notification.
    public func post(_ info: [AnyHashable: any Sendable]? = nil) {
        center.post(name: name, object: nil, userInfo: info)
    }

    /// A modern, type-safe method to post a single `Sendable` value.
    /// This prevents thread-safety issues when passing data across concurrency domains.
    /// - Parameters:
    ///   - value: The thread-safe data to send.
    ///   - key: The key used to store the data in the `userInfo` dictionary.
    public func post<T: Sendable>(value: T, forKey key: AnyHashable) {
        center.post(name: name, object: nil, userInfo: [key: value])
    }
}
