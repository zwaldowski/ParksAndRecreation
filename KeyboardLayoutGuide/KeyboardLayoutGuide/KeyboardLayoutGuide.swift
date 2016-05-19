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

private let KeyboardUserInfoIsDismissingKey = "DZWKeyboardIsDismissing"

private protocol KeyboardLayoutGuidePrivate: KeyboardLayoutGuide {

    var owningView: UIView? { get }
    
}

private final class KeyboardLayoutGuideSupport: NSObject {

    unowned let owner: KeyboardLayoutGuidePrivate
    let notificationCenter: NSNotificationCenter

    var registeredForNotifications = false
    var isDisappearing = false
    var bottomToContainerConstraint: NSLayoutConstraint?

    init(owner: KeyboardLayoutGuidePrivate, notificationCenter: NSNotificationCenter) {
        self.owner = owner
        self.notificationCenter = notificationCenter
        super.init()
    }

    deinit {
        if #available(iOS 9.0, *) {} else {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }

    func activate() {
        activateConstraints()

        isDisappearing = false

        guard !registeredForNotifications else { return }
        defer { registeredForNotifications = true }

        notificationCenter.addObserver(self, selector: #selector(noteKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardDidChangeFrame), name: UIKeyboardDidChangeFrameNotification, object: nil)
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
            vcTopAttribute = .Bottom
            vcBottomItem = vc.bottomLayoutGuide
            vcBottomAttribute = .Top
        } else {
            vcTopItem = view
            vcTopAttribute = .Top
            vcBottomItem = view
            vcBottomAttribute = .Bottom
        }

        let bottomToContainer = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: owner, attribute: .Bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([
            bottomToContainer,
            NSLayoutConstraint(item: owner, attribute: .Top, relatedBy: .Equal, toItem: vcTopItem, attribute: vcTopAttribute, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: vcBottomItem, attribute: vcBottomAttribute, relatedBy: .Equal, toItem: owner, attribute: .Bottom, multiplier: 1, constant: 0).atPriority(250),
            NSLayoutConstraint(item: vcBottomItem, attribute: vcBottomAttribute, relatedBy: .GreaterThanOrEqual, toItem: owner, attribute: .Bottom, multiplier: 1, constant: 0).atPriority(999),
            NSLayoutConstraint(item: owner, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .LeadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .TrailingMargin, relatedBy: .Equal, toItem: owner, attribute: .Trailing, multiplier: 1, constant: 0)
        ])
        bottomToContainerConstraint = bottomToContainer
    }

    func updateKeyboard(info info: KeyboardInfo?) {
        guard !isDisappearing, let view = owner.owningView else { return }

        let constant: CGFloat
        if !view.isEffectivelyInPopover, let overlap = info?.overlap(in: view) {
            constant = overlap
        } else {
            constant = 0
        }

        guard constant != bottomToContainerConstraint?.constant else { return }
        bottomToContainerConstraint?.constant = constant

        UIView.beginAnimations(nil, context: nil)
        defer { UIView.commitAnimations() }

        UIView.setAnimationDuration(info?.animationDuration ?? 0.25)
        UIView.setAnimationCurve(info?.animationCurve ?? .EaseInOut)

        view.layoutIfNeeded()
        owner.avoidFirstResponderInScrollView?.scrollFirstResponderToVisible(animated: true)
    }

    @objc func adjustForKeyboard(notificationUserInfo userInfo: [NSObject: AnyObject]?) {
        let info = KeyboardInfo(userInfo: userInfo)

        if owner.owningView == nil || owner.owningView?.isEffectivelyDisappearing == true {
            self.isDisappearing = true
            return
        } else if info?.isLocal == false {
            return
        }

        updateKeyboard(info: info)
    }

    @objc func noteKeyboardWillShow(note: NSNotification) {
        adjustForKeyboard(notificationUserInfo: note.userInfo)
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(adjustForKeyboard), object: nil)
    }

    @objc func noteKeyboardWillHide(note: NSNotification) {
        var userInfo = note.userInfo
        userInfo?[KeyboardUserInfoIsDismissingKey] = true
        performSelector(#selector(adjustForKeyboard), withObject: userInfo, afterDelay: 0, inModes: [ NSRunLoopCommonModes ])
    }

    @objc func noteKeyboardDidChangeFrame(note: NSNotification) {
        adjustForKeyboard(notificationUserInfo: note.userInfo)
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(adjustForKeyboard), object: nil)
    }

}

// MARK: - Native Guide

@available(iOS 9.0, *)
private final class KeyboardLayoutGuideNative: UILayoutGuide, KeyboardLayoutGuidePrivate {

    var support: KeyboardLayoutGuideSupport!
    weak var avoidFirstResponderInScrollView: UIScrollView?

    init(notificationCenter: NSNotificationCenter) {
        super.init()
        commonInit(notificationCenter: notificationCenter)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(notificationCenter: .defaultCenter())
    }

    func commonInit(notificationCenter notificationCenter: NSNotificationCenter) {
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

// MARK: - Legacy Guide

private final class KeyboardLayoutGuideLegacy: LayoutOnlyView, KeyboardLayoutGuidePrivate {

    var support: KeyboardLayoutGuideSupport!
    weak var avoidFirstResponderInScrollView: UIScrollView?

    init(notificationCenter: NSNotificationCenter) {
        super.init(frame: .zero)
        commonInit(notificationCenter: notificationCenter)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(notificationCenter: .defaultCenter())
    }

    func commonInit(notificationCenter notificationCenter: NSNotificationCenter) {
        userInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        support = KeyboardLayoutGuideSupport(owner: self, notificationCenter: notificationCenter)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        support.activate()
    }

    var owningView: UIView? {
        return superview
    }
    
    @objc var length: CGFloat {
        return bounds.height
    }
    
}

// MARK: - UIViewController

private struct AssociatedObjects {
    static var KeyboardLayoutGuide = 0
}

extension UIViewController {

    /// For unit testing purposes only.
    @nonobjc func makeKeyboardLayoutGuide(notificationCenter notificationCenter: NSNotificationCenter) -> KeyboardLayoutGuide {
        assert(isViewLoaded(), "This layout guide should not be accessed before the view is loaded.")

        guard #available(iOS 9.0, *) else {
            let guide = KeyboardLayoutGuideLegacy(notificationCenter: notificationCenter)
            view.addSubview(guide)
            return guide
        }

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

        let guide = makeKeyboardLayoutGuide(notificationCenter: .defaultCenter())
        objc_setAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide, guide, .OBJC_ASSOCIATION_ASSIGN)
        return guide
    }
    
}

// MARK: - Extensions

private extension UIView {

    func findNextViewController() -> UIViewController? {
        while let nextResponder = nextResponder() {
            if let vc = nextResponder as? UIViewController { return vc }
        }
        return nil
    }

    var isEffectivelyInPopover: Bool {
        guard let vc = findNextViewController() else { return false }
        var presenter = vc.presentingViewController
        while let currentPresenter = presenter {
            if currentPresenter.presentationController is UIPopoverPresentationController { return true }
            if currentPresenter.presentationController?.shouldPresentInFullscreen() == true { return false }
            presenter = currentPresenter.presentingViewController
        }
        return false
    }

    var isEffectivelyDisappearing: Bool {
        guard window != nil else { return true }
        guard let vc = findNextViewController() else { return false }
        return vc.isBeingDismissed() || vc.isMovingFromParentViewController()
    }

}

private extension NSLayoutConstraint {
    
    func atPriority(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
}

private struct KeyboardInfo {

    let animationDuration: NSTimeInterval
    let animationCurve: UIViewAnimationCurve
    let endFrame: CGRect
    let isLocal: Bool

    let forDismissing: Bool

    init?(userInfo: [NSObject: AnyObject]?) {
        guard let userInfo = userInfo,
            duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,
            curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
            endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
                return nil
        }

        self.animationDuration = duration
        // The kit uses a private animation curve that isn't represented in UIViewAnimationOptions
        self.animationCurve = unsafeBitCast(curve, UIViewAnimationCurve.self)
        self.endFrame = endFrame
        if #available(iOS 9, *), let isLocal = userInfo[UIKeyboardIsLocalUserInfoKey] as? Bool {
            self.isLocal = isLocal
        } else {
            self.isLocal = true
        }
        self.forDismissing = (userInfo[KeyboardUserInfoIsDismissingKey] as? Bool) ?? false
    }

    // A poor man's -[UIPeripheralHost getVerticalOverlapForView:usingKeyboardInfo:]
    func overlap(in view: UIView) -> CGFloat? {
        guard !forDismissing && !view.isEffectivelyInPopover, let target = view.superview else { return nil }
        let localMinY = target.convertPoint(endFrame.origin, fromView: nil).y
        return view.frame.maxY - localMinY
    }
    
}
