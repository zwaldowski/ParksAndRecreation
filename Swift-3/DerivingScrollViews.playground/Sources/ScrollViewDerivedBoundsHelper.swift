//
//  ScrollViewDerivedBoundsHelper.swift
//  Deriving
//
//  Created by Zachary Waldowski on 11/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

protocol ScrollViewBoundsDeriving: class {

    func invalidateLayoutForVisibleBoundsChange()

    func asScrollView() -> UIScrollView

}

extension ScrollViewBoundsDeriving where Self: UIScrollView {

    func asScrollView() -> UIScrollView {
        return self
    }
}

final class ScrollViewDerivedBoundsHelper: NSObject {

    private static var kvoContext = false

    weak var owner: ScrollViewBoundsDeriving?
    private var containingScrollViews = [UIScrollView]()

    // MARK: -

    var isEnabled = false {
        didSet {
            guard isEnabled != oldValue else { return }
            validate()
        }
    }

    var hasContainingScrollView: Bool {
        return !containingScrollViews.isEmpty
    }

    var shouldSizeToFit: Bool {
        return isEnabled && hasContainingScrollView
    }
    
    func visibleBounds(forOriginalBounds orig: CGRect) -> CGRect {
        guard let view = owner?.asScrollView() else { return orig }
        if shouldSizeToFit {
            let intersection = view.window.map { view.convert(orig, to: nil).intersection($0.bounds) } ?? .null
            guard !intersection.isNull else { return orig }
            return view.convert(intersection, from: nil)
        } else if orig.isEmpty {
            return CGRect(origin: .zero, size: view.frame.size)
        } else {
            return orig
        }
    }
    
    // MARK: -

    private(set) var shouldClipBounds = false

    func whileClippingBounds<T>(execute: () throws -> T) rethrows -> T? {
        guard !shouldClipBounds else { return nil }
        shouldClipBounds = true
        defer { shouldClipBounds = false }
        return try execute()
    }

    // MARK: -

    func reset() {
        stopObserving(containingScrollViews[containingScrollViews.indices])
        containingScrollViews.removeAll()
    }

    func validate() {
        guard isEnabled, let owner = owner?.asScrollView(), owner.window != nil else {
            return reset()
        }

        var oldScrollViewIndex = containingScrollViews.startIndex
        var newScrollViews = ScrollViewParentsIterator(startingFrom: owner)

        while oldScrollViewIndex != containingScrollViews.endIndex, let newScrollView = newScrollViews.next() {
            let oldScrollView = containingScrollViews[oldScrollViewIndex]
            if oldScrollView !== newScrollView {
                break
            }
            containingScrollViews.formIndex(after: &oldScrollViewIndex)
        }

        var toStopObserving = ArraySlice<UIScrollView>()
        swap(&toStopObserving, &containingScrollViews[oldScrollViewIndex ..< containingScrollViews.endIndex])
        stopObserving(toStopObserving)

        startObserving(&newScrollViews)
    }

    // MARK: -

    private func stopObserving(_ scrollViews: ArraySlice<UIScrollView>) {
        for scrollView in scrollViews {
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &ScrollViewDerivedBoundsHelper.kvoContext)
        }
    }

    private func startObserving(_ scrollViews: inout ScrollViewParentsIterator) {
        while let scrollView = scrollViews.next() {
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &ScrollViewDerivedBoundsHelper.kvoContext)
            containingScrollViews.append(scrollView)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        assert(context == &ScrollViewDerivedBoundsHelper.kvoContext)
        owner?.invalidateLayoutForVisibleBoundsChange()
    }

}

private struct ScrollViewParentsIterator: IteratorProtocol {

    var superview: UIView?

    init(startingFrom startingView: UIScrollView) {
        self.superview = startingView.superview
    }

    mutating func next() -> UIScrollView? {
        while let next = superview {
            defer { self.superview = next.superview }
            if let nextScrollView = next as? UIScrollView {
                return nextScrollView
            }
        }
        return nil
    }
    
}
