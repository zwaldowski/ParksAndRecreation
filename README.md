# ParksAndRecreation

Various Swift playgrounds, for fun and for profit.

## Index

### [AnyCollectionSlice](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/AnyCollectionSlice.playground)

Derived from @krzyzanowskim's [blog post](http://blog.krzyzanowskim.com/2015/10/24/chunksequence-have-cake-and-eat-it/): use protocol extension to split any collection into a group of slices. Think `flatten()`, but in reverse.

### [ConcretePlusProtocol](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/ConcretePlusProtocol.playground)

If you're hurting for Objective-C's `MyClassType<SomeProtocolType> *`, try this on for size.

### [Custom Truncation](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/CustomTruncation.playground)

Use [TextKit](https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html) to perform custom truncation with high performance. Also an example of creating building a drop-in `UILabel` backed by TextKit.

### [Geometry](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/Geometry.playground)

Mathematical operators and idiomatic bridging for Core Graphics types.

### [Keyboard Layout Guide](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/KeyboardLayoutGuide)

An extension on `UIViewController` providing a `keyboardLayoutGuide` property. The layout guide normally mirrors the `topLayoutGuide` and `bottomLayoutGuide`, but automatically resizes to avoid the keyboard.

Requires iOS 9.0.

### [String Tokenization](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/LineParagraphs.playground)

Line, paragraph, sentence, and word views for `Swift.String`, providing alternatives to `String.enumerateSubstringsInRange(_:options:_:)`.

```swift
Array(string.lines)            // -> [Range<String.Index>]
Array(string.lines.substrings) // -> [String]
```

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

### [Target-Action Notifier](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/Notifier.playground)

A helper for performing type-safe multicast callbacks. The result is a lot like
using `UIControl`, but for weakly held objects and without unsafe selectors.

Heavily inspired by [this blog post](http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/) from @ole.

### [Ordered Dictionary](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/OrderedDictionary.playground)

A simple glueing together of `Swift.Dictionary` and `Swift.String` into an ordered, hashed data structure. Useful if your keys are indeed already `Hashable`, but doesn't have great performance; insertion and removal tend towards the worst of both structures. If you have any alternative, prefer something [B-Tree based](https://github.com/lorentey/BTree/blob/master/Sources/Map.swift) instead.

### [Custom Size Classes](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/Overrides)

"Size classes are fine, but I can't customize them!" Yeah, you can! By inspecting what Mobile Safari does, you can do the same, using override trait collections.

### [Custom Readable Width](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/ReadableWidth.playground)

Emulating the calculation of [`UIView.readableContentGuide`](https://developer.apple.com/reference/uikit/uiview/1622644-readablecontentguide).

### [Regular Expressions](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/RegularExpression.playground)

Simple Swift bridging for [`NSRegularExpression`](https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSRegularExpression_Class/), as well as general patterns to go from `String.UTF16View` and `Range<String.UTF16Index>` to `NSString` and `NSRange`.

### [UI Geometry](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/UI%20Geometry.playground)

Conveniences for using Core Graphics types in UI programming, such as retina-friendly
rounding and equation operators that account for floating point inaccuracy.

### Value Coding

* [Swift 2](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/ValueCodable.playground)
* [Swift 3](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-3/ValueCodable.playground)

A simple bridge to bridges concrete value types into `NSCoding`.

### [View Recursion](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Swift-2/ViewRecursion.playground)

Showing off the simple power of Swift iterators by performing breadth-first travel through the trees created by `UIView`, `UIViewController`, and `CALayer`.

### Swift 2 only

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
