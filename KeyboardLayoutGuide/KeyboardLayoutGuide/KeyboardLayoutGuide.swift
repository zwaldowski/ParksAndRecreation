//
//  KeyboardLayoutGuide.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 8/23/15.
//  Copyright © 2015. Licensed under MIT. Some rights reserved.
//

import UIKit
import ObjectiveC

// MARK: Generic implementation

private let KeyboardUserInfoIsDismissingKey = "DZWKeyboardIsDismissing"

private struct KeyboardInfo {
    let animationDuration: NSTimeInterval
    let animationOptions: UIViewAnimationOptions
    let endFrame: CGRect
    let forDismissing: Bool
    
    init?(legacyUserInfo userInfo: [NSObject: AnyObject]?) {
        let dismissing = (userInfo?[KeyboardUserInfoIsDismissingKey] as? Bool) ?? false
        self.init(userInfo: userInfo, dismissing: dismissing)
    }
    
    init?(userInfo: [NSObject: AnyObject]?, dismissing: Bool) {
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
        let coveredFrame = view.frame.intersect(keyboardFrameLocal)
        let finalOverlap = window.convertRect(coveredFrame, toView: view.superview)
        return finalOverlap.height
    }
}

private protocol KeyboardLayoutGuideType: UILayoutSupport {
    
    weak var owningView: UIView? { get }

    var viewIsDisappearing: Bool { get set }
    var registeredForNotifications: Bool { get set }
    var keyboardBottomInsetConstraint: NSLayoutConstraint! { get set }
    
    @objc func keyboardResize(note: NSNotification)
    @objc func keyboardWillHide(note: NSNotification)
    
}

extension KeyboardLayoutGuideType {

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
    
    func setupConstraints() {
        guard let view = owningView else {
            keyboardBottomInsetConstraint = nil
            return
        }
        
        let vc = view.nextViewController
        let vcTopLayoutGuide: AnyObject = vc?.topLayoutGuide ?? view
        let vcTopLayoutAttr: NSLayoutAttribute = vc.map { _ in .Top } ?? .Bottom
        let vcBottomLayoutGuide: AnyObject = vc?.bottomLayoutGuide ?? view
        let newKeyboardConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .LeadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .TrailingMargin, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: vcTopLayoutGuide, attribute: vcTopLayoutAttr, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: vcBottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0).atPriority(250),
            NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: vcBottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0).atPriority(999),
            newKeyboardConstraint
        ])
        
        
        keyboardBottomInsetConstraint = newKeyboardConstraint
        
        resumeIfNeeded()
    }
    
    func updateForKeyboardInfo(info: KeyboardInfo?, animated: Bool) {
        guard !viewIsDisappearing, let view = owningView, let vc = view.nextViewController where vc.popoverPresentationController == nil else {
            return
        }
        
        keyboardBottomInsetConstraint.constant = info?.overlapInView(view) ?? 0
        if animated {
            let duration = info?.animationDuration ?? 0
            let curve = info?.animationOptions ?? []
            UIView.animateWithDuration(duration, delay: 0, options: [ curve, .BeginFromCurrentState ], animations: view.layoutIfNeeded, completion: nil)
        } else {
            view.layoutIfNeeded()
        }
    }
    
}

// MARK: - UILayoutGuide

@available(iOS 9.0, *)
private class KeyboardLayoutGuide: UILayoutGuide, KeyboardLayoutGuideType {
    
    var viewIsDisappearing = false
    var registeredForNotifications = false
    var keyboardBottomInsetConstraint: NSLayoutConstraint!
    var hidingDebounce: dispatch_block_t?
    
    override init() {
        super.init()
        identifier = "DZWKeyboard"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override weak var owningView: UIView? {
        didSet {
            setupConstraints()
        }
    }
    
    // MARK: Notifications
    
    @objc func keyboardResize(note: NSNotification) {
        guard !updateForDisappearing() else { return }
        
        let info = KeyboardInfo(userInfo: note.userInfo, dismissing: false)
        updateForKeyboardInfo(info, animated: false)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        guard !updateForDisappearing() else { return }

        let info = KeyboardInfo(userInfo: note.userInfo, dismissing: true)
        updateForKeyboardInfo(info, animated: false)
    }
    
    // MARK: UILayoutSupport
    
    @objc var length: CGFloat {
        return layoutFrame.height
    }
    
}

// MARK: - UIView

private class KeyboardLayoutGuideLegacy: UIView, KeyboardLayoutGuideType {
    
    var viewIsDisappearing = false
    var registeredForNotifications = false
    var keyboardBottomInsetConstraint: NSLayoutConstraint!
    var hidingDebounce: dispatch_block_t?
    
    override class func layerClass() -> AnyClass {
        return CATransformLayer.self
    }
    
    func commonInit() {
        super.hidden = true
        translatesAutoresizingMaskIntoConstraints = false
    }

    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupConstraints()
    }
    
    override var backgroundColor: UIColor? {
        get { return nil }
        set { }
    }
    
    override var opaque: Bool {
        get { return false }
        set { }
    }
    
    override var hidden: Bool {
        get { return true }
        set { }
    }
    
    // MARK: Notifications
    
    var deferredKeyboardUserInfo: [NSObject: AnyObject]?
    
    @objc func keyboardResize(note: NSNotification) {
        NSRunLoop.mainRunLoop().cancelPerformSelector("updateForCurrentKeyboardUserInfo", target: self, argument: nil)
        deferredKeyboardUserInfo = nil
        
        guard !updateForDisappearing() else { return }
        
        let info = KeyboardInfo(legacyUserInfo: note.userInfo)
        updateForKeyboardInfo(info, animated: true)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        NSRunLoop.mainRunLoop().cancelPerformSelector("updateForCurrentKeyboardUserInfo", target: self, argument: nil)
        
        guard !updateForDisappearing() else { return }
        
        var userInfo = note.userInfo ?? [:]
        userInfo[KeyboardUserInfoIsDismissingKey] = true
        deferredKeyboardUserInfo = userInfo
        
        NSRunLoop.mainRunLoop().performSelector("updateForCurrentKeyboardUserInfo", target: self, argument: nil, order: 0, modes: [NSRunLoopCommonModes])
    }
    
    @objc func updateForCurrentKeyboardUserInfo() {
        let info = KeyboardInfo(legacyUserInfo: deferredKeyboardUserInfo)
        updateForKeyboardInfo(info, animated: true)
        deferredKeyboardUserInfo = nil
    }
    
    // MARK: UILayoutSupport
    
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
    
    /// A layout guide that dynamically resizes based on the location of the
    /// keyboard. Normally, the guide is a rectangle matching the top and bottom
    /// guides of the recieving view controller and the leading and trailing
    /// margins of its view. When the keyboard is active, the bottom of the
    /// guide retracts to include whatever space the keyboard overlaps in.
    var keyboardLayoutGuide: UILayoutSupport {
        assert(isViewLoaded(), "This layout guide should not be accessed before the view is loaded.")
        
        if let guide = objc_getAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide) as? UILayoutSupport {
            return guide
        }
        
        if #available(iOS 9.0, *) {
            let guide = KeyboardLayoutGuide()
            view.addLayoutGuide(guide)
            objc_setAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide, guide, .OBJC_ASSOCIATION_ASSIGN)
            return guide
        } else {
            let guide = KeyboardLayoutGuideLegacy()
            view.addSubview(guide)
            objc_setAssociatedObject(self, &AssociatedObjects.KeyboardLayoutGuide, guide, .OBJC_ASSOCIATION_ASSIGN)
            return guide
        }
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
