import AVFoundation

/// Describes a wallpaper that changes based on the user's and angle of the
/// sun.
///
/// Image 0 will be used when System Preferences > General > Appearance is set
/// to Light.
///
/// Image 1 will be used when System Preferences > General > Appearance is set
/// to Light.
///
/// This trigger has no other information associated with it, but it must
/// be written to an image to distinguish it from other single-frame wallpaper.
public struct AppearanceTrigger: WallpaperTrigger {

    /// `apple_desktop:apr`.
    public static let tagName = "apr"

    /// Creates the empty trigger.
    public init() {}

}
