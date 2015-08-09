import UIKit

public extension UIView {
    
    @nonobjc
    var scale: CGFloat {
        let screen = window?.screen ?? UIScreen.mainScreen()
        return screen.scale
    }
    
    @nonobjc
    var hairline: CGFloat {
        return 1 / scale
    }
    
}
