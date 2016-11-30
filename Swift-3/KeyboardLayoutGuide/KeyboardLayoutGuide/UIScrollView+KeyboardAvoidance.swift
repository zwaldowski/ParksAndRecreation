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
        guard !isFirstResponder else {
            return self
        }

        return subviews.lazy.flatMap { $0.findFirstResponder() }.first
    }

    @nonobjc func containsFirstResponder() -> Bool {
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

    fileprivate struct Constants {
        static let minimumVisiblePadding: CGFloat = 8
    }

    func scrollFirstResponderToVisible(_ animated: Bool) {
        guard let firstResponder = findFirstResponder() else { return }

        let rect = convert(firstResponder.bounds, from: firstResponder).insetBy(dx: 0, dy: -Constants.minimumVisiblePadding)
        scrollRectToVisible(rect, animated: animated)
    }

}

extension UITableView {

    override func scrollFirstResponderToVisible(_ animated: Bool) {
        for cell in visibleCells where cell.containsFirstResponder() {
            guard let indexPath = indexPath(for: cell) else { continue }
            scrollToRow(at: indexPath, at: .none, animated: animated)
            return
        }

        super.scrollFirstResponderToVisible(animated)
    }

}

extension UICollectionView {

    override func scrollFirstResponderToVisible(_ animated: Bool) {
        for cell in visibleCells where cell.containsFirstResponder() {
            guard let indexPath = indexPath(for: cell) else { continue }
            scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: animated)
            return
        }

        super.scrollFirstResponderToVisible(animated)
    }
    
}
