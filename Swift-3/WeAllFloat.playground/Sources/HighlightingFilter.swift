//
//  HighlightingFilter.swift
//  WeAllFloat
//
//  Created by Zachary Waldowski on 4/5/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

/// A lazily-created effect that uses view composition to toggle dynamically.
protocol HighlightingFilter {

    var isActive: Bool { get set }

    var containerView: UIView { get }

    var highlightView: UIView? { get set }

    static func makeHighlightView() -> UIView

}

extension HighlightingFilter {

    var isActive: Bool {
        get {
            return !(highlightView?.isHidden ?? true)
        }
        set {
            if newValue, highlightView == nil {
                let highlightView = Self.makeHighlightView()
                highlightView.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(highlightView)
                NSLayoutConstraint.activate([
                    highlightView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                    containerView.rightAnchor.constraint(equalTo: highlightView.rightAnchor),
                    highlightView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    containerView.bottomAnchor.constraint(equalTo: highlightView.bottomAnchor)
                ])
                self.highlightView = highlightView
            }

            if let highlightView = highlightView {
                containerView.bringSubview(toFront: highlightView)
                highlightView.alpha = newValue ? 1 : 0
            }
        }
    }

}

/// Based off how a custom `UIAlertController` lightens its buttons.
struct VibrantLighterHighlight: HighlightingFilter {

    let containerView: UIView
    var highlightView: UIView?

    init(in containerView: UIView) {
        self.containerView = containerView
    }

    static func makeHighlightView() -> UIView {
        return BackgroundBlendingView(filters: (.colorBurn, #colorLiteral(red: 0.6642268896, green: 0.6642268896, blue: 0.6642268896, alpha: 1)), (.plusDarker, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.04)))
    }

}
