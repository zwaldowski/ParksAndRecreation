import UIKit

extension UIUserInterfaceLayoutDirection: CustomStringConvertible {
    
    /// Extension-safe user layout direction for iOS 8
    public static let standardUserInterfaceLayoutDirection: UIUserInterfaceLayoutDirection = {
        guard #available(iOS 9.0, watchOS 2.0, *) else {
            return UIView.userInterfaceLayoutDirectionForSemanticContentAttribute(.Unspecified)
        }
        
        let direction = NSParagraphStyle.defaultWritingDirectionForLanguage(nil)
        switch NSParagraphStyle.defaultWritingDirectionForLanguage(nil) {
        case .LeftToRight:
            return .LeftToRight
        case .RightToLeft:
            return .RightToLeft
        case .Natural:
            guard let localization = NSBundle.mainBundle().preferredLocalizations.first else {
                return .LeftToRight
            }
            return NSLocale.characterDirectionForLanguage(localization) == .RightToLeft ? .RightToLeft : .LeftToRight
        }
    }()
    
    public var description: String {
        switch self {
        case .LeftToRight: return "Left-to-Right"
        case .RightToLeft: return "Right-to-Left"
        }
    }
    
}
