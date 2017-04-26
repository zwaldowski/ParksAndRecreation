//
//  KeyboardLayoutGuide.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 8/23/15.
//  Copyright © 2015-2016. Licensed under MIT. Some rights reserved.
//

import UIKit

/// A keyboard layout guide may be used as an item in Auto Layout, for its
/// layout anchors, or may be queried for its length property.
public final class KeyboardLayoutGuide: UILayoutGuide, UILayoutSupport {

    private static let didUpdate = Notification.Name(rawValue: "KeyboardLayoutGuideDidUpdateNotification")

    // MARK: Lifecycle

    private let notificationCenter: NotificationCenter

    private func commonInit() {
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardShow), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardHide), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteKeyboardShow), name: .UIKeyboardDidChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteAncestorGuideUpdate), name: KeyboardLayoutGuide.didUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteTextFieldDidEndEditing), name: .UITextFieldTextDidEndEditing, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.notificationCenter = .default
        super.init(coder: aDecoder)
        commonInit()
    }

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        super.init()
        commonInit()
    }

    // MARK: Public API

    /// If assigned, and this scroll view contains the first responder, it will
    /// be scrolled into view upon any keyboard change.
    ///
    /// It is not necessary to track the scroll view that is managed as the
    /// primary view of a `UITableViewController` or, as of iOS 9,
    /// `UICollectionViewController`.
    public weak var avoidFirstResponderInScrollView: UIScrollView?

    // MARK: UILayoutGuide

    /// The view that owns this layout guide.
    override public weak var owningView: UIView? {
        didSet {
            activateConstraints()
        }
    }

    // MARK: UILayoutSupport

    /// Provides the length, in points, of the portion of a view controller’s
    /// view that is visible outside of translucent or transparent UIKit bars
    /// and the keyboard.
    public var length: CGFloat {
        return layoutFrame.height
    }

    // MARK: Actions

    private var keyboardBottomConstraint: NSLayoutConstraint?
    private var lastScrollViewInsetDelta: CGFloat = 0

    private func activateConstraints() {
        guard let view = owningView else {
            keyboardBottomConstraint = nil
            return
        }

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: trailingAnchor), {
                let constraint = topAnchor.constraint(equalTo: view.topAnchor)
                constraint.priority = UILayoutPriorityDefaultLow
                return constraint
            }(), {
                let constraint = view.bottomAnchor.constraint(equalTo: bottomAnchor)
                constraint.priority = 998
                self.keyboardBottomConstraint = constraint
                return constraint
            }()
        ])
    }

    @objc
    private func updateKeyboard(forUserInfo userInfo: [AnyHashable: Any]?) {
        let info = KeyboardInfo(userInfo: userInfo)
        guard info.isLocal, let view = owningView, !view.isEffectivelyDisappearing else { return }

        UIView.performWithoutAnimation(view.layoutIfNeeded)

        keyboardBottomConstraint?.constant = info.overlap(in: view)

        info.animate {
            info.adjustForOverlap(in: avoidFirstResponderInScrollView, lastAppliedInset: &lastScrollViewInsetDelta)

            view.layoutIfNeeded()
        }

        NotificationCenter.default.post(name: KeyboardLayoutGuide.didUpdate, object: view, userInfo: userInfo)
    }

    // MARK: - Notifications

    @objc
    private func noteKeyboardShow(note: Notification) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateKeyboard), object: nil)
        updateKeyboard(forUserInfo: note.userInfo)
    }

    @objc
    private func noteKeyboardHide(note: Notification) {
        perform(#selector(updateKeyboard), with: nil, afterDelay: 0, inModes: [ .commonModes ])
    }

    @objc
    private func noteAncestorGuideUpdate(note: Notification) {
        guard let view = owningView, let ancestorView = note.object as? UIView,
            view !== ancestorView, view.isDescendant(of: ancestorView) else { return }

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateKeyboard), object: nil)
        updateKeyboard(forUserInfo: note.userInfo)
    }

    // Workaround for <rdar://problem/30978412> UIKit > Bug > UITextField contents animate in when layout performed during editing end
    @objc
    private func noteTextFieldDidEndEditing(_ note: Notification) {
        guard let view = owningView, let textField = note.object as? UITextField,
            view !== textField, textField.isDescendant(of: view), !view.isEffectivelyDisappearing else { return }

        UIView.performWithoutAnimation(textField.layoutIfNeeded)
    }

}

// MARK: - UIViewController

extension UIViewController {

    private static var keyboardLayoutGuideKey = false

    /// For unit testing purposes only.
    @nonobjc
    internal func makeKeyboardLayoutGuide(notificationCenter: NotificationCenter) -> KeyboardLayoutGuide {
        assert(isViewLoaded, "This layout guide should not be accessed before the view is loaded.")

        let guide = KeyboardLayoutGuide(notificationCenter: notificationCenter)
        view.addLayoutGuide(guide)

        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: guide.bottomAnchor)
        ])

        return guide
    }

    /// A keyboard layout guide is a rectangle in the layout system representing
    /// the area on screen not currently occupied by the keyboard; thus, it is a
    /// simplified model for performing layout by avoiding the keyboard.
    ///
    /// Normally, the guide is a rectangle matching the top and bottom
    /// guides of a receiving view controller and the leading and trailing
    /// margins of its view. When the keyboard is active.
    ///
    /// - seealso: KeyboardLayoutGuide
    @nonobjc
    public var keyboardLayoutGuide: KeyboardLayoutGuide {
        if let guide = objc_getAssociatedObject(self, &UIViewController.keyboardLayoutGuideKey) as? KeyboardLayoutGuide {
            return guide
        }

        let guide = makeKeyboardLayoutGuide(notificationCenter: .default)
        objc_setAssociatedObject(self, &UIViewController.keyboardLayoutGuideKey, guide, .OBJC_ASSOCIATION_ASSIGN)
        return guide
    }

}

// MARK: - Extensions

private extension UIView {

    func findNextViewController() -> UIViewController? {
        var next: UIResponder? = self
        while let current = next {
            if let vc = current as? UIViewController { return vc }
            next = current.next
        }
        return nil
    }

    func findEnclosingScrollView() -> UIScrollView? {
        var responder = next
        while let current = responder {
            if let scrollView = current as? UIScrollView { return scrollView }
            responder = current.next
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
    let endFrame: CGRect
    let isLocal: Bool

    init(userInfo: [AnyHashable: Any]?) {
        self.animationDuration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        self.animationCurve = UIViewAnimationOptions(rawValue: ((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt) ?? 7) << 16)
        self.endFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        self.isLocal = (userInfo?[UIKeyboardIsLocalUserInfoKey] as? Bool) ?? true
    }

    func animate(by animations: () -> Void) {
        // When performing a keyboard update around a screen rotation animation,
        // UIKit disables animations and sends a duration of 0.
        guard UIView.areAnimationsEnabled else {
            return animations()
        }

        withoutActuallyEscaping(animations) {
            UIView.animate(withDuration: animationDuration, delay: 0, options: [ animationCurve, .beginFromCurrentState ], animations: $0)
        }
    }

    // Modeled after -[UIPeripheralHost getVerticalOverlapForView:usingKeyboardInfo:]
    func overlap(in view: UIView) -> CGFloat {
        guard !view.isEffectivelyInPopover, !endFrame.isEmpty, let target = view.superview else { return 0 }
        let localMinY = target.convert(endFrame, from: UIScreen.main.coordinateSpace).minY
        return max(view.frame.maxY - localMinY, 0)
    }

    // Modeled after -[UIScrollView _adjustForAutomaticKeyboardInfo:animated:lastAdjustment:].
    func adjustForOverlap(in scrollView: UIScrollView?, lastAppliedInset: inout CGFloat) {
        guard let scrollView = scrollView, scrollView.findEnclosingScrollView() == nil else { return }

        let newOverlap = overlap(in: scrollView)

        let baseline = scrollView.contentInset.bottom - lastAppliedInset
        let newInset = max(baseline, newOverlap)
        lastAppliedInset = newInset - baseline

        scrollView.scrollIndicatorInsets.bottom += newInset - scrollView.contentInset.bottom
        scrollView.contentInset.bottom = newInset

        scrollView.scrollFirstResponderToVisible(animated: false)
    }

}
