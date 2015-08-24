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

private struct KeyboardInfo {
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

private protocol KeyboardLayoutGuideType: UILayoutSupport {
    
    weak var owningView: UIView? { get }

    var viewIsDisappearing: Bool { get set }
    var registeredForNotifications: Bool { get set }
    var keyboardBottomInsetConstraint: NSLayoutConstraint! { get set }
    var hidingDebounce: dispatch_block_t? { get set }
    
    @objc func keyboardResize(note: NSNotification)
    @objc func keyboardWillHide(note: NSNotification)
    
}

private struct Debounce {
    static var HideKeyboard = false
}

extension KeyboardLayoutGuideType {
    
    // MARK: Tracking

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
    
    // MARK: Notifications
    
    func resizeKeyboardFromUserInfo(userInfo: [NSObject : AnyObject]?) {
        if let block = hidingDebounce {
            dispatch_block_cancel(block)
        }
        
        guard !updateForDisappearing() else { return }
        
        let info = KeyboardInfo(userInfo, dismissing: false)
        updateForKeyboardInfo(info)
    }
    
    func hideKeyboardFromUseInfokeyboardWillHide(userInfo: [NSObject : AnyObject]?) {
        if let block = hidingDebounce {
            dispatch_block_cancel(block)
        }
        
        guard !updateForDisappearing() else { return }
        
        let info = KeyboardInfo(userInfo, dismissing: true)
        hidingDebounce = NSRunLoop.mainRunLoop().perform {
            self.updateForKeyboardInfo(info)
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
        resizeKeyboardFromUserInfo(note.userInfo)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        hideKeyboardFromUseInfokeyboardWillHide(note.userInfo)
    }
    
    // MARK: UILayoutSupport
    
    @objc private var length: CGFloat {
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
    
    private func commonInit() {
        super.hidden = true
        translatesAutoresizingMaskIntoConstraints = false
    }

    init() {
        super.init(frame: CGRect.zeroRect)
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
    
    @objc func keyboardResize(note: NSNotification) {
        resizeKeyboardFromUserInfo(note.userInfo)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        hideKeyboardFromUseInfokeyboardWillHide(note.userInfo)
    }
    
    // MARK: UILayoutSupport
    
    var owningView: UIView? {
        return superview
    }
    
    @objc private var length: CGFloat {
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
