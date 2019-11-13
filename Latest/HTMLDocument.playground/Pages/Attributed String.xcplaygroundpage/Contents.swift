//: [Previous](@previous)

import Foundation

#if canImport(AppKit)
import AppKit

private extension NSFont {

    static var htmlDefault: NSFont {
        return .systemFont(ofSize: NSFont.systemFontSize)
    }

    func addingSymbolicTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
        let oldFontDescriptor = self.fontDescriptor
        let newSymbolicTraits = oldFontDescriptor.symbolicTraits.union(traits)
        let newFontDescriptor = oldFontDescriptor.withSymbolicTraits(newSymbolicTraits)
        return NSFont(descriptor: newFontDescriptor, size: 0) ?? self
    }

    var boldFont: NSFont {
        return addingSymbolicTraits(.bold)
    }

    var italicFont: NSFont {
        return addingSymbolicTraits(.italic)
    }

}

public typealias Font = NSFont
#elseif canImport(UIKit)
import UIKit

private extension UIFont {

    static var htmlDefault: UIFont {
        return .preferredFont(forTextStyle: .body)
    }

    func addingSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let oldFontDescriptor = self.fontDescriptor
        let newSymbolicTraits = oldFontDescriptor.symbolicTraits.union(traits)
        let newFontDescriptor = fontDescriptor.withSymbolicTraits(newSymbolicTraits) ?? fontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }

    var boldFont: UIFont {
        return addingSymbolicTraits(.traitBold)
    }

    var italicFont: UIFont {
        return addingSymbolicTraits(.traitItalic)
    }

}

public typealias Font = UIFont
#else
#error("Unsupported platform")
#endif


private extension NSMutableAttributedString {

    /// Removes text at the start and end matching `CharacterSet.whitespaceAndNewlines`.
    func trim() {
        beginEditing()
        defer { endEditing() }

        let characterSet = CharacterSet.whitespacesAndNewlines.inverted
        let rawText = string

        if let trailingStart = rawText.rangeOfCharacter(from: characterSet, options: .backwards)?.upperBound {
            let rangeToRemove = NSRange(trailingStart ..< rawText.endIndex, in: rawText)
            deleteCharacters(in: rangeToRemove)
        }

        if let leadingEnd = rawText.rangeOfCharacter(from: characterSet)?.lowerBound {
            let rangeToRemove = NSRange(rawText.startIndex ..< leadingEnd, in: rawText)
            deleteCharacters(in: rangeToRemove)
        }
    }

}

// MARK: -

extension HTMLDocument.Node {

    public struct AttributedStringOptions {
        public var font: Font?

        public init() {}
    }

    static let meaninglessWhitespace = try! NSRegularExpression(pattern: #"\s+"#)

    private func replacingMeaninglessWhitespace(_ string: String) -> String {
        return HTMLDocument.Node.meaninglessWhitespace.stringByReplacingMatches(in: string, range: NSRange(0 ..< string.utf16.count), withTemplate: " ")
    }

    private func appendContents(to attributedString: NSMutableAttributedString, options: AttributedStringOptions, inheriting attributes: [NSAttributedString.Key: Any]) {
        var attributes = attributes

        switch (kind, name) {
        case (.element, "br"):
            attributedString.append(NSAttributedString(string: "\n", attributes: attributes))
        case (.element, "b"), (.element, "strong"):
            guard let currentFont = attributes[.font] as? Font else { break }
            attributes[.font] = currentFont.boldFont
        case (.element, "i"), (.element, "em"):
            guard let currentFont = attributes[.font] as? Font else { break }
            attributes[.font] = currentFont.italicFont
        case (.element, "u"):
            // `rawValue` needed due to <https://bugs.swift.org/browse/SR-3177>
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        case (.element, "a"):
            guard let url = self["href"].flatMap(URL.init) else { break }
            // `rawValue` needed due to <https://bugs.swift.org/browse/SR-3177>
            attributes[.link] = url
            attributes[.underlineStyle] = NSUnderlineStyle().rawValue
        case (.element, "p"):
            attributedString.append(NSAttributedString(string: "\n", attributes: attributes))
        case (.element, "ul"):
            attributedString.append(NSAttributedString(string: "\n", attributes: attributes))

            let marker = "\u{2022}"
            for child in self where child.kind == .element && child.name == "li" {
                // Avoid showing a blank item for empty list items.
                let text = child.content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }
                let string = "\n\(marker) \(text)"
                attributedString.append(NSAttributedString(string: string, attributes: attributes))
            }

            return
        case (.element, "ol"):
            attributedString.append(NSAttributedString(string: "\n", attributes: attributes))

            var marker = self["start"].flatMap(Int.init) ?? 1
            for child in self where child.kind == .element && child.name == "li" {
                // Avoid showing a blank item for empty list items.
                let text = child.content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }
                let string = "\n\(marker). \(text)"
                attributedString.append(NSAttributedString(string: string, attributes: attributes))
                marker += 1
            }

            return
        case (.element, _), (.documentFragment, _), (.characterDataSection, _):
            // Nothing to customize for unrecognized elements. Recurse and
            // print out children.
            break
        case (.text, _):
            let string = replacingMeaninglessWhitespace(content)
            attributedString.append(NSAttributedString(string: string, attributes: attributes))
            return
        default:
            // Add OBJECT REPLACEMENT CHARACTER to signal to someone debugging
            // that a node was ignored.
            attributedString.append(NSAttributedString(string: "\u{fffc}", attributes: attributes))
            return
        }

        for child in self {
            child.appendContents(to: attributedString, options: options, inheriting: attributes)
        }
    }

    public func attributedString(options: AttributedStringOptions = AttributedStringOptions()) -> NSAttributedString {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = options.font ?? Font.htmlDefault

        let attributedString = NSMutableAttributedString()
        attributedString.beginEditing()

        self.appendContents(to: attributedString, options: options, inheriting: attributes)

        attributedString.trim()
        attributedString.endEditing()
        return attributedString.copy() as! NSAttributedString
    }

}

// MARK: -

HTMLDocument.parse(##"""
Super. Computer. <a href="http://www.apple.com/ipad-pro/" title="iPad Pro">Now in two sizes.</a>
"""##)?.attributedString()

HTMLDocument.parse(##"""
<b>Hello, <br /><br /><i><font face="Times New Roman">world</font></i>!</b><br />
"""##)?.attributedString()

HTMLDocument.parse(##"""
<p>Foo.</p><br><p>Bar.</p><br><p>Qux.</p>
"""##)?.attributedString()


HTMLDocument.parseFragment(##"""
&lt;p&gt;Paragraph in WYSIWYG editor: &lt;p&gt;1 &lt; 2&lt;/p&gt;&lt;/p&gt;
&lt;p&gt;Less than character: 4 &lt; 5, 5 &gt; 3&lt;/p&gt;
&lt;p&gt;Yo &lt;b&gt;Bold Text&lt;/b&gt;&lt;/p&gt;
&lt;p&gt;&lt;a href="#dashboard"&gt;Manual HTML Link&lt;/a&gt;&lt;/p&gt;
&lt;p&gt;&lt;a href="#dashboard"&gt;Link&lt;/a&gt;&lt;/p&gt;
&lt;ul&gt;
&lt;li&gt;List Item One&lt;/li&gt;
&lt;li&gt;Two&lt;/li&gt;
&lt;/ul&gt;
"""##)!.attributedString()

//: [Next](@next)
