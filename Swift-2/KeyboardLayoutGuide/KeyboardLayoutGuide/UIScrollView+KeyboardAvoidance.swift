//
//  UIScrollView+KeyboardAvoidance
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 5/3/16.
//  Copyright © 2015-2016. Licensed under MIT. Some rights reserved.
//

import UIKit

private extension UIView {

    @nonobjc func findFirstResponder() -> UIView? {
        guard !isFirstResponder() else {
            return self
        }

        return subviews.lazy.flatMap { $0.findFirstResponder() }.first
    }

    @nonobjc func containsFirstResponder() -> Bool {
        guard !isFirstResponder() else {
            return true
        }

        for view in subviews where view.containsFirstResponder() {
            return true
        }

        return false
    }

}

extension UIScrollView {

    private struct Constants {
        static let minimumVisiblePadding: CGFloat = 8
    }

    func scrollFirstResponderToVisible(animated animated: Bool) {
        guard let firstResponder = findFirstResponder() else { return }

        var rect = convertRect(firstResponder.bounds, fromView: firstResponder)
        rect.insetInPlace(dx: 0, dy: -Constants.minimumVisiblePadding)
        scrollRectToVisible(rect, animated: animated)
    }

}

extension UITableView {

    override func scrollFirstResponderToVisible(animated animated: Bool) {
        for cell in visibleCells where cell.containsFirstResponder() {
            guard let indexPath = indexPathForCell(cell) else { continue }
            scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: animated)
            return
        }

        super.scrollFirstResponderToVisible(animated: animated)
    }

}

extension UICollectionView {

    override func scrollFirstResponderToVisible(animated animated: Bool) {
        for cell in visibleCells() where cell.containsFirstResponder() {
            guard let indexPath = indexPathForCell(cell) else { continue }
            scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: animated)
            return
        }

        super.scrollFirstResponderToVisible(animated: animated)
    }
    
}
