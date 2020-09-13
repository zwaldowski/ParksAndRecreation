//  Copyright © 2018 Apple Inc. All rights reserved.

import UIKit

extension UIView {
    public func addSubviewConstrainingToBounds(_ subview: UIView, bottomSpacing: CGFloat = 0.0) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            topAnchor.constraint(equalTo: subview.topAnchor),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: bottomSpacing)
        ])
    }

    public func addSubviewConstrainingToCenter(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: subview.centerXAnchor),
            centerYAnchor.constraint(equalTo: subview.centerYAnchor)
        ])
    }

    public func addSubviewConstrainingToMargins(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            layoutMarginsGuide.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            layoutMarginsGuide.topAnchor.constraint(equalTo: subview.topAnchor),
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: subview.bottomAnchor)
            ])
    }

}
