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
public final class KeyboardLayoutGuide: UILayoutGuide {
    
    // MARK: - Properties
    
    private let notificationCenter: NotificationCenter
    private var registeredForNotifications = false
    private var bottomToContainerConstraint: NSLayoutConstraint?
    
    /// If assigned, and this scroll view contains the first responder, it will
    /// be scrolled into view upon any keyboard change.
    ///
    /// It is not necessary to track the scroll view that is managed as the
    /// primary view of a `UITableViewController` or, as of iOS 9,
    /// `UICollectionViewController`.
    public weak var avoidFirstResponderInScrollView: UIScrollView?

    // MARK: - Lifecycle

    private func commonInit() {
        identifier = "KeyboardLayoutGuide"
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardDidChangeFrame), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }

    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        super.init()
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.notificationCenter = .default
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - UILayoutGuide
    
    override public weak var owningView: UIView? {
        didSet {
            activateConstraints()
        }
    }
    
    // MARK: - Actions

    private func activateConstraints() {
        guard let view = owningView else {
            bottomToContainerConstraint = nil
            return
        }

        let vcTopAnchor: NSLayoutYAxisAnchor
        let vcBottomAnchor: NSLayoutYAxisAnchor
        if let vc = view.findNextViewController() {
            vcTopAnchor = vc.topLayoutGuide.bottomAnchor
            vcBottomAnchor = vc.bottomLayoutGuide.topAnchor
        } else {
            vcTopAnchor = view.topAnchor
            vcBottomAnchor = view.bottomAnchor
        }

        let bottomToContainer = view.bottomAnchor.constraint(equalTo: bottomAnchor)
        self.bottomToContainerConstraint = bottomToContainer

        NSLayoutConstraint.activate([
            bottomToContainer,
            topAnchor.constraint(equalTo: vcTopAnchor), {
                let constraint = vcBottomAnchor.constraint(equalTo: bottomAnchor)
                constraint.priority = UILayoutPriorityDefaultLow
                return constraint
            }(), {
                let constraint = vcBottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
                constraint.priority = 999
                return constraint
            }(),
            leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func updateKeyboard(forInfo info: Any?) {
        guard let info = info as? KeyboardInfo, info.isLocal,
            let view = owningView, !view.isEffectivelyDisappearing else { return }
        
        let constant = info.overlap(in: view)
        guard constant != bottomToContainerConstraint?.constant else { return }
        bottomToContainerConstraint?.constant = constant
        
        info.animate(animations: view.layoutIfNeeded)
        
        avoidFirstResponderInScrollView?.scrollFirstResponderToVisible(animated: true)
    }
    
    // MARK: - Notifications

    @objc private func noteKeyboardWillShow(note: NSNotification) {
        updateKeyboard(forInfo: KeyboardInfo(userInfo: note.userInfo))
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateKeyboard(forInfo:)), object: nil)
    }

    @objc private func noteKeyboardWillHide(note: NSNotification) {
        perform(#selector(updateKeyboard(forInfo:)), with: KeyboardInfo(userInfo: nil), afterDelay: 0)
    }

    @objc private func noteKeyboardDidChangeFrame(note: NSNotification) {
        updateKeyboard(forInfo: KeyboardInfo(userInfo: note.userInfo))
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateKeyboard(forInfo:)), object: nil)
    }
    
}

// MARK: - UIViewController

extension UIViewController {
    
    private static var keyboardLayoutGuideKey = false

    /// For unit testing purposes only.
    @nonobjc func makeKeyboardLayoutGuide(notificationCenter: NotificationCenter) -> KeyboardLayoutGuide {
        assert(isViewLoaded, "This layout guide should not be accessed before the view is loaded.")

        let guide = KeyboardLayoutGuide(notificationCenter: notificationCenter)
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
    public var keyboardLayoutGuide: KeyboardLayoutGuide {
        if let guide = objc_getAssociatedObject(self, &UIViewController.keyboardLayoutGuideKey) as? KeyboardLayoutGuide {
            return guide
        }

        let guide = makeKeyboardLayoutGuide(notificationCenter: .default)
        objc_setAssociatedObject(self, &UIViewController.keyboardLayoutGuideKey, guide, .OBJC_ASSOCIATION_ASSIGN)
        return guide
    }
    
}

// MARK: - Helpers

private extension UIView {

    func findNextViewController() -> UIViewController? {
        var next: UIResponder? = self
        while let current = next {
            if let vc = current as? UIViewController { return vc }
            next = current.next
        }
        return nil
    }

    var isEffectivelyInPopover: Bool {
        guard let vc = findNextViewController() else { return false }
        var presenter = vc.presentingViewController
        while let current = presenter {
            if current.presentationController is UIPopoverPresentationController { return true }
            if current.presentationController?.shouldPresentInFullscreen == true { return false }
            presenter = current.presentingViewController
        }
        return false
    }

    var isEffectivelyDisappearing: Bool {
        guard window != nil else { return true }
        guard let vc = findNextViewController() else { return false }
        return vc.isBeingDismissed || vc.isMovingFromParentViewController
    }

}

private struct KeyboardInfo {

    let animationDuration: TimeInterval
    let animationCurve: UIViewAnimationOptions
    let endFrame: CGRect?
    let isLocal: Bool

    init(userInfo: [AnyHashable: Any]?) {
        self.animationDuration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        self.animationCurve = UIViewAnimationOptions(rawValue: ((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt) ?? 7) << 16)
        self.endFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        self.isLocal = (userInfo?[UIKeyboardIsLocalUserInfoKey] as? Bool) ?? true
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
