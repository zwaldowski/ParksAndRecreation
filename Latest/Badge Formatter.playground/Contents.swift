//#-hidden-code
import UIKit
import PlaygroundSupport
//#-end-hidden-code

//: A badge can be rendered in four different styles.
let format = BadgeFormatter(style: .filledSquare)
//: Basic Latin capital letters can be put inside a badge.
format.string(for: "Y")
format.string(for: "n")
//: Single digit integers can also be put inside a badge.
format.string(for: 3)
format.string(for: 42.5)
//: Some common symbols like `✓` are even supported.
format.checkmark

//#-hidden-code
PlaygroundPage.current.liveView = BadgeGalleryViewController()
//#-end-hidden-code
