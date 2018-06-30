import AVFoundation

// Supports every 4 hours (1 / 6)
// Supports every 3 hours (1 / 8)
// Supports every 2 hours (1 / 12)
// Supports every 1 hour (1 / 24)

/// Describes a wallpaper that changes periodically based on the wall clock.
///
/// The value for this trigger is interpreted by macOS based on your "progress"
/// through a day. For a given time, the closest trigger without going over is
/// used. That is, modulo other changes to the hours in a day, 12:00
/// is 0.5 (50%), 18:00 is 0.75 (75%), and so on.
public struct HourTrigger: WallpaperTrigger {

    /// `apple_desktop:h24`.
    public static let tagName = "h24"

    /// Describes an image in the image set, and when it should be used.
    public struct Image: Codable {

        /// The percent through a 24-hour day.
        ///
        /// In a normal day, 12:00 is 0.5 (50%), 18:00 is 0.75 (75%), and so on.
        /// The system accounts for changes in duration to a day on your behalf.
        public let normalizedTime: Double
        public let index: UInt32

        /// Creates an image to be used when the user's percent progress through
        /// a day is closest to `normalizedTime` without going over.
        public static func image(normalizedTime: Double, index: UInt32) -> Image {
            return Image(normalizedTime: normalizedTime, index: index)
        }

        private enum CodingKeys: String, Swift.CodingKey {
            case normalizedTime = "t"
            case index = "i"
        }

    }

    /// The mapping from the time of day to an index in the image set.
    public let hourToIndex: [Image]

    /// Creates the trigger with a mapping from the time of day to an index in
    /// your image set.
    public init(hourToIndex: [Image]) {
        self.hourToIndex = hourToIndex
    }

    private enum CodingKeys: String, Swift.CodingKey {
        case hourToIndex = "ti"
    }

}
