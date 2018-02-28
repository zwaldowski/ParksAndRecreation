//
//  KeyboardLayoutGuide.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 8/23/15.
//  Copyright © 2015-2016. Licensed under MIT. Some rights reserved.
//

import UIKit

/// A keyboard layout guide may be used as an item in Auto Layout or for its
/// layout anchors.
public final class KeyboardLayoutGuide: UILayoutGuide {

    private static let didUpdate = Notification.Name(rawValue: "KeyboardLayoutGuideDidUpdateNotification")

    // MARK: Lifecycle

    private let notificationCenter: NotificationCenter

    private func commonInit() {
        notificationCenter.addObserver(self, selector: #selector(noteUpdateKeyboard), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteUpdateKeyboard), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteUpdateKeyboard), name: .UIKeyboardDidChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteAncestorGuideUpdate), name: KeyboardLayoutGuide.didUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(noteTextFieldDidEndEditing), name: .UITextFieldTextDidEndEditing, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.notificationCenter = .default
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        super.init()
        commonInit()
    }

    override convenience init() {
        self.init(notificationCenter: .default)
    }

    // MARK: Public API

    /// If assigned, the `contentInsets` of the view will be adjusted to match
    /// the keyboard insets.
    ///
    /// It is not necessary to track the scroll view that is managed as the
    /// primary view of a `UITableViewController` or
    /// `UICollectionViewController`.
    public weak var adjustContentInsetsInScrollView: UIScrollView?

    // MARK: Actions

    private var keyboardBottomConstraint: NSLayoutConstraint?
    private var lastScrollViewInsetDelta: CGFloat = 0
    private var currentAnimator: UIViewPropertyAnimator?

    override public var owningView: UIView? {
        didSet {
            guard owningView !== oldValue else { return }
            keyboardBottomConstraint?.isActive = false
            keyboardBottomConstraint = nil

            guard let view = owningView else { return }
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
                topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor), {
                    let constraint = view.bottomAnchor.constraint(equalTo: bottomAnchor)
                    constraint.priority = UILayoutPriority(rawValue: 999.5)
                    self.keyboardBottomConstraint = constraint
                    return constraint
                }()
            ])
        }
    }

    private func update(for info: KeyboardInfo, in view: UIView, animatingWith animator: UIViewPropertyAnimator?) {
        keyboardBottomConstraint?.constant = info.overlap(in: view)

        if let animator = animator, !view.isEffectivelyDisappearing {
            animator.addAnimations {
                info.adjustForOverlap(in: self.adjustContentInsetsInScrollView, lastAppliedInset: &self.lastScrollViewInsetDelta)
                view.layoutIfNeeded()
            }
        } else {
            info.adjustForOverlap(in: adjustContentInsetsInScrollView, lastAppliedInset: &lastScrollViewInsetDelta)
        }
    }

    // MARK: - Notifications

    @objc
    private func noteUpdateKeyboard(_ note: Notification) {
        let info = KeyboardInfo(userInfo: note.userInfo)
        guard let view = owningView else { return }

        let animator = currentAnimator ?? {
            UIView.performWithoutAnimation(view.layoutIfNeeded)

            let animator = info.makeAnimator()
            animator.addCompletion { [weak self] _ in
                self?.currentAnimator = nil
            }
            self.currentAnimator = animator
            return animator
        }()

        update(for: info, in: view, animatingWith: animator)

        NotificationCenter.default.post(name: KeyboardLayoutGuide.didUpdate, object: self, userInfo: note.userInfo)

        animator.startAnimation()
    }

    @objc
    private func noteAncestorGuideUpdate(note: Notification) {
        guard let view = owningView, let ancestor = note.object as? KeyboardLayoutGuide, let ancestorView = ancestor.owningView,
            view !== ancestorView, view.isDescendant(of: ancestorView) else { return }

        let info = KeyboardInfo(userInfo: note.userInfo)
        update(for: info, in: view, animatingWith: ancestor.currentAnimator)
    }

    // <rdar://problem/30978412> UITextField contents animate in when layout performed during editing end
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
        return guide
    }

    /// A keyboard layout guide is a rectangle in the layout system representing
    /// the area on screen not currently occupied by the keyboard; thus, it is a
    /// simplified model for performing layout by avoiding the keyboard.
    ///
    /// Normally, the guide is a rectangle matching the safe area of a view
    /// controller's view. When the keyboard is active, its bottom contracts to
    /// account for the keyboard. This change is animated alongside the keyboard
    /// animation.
    ///
    /// - seealso: KeyboardLayoutGuide
    @nonobjc public var keyboardLayoutGuide: KeyboardLayoutGuide {
        if let guide = objc_getAssociatedObject(self, &UIViewController.keyboardLayoutGuideKey) as? KeyboardLayoutGuide {
            return guide
        }

        let guide = makeKeyboardLayoutGuide(notificationCenter: .default)
        objc_setAssociatedObject(self, &UIViewController.keyboardLayoutGuideKey, guide, .OBJC_ASSOCIATION_ASSIGN)
        return guide
    }

}

// MARK: -

private struct KeyboardInfo {

    let userInfo: [AnyHashable: Any]?

    func makeAnimator() -> UIViewPropertyAnimator {
        let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        return UIViewPropertyAnimator(duration: duration, timingParameters: UISpringTimingParameters())
    }

    func overlap(in view: UIView) -> CGFloat {
        guard let endFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            view.canBeObscuredByKeyboard else { return 0 }

        let intersection = view.convert(endFrame, from: UIScreen.main.coordinateSpace).intersection(view.bounds)
        guard !intersection.isNull, intersection.maxY == view.bounds.maxY else { return 0 }

        var height = intersection.height
        if let scrollView = view as? UIScrollView, scrollView.contentInsetAdjustmentBehavior != .never {
            height -= view.safeAreaInsets.bottom
        }
        return max(height, 0)
    }

    func adjustForOverlap(in scrollView: UIScrollView?, lastAppliedInset: inout CGFloat) {
        guard let scrollView = scrollView else { return }

        let newOverlap = overlap(in: scrollView)

        let delta = newOverlap - lastAppliedInset
        lastAppliedInset = newOverlap

        scrollView.scrollIndicatorInsets.bottom += delta
        scrollView.contentInset.bottom += delta
    }

}

