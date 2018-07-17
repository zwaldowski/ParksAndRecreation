import AVFoundation

/// Describes a wallpaper that can change based on the position and angle of the
/// sun.
///
/// Still images may also be for light and dark appearances. For instance, the
/// "Mojave (Dynamic)" image has 16 stills to be used throughout the day, and
/// also marks the first and last stills for the "Light (Still)" and
/// "Dark (Still)" options in System Preferences.
///
/// The values for this trigger are interpreted by macOS based on your
/// location and the season to correlate to a time of day. If you've used the
/// Solar face on Apple Watch, this trigger models points along the curve of
/// that face.
public struct SolarTrigger: DynamicDesktopTrigger {

    /// `apple_desktop:solar`.
    public static let tagName = "solar"

    /// Describes images in the image set, and when they should be used.
    public struct Mapping: Codable {

        /// The angle up from the horizon for the sun.
        ///
        /// This image will be used when the time of day most closely
        /// corresponds to this and the `azimuth` value for the user's location
        /// and season.
        public let altitude: Double

        /// The angle along the horizon for the sun.
        ///
        /// This image will be used when the time of day most closely
        /// corresponds to this and the `altitude` value for the user's location
        /// and season.
        public let azimuth: Double

        /// The index in the image set for this image.
        public let index: UInt32

        /// Creates an image definition.
        public init(altitude: Double, azimuth: Double, index: UInt32) {
            self.altitude = altitude
            self.azimuth = azimuth
            self.index = index
        }

        private enum CodingKeys: String, Swift.CodingKey {
            case altitude = "a"
            case azimuth = "z"
            case index = "i"
        }

    }

    /// The mapping from the sun's position to an index in the image set.
    public var solarToIndex = [Mapping]()

    /// The mapping from preference names ("Dark" and "Light") to indexes in the
    /// image set.
    public var appearanceIndexes: AppearanceIndexes?

    /// Creates the empty trigger.
    public init() {}

    private enum CodingKeys: String, Swift.CodingKey {
        case solarToIndex = "si"
        case appearanceIndexes = "ap"
    }

}

extension SolarTrigger.Mapping: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Mapping(altitude: \(altitude), azimuth: \(azimuth), index: \(index))"
    }

}
