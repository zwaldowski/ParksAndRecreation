//
//  KeyboardLayoutGuide.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 8/23/15.
//  Copyright © 2015. Licensed under MIT. Some rights reserved.
//

import UIKit
import ObjectiveC

private class KeyboardLayoutGuide: UILayoutGuide {
    
    struct KeyboardInfo {
        let animationDuration: NSTimeInterval
        let animationOptions: UIViewAnimationOptions
        let endFrame: CGRect
        let forDismissing: Bool
        
        init?(_ userInfo: [NSObject: AnyObject]?, dismissing: Bool) {
            guard let userInfo = userInfo,
                duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,
                curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
                endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
                    return nil
            }
            
            self.animationDuration = duration
            self.animationOptions = UIViewAnimationOptions(rawValue: curve << 16)
            self.endFrame = endFrame
            self.forDismissing = dismissing
        }
        
        func overlapInView(view: UIView) -> CGFloat? {
            guard let window = view.window where !forDismissing else {
                return nil
            }

            let keyboardFrameWindow = window.convertRect(endFrame, fromWindow: nil)
            let keyboardFrameLocal = window.convertRect(keyboardFrameWindow, toView: view.superview)
            let coveredFrame = view.frame.rectByIntersecting(keyboardFrameLocal)
            let finalOverlap = window.convertRect(coveredFrame, toView: view.superview)
            return finalOverlap.height
        }
    }
    
    // MARK: UILayoutGuide
    
    init(forViewController: ()) {
        super.init()
        identifier = "DZWKeyboard"
    }
    
    override init() {
        fatalError("This layout guide cannot be instantiated on its own. See UIViewController.keyboardLayoutGuide.")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override weak var owningView: UIView? {
        didSet {
            guard let view = owningView else {
                keyboardBottomInsetConstraint = nil
                return
            }
            
            let vc = view.nextViewController
            let vcTopAnchor = vc?.topLayoutGuide.bottomAnchor ?? view.layoutMarginsGuide.topAnchor
            let vcBottomAnchor = vc?.bottomLayoutGuide.topAnchor ?? view.layoutMarginsGuide.bottomAnchor
            let newKeyboardConstraint = view.layoutMarginsGuide.bottomAnchor.constraintEqualToAnchor(bottomAnchor)

            NSLayoutConstraint.activateConstraints([
                leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
                trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
                topAnchor.constraintEqualToAnchor(vcTopAnchor),
                bottomAnchor.constraintEqualToAnchor(vcBottomAnchor).atPriority(250),
                bottomAnchor.constraintLessThanOrEqualToAnchor(vcBottomAnchor).atPriority(999),
                newKeyboardConstraint
            ])
            
            keyboardBottomInsetConstraint = newKeyboardConstraint
            
            resumeIfNeeded()
        }
    }
    
    // MARK: Tracking
    
    var viewIsDisappearing = false
    var registeredForNotifications = false
    var keyboardBottomInsetConstraint: NSLayoutConstraint!
    
    func resumeIfNeeded() {
        defer { viewIsDisappearing = false }
        guard !registeredForNotifications else { return }
        defer { registeredForNotifications = true }
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "keyboardResize:", name: UIKeyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        nc.addObserver(self, selector: "keyboardResize:", name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    func updateForDisappearing() -> Bool {
        guard let view = owningView else { return false }
        let isHidden = view.window == nil || view.nextViewController.map { $0.isBeingDismissed() || $0.isMovingFromParentViewController() } ?? false
        viewIsDisappearing = isHidden
        return isHidden
    }
    
    func updateForKeyboardInfo(info: KeyboardInfo?) {
        guard !viewIsDisappearing, let view = owningView where view.nextViewController?.popoverPresentationController == nil else {
            return
        }
        
        keyboardBottomInsetConstraint.constant = info?.overlapInView(view) ?? 0
        
        let duration = info?.animationDuration ?? 0
        let curve = info?.animationOptions ?? []
        UIView.animateWithDuration(duration, delay: 0, options: [ curve, .BeginFromCurrentState ], animations: view.layoutIfNeeded, completion: nil)
    }
    
    // MARK: Notifications
    
    var hidingDebounce: dispatch_block_t?
    
    @objc func keyboardResize(note: NSNotification) {
        if let block = hidingDebounce {
            dispatch_block_cancel(block)
        }
        
        guard !updateForDisappearing() else { return }
        
        let info = KeyboardInfo(note.userInfo, dismissing: false)
        updateForKeyboardInfo(info)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        if let block = hidingDebounce {
            dispatch_block_cancel(block)
        }

        guard !updateForDisappearing() else { return }

        let info = KeyboardInfo(note.userInfo, dismissing: true)
        hidingDebounce = NSRunLoop.mainRunLoop().perform {
            self.updateForKeyboardInfo(info)
        }
    }
    
}

// MARK: - UIViewController

private struct AssociatedObjects {
    static var KeyboardLayoutGuide = 0
}

extension UIViewController {
    
    /// A layout guide that dynamically resizes based on the location of the
    /// keyboard. Normally, the guide is a rectangle matching the top and bottom
    /// guides of the recieving view controller and the leading and trailing
    /// margins of its view. When the keyboard is active, the bottom of the
    /// guide retracts to include whatever space the keyboard overlaps in.
    var keyboardLayoutGuide: UILayoutGuide {
        assert(isViewLoaded(), "This layout guide should not be accessed before the view is loaded.")
        
        if let guide = objc_getAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide) as? KeyboardLayoutGuide {
            return guide
        }
        
        let guide = KeyboardLayoutGuide(forViewController: ())
        view.addLayoutGuide(guide)
        objc_setAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide, guide, .OBJC_ASSOCIATION_ASSIGN)
        return guide
    }
    
}

// MARK: - Extensions

private extension UIView {
    
    var nextViewController: UIViewController? {
        while let nextResponder = nextResponder() {
            guard let vc = nextResponder as? UIViewController else { continue }
            return vc
        }
        return nil
    }
    
}

private extension NSLayoutConstraint {
    
    func atPriority(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
}

private extension NSRunLoop {
    
    // A fancy cancellable `performSelector(_:withObject:afterDelay:inModes:)`
    // cribbed from UIKit disassembly. Similar to `dispatch_async`, but
    // using @c NSRunLoopCommonModes ensures dispatch during tracking
    // runloops (such as dragging a scroll view) to allow animating out.
    func perform(inModes modes: [String] = [NSRunLoopCommonModes], body: () -> ()) -> dispatch_block_t {
        let wrapper = dispatch_block_create(dispatch_block_flags_t(0), body)!
        CFRunLoopPerformBlock(getCFRunLoop(), NSRunLoopCommonModes, wrapper)
        return wrapper
    }
    
}
