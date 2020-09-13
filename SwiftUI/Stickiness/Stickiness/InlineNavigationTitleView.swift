//  Copyright © 2020 Apple Inc. All rights reserved.

import UIKit
import Combine

/// Replicates the classic appearance of the single-line title view for `UINavigationItem`.
/// Pairs well with `NavigationLargeTitleCollapseInteraction`.
public final class InlineNavigationTitleView: UIView {

    public let label = UILabel()
    private var navigationItemSubscription: AnyCancellable?

    public init(navigationItem: UINavigationItem) {
        super.init(frame: .zero)

        navigationItemSubscription = navigationItem
            .publisher(for: \.title)
            .assign(to: \.text, on: label)

        // Not Dynamic Type as of iOS 14.
        label.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))
            .addingSymbolicTraits([ .traitBold, .traitTightLeading ])
        label.setContentCompressionResistancePriority(.defaultHigh - 50, for: .horizontal)
        label.accessibilityTraits = .header
        addSubviewConstrainingToBounds(label)

        navigationItem.titleView = self
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

}
