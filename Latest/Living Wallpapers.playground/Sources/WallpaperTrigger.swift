import AVFoundation

/// A wallpaper trigger describes an index and set of conditions that can be
/// written with multiple images into a file to serve as a Dynamic Desktop
/// picture on macOS Mojave.
///
/// This protocol is not meant to be adopted by users. Its conformances in this
/// framework correspond with the triggers supported by macOS Mojave. You cannot
/// add custom triggers with this code alone.
///
/// Dynamic Desktop pictures use the HEIC format to write several images into
/// a single file. The trigger data is encoded as a metadata tag, like
/// Manufacturer or GPS location, alongside the first image.
///
/// Triggers can be read and written using the ImageIO framework on macOS Sierra
/// and better, with the caveat that not all functionality related to HEIC is
/// public yet, or as optimized as you'd like it do be. For instance, this
/// framework exposes the private `kCGImageSourceRespectHEIFFileOrder`
/// option needed to read the Dynamic Desktop pictures as separate images.
///
/// - seealso:
/// [Image I/O Framework](https://developer.apple.com/documentation/imageio?language=swift)
/// [High Efficiency Image File Format](https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format)
public protocol WallpaperTrigger: Codable {

    /// The name of this trigger in Apple's `apple_desktop` namespace.
    ///
    /// It must be a valid XMP name.
    static var tagName: String { get }

}

private struct ImageMetadataCodingKey: CodingKey {
    let stringValue: String
    init(stringValue: String) {
        self.stringValue = stringValue
    }

    let intValue: Int? = nil
    init?(intValue: Int) {
        return nil
    }
}

extension WallpaperTrigger {

    private static var tagPath: String {
        return "apple_desktop:\(tagName)"
    }

    /// Attempts to decode a trigger list from `imageMetadata`.
    /// - throws: `DecodingError.keyNotFound` if `imageMetadata` does not have a
    ///   a tag corresponding to this trigger.
    /// - throws: `DecodingError.dataCorrupted` if a tag was found in
    ///   `imageMetadata` but it cannot be converted for decoding.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to `Self`.
    public static func read(from imageMetadata: CGImageMetadata) throws -> Self {
        let tagPath = self.tagPath

        guard let tag = CGImageMetadataCopyTagWithPath(imageMetadata, nil, tagPath as CFString),
            let stringValue = CGImageMetadataTagCopyValue(tag) as? String else {
                let fakeCodingKey = ImageMetadataCodingKey(stringValue: tagPath)
                let context = DecodingError.Context(codingPath: [], debugDescription: "The trigger key (\(tagPath)) didn't exist in the image metadata.")
                throw DecodingError.keyNotFound(fakeCodingKey, context)
        }

        guard let data = Data(base64Encoded: stringValue) else {
            let fakeCodingKey = ImageMetadataCodingKey(stringValue: tagPath)
            let context = DecodingError.Context(codingPath: [ fakeCodingKey ], debugDescription: "The metadata didn't contain a base64-encoded string.")
            throw DecodingError.dataCorrupted(context)
        }

        return try PropertyListDecoder().decode(self, from: data)
    }

    /// Attempts to encode a trigger list into `imageMetadata`.
    /// - throws: `EncodingError.invalidValue` if `self` is not valid in the current
    ///   context for this format.
    public func write(to imageMetadata: CGMutableImageMetadata) throws {
        let encoded = try PropertyListEncoder().encode(self).base64EncodedString()
        CGImageMetadataRegisterNamespaceForPrefix(imageMetadata, "http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, nil)
        CGImageMetadataSetValueWithPath(imageMetadata, nil, Self.tagPath as CFString, encoded as CFString)
    }

}
