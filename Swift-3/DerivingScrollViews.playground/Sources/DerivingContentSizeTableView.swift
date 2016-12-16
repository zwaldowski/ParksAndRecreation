//
//  DerivingContentSizeTableView.swift
//  Deriving
//
//  Created by Zachary Waldowski on 10/26/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

public final class DerivingContentSizeTableView: UITableView, ScrollViewBoundsDeriving {

    private let helper = ScrollViewDerivedBoundsHelper()

    private func commonInit() {
        helper.isEnabled = !isScrollEnabled
        helper.owner = self
    }

    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        helper.reset()
    }

    // MARK: - UIScrollView

    public override var contentSize: CGSize {
        didSet {
            if helper.isEnabled {
                invalidateIntrinsicContentSize()
            }
        }
    }

    public override var isScrollEnabled: Bool {
        didSet {
            helper.isEnabled = !isScrollEnabled
            invalidateIntrinsicContentSize()
        }
    }

    // MARK: - UIView

    public override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            helper.whileClippingBounds {
                super.frame = newValue
            }
        }
    }

    public override var bounds: CGRect {
        get {
            return helper.shouldClipBounds ? helper.visibleBounds(forOriginalBounds: super.bounds) : super.bounds
        }
        set {
            helper.whileClippingBounds {
                super.bounds = newValue
            }
        }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        helper.reset()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        helper.validate()

        if helper.isEnabled {
            invalidateIntrinsicContentSize()
        }
    }

    public override func layoutSubviews() {
        helper.validate()

        helper.whileClippingBounds {
            super.layoutSubviews()
        }

        if helper.shouldSizeToFit && bounds.size != contentSize {
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        guard helper.shouldSizeToFit else {
            return super.intrinsicContentSize
        }

        layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }

    // MARK: - ScrollViewBoundsDeriving

    func invalidateLayoutForVisibleBoundsChange() {
        // assigning bounds to get:
        //  - collection view layout invalidation
        //  - set the "scheduledUpdateVisibleCells" flag
        let oldBounds = super.bounds
        super.bounds = helper.visibleBounds(forOriginalBounds: oldBounds)
        super.bounds = oldBounds
    }

}
