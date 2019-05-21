import UIKit

extension UIFont {

    public func addingSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let oldFontDescriptor = fontDescriptor
        let newSymbolicTraits = oldFontDescriptor.symbolicTraits.union(traits)
        let newFontDescriptor = fontDescriptor.withSymbolicTraits(newSymbolicTraits) ?? fontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }

    public var boldFont: UIFont {
        return addingSymbolicTraits(.traitBold)
    }

}
