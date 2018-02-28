//
//  UIResponder+KeyboardAvoidance.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 5/3/16.
//  Copyright © 2015-2016. Licensed under MIT. Some rights reserved.
//

import UIKit

extension UIResponder {

    private func findNextResponder<Responder>(of type: Responder.Type = Responder.self) -> Responder? {
        var next = self.next
        while let current = next {
            if let result = current as? Responder { return result }
            next = current.next
        }
        return nil
    }

    var canBeObscuredByKeyboard: Bool {
        // Traverse `presentingViewController`s looking for an active presenter
        // that already handles the keyboard.
        var next = findNextResponder(of: UIViewController.self)
        while let current = next {
            if current.presentingViewController == nil {
                // `modalPresentationStyle` doesn't matter, we're the root
                break
            } else if current.modalPresentationStyle == .popover || current is UITableViewController || next is UICollectionViewController {
                // Popovers handle keyboard avoidance in their totality.
                return false
            } else if current.modalPresentationStyle == .custom, current.presentationController?.shouldPresentInFullscreen == true {
                // full-screen presentation, we're equivalent to the root
                break
            } else {
                // no info at this level, move to next step
                next = current.presentingViewController
            }
        }
        return !isEffectivelyDisappearing
    }

    var isEffectivelyDisappearing: Bool {
        guard let viewController = findNextResponder(of: UIViewController.self) else { return false }
        return viewController.isMovingFromParentViewController || viewController.isBeingDismissed
    }

}
