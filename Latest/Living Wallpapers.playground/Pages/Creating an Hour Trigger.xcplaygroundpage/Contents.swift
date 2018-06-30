//: [Previous](@previous)

import Cocoa
import AVFoundation
import PlaygroundSupport

// Generate one trigger for every hour.
let percentages = stride(from: 0.0, to: 1.0, by: 1 / 24)

let trigger = HourTrigger(hourToIndex: percentages.enumerated().map { (arg) in
    .image(normalizedTime: arg.element, index: UInt32(arg.offset))
})

let context = NSStringDrawingContext()
let font = NSFont.boldSystemFont(ofSize: 400)

let images = percentages.enumerated().map { (arg) -> NSImage in
    return NSImage(size: NSSize(width: 2560, height: 1440), flipped: false) { (rect) in
        let text = "\(arg.offset)"
        return text.drawCentered(in: rect, font: font, context: context)
    }
}

let destinationURL = playgroundSharedDataDirectory.appendingPathComponent("hourly").appendingPathExtension("heic")
let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, AVFileType.heic as CFString, images.count, nil)!

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
