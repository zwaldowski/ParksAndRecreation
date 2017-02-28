//
//  AccessoryTabBarController.swift
//  WeAllFloat
//
//  Created by Zachary Waldowski on 2/23/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

/// A drop-in tab bar controller that can have a palette above the tab bar, like
/// the Now Playing control in Music.
///
/// Use of the palette properly updates `UIViewController.bottomLayoutGuide`,
/// including animations, so simply use it as normal.
final class AccessoryTabBarController: UITabBarController, UIGestureRecognizerDelegate {

    private var paletteContainer: UIVisualEffectView!
    private var palettePreferredHeight: NSLayoutConstraint!
    private var paletteHighlightGesture: UIGestureRecognizer!
    private var paletteHighlight: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let container = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.preservesSuperviewLayoutMargins = true
        view.insertSubview(container, belowSubview: tabBar)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            container.topAnchor.constraint(greaterThanOrEqualTo: topLayoutGuide.bottomAnchor),
            tabBar.topAnchor.constraint(equalTo: container.bottomAnchor), {
                let c = container.heightAnchor.constraint(equalToConstant: 0)
                c.priority = UILayoutPriorityFittingSizeLevel
                self.palettePreferredHeight = c
                return c
            }()
        ])
        self.paletteContainer = container

        let paletteHighlightGesture = UILongPressGestureRecognizer(target: self, action: #selector(onPress))
        paletteHighlightGesture.minimumPressDuration = 0.01
        paletteHighlightGesture.cancelsTouchesInView = false
        paletteHighlightGesture.delegate = self
        container.addGestureRecognizer(paletteHighlightGesture)
        self.paletteHighlightGesture = paletteHighlightGesture

        if let paletteViewController = paletteViewController,
            paletteViewController.viewIfLoaded?.superview !== paletteContainer.contentView {
            installView(of: paletteViewController)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paletteViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        paletteViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        paletteViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        paletteViewController?.endAppearanceTransition()
    }

    override func overrideTraitCollection(forChildViewController childViewController: UIViewController) -> UITraitCollection? {
        let overrideTraitCollection = super.overrideTraitCollection(forChildViewController: childViewController)
        guard childViewController === paletteViewController else { return overrideTraitCollection }
        var toCombine = [
            UITraitCollection(horizontalSizeClass: .compact),
            UITraitCollection(verticalSizeClass: .compact),
            UITraitCollection(userInterfaceIdiom: .phone)
        ]

        if let overrideTraitCollection = overrideTraitCollection {
            toCombine.append(overrideTraitCollection)
        }

        return UITraitCollection(traitsFrom: toCombine)
    }

    override func updateViewConstraints() {
        palettePreferredHeight.constant = paletteViewController?.view.systemLayoutSizeFitting(self.tabBar.frame.size, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel).height ?? 0

        super.updateViewConstraints()
    }

    // MARK: -

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard let paletteViewController = paletteViewController else { return }
        let size = self.size(forChildContentContainer: paletteViewController, withParentContainerSize: size)
        if size != paletteViewController.viewIfLoaded?.frame.size {
            paletteViewController.viewWillTransition(to: size, with: coordinator)
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        guard let paletteViewController = paletteViewController else { return }
        let traitCollection = overrideTraitCollection(forChildViewController: paletteViewController).map {
            UITraitCollection(traitsFrom: [ newCollection, $0 ])
        } ?? newCollection
        paletteViewController.willTransition(to: traitCollection, with: coordinator)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        guard container === paletteViewController else { return }
        palettePreferredHeight.constant = container.preferredContentSize.height
        setNeedsUpdateEdgeInsets(forChild: selectedViewController, animated: true)
    }

    override func systemLayoutFittingSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.systemLayoutFittingSizeDidChange(forChildContentContainer: container)

        guard container === paletteViewController else { return }
        setNeedsUpdateEdgeInsets(forChild: selectedViewController, animated: true)
    }

    // MARK: -

    /// The custom accessory view controller to display above the tab bar.
    private(set) var paletteViewController: UIViewController?

    /// Attach or detach the custom accessory.
    ///
    /// If `animated` is `true`, will also reflow the content of the selected
    /// view controller.
    func setPaletteViewController(_ newValue: UIViewController?, animated: Bool) {
        let completion: (Bool) -> Void

        let oldValue = paletteViewController
        paletteViewController = newValue

        switch (oldValue, newValue) {
        case (let oldValue, let newValue) where !isViewLoaded && oldValue !== newValue:
            // No use setting up views until viewDidLoad.
            if let oldValue = oldValue {
                startUninstalling(oldValue, animated: false)
            }

            if let newValue = newValue {
                startInstalling(newValue, animated: false)
            }

            return
        case (nil, let newValue?):
            // Get the palette laid out correctly, then animate in from
            // offscreen.
            startInstalling(newValue, animated: animated)

            UIView.performWithoutAnimation(view.layoutIfNeeded)

            paletteContainer.transform = animated ? CGAffineTransform(translationX: 0, y: paletteContainer.bounds.height) : .identity

            completion = { _ in
                self.finishInstalling(newValue)
            }
        case let (oldValue?, newValue?) where oldValue !== newValue:
            // Transition from a to b. Not really animated, but this is expected
            // to be rare; could throw in fade or something instead.
            startUninstalling(oldValue, animated: animated)
            startInstalling(newValue, animated: animated)

            completion = { _ in
                self.finishUninstalling(oldValue)
                self.finishInstalling(newValue)
            }
        case (let oldValue?, nil):
            // Collapse the palette to animate offscreen - don't slide so we
            // don't do a layout pass on the moribund view controller.
            startUninstalling(oldValue, animated: animated)

            let constraint = paletteContainer.contentView.heightAnchor.constraint(equalToConstant: 0)
            constraint.isActive = true

            completion = { _ in
                constraint.isActive = false
                self.finishUninstalling(oldValue)
            }
        default:
            // Hey, look, saved us an animation!
            return
        }

        // Address the layout guide. Animated below by `self.view.layoutIfNeeded()`.
        setNeedsUpdateEdgeInsets(forChild: selectedViewController, animated: false)

        // Rather than duration = 0 when not animated, spare extra layout.
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
                self.paletteContainer.transform = .identity
                self.view.layoutIfNeeded()
            }, completion: completion)
        } else {
            completion(true)
        }
    }

    private func startInstalling(_ newValue: UIViewController, animated: Bool) {
        if newValue.parent != nil {
            newValue.willMove(toParentViewController: self)
            newValue.removeFromParentViewController()
        }
        newValue.setValue(self, forKeyPath: "parentViewController")
        defer { newValue.didMove(toParentViewController: self) }

        guard isViewLoaded else { return }

        newValue.beginAppearanceTransition(true, animated: animated)

        UIView.performWithoutAnimation {
            self.installView(of: newValue)
        }
    }

    private func finishInstalling(_ newValue: UIViewController) {
        assert(isViewLoaded)

        newValue.endAppearanceTransition()
    }

    private func startUninstalling(_ oldValue: UIViewController, animated: Bool) {
        if viewIfLoaded?.window != nil {
            oldValue.beginAppearanceTransition(false, animated: animated)
        }

        oldValue.willMove(toParentViewController: nil)
    }

    private func finishUninstalling(_ oldValue: UIViewController) {
        assert(isViewLoaded)

        oldValue.view.removeFromSuperview()
        oldValue.endAppearanceTransition()

        palettePreferredHeight.constant = 0
        updateHighlightingSupport(for: nil)
    }

    private func installView(of viewController: UIViewController) {
        assert(isViewLoaded)

        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.frame = paletteContainer.contentView.bounds
        paletteContainer.contentView.insertSubview(viewController.view, at: 0)

        if viewController.view.translatesAutoresizingMaskIntoConstraints {
            palettePreferredHeight.constant = viewController.preferredContentSize.height
        } else {
            NSLayoutConstraint.activate([
                viewController.view.leadingAnchor.constraint(equalTo: paletteContainer.contentView.leadingAnchor),
                paletteContainer.contentView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                viewController.view.topAnchor.constraint(equalTo: paletteContainer.contentView.topAnchor),
                paletteContainer.contentView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])

            // This serves a dual purpose: give the palette container a more
            // accurate ambuiguty-breaker, and activating the monitor for
            // systemLayoutFittingSizeDidChange(forChildContentContainer:).
            palettePreferredHeight.constant = viewController.view.systemLayoutSizeFitting(self.tabBar.frame.size, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel).height
        }

        updateHighlightingSupport(for: viewController.view)
    }

    // MARK: - Content insets

    private func setNeedsUpdateEdgeInsets(forChild child: UIViewController?, animated: Bool) {
        guard let child = {
            moreNavigationController.viewIfLoaded?.superview != nil ? moreNavigationController : nil
        }() ?? child else { return }

        child.view.setNeedsLayout()
        
        if animated, UIView.areAnimationsEnabled {
            view.layoutIfNeeded()
        }
    }

    // iOS 9 and iOS 10
    @objc(_edgeInsetsForChildViewController:insetsAreAbsolute:)
    @available(iOS, introduced: 9.0, deprecated: 11.0, message: "Did we get a public version of this API yet? Pretty please?")
    private func edgeInsets(forChild child: UIViewController, insetsAreAbsolute: UnsafeMutablePointer<ObjCBool>) -> UIEdgeInsets {
        defer { insetsAreAbsolute.pointee = false }
        guard child !== paletteViewController else { return .zero }
        var insets = UIEdgeInsets.zero

        if !tabBar.isHidden, child.edgesForExtendedLayout.contains(.bottom), tabBar.isTranslucent || child.extendedLayoutIncludesOpaqueBars {
            insets.bottom += tabBar.bounds.height
        }

        if let paletteContainer = paletteContainer, child.edgesForExtendedLayout.contains(.bottom) {
            insets.bottom += paletteContainer.bounds.height
        }

        return insets
    }

    // MARK: - Highlight support

    private final class PaletteHighlightView: UIView {

        private func commonInit() {
            layer.setValue(false, forKey: "allowsGroupBlending")

            for (compositingColor, compositingFilter) in [
                (#colorLiteral(red: 0.6642268896, green: 0.6642268896, blue: 0.6642268896, alpha: 1), "colorBurnBlendMode"),
                (#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.04), "plusD"),
            ] {
                let sublayer = CALayer()
                sublayer.backgroundColor = compositingColor.cgColor
                sublayer.compositingFilter = compositingFilter
                layer.addSublayer(sublayer)
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }

        override func layoutSublayers(of layer: CALayer) {
            guard layer === self.layer else { return }
            for sublayer in layer.sublayers ?? [] {
                sublayer.frame = layer.bounds
            }
        }

    }

    private var isHighlighted = false {
        didSet {
            if isHighlighted, paletteHighlight == nil {
                let paletteHighlight = PaletteHighlightView()
                paletteHighlight.translatesAutoresizingMaskIntoConstraints = false
                paletteContainer.insertSubview(paletteHighlight, at: 0)
                NSLayoutConstraint.activate([
                    paletteHighlight.leadingAnchor.constraint(equalTo: paletteContainer.leadingAnchor),
                    paletteContainer.trailingAnchor.constraint(equalTo: paletteHighlight.trailingAnchor),
                    paletteHighlight.topAnchor.constraint(equalTo: paletteContainer.topAnchor),
                    paletteContainer.bottomAnchor.constraint(equalTo: paletteHighlight.bottomAnchor),
                ])
                self.paletteHighlight = paletteHighlight
            }
            paletteHighlight?.isHidden = !isHighlighted
        }
    }

    private func updateHighlightingSupport(for view: UIView?) {
        isHighlighted = false
        paletteHighlightGesture.isEnabled = view?.gestureRecognizers?.contains(where: { (gestureRecognizer) in
            (gestureRecognizer is UITapGestureRecognizer) || (gestureRecognizer is UILongPressGestureRecognizer)
        }) ?? false
    }

    @objc private func onPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            isHighlighted = true
        case _:
            isHighlighted = false
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === paletteHighlightGesture else { return false }
        return true
    }

}
