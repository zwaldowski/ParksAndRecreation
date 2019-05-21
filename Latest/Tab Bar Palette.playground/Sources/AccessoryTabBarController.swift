import UIKit

/// A drop-in tab bar controller that can have a palette above the tab bar, like
/// the Now Playing control in Music.
///
/// Use of the palette properly updates `UIViewController.bottomLayoutGuide`,
/// including animations, so simply use it as normal.
open class AccessoryTabBarController: UITabBarController, UIGestureRecognizerDelegate {

    private var paletteContainer: UIVisualEffectView!
    private var palettePreferredHeight: NSLayoutConstraint!
    private var paletteHighlightGesture: UIGestureRecognizer!
    private var paletteHighlight: HighlightingFilter!
    private var paletteHairlineHeight: NSLayoutConstraint!

    public convenience init(viewControllers: [UIViewController]) {
        self.init()
        self.viewControllers = viewControllers
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        let container = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        container.preservesSuperviewLayoutMargins = true
        view.insertSubview(container, belowSubview: tabBar)
        self.paletteContainer = container

        paletteHighlight = VibrantLighterHighlight(in: container.contentView)

        let hairline = UIView()
        hairline.translatesAutoresizingMaskIntoConstraints = false
        hairline.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        container.contentView.addSubview(hairline)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            container.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            tabBar.topAnchor.constraint(equalTo: container.bottomAnchor), {
                let c = container.heightAnchor.constraint(equalToConstant: 0)
                c.priority = .fittingSizeLevel
                self.palettePreferredHeight = c
                return c
            }(),
            hairline.leadingAnchor.constraint(equalTo: paletteContainer.leadingAnchor),
            paletteContainer.trailingAnchor.constraint(equalTo: hairline.trailingAnchor),
            hairline.topAnchor.constraint(equalTo: paletteContainer.topAnchor), {
                let c = hairline.heightAnchor.constraint(equalToConstant: effectiveHairline)
                self.paletteHairlineHeight = c
                return c
            }()
        ])

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

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paletteViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        paletteViewController?.endAppearanceTransition()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        paletteViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        paletteViewController?.endAppearanceTransition()
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        paletteHairlineHeight.constant = effectiveHairline
    }

    override open func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        let overrideTraitCollection = super.overrideTraitCollection(forChild: childViewController)
        guard childViewController === paletteViewController else { return overrideTraitCollection }

        var toCombine = [UITraitCollection]()
        if let overrideTraitCollection = overrideTraitCollection {
            toCombine.append(overrideTraitCollection)
        }
        toCombine.append(UITraitCollection(verticalSizeClass: .compact))

        return UITraitCollection(traitsFrom: toCombine)
    }

    private var lastPaletteHeight: CGFloat = 0

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Track our modifications to `additionalSafeAreaInsets` through
        // continuous diffing, to support a scenario where `UITabBarController`
        // itself migrates to using `additionalSafeAreaInsets`.
        let newPaletteHeight = paletteViewController != nil ? paletteContainer.frame.size.height : 0
        let paletteHeightDelta = newPaletteHeight - lastPaletteHeight
        for viewController in children {
            viewController.additionalSafeAreaInsets.bottom += paletteHeightDelta
        }
        self.lastPaletteHeight = newPaletteHeight
    }

    override open func updateViewConstraints() {
        if paletteViewController == nil {
            palettePreferredHeight.constant = 0
        }

        super.updateViewConstraints()
    }

    // MARK: -

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard let paletteViewController = paletteViewController else { return }
        let size = self.size(forChildContentContainer: paletteViewController, withParentContainerSize: size)
        if size != paletteViewController.viewIfLoaded?.frame.size {
            paletteViewController.viewWillTransition(to: size, with: coordinator)
        }
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        guard let paletteViewController = paletteViewController else { return }
        let traitCollection = overrideTraitCollection(forChild: paletteViewController).map {
            UITraitCollection(traitsFrom: [ newCollection, $0 ])
        } ?? newCollection
        paletteViewController.willTransition(to: traitCollection, with: coordinator)
    }

    override open func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        guard container === paletteViewController else { return }
        palettePreferredHeight.constant = container.preferredContentSize.height
    }

    // MARK: -

    /// The custom accessory view controller to display above the tab bar.
    private(set) var paletteViewController: UIViewController?
    private var lastAnimator: UIViewImplicitlyAnimating?

    /// Attach or detach the custom accessory.
    ///
    /// If `animated` is `true`, will also reflow the content of the selected
    /// view controller.
    public func setPaletteViewController(_ newValue: UIViewController?, animated: Bool) {
        let oldValue = paletteViewController?.viewIfLoaded?.superview == nil ? nil : paletteViewController
        guard viewIfLoaded?.window != nil else {
            // No use setting up views until viewDidLoad...
            if let oldValue = oldValue, oldValue !== newValue {
                startUninstalling(oldValue, animated: false)
                finishUninstalling(oldValue)
            }

            paletteViewController = newValue

            if let newValue = newValue, oldValue !== newValue {
                startInstalling(newValue, animated: false)
            }

            return
        }

        lastAnimator?.stopAnimation(false)
        lastAnimator?.finishAnimation(at: .current)

        let animator = UIViewPropertyAnimator(duration: animated ? 0.35 : 0, dampingRatio: 1)
        animator.addAnimations(view.layoutIfNeeded)
        defer { animator.startAnimation() }
        lastAnimator = animator

        switch (oldValue, newValue) {
        case (nil, let newValue?):
            // Get the palette laid out correctly, then animate in from
            // offscreen.
            startInstalling(newValue, animated: animated)

            // Lay out the view, no additional insets.
            view.layoutIfNeeded()

            // Place the bar offscreen.
            paletteContainer.transform = CGAffineTransform(translationX: 0, y: paletteContainer.bounds.height)

            // Once set, the safe area can be updated.
            paletteViewController = newValue
            view.setNeedsLayout()

            // Animate safe area adjustment and pulling the bar onscreen.
            animator.addAnimations {
                self.paletteContainer.transform = .identity
            }
        case let (oldValue?, newValue?) where oldValue !== newValue:
            // Transition from a to b. Not really animated, but this is expected
            // to be rare; could throw in fade or something instead.
            startUninstalling(oldValue, animated: animated)
            finishUninstalling(oldValue)
            startInstalling(newValue, animated: animated)
            paletteViewController = newValue
        case (let oldValue?, nil):
            // Collapse the palette to animate offscreen - don't slide so we
            // don't do a layout pass on the moribund view controller.
            startUninstalling(oldValue, animated: animated)

            // Lay out the view with no animation.
            view.layoutIfNeeded()

            // Once this is changed, the safe area can be reset.
            paletteViewController = nil
            view.setNeedsLayout()

            // Animate the bar offscreen.
            animator.addAnimations {
                self.paletteContainer.transform = CGAffineTransform(translationX: 0, y: self.paletteContainer.frame.height)
            }

            animator.addCompletion { _ in
                self.paletteContainer.transform = .identity
                self.finishUninstalling(oldValue)
            }
        default:
            break
        }
    }

    private func startInstalling(_ newValue: UIViewController, animated: Bool) {
        newValue.willMove(toParent: self)
        newValue.removeFromParent()
        newValue.edgesForExtendedLayout.remove(.bottom)
        newValue.setValue(self, forKeyPath: "parentViewController")
        defer { newValue.didMove(toParent: self) }

        guard isViewLoaded else { return }

        newValue.beginAppearanceTransition(true, animated: animated)
        defer { newValue.endAppearanceTransition() }

        UIView.performWithoutAnimation {
            self.installView(of: newValue)
        }
    }

    private func startUninstalling(_ oldValue: UIViewController, animated: Bool) {
        oldValue.willMove(toParent: nil)

        if viewIfLoaded?.window != nil {
            oldValue.beginAppearanceTransition(false, animated: animated)
        }
    }

    private func finishUninstalling(_ oldValue: UIViewController) {
        let isLive = viewIfLoaded?.window != nil

        oldValue.viewIfLoaded?.removeFromSuperview()

        oldValue.removeFromParent()

        if isLive {
            oldValue.endAppearanceTransition()
        }

        oldValue.removeFromParent()

        view.setNeedsUpdateConstraints()

        updateHighlightingSupport()
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
                viewController.view.leadingAnchor.constraint(equalTo: paletteContainer.leadingAnchor),
                paletteContainer.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                viewController.view.topAnchor.constraint(equalTo: paletteContainer.topAnchor),
                paletteContainer.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])

            palettePreferredHeight.constant = 0
        }

        updateHighlightingSupport()
    }

    private var effectiveHairline: CGFloat {
        return 1 / max(traitCollection.displayScale, 1)
    }

    // MARK: - Highlight support

    private func updateHighlightingSupport() {
        guard isViewLoaded else { return }
        paletteHighlight.isActive = false
        paletteHighlightGesture.isEnabled = paletteViewController?.view.gestureRecognizers?.contains(where: { (gestureRecognizer) in
            gestureRecognizer is UITapGestureRecognizer || gestureRecognizer is UILongPressGestureRecognizer
        }) == true || paletteViewController?.view.subviews.contains(where: { (subview) in
            subview is UIButton
        }) == true
    }

    @objc
    private func onPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            paletteHighlight.isActive = true
        case _:
            paletteHighlight.isActive = false
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === paletteHighlightGesture else { return false }
        return true
    }

}
