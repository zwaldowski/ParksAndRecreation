import AVFoundation

/// Describes a wallpaper that changes periodically based on the wall clock.
///
/// The value for this trigger is interpreted by macOS based on your "progress"
/// through a day. For a given time, the closest trigger without going over is
/// used. That is, modulo other changes to the hours in a day, 12:00
/// is 0.5 (50%), 18:00 is 0.75 (75%), and so on.
public struct HourTrigger: DynamicDesktopTrigger {

    /// `apple_desktop:h24`.
    public static let tagName = "h24"

    /// Describes an image in the image set, and when it should be used.
    public struct Mapping: Codable {

        /// The percent through a 24-hour day.
        ///
        /// In a normal day, 12:00 is 0.5 (50%), 18:00 is 0.75 (75%), and so on.
        /// The system accounts for changes in duration to a day on your behalf.
        public let normalizedTime: Double

        /// The index in the image set for this image.
        public let index: UInt32

        /// Creates an image to be used when the user's percent progress through
        /// a day is closest to `normalizedTime` without going over.
        public init(normalizedTime: Double, index: UInt32) {
            self.normalizedTime = normalizedTime
            self.index = index
        }

        private enum CodingKeys: String, Swift.CodingKey {
            case normalizedTime = "t"
            case index = "i"
        }

    }

    /// The mapping from the time of day to an index in the image set.
    public var timeToIndex = [Mapping]()

    /// The mapping from preference names ("Dark" and "Light") to indexes in the
    /// image set.
    public var appearanceIndexes: AppearanceIndexes?

    /// Creates the empty trigger.
    public init() {}

    private enum CodingKeys: String, Swift.CodingKey {
        case timeToIndex = "ti"
        case appearanceIndexes = "ap"
    }

}
