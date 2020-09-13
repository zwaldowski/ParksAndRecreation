//  Copyright © 2016 Apple Inc. All rights reserved.

import UIKit

extension UIResponder {

    /// Walks the responder chain looking for a specific subclass or protocol.
    ///
    /// Examples of use:
    /// - Find a view controller from a view.
    /// - Find a specific container, like a scroll view. (Very useful for accessibility.)
    /// - Call a method using the responder chain that can't be exposed `@objc`.
    func findNextResponder<Responder>(of type: Responder.Type) -> Responder? {
        var next = self as UIResponder?
        while let current = next {
            if let result = current as? Responder { return result }
            next = current.next
        }
        return nil
    }

}
