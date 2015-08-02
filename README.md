# ParksAndRecreation
Various Swift playgrounds, for fun and for profit.

## Index

### [String Localization](https://github.com/zwaldowski/ParksAndRecreation/blob/master/Localize.playground)

Formatted localization using Swift string formatting. Introduces `localize` with a similar prototype to `NSLocalizedString`:

```swift
func localize(text: LocalizableText, tableName: String? = default, bundle: NSBundle = default, value: String = default, comment: String)
```

What's a `LocalizableText`? It's an intermediary type that deconstructs interpolation segments for use with string formatting. But that's not important, what's important is that it's literal convertible:

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

All placeholders should be `%@` on the end of the key, and be represented positionally, i.e., with `%1$@`, `%2$@`, and so on.
