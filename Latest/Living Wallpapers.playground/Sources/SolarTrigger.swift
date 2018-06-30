import AVFoundation

/// Describes a wallpaper that changes based on the position and angle of the
/// sun.
///
/// Images may be provided separately for light and dark appearances. For
/// instance, the Mojave Dynamic Desktop picture has a 13 images in the light
/// appearance for day and night, but only 3 images in the dark apperance just
/// for night.
///
/// The values for this trigger are interpreted by macOS based on your
/// location and the season to correlate to a time of day. If you've used the
/// Solar face on Apple Watch, this trigger models points along the curve of
/// that face.
public struct SolarTrigger: WallpaperTrigger {

    /// `apple_desktop:solar`.
    public static let tagName = "solar"

    /// Options used to interpret an `Image`.
    public struct ImageOptions: RawRepresentable, Codable {

        public let rawValue: UInt8
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// The image should be used when System Preferences > General >
        /// Appearance is set to Light.
        public static let useForLightAppearance = ImageOptions(rawValue: 1 << 0)

        /// The image should be used when System Preferences > General >
        /// Appearance is set to Dark.
        public static let useForDarkAppearance = ImageOptions(rawValue: 0)

    }

    /// Describes an image in the image set, and when it should be used.
    public struct Image: Codable {

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

        /// Which appearance the image should be used for.
        public let options: ImageOptions

        /// Creates an image to be used when System Preferences > General >
        /// Appearance is set to Light.
        public static func lightImage(altitude: Double, azimuth: Double, index: UInt32) -> Image {
            return Image(altitude: altitude, azimuth: azimuth, index: index, options: .useForLightAppearance)
        }

        /// Creates an image to be used when System Preferences > General >
        /// Appearance is set to Dark.
        public static func darkImage(altitude: Double, azimuth: Double, index: UInt32) -> Image {
            return Image(altitude: altitude, azimuth: azimuth, index: index, options: .useForDarkAppearance)
        }

        private enum CodingKeys: String, Swift.CodingKey {
            case altitude = "a"
            case azimuth = "z"
            case index = "i"
            case options = "o"
        }

    }

    /// The mapping from the sun's position to an index in the image set.
    public let solarToIndex: [Image]

    /// Create the trigger.
    public init(solarToIndex: [Image]) {
        self.solarToIndex = solarToIndex
    }

    private enum CodingKeys: String, Swift.CodingKey {
        case solarToIndex = "si"
    }

}

extension SolarTrigger.Image: CustomDebugStringConvertible {

    public var debugDescription: String {
        return ".\(options == .useForDarkAppearance ? "dark" : "light")Image(altitude: \(altitude), azimuth: \(azimuth), index: \(index))"
    }

}
