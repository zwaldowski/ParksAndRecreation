import Cocoa

private final class WindowContentLayoutGuide: NSLayoutGuide {

    var owningViewWindowObservation: NSKeyValueObservation?
    var managedConstraints = [NSLayoutConstraint]()

    // MARK: -

    override init() {
        super.init()
        setDefaultIdentifier()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setDefaultIdentifier()
    }

    // MARK: -

    override weak var owningView: NSView? {
        didSet {
            guard owningView !== oldValue else { return }
            invalidateManagedConstraints()
            owningViewWindowObservation = owningView?.observe(\.window, options: [ .initial, .prior ]) { [unowned self] (view, change) in
                if change.isPrior {
                    self.invalidateManagedConstraints()
                } else {
                    self.updateManagedConstraints(for: view.window)
                }
            }
        }
    }

    // MARK: -

    func setDefaultIdentifier() {
        if identifier.rawValue.isEmpty {
            identifier = NSUserInterfaceItemIdentifier("ZWViewWindowContentLayoutGuide")
        }
    }

    func invalidateManagedConstraints() {
        NSLayoutConstraint.deactivate(managedConstraints)
        managedConstraints.removeAll()
    }

    func updateManagedConstraints(for window: NSWindow?) {
        guard managedConstraints.isEmpty, let view = owningView else { return }

        let content = window?.contentLayoutGuide as? NSLayoutGuide

        let top = topAnchor.constraint(equalTo: content?.topAnchor ?? view.topAnchor)
        let leading = leadingAnchor.constraint(equalTo: content?.leadingAnchor ?? view.leadingAnchor)
        let bottom = bottomAnchor.constraint(equalTo: content?.bottomAnchor ?? view.bottomAnchor)
        let trailing = trailingAnchor.constraint(equalTo: content?.trailingAnchor ?? view.trailingAnchor)

        managedConstraints = [ top, leading, bottom, trailing ]
        NSLayoutConstraint.activate(managedConstraints)
    }

}

private final class MarginsLayoutGuide: NSLayoutGuide {

    var owningViewSuperviewObservation: NSKeyValueObservation?
    var managedEdgeConstraints = [NSLayoutConstraint]()
    var managedSuperviewConstraints = [NSLayoutConstraint]()

    // MARK: -

    override init() {
        super.init()
        setDefaultIdentifier()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setDefaultIdentifier()
    }

    // MARK: -

    override weak var owningView: NSView? {
        didSet {
            guard owningView != oldValue else { return }
            invalidateManagedEdgeConstraints()
            invalidateManagedSuperviewConstraints()
            updateManagedEdgeConstraints()
            startObservingOwningViewSuperviewIfNeeded()
        }
    }

    enum LayoutMarginsMode {
        case `default`
        case languageDirectional(NSView.DirectionalEdgeInsets)
        case fixed(NSEdgeInsets)
    }

    var layoutMarginsMode = LayoutMarginsMode.default {
        didSet {
            switch (oldValue, layoutMarginsMode) {
                case (.default, .fixed),
                     (.fixed, .default),
                     (.languageDirectional, .fixed),
                     (.fixed, .languageDirectional):
                    invalidateManagedEdgeConstraints()
            default:
                break
            }

            guard updateManagedEdgeConstraints() else { return }

            let (constants, _) = currentConstraintConstants()
            managedEdgeConstraints[0].constant = constants.top
            managedEdgeConstraints[1].constant = constants.left
            managedEdgeConstraints[2].constant = constants.bottom
            managedEdgeConstraints[3].constant = constants.right
        }
    }

    func currentConstraintConstants() -> (NSEdgeInsets, isDirectional: Bool) {
        switch layoutMarginsMode {
        case .default:
            return (NSView.defaultLayoutMargins, isDirectional: false)
        case .languageDirectional(let directionalLayoutMargins):
            return (NSEdgeInsets(top: directionalLayoutMargins.top, left: directionalLayoutMargins.leading, bottom: directionalLayoutMargins.bottom, right: directionalLayoutMargins.trailing), isDirectional: true)
        case .fixed(let layoutMargins):
            return (layoutMargins, isDirectional: false)
        }
    }

    var effectiveLayoutMargins: NSEdgeInsets {
        guard let view = owningView else { return NSEdgeInsets() }

        let minY = frame.minY
        let maxY = view.frame.height - frame.maxY

        let top = view.isFlipped ? minY : maxY
        let left = frame.minX
        let bottom = view.isFlipped ? maxY : minY
        let right = view.frame.width - frame.maxX

        return NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    var effectiveDirectionalLayoutMargins: NSView.DirectionalEdgeInsets {
        let layoutMargins = effectiveLayoutMargins
        switch owningView?.userInterfaceLayoutDirection ?? NSApp.userInterfaceLayoutDirection {
        case .leftToRight:
            return NSView.DirectionalEdgeInsets(top: layoutMargins.top, leading: layoutMargins.left, bottom: layoutMargins.bottom, trailing: layoutMargins.right)
        case .rightToLeft:
            return NSView.DirectionalEdgeInsets(top: layoutMargins.top, leading: layoutMargins.left, bottom: layoutMargins.bottom, trailing: layoutMargins.right)
        }
    }

    var insetsLayoutMarginsFromWindowContent = true {
        didSet {
            guard insetsLayoutMarginsFromWindowContent != oldValue else { return }
            invalidateManagedEdgeConstraints()
            updateManagedEdgeConstraints()
        }
    }

    var preservesSuperviewLayoutMargins = false {
        didSet {
            guard preservesSuperviewLayoutMargins != oldValue else { return }
            invalidateManagedSuperviewConstraints()
            startObservingOwningViewSuperviewIfNeeded()
        }
    }

    // MARK: -

    func setDefaultIdentifier() {
        if identifier.rawValue.isEmpty {
            identifier = NSUserInterfaceItemIdentifier("ZWViewLayoutMarginsGuide")
        }
    }

    func startObservingOwningViewSuperviewIfNeeded() {
        owningViewSuperviewObservation = preservesSuperviewLayoutMargins ? owningView?.observe(\.superview, options: [ .initial, .prior ]) { [unowned self] (view, change) in
            if change.isPrior {
                self.invalidateManagedSuperviewConstraints()
            } else {
                self.updateManagedSuperviewConstraints()
            }
        } : nil
    }

    func invalidateManagedEdgeConstraints() {
        NSLayoutConstraint.deactivate(managedEdgeConstraints)
        managedEdgeConstraints.removeAll()
    }

    @discardableResult
    func updateManagedEdgeConstraints() -> Bool {
        guard let owningView = owningView else { return false }
        guard managedEdgeConstraints.isEmpty else { return true }

        let (constants, isDirectional) = currentConstraintConstants()
        let contentGuide = insetsLayoutMarginsFromWindowContent ? owningView.windowContentLayoutGuide : nil

        let contentTop = contentGuide?.topAnchor ?? owningView.topAnchor
        let top = topAnchor.constraint(equalTo: contentTop, constant: constants.top)
        top.identifier = "View-top-layoutMarginsGuide"
        top.priority = NSLayoutConstraint.Priority(999.5)

        let theirLeft = isDirectional ? (contentGuide?.leadingAnchor ?? owningView.leadingAnchor) : (contentGuide?.leftAnchor ?? owningView.leftAnchor)
        let myLeft = isDirectional ? leadingAnchor : leftAnchor
        let left = myLeft.constraint(equalTo: theirLeft, constant: constants.left)
        left.identifier = isDirectional ? "View-leading-layoutMarginsGuide" :  "View-left-layoutMarginsGuide"
        left.priority = NSLayoutConstraint.Priority(999.5)

        let theirBottom = contentGuide?.bottomAnchor ?? owningView.bottomAnchor
        let bottom = theirBottom.constraint(equalTo: bottomAnchor, constant: constants.bottom)
        bottom.identifier = "View-bottom-layoutMarginsGuide"
        bottom.priority = NSLayoutConstraint.Priority(999.5)

        let theirRight = isDirectional ? (contentGuide?.trailingAnchor ?? owningView.trailingAnchor) : (contentGuide?.rightAnchor ?? owningView.rightAnchor)
        let myRight = isDirectional ? trailingAnchor : rightAnchor
        let right = theirRight.constraint(equalTo: myRight, constant: constants.right)
        right.identifier = isDirectional ? "View-trailing-layoutMarginsGuide" :  "View-right-layoutMarginsGuide"
        right.priority = NSLayoutConstraint.Priority(999.5)

        managedEdgeConstraints = [ top, left, bottom, right ]
        NSLayoutConstraint.activate(managedEdgeConstraints)
        return false
    }

    func invalidateManagedSuperviewConstraints() {
        NSLayoutConstraint.deactivate(managedEdgeConstraints)
        managedEdgeConstraints.removeAll()
    }

    func updateManagedSuperviewConstraints() {
        guard managedSuperviewConstraints.isEmpty, preservesSuperviewLayoutMargins, let view = owningView, let superview = view.superview else { return }

        let top = topAnchor.constraint(greaterThanOrEqualTo: superview.layoutMarginsGuide.topAnchor)
        top.identifier = "View-top-layoutMarginsGuide-superviewPreserving"

        let leading = leadingAnchor.constraint(greaterThanOrEqualTo: superview.layoutMarginsGuide.leadingAnchor)
        leading.identifier = "View-leading-layoutMarginsGuide-superviewPreserving"

        let bottom = superview.layoutMarginsGuide.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        bottom.identifier = "View-bottom-layoutMarginsGuide-superviewPreserving"

        let trailing = superview.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor)
        trailing.identifier = "View-trailing-layoutMarginsGuide-superviewPreserving"

        managedSuperviewConstraints = [ top, leading, bottom, trailing ]
        NSLayoutConstraint.activate(managedSuperviewConstraints)
    }

}

private final class ReadableContentLayoutGuide: NSLayoutGuide {

    var managedConstraints = [NSLayoutConstraint]()

    // MARK: -

    override init() {
        super.init()
        setDefaultIdentifier()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setDefaultIdentifier()
    }

    // MARK: -

    override weak var owningView: NSView? {
        didSet {
            guard owningView != oldValue else { return }
            invalidateManagedConstraints()
            updateManagedConstraints()
        }
    }

    // MARK: -

    func setDefaultIdentifier() {
        if identifier.rawValue.isEmpty {
            identifier = NSUserInterfaceItemIdentifier("ZWViewReadableContentGuide")
        }
    }

    func invalidateManagedConstraints() {
        NSLayoutConstraint.deactivate(managedConstraints)
        managedConstraints.removeAll()
    }

    func updateManagedConstraints() {
        guard managedConstraints.isEmpty, let view = owningView else { return }
        let layoutMargins = view.layoutMarginsGuide

        let top = topAnchor.constraint(equalTo: layoutMargins.topAnchor)
        top.identifier = "View-top-readableContentGuide"

        let leading = leadingAnchor.constraint(greaterThanOrEqualTo: layoutMargins.leadingAnchor)
        leading.identifier = "View-leadingMargin-readableContentGuide"

        let bottom = layoutMargins.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottom.identifier = "View-bottom-readableContentGuide"

        let centerX = centerXAnchor.constraint(equalTo: layoutMargins.centerXAnchor)
        centerX.identifier = "View-centerXMargin-readableContentGuide"

        let width = widthAnchor.constraint(equalToConstant: 780)
        width.identifier = "View-width-readableContentGuide"
        width.priority = NSLayoutConstraint.Priority(rawValue: 999.5)

        managedConstraints = [ top, leading, bottom, centerX, width ]
        NSLayoutConstraint.activate(managedConstraints)
    }

}

private extension NSView {

    static let defaultLayoutMargins = NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    static let defaultDirectionalLayoutMargins = DirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

    func existingLayoutGuide<LayoutGuide: NSLayoutGuide>(for type: LayoutGuide.Type) -> LayoutGuide? {
        let key = unsafeBitCast(type, to: UnsafeRawPointer.self)
        return objc_getAssociatedObject(self, key) as? LayoutGuide
    }

    func layoutGuide<LayoutGuide: NSLayoutGuide>(by constructor: () -> LayoutGuide) -> LayoutGuide {
        if let existing = existingLayoutGuide(for: LayoutGuide.self) {
            return existing
        }

        let guide = constructor()
        addLayoutGuide(guide)

        let key = unsafeBitCast(LayoutGuide.self, to: UnsafeRawPointer.self)
        objc_setAssociatedObject(self, key, guide, .OBJC_ASSOCIATION_ASSIGN)

        return guide
    }

}

// MARK: -

extension NSView {

    /// A layout guide representing the view's margins.
    ///
    /// Use this layout guide's anchors to create constraints with the view's margin.
    public final var layoutMarginsGuide: NSLayoutGuide {
        return layoutGuide(by: MarginsLayoutGuide.init)
    }

    /// The layout guide representing the portion of the view that is unobscured
    /// by bars and other content.
    ///
    /// Typically, the area represented by this layout guide is the same as the
    /// view. However, when the view is visible in a window with
    /// `NSWindow.StyleMask.fullSizeContentView` set, this layout guide reflects
    /// the portion of the view that is not covered by the toolbar.
    public final var windowContentLayoutGuide: NSLayoutGuide {
        return layoutGuide(by: WindowContentLayoutGuide.init)
    }

    /// Custom spacing to use when laying out content in the view.
    ///
    /// Use this property to specify the desired amount of space (measured in
    /// points) between the edges of this view and its subviews.
    ///
    /// The default layout margins are normally 16 points on the left and
    /// right sides, but the values may be greater if the view is not fully
    /// inside the window content rect or if `preservesSuperviewLayoutMargins`
    /// is `true`. You can change these values as needed for your interface.
    ///
    /// Auto Layout can use your margins to place content. For example, if you
    /// specify a set of constraints using the `layoutMarginsGuide`, the edges
    /// of a subview are inset from the edge of the superview by the
    /// corresponding margins.
    ///
    /// When possible, prefer using `directionalLayoutMargins` to specify layout
    /// margins instead. The leading and trailing edge insets are synchronized
    /// with the left and right insets in this property. For example, setting
    /// the leading directional edge inset to 20 points causes the left inset of
    /// this property to be set to 20 points on a system with a left-to-right
    /// language.
    public final var layoutMargins: NSEdgeInsets {
        get {
            let layoutMarginsGuide = existingLayoutGuide(for: MarginsLayoutGuide.self)
            return layoutMarginsGuide?.effectiveLayoutMargins ?? NSView.defaultLayoutMargins
        }
        set {
            let layoutMarginsGuide = layoutGuide(by: MarginsLayoutGuide.init)
            layoutMarginsGuide.layoutMarginsMode = .fixed(newValue)
        }
    }

    /// Edge insets that take language direction into account.
    public struct DirectionalEdgeInsets {
        /// The top edge inset value.
        public var top: CGFloat
        /// The leading edge inset value.
        public var leading: CGFloat
        /// The bottom edge inset value.
        public var bottom: CGFloat
        /// The trailing edge inset value.
        public var trailing: CGFloat

        /// Creates a directional edge insets type with the specified values.
        public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
        }
    }

    /// The default spacing to use when laying out content in the view, taking
    /// into account the current language direction.
    ///
    /// Use this property to specify the desired amount of space (measured in
    /// points) between the edges of this view and its subviews. The leading
    /// and trailing margins are applied appropriately to the left or right
    /// margins based on the current layout direction. For example, the leading
    /// margin is applied to the right edge of the view in right-to-left
    /// layouts.
    ///
    /// The default layout margins are normally 16 points on the leading and
    /// trailing sides, but the values may be greater if the view is not fully
    /// inside the window content rect or if `preservesSuperviewLayoutMargins`
    /// is `true`. You can change these values as needed for your interface.
    ///
    /// Auto Layout can use your margins to place content. For example, if you
    /// specify a set of constraints using the `layoutMarginsGuide`, the edges
    /// of a subview are inset from the edge of the superview by the
    /// corresponding margins.
    public final var directionalLayoutMargins: DirectionalEdgeInsets {
        get {
            let layoutMarginsGuide = existingLayoutGuide(for: MarginsLayoutGuide.self)
            return layoutMarginsGuide?.effectiveDirectionalLayoutMargins ?? NSView.defaultDirectionalLayoutMargins
        }
        set {
            let layoutMarginsGuide = layoutGuide(by: MarginsLayoutGuide.init)
            layoutMarginsGuide.layoutMarginsMode = .languageDirectional(newValue)
        }
    }

    /// Whether the view's layout margins are updated automatically to reflect
    /// the window content rect.
    ///
    /// Defaults to `true`. When `true`, margins that are outside the window
    /// content rect are automatically modified to fall within the boundary.
    /// Changing to `false` allows your margins to remain at their original
    /// locations, even when they are outside the window content rect.
    public final var insetsLayoutMarginsFromWindowContent: Bool {
        get {
            let layoutMarginsGuide = existingLayoutGuide(for: MarginsLayoutGuide.self)
            return layoutMarginsGuide?.insetsLayoutMarginsFromWindowContent ?? true
        }
        set {
            let layoutMarginsGuide = layoutGuide(by: MarginsLayoutGuide.init)
            layoutMarginsGuide.insetsLayoutMarginsFromWindowContent = newValue
        }
    }

    /// Indicates whether this view also respects the margins of its superview.
    ///
    /// Defaults to `false`. When `true`, the superview's margins are also
    /// considered when laying out content. This margin affects layouts where
    /// the distance between the edge of a view and its superview is smaller
    /// than the corresponding margin.
    ///
    /// For example, you might have a content view whose frame precisely matches
    /// the bounds of its superview. When any of the superview's margins is
    /// inside the area represented by the content view and its own margins,
    /// the content view's layout will be adjusted to respect the superview's
    /// margins. The amount of the adjustment is the smallest amount needed t
    /// ensure that content is also inside the superview's margins.
    public final var preservesSuperviewLayoutMargins: Bool {
        get {
            let layoutMarginsGuide = existingLayoutGuide(for: MarginsLayoutGuide.self)
            return layoutMarginsGuide?.preservesSuperviewLayoutMargins ?? false
        }
        set {
            let layoutMarginsGuide = layoutGuide(by: MarginsLayoutGuide.init)
            layoutMarginsGuide.preservesSuperviewLayoutMargins = newValue
        }
    }

    /// A layout guide representing an area with a readable width within the
    /// view.
    ///
    /// This layout guide defines an area that can easily be read without
    /// forcing users to move their head to track the lines. The readable
    /// content area follows the following rules:
    /// 1. The readable content guide never extends beyond the view's
    ///    layout margins.
    /// 2. The readable content guide is vertically equivalent to the view's
    ///    layout margins.
    /// 3. The readable content width is less than or equal to a readable width
    ///    defined for the system font size.
    ///
    /// Use the readable content guide to lay out a single column of text. If
    /// you are laying out multiple columns, you can use the guide's width to
    /// determine the optimal width for all of your columns.
    public final var readableContentGuide: NSLayoutGuide {
        return layoutGuide(by: ReadableContentLayoutGuide.init)
    }

}

extension NSView.DirectionalEdgeInsets: Equatable, Codable {

    /// Creates the edge insets type with default values.
    public init() {
        self.top = 0
        self.leading = 0
        self.bottom = 0
        self.trailing = 0
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let top = try container.decode(CGFloat.self)
        let leading = try container.decode(CGFloat.self)
        let bottom = try container.decode(CGFloat.self)
        let trailing = try container.decode(CGFloat.self)
        self.init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(top)
        try container.encode(leading)
        try container.encode(bottom)
        try container.encode(trailing)
    }

}
