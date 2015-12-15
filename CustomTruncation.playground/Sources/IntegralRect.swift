//
//  IntegralRect.swift
//
//  Created by Zachary Waldowski on 6/26/15.
//  Copyright (c) 2015 Zachary Waldowski. Some rights reserved. Licensed under MIT.
//

import UIKit

private func roundUp(value: CGFloat) -> CGFloat {
    return floor(value + 0.5)
}

private extension CGFloat {

    func adjustToScale(scale: CGFloat, @noescape adjustment: CGFloat -> CGFloat) -> CGFloat {
        guard scale > 1 else {
            return adjustment(self)
        }
        return adjustment(self * scale) / scale
    }

}

extension CGRect {

    func integralizeOutward(scale: CGFloat = UIScreen.mainScreen().scale) -> CGRect {
        var integralRect = CGRect.zero
        integralRect.origin.x    = minX.adjustToScale(scale, adjustment: roundUp)
        integralRect.size.width  = max(width.adjustToScale(scale, adjustment: ceil), 0)
        integralRect.origin.y    = minY.adjustToScale(scale, adjustment: roundUp)
        integralRect.size.height = max(height.adjustToScale(scale, adjustment: ceil), 0)
        return integralRect
    }
    
}
