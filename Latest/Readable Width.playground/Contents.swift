import UIKit

extension UIFont {

    static var readableWidth: CGFloat {
        return preferredFont(forTextStyle: .body).readableWidth
    }

    var readableWidth: CGFloat {
        let text = String(repeating: "M", count: 46)
        let attributedText = NSAttributedString(string: text, attributes: [
            .font: self
        ])
        let width = attributedText.size().width
        return ceil(width / 8) * 8
    }

}

UIFont.readableWidth
