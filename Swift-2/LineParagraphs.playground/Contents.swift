import Cocoa

let str = try! NSAttributedString(URL: [#FileReference(fileReferenceLiteral: "Paragraphs.rtf")#], options: [:], documentAttributes: nil)

Array(str.string.lines.substrings)
Array(str.string.paragraphs.substrings)
Array(str.string.words.substrings)
Array(str.string.sentences.substrings)
