//: [Previous](@previous)

import Cocoa
import AVFoundation
import PlaygroundSupport

// This copies the timings from Mojave (Dynamic).
// Synthesizing your own timing information is left as an exercise to the reader.
var trigger = SolarTrigger()
trigger.solarToIndex = [
    SolarTrigger.Mapping(altitude: -0.3427528387535028, azimuth: 270.9334057827345, index: 0),
    SolarTrigger.Mapping(altitude: -10.239758644725045, azimuth: 81.77588714480999, index: 1),
    SolarTrigger.Mapping(altitude: -4.247734408075456, azimuth: 86.33545030477751, index: 2),
    SolarTrigger.Mapping(altitude: 1.3890866331008431, azimuth: 90.81267037496195, index: 3),
    SolarTrigger.Mapping(altitude: 7.167168970526129, azimuth: 95.30740958876589, index: 4),
    SolarTrigger.Mapping(altitude: 13.08619419164163, azimuth: 99.92062963268938, index: 5),
    SolarTrigger.Mapping(altitude: 40.41563946490428, azimuth: 129.18652208191958, index: 6),
    SolarTrigger.Mapping(altitude: 53.43347266172774, azimuth: 182.2330942549791, index: 7),
    SolarTrigger.Mapping(altitude: 38.793128200638634, azimuth: 233.5515919580959, index: 8),
    SolarTrigger.Mapping(altitude: 11.089423171265878, azimuth: 261.87159046576664, index: 9),
    SolarTrigger.Mapping(altitude: 5.1845753236736245, azimuth: 266.4432737071051, index: 10),
    SolarTrigger.Mapping(altitude: -6.248309374122789, azimuth: 275.44204536695247, index: 11),
    SolarTrigger.Mapping(altitude: -12.20770735214888, azimuth: 280.07031589401174, index: 12),
    SolarTrigger.Mapping(altitude: -39.48933951993012, azimuth: 309.41857318745144, index: 13),
    SolarTrigger.Mapping(altitude: -52.75318137879935, azimuth: 2.1750965538675473, index: 14),
    SolarTrigger.Mapping(altitude: -38.04743388682423, azimuth: 53.50908581251309, index: 15)
]

let context = NSStringDrawingContext()
let font = NSFont.boldSystemFont(ofSize: 400)

let images = trigger.solarToIndex.indices.map { (index) in
    NSImage(size: NSSize(width: 2560, height: 1440), flipped: false) { (rect) in
        let text = "\(index)"
        return text.drawCentered(in: rect, font: font, context: context)
    }
}

let destinationURL = playgroundSharedDataDirectory.appendingPathComponent("solar").appendingPathExtension("heic")
let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, AVFileType.heic as CFString, trigger.solarToIndex.count, nil)!

for (i, image) in images.enumerated() {
    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!

    if i == 0 {
        let imageMetadata = CGImageMetadataCreateMutable()
        try trigger.write(to: imageMetadata)
        CGImageDestinationAddImageAndMetadata(destination, cgImage, imageMetadata, nil)
    } else {
        CGImageDestinationAddImage(destination, cgImage, nil)
    }
}

CGImageDestinationFinalize(destination)
print("Done!")

//: [Next](@next)
