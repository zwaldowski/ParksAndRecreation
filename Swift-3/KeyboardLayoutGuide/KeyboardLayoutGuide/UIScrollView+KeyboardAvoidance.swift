//
//  UIScrollView+KeyboardAvoidance.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 5/3/16.
//  Copyright © 2015-2016. Licensed under MIT. Some rights reserved.
//

import UIKit

private extension UIView {

    @nonobjc @available(*, deprecated)
    func findFirstResponder() -> UIView? {
        guard !isFirstResponder else {
            return self
        }

        return subviews.lazy.flatMap { $0.findFirstResponder() }.first
    }

    @nonobjc
    func containsFirstResponder() -> Bool {
        guard !isFirstResponder else {
            return true
        }

        for view in subviews where view.containsFirstResponder() {
            return true
        }

        return false
    }

}

extension UIScrollView {

    @objc(bnr_scrollFirstResponderToVisible:)
    func scrollFirstResponderToVisible(animated: Bool) {}

}

extension UITableView {

    override func scrollFirstResponderToVisible(animated: Bool) {
        for cell in visibleCells where cell.containsFirstResponder() {
            guard let indexPath = indexPath(for: cell) else { continue }
            scrollToRow(at: indexPath, at: .none, animated: animated)
            return
        }

        super.scrollFirstResponderToVisible(animated: animated)
    }

}

extension UICollectionView {

    override func scrollFirstResponderToVisible(animated: Bool) {
        for cell in visibleCells where cell.containsFirstResponder() {
            guard let indexPath = indexPath(for: cell) else { continue }
            scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: animated)
            return
        }

        super.scrollFirstResponderToVisible(animated: animated)
    }
    
}
