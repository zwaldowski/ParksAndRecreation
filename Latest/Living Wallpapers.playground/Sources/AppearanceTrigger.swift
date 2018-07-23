import AVFoundation

/// Describes a wallpaper that changes based on the user's appearance
/// preference.
public struct AppearanceTrigger: DynamicDesktopTrigger {

    /// `apple_desktop:apr`.
    public static let tagName = "apr"

    /// The mapping from preference names ("Dark" and "Light") to indexes in the
    /// image set.
    public var appearanceIndexes: AppearanceIndexes

    /// Creates the trigger with a mapping to indexes in the image set.
    public init(lightIndex: UInt32, darkIndex: UInt32) {
        self.appearanceIndexes = AppearanceIndexes(lightIndex: lightIndex, darkIndex: darkIndex)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.appearanceIndexes = try container.decode(AppearanceIndexes.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(appearanceIndexes)
    }

}
