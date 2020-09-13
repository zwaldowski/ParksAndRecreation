//
//  UpdatesNavigationBar.swift
//  BatteryDude
//
//  Created by Zachary Waldowski on 8/27/20.
//

import SwiftUI

private struct UpdatesNavigationBarOverlay: UIViewRepresentable {

    let hidesBackground: Bool
    let hidesTitle: Bool

    class Implementation: UIView {

        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear)
        var hidesBackground = false
        var hidesTitle = false
        var navigationItem: UINavigationItem?
        var titleView: InlineNavigationTitleView?

        override func didMoveToWindow() {
            super.didMoveToWindow()

            guard window != nil,
                  let navigationController = findNextResponder(of: UINavigationController.self),
                  let viewController = navigationController.viewControllers.first(where: { $0.isViewLoaded && isDescendant(of: $0.view) }) else { return }

            navigationItem = viewController.navigationItem
            titleView = InlineNavigationTitleView(navigationItem: viewController.navigationItem)
            update()
        }

        func update(animated: Bool = false) {
            func changes() {
                let appearance = UINavigationBarAppearance()
                if hidesBackground {
                    appearance.configureWithTransparentBackground()
                } else {
                    appearance.configureWithDefaultBackground()
                }
                navigationItem?.standardAppearance = appearance
                titleView?.label.accessibilityElementsHidden = hidesTitle
                titleView?.label.alpha = hidesTitle ? 0 : 1
            }

            guard animated else {
                changes()
                return
            }

            animator.addAnimations(changes)

            if let navigationBar = findNextResponder(of: UINavigationController.self)?.navigationBar {
                animator.addAnimations(navigationBar.layoutIfNeeded)
            }

            animator.startAnimation()
        }

    }

    func makeUIView(context: Context) -> Implementation {
        let view = Implementation()
        view.hidesBackground = hidesBackground
        view.hidesTitle = hidesTitle
        return view
    }

    func updateUIView(_ view: Implementation, context: Context) {
        view.hidesBackground = hidesBackground
        view.hidesTitle = hidesTitle
        view.update(animated: !context.transaction.disablesAnimations)
    }

}

extension View {

    func updatesNavigationBar(backgroundHidden hidesBackground: Bool, titleHidden hidesTitle: Bool) -> some View {
        overlay(
            UpdatesNavigationBarOverlay(hidesBackground: hidesBackground, hidesTitle: hidesTitle)
                .frame(width: 0, height: 0))
    }

}
