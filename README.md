# ParksAndRecreation

Various Swift playgrounds, for fun and for profit.

## Index

### [Asynchronous Operations](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Asynchronous%Operations.playground)

Base classes for tracking work inside `OperationQueue` that takes place outside of the queue, without causing a thread to hang by waiting. Includes an `Operation` for wrapping `URLSessionTask`.

Inspired by and lovingly nerd-sniped by [@jaredsinclair](https://github.com/jaredsinclair).

### [Badge Formatter](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Badge%20Formatter.playground)

A simple class for using Unicode to encircle some characters or single-digit numbers in the iOS system font, inspired by [this tweet](https://twitter.com/Tricertops/status/952265724789129216). Includes a gallery live view for demonstration.

![Badge gallery](https://raw.githubusercontent.com/zwaldowski/ParksAndRecreation/master/Media/2018-01-17%20Badge%20Formatter.png)

### [Chunk Sequence](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Chunk%20Sequence.playground)

Derived from @krzyzanowskim's [blog post](http://blog.krzyzanowskim.com/2015/10/24/chunksequence-have-cake-and-eat-it/): use a protocol extension to split any collection into a group of slices. Think `flatten()`, but in reverse.

### [Custom Truncation](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/CustomTruncation.playground)

Use [TextKit](https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html) to perform custom truncation with high performance. Also an example of creating building a drop-in `UILabel` backed by TextKit.

### [Debounce](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Debounce.playground)

Use [`DispatchSource`](https://developer.apple.com/reference/dispatch/dispatchsource) to coalesce calls that shouldn't be called more than once per runloop iteration, like UI reconfiguration.

### [Delimited](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-3/Delimited.playground)

A fast recursive-descent parser for CSVs and similarly structured data inspired by [Matt Gallagher](http://www.cocoawithlove.com/2009/11/writing-parser-using-nsscanner-csv.html).

### [Deriving Scroll Views](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Deriving%20Scroll%20Views.playground)

Based on a technique used in the iOS 10 Music app, subclasses of `UICollectionView` and `UITableView` that derive their intrinsic content size and visible bounds from their content and context, respectively, when `isScrollEnabled = false`. This is similar to behavior on `UITextView`. It enables, for instance, putting three collection views in a stack view in a scroll view with low performance impact.

### [Geometry](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/Geometry.playground)

Mathematical operators and idiomatic bridging for Core Graphics types.

### [HTML Reader](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/HaitchTee.playground)

Extremely simple read-only HTML parser based on `libxml2` with 100% test coverage.

### [Keyboard Layout Guide](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Keyboard%20Layout%20Guide)

An extension on `UIViewController` providing a `keyboardLayoutGuide` property. The layout guide normally mirrors the safe area, but automatically shrinks to avoid the keyboard. It also allows emulating the automatic content keyboard insets applied to `UICollectionViewController` and `UITableViewController`. It avoids the pitfalls of most keyboard avoidance implementations, like correctly syncing animations.

The Swift 3 version requires iOS 9.0.

### [Living Wallpapers](https://github.com/zwaldowski/ParksAndRecreation/tree/master/Latest/Living%20Wallpapers.playground)

Create your own sun-, time-, or light/dark-based wallpaper for macOS Mojave.

![Wallpaper changing from light to dark](https://raw.githubusercontent.com/zwaldowski/ParksAndRecreation/master/Media/2018-06-30%20Living%20Wallpapers.gif)

Playground requires Swift 4.2 beta and macOS Mojave.

### [String Localization](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/Localize.playground)

Formatted localization using Swift string formatting. Introduces `localize` with
a similar prototype to `NSLocalizedString`:

```swift
func localize(text: LocalizableText, tableName: String? = default, bundle: NSBundle = default, value: String = default, comment: String)
```

What's a `LocalizableText`? It's an intermediary type that deconstructs
interpolation segments for use with string formatting. But that's not important,
what's important is that it's literal convertible:

```swift
let filesLeft = 4
let filesTotal = 5
let labelText = localize("test-progress-\(filesLeft)-of-\(filesTotal)", comment: "Help text used for a positional description")
```

And in your `Localizable.strings`, just like in Cocoa:

```swift
/* Help text used for a positional description */
"test-progress-%@-of-%@" = "%1$@ of %2$@ remaining.";

```

All placeholders should be `%@` on the end of the key, and be represented
positionally, i.e., with `%1$@`, `%2$@`, and so on.

### [Target-Action Notifier](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Notifier.playground)

A helper for performing type-safe multicast callbacks. The result is a lot like
using `UIControl`, but for weakly held objects and without unsafe selectors.

Heavily inspired by [this blog post](http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/) from @ole.

### [`NSView` Layout Margins](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/NSView%20Layout%20Margins.playground)

Extending `NSView` Auto Layout with conveniences from iOS, including
a view-level version of `NSWindow.contentLayoutGuide` (think of it like you
would safe areas), `directionalLayoutMargins`, `layoutMarginsGuide`, and
`readableContentGuide`.

![Layout margins](https://raw.githubusercontent.com/zwaldowski/ParksAndRecreation/master/Media/2018-12-09%20Layout%20Margins.png)

### [Ordered Dictionary](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Ordered%20Dictionary.playground)

A simple glueing-together of `Dictionary` and `Array` into an ordered, hashed data structure. Useful if your keys are indeed already `Hashable`, but doesn't have great performance; insertion and removal tend towards the worst of both structures. If you have any alternative, prefer something [B-Tree based](https://github.com/lorentey/BTree) instead.

### [Custom Size Classes](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/Overrides)

"Size classes are fine, but I can't customize them!" Yeah, you can! By inspecting what Mobile Safari does, you can do the same, using override trait collections.

### [Custom Readable Width](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/ReadableWidth.playground)

Emulating the calculation of [`UIView.readableContentGuide`](https://developer.apple.com/reference/uikit/uiview/1622644-readablecontentguide).

### [Regular Expressions](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/RegularExpression.playground)

Simple Swift bridging for [`NSRegularExpression`](https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSRegularExpression_Class/), as well as general patterns to go from `String.UTF16View` and `Range<String.UTF16Index>` to `NSString` and `NSRange`.

### [String Views](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/String%20Views.playground)

Line, paragraph, sentence, and word views for `Swift.String`, providing a more idiomatic take on `StringProtocol.getLineStart(_:end:contentsEnd:for:)` and `StringProtocol.getParagraphStart(_:end:contentsEnd:for:)` as Swift collections.

```swift
Array(string.lines) // -> [Substring]
```

### [Floating Now Playing Bar](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Tab%20Bar%20Palette.playground)

Experiment adding an accessory to `UITabBarController`, like Now Playing in Music.​app.

![Tab bar palette gallery](https://raw.githubusercontent.com/zwaldowski/ParksAndRecreation/master/Media/2018-01-17%20Tab%20Bar%20Palette.png)

- Drop-in UITabBarController with a `paletteViewController` property
- Palette is forwarded appearance (i.e., `viewWillAppear`) and trait collection events
- Palette supports sizing through Auto Layout and `preferredContentSize` and animating changes to those
- Can animate in, out, and between palette changes
- Detects and supports highlighting of palette background on tap
- Supports Interface Builder, 3D Touch, and modal view controllers

### [Thread with Function](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/Thread%20with%20Function.playground)

Spawn and join with a `pthread_t` returning a result from a Swift function, inspired by [the Swift stdlib](https://github.com/apple/swift/blob/master/stdlib/private/SwiftPrivatePthreadExtras/SwiftPrivatePthreadExtras.swift). See also [`Thread.init(block:)`](https://developer.apple.com/documentation/foundation/thread/2088561-init) from iOS 10 and up.

### [UI Geometry](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/UI%20Geometry.playground)

Conveniences for using Core Graphics types in UI programming, such as retina-friendly
rounding and equation operators that account for floating point inaccuracy.

### [View Recursion](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/ViewRecursion.playground)

Showing off the simple power of Swift iterators by performing breadth-first travel through the trees created by `UIView`, `UIViewController`, and `CALayer`.

### Obsoleted in Swift 4

#### [ConcretePlusProtocol](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/ConcretePlusProtocol.playground)

If you're hurting for Objective-C's `MyClassType<SomeProtocolType> *`, try this on for size.

Obsoleted in Swift 4 by `MyClass & SomeProtocol` syntax.

#### [Value Coding](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Latest/ValueCodable.playground)

A simple bridge to bridges concrete value types into `NSCoding`.

Obsoleted in Swift 4 by `Codable`.

### Obsoleted in Swift 3

#### [BetterCoreDataInit](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/BetterCoreDataInit.playground)

Use protocol extension to achieve simpler Core Data, like `MyManagedObject(context:)`.

#### [Data](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/Data.playground)

An idiomatic `Data<T>`, representing any buffer (contiguous or discontiguous) of
numeric elements. Part `NSData`, part `dispatch_data_t`, `Data` is useful for
low-level byte-based APIs in Swift, such as crypto and string parsing.

Create one with an array:

```swift
let data = Data<UInt8>(array: [ 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21 ])
```

And enumerate through it in constant time:

```swift
for byte in data {
	...
}
```

Made with lots of help from [@a2](https://github.com/a2).

#### [Fixing `dispatch_block_t`](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/DispatchBlock.playground)

Even though it's been fixed in 2.1, Swift 2.0 has a rather ugly bug with wrapped `dispatch_block_t` types. Fix it with a C few tricks and a rational `DispatchBlock` type.
