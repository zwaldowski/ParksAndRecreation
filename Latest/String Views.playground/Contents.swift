let text = try! String(contentsOf: #fileLiteral(resourceName: "swift.txt"), encoding: .utf8)

Array(text.lines)
Array(text.lines.reversed())

Array(text.paragraphs)
Array(text.paragraphs.reversed())

Array(text.sentences)

Array(text.words)

