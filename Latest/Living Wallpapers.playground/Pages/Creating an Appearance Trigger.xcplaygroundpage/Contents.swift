//: [Previous](@previous)

import Cocoa
import AVFoundation
import PlaygroundSupport

// An appearance trigger has no information, but must still be written to the
// file to distinguish from single wallpapers.
let trigger = AppearanceTrigger()

let context = NSStringDrawingContext()
let font = NSFont.boldSystemFont(ofSize: 400)

let images = [
    NSImage(size: NSSize(width: 2560, height: 1440), flipped: false) { (rect) in
        let text = "Light"
        return text.drawCentered(in: rect, background: .white, foreground: .black, font: font, context: context)
    }, NSImage(size: NSSize(width: 2560, height: 1440), flipped: false) { (rect) in
        let text = "Dark"
        return text.drawCentered(in: rect, background: .black, foreground: .white, font: font, context: context)
    }
]

let destinationURL = playgroundSharedDataDirectory.appendingPathComponent("appearancely2").appendingPathExtension("heic")
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
