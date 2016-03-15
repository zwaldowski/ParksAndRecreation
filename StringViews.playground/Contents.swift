//: Playground - noun: a place where people can play

import Foundation

let textURL = [#FileReference(fileReferenceLiteral: "swift.txt")#]
let textData = try! String(contentsOfURL: textURL, encoding: NSUTF8StringEncoding)

Array(textData.paragraphs)
Array(textData.paragraphs.reverse())

Array(textData.lines)
Array(textData.lines.reverse())