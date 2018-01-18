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

    var isEffectivelyInPopover: Bool {
        var presenter = findNextResponder(of: UIViewController.self)
        while let current = presenter {
            if current.presentationController is UIPopoverPresentationController { return true }
            if current.presentationController?.shouldPresentInFullscreen == true { return false }
            presenter = current.presentingViewController
        }
        return false
    }

    var isEffectivelyDisappearing: Bool {
        guard let viewController = findNextResponder(of: UIViewController.self) else { return false }
        return viewController.isMovingFromParentViewController || viewController.isBeingDismissed
    }

}
