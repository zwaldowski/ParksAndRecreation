import UIKit

private extension UIResponder {

    func findNextResponder<Responder>(of type: Responder.Type) -> Responder? {
        var next = self.next
        while let current = next {
            if let result = current as? Responder { return result }
            next = current.next
        }
        return nil
    }

}

private class NavigationFloatingTitleView: UIView {

    unowned let navigationItem: UINavigationItem
    let titleLabel = UILabel()
    let targetViewBaseline = UILayoutGuide()

    init(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = navigationItem.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(700), for: .horizontal)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: UITraitCollection(traitsFrom: [
            traitCollection, UITraitCollection(preferredContentSizeCategory: .large)
        ])).addingSymbolicTraits([
            .traitBold, .traitTightLeading
        ])
        addSubview(titleLabel)

        targetViewBaseline.identifier = "\(type(of: self))-targetViewBaseline"

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        targetViewBaseline.owningView?.removeLayoutGuide(targetViewBaseline)
    }

    // MARK: -

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview != nil {
            configureView(animated: false)
        }
    }

    // MARK: -

    weak var targetView: UIView?
    weak var scrollView: UIScrollView?
    var scrollViewObservation: NSKeyValueObservation?

    func startObserving(_ targetView: UIView, in scrollView: UIScrollView) {
        targetView.addLayoutGuide(targetViewBaseline)
        NSLayoutConstraint.activate([
            targetViewBaseline.topAnchor.constraint(equalTo: targetView.topAnchor),
            targetViewBaseline.leadingAnchor.constraint(equalTo: targetView.leadingAnchor),
            targetView.lastBaselineAnchor.constraint(equalTo: targetViewBaseline.bottomAnchor),
            targetView.trailingAnchor.constraint(equalTo: targetViewBaseline.trailingAnchor)
        ])
        self.targetView = targetView

        scrollViewObservation = scrollView.observe(\.contentOffset, options: .initial) { [weak self] (scrollView, change) in
            guard let self = self, self.superview != nil else { return }
            self.configureView(animated: true)
        }
        self.scrollView = scrollView
    }

    let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)

    func configureView(animated: Bool) {
        let parentViewController = scrollView?.findNextResponder(of: UIViewController.self)
        let navigationBar = parentViewController?.navigationController?.navigationBar
        navigationBar?.barTintColor = parentViewController?.view.backgroundColor

        let shouldShowTitle: Bool
        if let targetView = targetView,
            let scrollView = scrollView {
            let visibleBounds = scrollView.bounds.inset(by: scrollView.adjustedContentInset)
            let targetRect = scrollView.convert(targetViewBaseline.layoutFrame, from: targetView)
            shouldShowTitle = !visibleBounds.contains(CGPoint(x: visibleBounds.minX, y: targetRect.maxY))
        } else {
            shouldShowTitle = false
        }

        if shouldShowTitle {
            titleLabel.text = navigationItem.title
        }

        func animations() {
            targetView?.alpha = shouldShowTitle ? 0 : 1
            titleLabel.alpha = shouldShowTitle ? 1 : 0
            navigationBar?.shadowImage = shouldShowTitle ? nil : UIImage()
        }

        func completion(_: UIViewAnimatingPosition) {
            guard titleLabel.alpha.isZero else { return }
            titleLabel.text = nil
        }

        guard animated else {
            animations()
            completion(.end)
            return
        }

        animator.addAnimations(animations)

        if animator.state == .inactive {
            animator.addCompletion(completion)
        }

        animator.startAnimation()
    }

}

extension UINavigationItem {

    public func setWantsScrollingTitle(tracking targetView: UIView, in scrollView: UIScrollView) {
        let floatingTitleView = titleView as? NavigationFloatingTitleView ?? NavigationFloatingTitleView(navigationItem: self)
        floatingTitleView.startObserving(targetView, in: scrollView)
        titleView = floatingTitleView
        largeTitleDisplayMode = .never
    }

}
