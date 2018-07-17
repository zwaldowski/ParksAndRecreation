import Cocoa
import AVFoundation

extension NSColor {

    /// Creates an arbitrary color, without accounting for taste.
    public static func random() -> NSColor {
        let r = CGFloat.random(in: 0 ... 1)
        let g = CGFloat.random(in: 0 ... 1)
        let b = CGFloat.random(in: 0 ... 1)
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }

}

extension String {

    /// Draws a string in the current graphics context both horizontally and
    /// vertically centered within an area.
    @discardableResult
    public func drawCentered(in rect: CGRect, background backgroundColor: NSColor = .random(), foreground foregroundColor: NSColor = .white, font: NSFont, context: NSStringDrawingContext) -> Bool {
        backgroundColor.setFill()
        rect.fill()

        let attributed = NSAttributedString(string: self, attributes: [
            .backgroundColor: backgroundColor,
            .foregroundColor: foregroundColor,
            .font: font
        ])

        let options = NSString.DrawingOptions.usesLineFragmentOrigin
        let size = attributed.boundingRect(with: rect.size, options: options, context: context).size
        let textRect = CGRect(x: rect.minX + (rect.width - size.width) / 2, y: rect.minY + (rect.height - size.height) / 2, width: size.width, height: size.height)
        attributed.draw(with: textRect, options: options, context: context)

        return true
    }

}
