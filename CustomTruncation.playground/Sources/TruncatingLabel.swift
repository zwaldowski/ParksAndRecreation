//
//  TruncatingLabel.swift
//
//  Created by Zachary Waldowski on 6/27/15.
//  Copyright (c) 2015 Zachary Waldowski. Some rights reserved. Licensed under MIT.
//

import UIKit

private extension NSMutableAttributedString {
    
    func mapAttributeInPlace<T: AnyObject>(name: String, ofType _: T.Type = T.self, options: NSAttributedStringEnumerationOptions = [], transform: T -> T?) {
        enumerateAttribute(name, inRange: string.utf16.range, options: options) { [unowned self] (obj, range, _) in
            if let newValue = transform(obj as! T) {
                self.addAttribute(name, value: newValue, range: range)
            } else {
                self.removeAttribute(name, range: range)
            }
        }
    }
    
    func deleteAllCharacters() {
        deleteCharactersInRange(string.utf16.range)
    }
    
}

private extension NSLayoutManager {
    
    func textContainer(glyphIndex index: Int) -> (NSTextContainer, effectiveRange: NSRange)? {
        var range = NSRange(location: NSNotFound, length: 0)
        if let textContainer = textContainerForGlyphAtIndex(index, effectiveRange: &range) {
            return (textContainer, range)
        } else {
            return nil
        }
    }
    
    func invalidateGlyphsForRange(range: Range<String.Index>, changeInLength delta: String.Index.Distance = 0) {
        let string = textStorage?.string ?? ""
        let utf16 = string.utf16
        let range16 = range.startIndex.samePositionIn(utf16)..<range.endIndex.samePositionIn(utf16)
        let range = NSRange(range16, within: utf16)
        invalidateGlyphsForCharacterRange(range, changeInLength: delta, actualCharacterRange: nil)
    }
    
    func truncationInfoForGlyphRange(glyphRange: NSRange) -> (NSRange, lineIndex: Int, glyphOffset: Int)? {
        var truncatedLineIndex = 0
        var truncatedLineGlyph = 0
        var truncatedGlyphs: NSRange?
        
        enumerateLineFragmentsForGlyphRange(glyphRange) { [unowned self] (_, _, _, range, stop) in
            let thisLineTruncated = self.truncatedGlyphRangeInLineFragmentForGlyphAtIndex(range.location)
            if thisLineTruncated.location != NSNotFound {
                truncatedGlyphs = thisLineTruncated
                truncatedLineGlyph = range.location
                stop.memory = true
            } else {
                ++truncatedLineIndex
            }
        }
        
        return truncatedGlyphs.map { ($0, truncatedLineIndex, truncatedLineGlyph) }
    }
    
}

private extension NSGlyphProperty {
    
    static var Regular: NSGlyphProperty {
        return NSGlyphProperty(rawValue: 0)!
    }
    
}

@IBDesignable
public class TruncatingLabel: UILabel, NSLayoutManagerDelegate {
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        updateTextStore()
    }

    // MARK: - Text Storage
    
    private lazy var textStorage = NSTextStorage()
    
    private lazy var textContainer: NSTextContainer = {
        let textContainer = NSTextContainer()
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.lineFragmentPadding = 0
        return textContainer
    }()
    
    private lazy var layoutManager: NSLayoutManager = {
        let layoutManager = NSLayoutManager()
        layoutManager.delegate = self
        layoutManager.addTextContainer(self.textContainer)
        self.textStorage.addLayoutManager(layoutManager)
        return layoutManager
    }()
    
    private lazy var truncationDrawingContext = NSStringDrawingContext()
    
    // MARK: - Properties
    
    private var truncationTextStorage: String?
    
    /** Text to display when truncated, displayed at the trailing end of multi-line
    * text. The default is "more". The @c truncationText is displayed in the
    * @c tintColor of this view.
    **/
    public var truncationText: String! {
        get {
            return truncationTextStorage ?? NSLocalizedString("more", comment: "Default text to display after truncated text")
        }
        set {
            truncationTextStorage = newValue
            invalidateCustomTruncation()
            setNeedsDisplay()
        }
    }
    
    // MARK: - UILabel
    
    public override var numberOfLines: Int {
        willSet {
            textContainer.maximumNumberOfLines = newValue
        }
    }
    
    public override var lineBreakMode: NSLineBreakMode {
        willSet {
            textContainer.lineBreakMode = newValue
        }
    }
    
    public override var text: String? {
        didSet {
            updateTextStore()
        }
    }
    
    public override var attributedText: NSAttributedString? {
        didSet {
            updateTextStore()
        }
    }
    
    public override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        invalidateCustomTruncation()
        textContainer.maximumNumberOfLines = numberOfLines

        switch (bounds.width, bounds.height) {
        case (CGFloat(FLT_MAX), CGFloat(FLT_MAX)):
            textContainer.size = CGRect.infinite.size
        case (let width, CGFloat(FLT_MAX)):
            textContainer.size = CGSize(width: width, height: CGFloat.max)
        case (CGFloat(FLT_MAX), let height):
            textContainer.size = CGSize(width: CGFloat.max, height: height)
        case let (width, height):
            textContainer.size = CGSize(width: width, height: height)
        }
        forceLayout()
        
        let textBounds = layoutManager.usedRectForTextContainer(textContainer)
        let scale = window?.screen.scale ?? 1

        return textBounds.integralizeOutward(scale)
    }
    
    public override func drawTextInRect(rect: CGRect) {
        // force layout, bail for empty layouts
        guard case let (self.textContainer, glyphRange)? = layoutManager.textContainer(glyphIndex: 0) where glyphRange.length != 0 else {
            return
        }
        
        defer {
            layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: rect.origin)
            layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: rect.origin)
        }
        
        guard !truncationText.isEmpty else { return }
        
        let tokenDrawingOpts = [.UsesLineFragmentOrigin, .UsesFontLeading] as NSStringDrawingOptions
        let nsTruncationText = truncationText as NSString
        
        defer {
            switch truncationTextCache {
            case .None, .NeedsUpdate:
                break
            case .Cached(var truncationFrame, let attributes):
                truncationFrame.origin.x += rect.minX
                truncationFrame.origin.y += rect.minY
                nsTruncationText.drawWithRect(truncationFrame, options: tokenDrawingOpts, attributes: attributes, context: truncationTextContext)
            }
        }
        
        guard case .NeedsUpdate = truncationTextCache else {
            return
        }
        
        guard let (truncatedGlyphs, truncatedLineIndex, truncatedLineGlyph) = layoutManager.truncationInfoForGlyphRange(glyphRange), truncatedCharsUTF16 = layoutManager.characterRangeForGlyphRange(truncatedGlyphs, actualGlyphRange: nil).toRange() where truncatedLineIndex > 0 else {
            truncationTextCache = .None
            return
        }
        
        let string = textStorage.string
        let minIndex = string.startIndex
        var moreAttributes = textStorage.attributesAtIndex(truncatedCharsUTF16.startIndex, effectiveRange: nil) 
        var moreBounding = nsTruncationText.boundingRectWithSize(CGSize.zero, options: tokenDrawingOpts, attributes: moreAttributes, context: truncationTextContext)
        
        var newTruncation = string.utf16.startIndex.advancedBy(truncatedCharsUTF16.startIndex).samePositionIn(string) ?? minIndex
        var truncatedLineRect: CGRect
        repeat {
            guard newTruncation != minIndex else {
                customTruncationStart = nil
                truncationTextCache = .None
                return
            }
            
            customTruncationStart = --newTruncation
            layoutManager.invalidateGlyphsForRange(newTruncation..<string.endIndex)
            
            truncatedLineRect = layoutManager.lineFragmentUsedRectForGlyphAtIndex(truncatedLineGlyph, effectiveRange: nil)
        } while rect.width - truncatedLineRect.width < moreBounding.width
        
        if truncatedLineRect.minX > rect.minX { // RTL
            moreBounding.origin.x = rect.minX
        } else {
            moreBounding.origin.x = rect.maxX - moreBounding.width
        }
        moreBounding.origin.y += truncatedLineRect.minY
        moreAttributes[NSForegroundColorAttributeName] = tintColor
        
        truncationTextCache = .Cached(moreBounding, moreAttributes)
    }
    
    // MARK: - UIView
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        
        switch truncationTextCache {
        case .None:
            break
        case .NeedsUpdate:
            setNeedsDisplay()
        case .Cached(let rect, var attributes):
            attributes[NSForegroundColorAttributeName] = tintColor
            truncationTextCache = .Cached(rect, attributes)
            setNeedsDisplay()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let newSize = bounds.size
        if textContainer.size != newSize {
            invalidateCustomTruncation()
            textContainer.size = newSize
        }
    }
    
    // MARK: - UI
    
    private var lastNumberOfLines = 0
    
    @IBAction public func toggleTruncation() {
        swap(&numberOfLines, &lastNumberOfLines)
    }
    
    // MARK: - Text Truncation
    
    private enum TruncationInfo {
        case None
        case NeedsUpdate
        case Cached(CGRect, [String: AnyObject])
    }
    
    private var customTruncationStart: String.Index?
    private var truncationTextCache = TruncationInfo.NeedsUpdate
    private lazy var truncationTextContext = NSStringDrawingContext()
    
    // MARK: - Internal
    
    private func updateTextStore() {
        textStorage.beginEditing()
        defer {
            textStorage.endEditing()
        }
        
        guard let attributedString = attributedText else {
            textStorage.deleteAllCharacters()
            return
        }
        
        textStorage.setAttributedString(attributedString)
        textStorage.mapAttributeInPlace(NSParagraphStyleAttributeName, ofType: NSParagraphStyle.self) {
            let mutablePStyle = $0.mutableCopy() as! NSMutableParagraphStyle
            mutablePStyle.lineBreakMode = .ByWordWrapping
            return mutablePStyle
        }
    }
    
    private func invalidateCustomTruncation() {
        if let start = customTruncationStart {
            customTruncationStart = nil
            layoutManager.invalidateGlyphsForRange(start..<textStorage.string.endIndex)
        }
        truncationTextCache = .NeedsUpdate
    }
    
    private func forceLayout() {
        layoutManager.ensureLayoutForCharacterRange(textStorage.string.utf16.range)
    }
    
    // MARK: - NSLayoutManagerDelegate
    
    private func extendToIncludeTrailingWhitespace(index: String.Index, within string: String) -> String.Index {
        let characterSet = NSCharacterSet.whitespaceCharacterSet()
        if let whiteSpaceChar = string.rangeOfCharacterFromSet(characterSet, options: .BackwardsSearch, range: string.startIndex...index) where whiteSpaceChar.endIndex == index {
            return whiteSpaceChar.startIndex
        } else {
            return index
        }
    }
    
    public func layoutManager(layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphsPtr: UnsafePointer<CGGlyph>, properties propertiesPtr: UnsafePointer<NSGlyphProperty>, characterIndexes charIndexesUTF16Ptr: UnsafePointer<Int>, font: UIFont, forGlyphRange inGlyphRange: NSRange) -> Int {
        guard let truncationChar = customTruncationStart, glyphRange = inGlyphRange.toRange(), string = layoutManager.textStorage?.string else {
            return 0
        }
        
        let glyphsCount = glyphRange.count
        let charIndexesUTF16 = UnsafeBufferPointer(start: charIndexesUTF16Ptr, count: glyphsCount)
        let charIndexes = charIndexesUTF16.lazy.map {
            string.utf16.startIndex.advancedBy($0).samePositionIn(string)!
        }
        
        // Bail if we don't need to truncated
        let characterRange = charIndexes[charIndexes.startIndex]...charIndexes[charIndexes.endIndex.predecessor()]
        guard characterRange.contains(truncationChar) else {
            return 0
        }

        // Include trailing whitespace while truncating
        let targetChar = extendToIncludeTrailingWhitespace(truncationChar, within: string)
        guard let glyphOffset = charIndexes.indexOf(targetChar) else {
            return 0
        }
        
        // Flush the pre-generated glyphs up to this point
        if targetChar != string.startIndex {
            layoutManager.setGlyphs(glyphsPtr, properties: propertiesPtr, characterIndexes: charIndexesUTF16Ptr, font: font, forGlyphRange: NSRange(location: glyphRange.startIndex, length: glyphOffset))
        }
        
        // Substitute "..." as the glyph for the truncation
        var ellipsis: UniChar = 0x2026
        var truncationProperty: NSGlyphProperty
        var truncationGlyph = kCGFontIndexInvalid
        var truncationIndex = charIndexesUTF16[glyphOffset]
        
        if CTFontGetGlyphsForCharacters(font, &ellipsis, &truncationGlyph, 1) {
            truncationProperty = .Regular
        } else {
            truncationProperty = .ControlCharacter
        }
        
        layoutManager.setGlyphs(&truncationGlyph, properties: &truncationProperty, characterIndexes: &truncationIndex, font: font, forGlyphRange: NSRange(location: glyphRange.startIndex.advancedBy(glyphOffset), length: 1))

        // Ignore remaining glyphs. Offset charIndexesUTF16Ptr by 1, but glyphRange by 2
        let glyphSkipped = glyphOffset.successor()
        if glyphsCount > glyphSkipped {
            var truncationProperties = [NSGlyphProperty](count: 32, repeatedValue: .Null)
            for glyphOffset in glyphSkipped.stride(to: glyphsCount, by: truncationProperties.count) {
                let start = glyphRange.startIndex.advancedBy(glyphOffset)
                let end = start.advancedBy(truncationProperties.count, limit: glyphRange.endIndex)
                layoutManager.setGlyphs(glyphsPtr.advancedBy(glyphOffset), properties: &truncationProperties, characterIndexes: charIndexesUTF16Ptr.advancedBy(glyphOffset), font: font, forGlyphRange: NSRange(start..<end))
            }
        }
        
        return glyphsCount
    }

}
