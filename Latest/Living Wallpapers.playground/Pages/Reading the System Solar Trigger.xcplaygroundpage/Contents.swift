//: [Previous](@previous)


import AVFoundation

let url = URL(fileURLWithPath: "/Library/Desktop Pictures/Mojave (Dynamic).heic")

let imageSource = CGImageSourceCreateWithURL(url as CFURL, [
    kCGImageSourceRespectHEIFFileOrder: true,
    kCGImageSourceShouldMemoryMap: true
] as CFDictionary)!

let imageMetadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil)!

try print(SolarTrigger.read(from: imageMetadata))

//: [Next](@next)
