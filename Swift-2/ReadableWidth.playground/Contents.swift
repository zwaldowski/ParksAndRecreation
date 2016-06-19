import UIKit
import XCPlayground

private extension UIFont {

    @nonobjc static var readableWidth: CGFloat {
        return preferredFontForTextStyle(UIFontTextStyleBody).readableWidth
    }

    @nonobjc static var screenReadableWidth: CGFloat {
        return preferredFontForTextStyle(UIFontTextStyleBody).screenReadableWidth
    }

    @nonobjc var readableWidth: CGFloat {
        let text = String(count: 46, repeatedValue: "M" as UnicodeScalar)
        let attrString = NSAttributedString(string: text, attributes: [
            NSFontAttributeName: self
        ])

        return attrString.size().width
    }

    @nonobjc var screenReadableWidth: CGFloat {
        return ceil(readableWidth / 8) * 8
    }

}

UIFont.screenReadableWidth
