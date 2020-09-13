//  Copyright © 2017 Apple Inc. All rights reserved.

import UIKit

extension UIFont {

    /// Returns a font from the same family by augmenting it with additional traits, like boldness or obliqueness.
    ///
    /// If `self` is a Dynamic Type font, the returned font will be as well, and adapt in the future if under i.e., `adjustsFontForContentSizeCategory`.
    ///
    /// Not every family has a matching font for additional traits, including Dynamic Type fonts. For instance, `.body` can adapt for `.traitItalic`, but
    /// not `.largeTitle`. All the Dynamic Type fonts are known to support `.traitBold`, however.
    func addingSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let oldFontDescriptor = self.fontDescriptor
        let newSymbolicTraits = oldFontDescriptor.symbolicTraits.union(traits)
        let newFontDescriptor = oldFontDescriptor.withSymbolicTraits(newSymbolicTraits) ?? oldFontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }

}
