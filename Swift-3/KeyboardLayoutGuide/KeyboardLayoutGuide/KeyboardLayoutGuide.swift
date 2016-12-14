//
//  KeyboardLayoutGuide.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 8/23/15.
//  Copyright © 2015-2016. Licensed under MIT. Some rights reserved.
//

import UIKit
import ObjectiveC

/// A keyboard layout guide may be used as an item in Auto Layout, for its
/// layout anchors, or may be queried for its length property.
public protocol KeyboardLayoutGuide: UILayoutSupport {

    /// If assigned, and this scroll view contains the first responder, it will
    /// be scrolled into view upon any keyboard change.
    ///
    /// It is not necessary to track the scroll view that is managed as the
    /// primary view of a `UITableViewController` or, as of iOS 9,
    /// `UICollectionViewController`.
    var avoidFirstResponderInScrollView: UIScrollView? { get set }

}

// MARK: Generic implementation

private protocol KeyboardLayoutGuidePrivate: KeyboardLayoutGuide {

    var owningView: UIView? { get }
    
}

private final class KeyboardLayoutGuideSupport: NSObject {

    unowned let owner: KeyboardLayoutGuidePrivate
    let notificationCenter: NotificationCenter

    var registeredForNotifications = false
    var bottomToContainerConstraint: NSLayoutConstraint?

    init(owner: KeyboardLayoutGuidePrivate, notificationCenter: NotificationCenter) {
        self.owner = owner
        self.notificationCenter = notificationCenter
        super.init()
    }

    func activate() {
        activateConstraints()

        guard !registeredForNotifications else { return }
        defer { registeredForNotifications = true }

        notificationCenter.addObserver(self, selector: #selector(noteKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardDidChangeFrame), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }

    func activateConstraints() {
        guard let view = owner.owningView else {
            bottomToContainerConstraint = nil
            return
        }

        let vcTopItem: AnyObject
        let vcTopAttribute: NSLayoutAttribute
        let vcBottomItem: AnyObject
        let vcBottomAttribute: NSLayoutAttribute
        if let vc = view.findNextViewController() {
            vcTopItem = vc.topLayoutGuide
            vcTopAttribute = .bottom
            vcBottomItem = vc.bottomLayoutGuide
            vcBottomAttribute = .top
        } else {
            vcTopItem = view
            vcTopAttribute = .top
            vcBottomItem = view
            vcBottomAttribute = .bottom
        }

        let bottomToContainer = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: owner, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            bottomToContainer,
            NSLayoutConstraint(item: owner, attribute: .top, relatedBy: .equal, toItem: vcTopItem, attribute: vcTopAttribute, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: vcBottomItem, attribute: vcBottomAttribute, relatedBy: .equal, toItem: owner, attribute: .bottom, multiplier: 1, constant: 0).atPriority(priority: 250),
            NSLayoutConstraint(item: vcBottomItem, attribute: vcBottomAttribute, relatedBy: .greaterThanOrEqual, toItem: owner, attribute: .bottom, multiplier: 1, constant: 0).atPriority(priority: 999),
            NSLayoutConstraint(item: owner, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .trailingMargin, relatedBy: .equal, toItem: owner, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        bottomToContainerConstraint = bottomToContainer
    }

    func updateKeyboard(info: KeyboardInfo) {
        guard info.isLocal, let view = owner.owningView, !view.isEffectivelyDisappearing else { return }

        let constant = info.overlap(in: view)
        guard constant != bottomToContainerConstraint?.constant else { return }
        bottomToContainerConstraint?.constant = constant

        info.animate(animations: view.layoutIfNeeded)

        owner.avoidFirstResponderInScrollView?.scrollFirstResponderToVisible(animated: true)
    }

    @objc func adjustForKeyboard(notificationUserInfo userInfo: [AnyHashable: Any]?) {
        updateKeyboard(info: .init(userInfo: userInfo))
    }

    @objc func noteKeyboardWillShow(note: NSNotification) {
        adjustForKeyboard(notificationUserInfo: note.userInfo)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(adjustForKeyboard), object: nil)
    }

    @objc func noteKeyboardWillHide(note: NSNotification) {
        perform(#selector(adjustForKeyboard), with: nil, afterDelay: 0)
    }

    @objc func noteKeyboardDidChangeFrame(note: NSNotification) {
        adjustForKeyboard(notificationUserInfo: note.userInfo)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(adjustForKeyboard), object: nil)
    }

}

// MARK: - Native Guide

@available(iOS 9.0, *)
private final class KeyboardLayoutGuideNative: UILayoutGuide, KeyboardLayoutGuidePrivate {

    var support: KeyboardLayoutGuideSupport!
    weak var avoidFirstResponderInScrollView: UIScrollView?

    init(notificationCenter: NotificationCenter) {
        super.init()
        commonInit(notificationCenter: notificationCenter)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(notificationCenter: .default)
    }

    func commonInit(notificationCenter: NotificationCenter) {
        identifier = "KeyboardLayoutGuide"
        support = KeyboardLayoutGuideSupport(owner: self, notificationCenter: notificationCenter)
    }

    override weak var owningView: UIView? {
        didSet {
            support?.activate()
        }
    }

    @objc var length: CGFloat {
        return layoutFrame.height
    }
    
}

// MARK: - UIViewController

private struct AssociatedObjects {
    static var KeyboardLayoutGuide = 0
}

extension UIViewController {

    /// For unit testing purposes only.
    @nonobjc func makeKeyboardLayoutGuide(notificationCenter: NotificationCenter) -> KeyboardLayoutGuide {
        assert(isViewLoaded, "This layout guide should not be accessed before the view is loaded.")

        let guide = KeyboardLayoutGuideNative(notificationCenter: notificationCenter)
        view.addLayoutGuide(guide)
        return guide
    }

    /// A keyboard layout guide is a rectangle in the layout system representing
    /// the area on screen not currently occupied by the keyboard; thus, it is a
    /// simplified model for performing layout by avoiding the keyboard.
    ///
    /// Normally, the guide is a rectangle matching the top and bottom
    /// guides of a recieving view controller and the leading and trailing
    /// margins of its view. When the keyboard is active.
    ///
    /// - seealso: KeyboardLayoutGuide
    @nonobjc var keyboardLayoutGuide: KeyboardLayoutGuide {
        if let guide = objc_getAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide) as? KeyboardLayoutGuide {
            return guide
        }

        let guide = makeKeyboardLayoutGuide(notificationCenter: .default)
        objc_setAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide, guide, .OBJC_ASSOCIATION_ASSIGN)
        return guide
    }
    
}

// MARK: - Extensions

private extension UIView {

    func findNextViewController() -> UIViewController? {
        while let nextResponder = next {
            if let vc = nextResponder as? UIViewController { return vc }
        }
        return nil
    }

    var isEffectivelyInPopover: Bool {
        guard let vc = findNextViewController() else { return false }
        var presenter = vc.presentingViewController
        while let currentPresenter = presenter {
            if currentPresenter.presentationController is UIPopoverPresentationController { return true }
            if currentPresenter.presentationController?.shouldPresentInFullscreen == true { return false }
            presenter = currentPresenter.presentingViewController
        }
        return false
    }

    var isEffectivelyDisappearing: Bool {
        guard window != nil else { return true }
        guard let vc = findNextViewController() else { return false }
        return vc.isBeingDismissed || vc.isMovingFromParentViewController
    }

}

private extension NSLayoutConstraint {
    
    func atPriority(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
}

private struct KeyboardInfo {

    let animationDuration: TimeInterval
    let animationCurve: UIViewAnimationOptions
    let endFrame: CGRect?
    let isLocal: Bool

    init(userInfo: [AnyHashable: Any]?) {
        self.animationDuration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        self.animationCurve = .init(rawValue: ((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt) ?? 7) << 16)
        
        self.endFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        if let isLocal = userInfo?[UIKeyboardIsLocalUserInfoKey] as? Bool {
            self.isLocal = isLocal
        } else {
            self.isLocal = true
        }
    }

    func animate(animations: @escaping () -> Void) {
        // When performing a keyboard update around a screen rotation animation,
        // UIKit disables animations and sends a duration of 0.
        //
        // For the keyboard, we're just going to assume a layout pass happens
        // soon. (And maybe pray. Just a little.)
        guard UIView.areAnimationsEnabled && !animationDuration.isZero else { return }

        UIView.animate(withDuration: animationDuration, delay: 0, options: [ animationCurve, .allowUserInteraction, .beginFromCurrentState ], animations: animations, completion: nil)
    }

    // A poor man's -[UIPeripheralHost getVerticalOverlapForView:usingKeyboardInfo:]
    func overlap(in view: UIView) -> CGFloat {
        guard !view.isEffectivelyInPopover, let endFrame = endFrame, let target = view.superview else { return 0 }
        let localMinY = target.convert(endFrame.origin, from: nil).y
        return max(view.frame.maxY - localMinY, 0)
    }
    
}
