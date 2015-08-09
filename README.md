# ParksAndRecreation
Various Swift playgrounds, for fun and for profit.

## Index

### [Data](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Data.playground)

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

### [Geometry](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Geometry.playground)

Mathematical operators and idiomatic bridging for Core Graphics types.

### [String Localization](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Localize.playground)

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


### [UI Geometry](https://github.com/zwaldowski/ParksAndRecreation/blob/master/UI%020Geometry.playground)

Conveniences for using Core Graphics types in UI programming, such as retina-friendly
rounding and equation operators that account for floating point inaccuracy.
