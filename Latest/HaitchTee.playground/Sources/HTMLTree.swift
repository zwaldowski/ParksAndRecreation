import Darwin

private struct XML2 {

    typealias CBufferCreate = @convention(c) () -> UnsafeMutableRawPointer
    typealias CBufferGetContent = @convention(c) (UnsafeRawPointer) -> UnsafePointer<CChar>
    typealias CBufferFree = @convention(c) (UnsafeMutableRawPointer) -> Void
    typealias CDocFree = @convention(c) (UnsafeMutableRawPointer) -> Void
    typealias CDocGetRootElement = @convention(c) (UnsafeRawPointer) -> UnsafeMutableRawPointer?
    typealias CNodeCopyProperty = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?
    typealias CNodeCopyContent = @convention(c) (UnsafeRawPointer) -> UnsafeMutablePointer<CChar>
    typealias CHTMLNodeDump = @convention(c) (UnsafeMutableRawPointer, UnsafeRawPointer, UnsafeRawPointer) -> Int32
    typealias CHTMLReadMemory = @convention(c) (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, UInt32) -> UnsafeMutableRawPointer?

    // libxml/tree.h
    let bufferCreate: CBufferCreate
    let bufferGetContent: CBufferGetContent
    let bufferFree: CBufferFree
    let docFree: CDocFree
    let docGetRootElement: CDocGetRootElement
    let nodeCopyProperty: CNodeCopyProperty
    let nodeCopyContent: CNodeCopyContent

    // libxml/HTMLtree.h
    let htmlNodeDump: CHTMLNodeDump

    // libxml/HTMLparser.h
    let htmlReadMemory: CHTMLReadMemory

    static let shared: XML2 = {
        let handle = dlopen("/usr/lib/libxml2.dylib", RTLD_LAZY)
        return XML2(
            bufferCreate: unsafeBitCast(dlsym(handle, "xmlBufferCreate"), to: CBufferCreate.self),
            bufferGetContent: unsafeBitCast(dlsym(handle, "xmlBufferContent"), to: CBufferGetContent.self),
            bufferFree: unsafeBitCast(dlsym(handle, "xmlBufferFree"), to: CBufferFree.self),
            docFree: unsafeBitCast(dlsym(handle, "xmlFreeDoc"), to: CDocFree.self),
            docGetRootElement: unsafeBitCast(dlsym(handle, "xmlDocGetRootElement"), to: CDocGetRootElement.self),
            nodeCopyProperty: unsafeBitCast(dlsym(handle, "xmlGetProp"), to: CNodeCopyProperty.self),
            nodeCopyContent: unsafeBitCast(dlsym(handle, "xmlNodeGetContent"), to: CNodeCopyContent.self),
            htmlNodeDump: unsafeBitCast(dlsym(handle, "htmlNodeDump"), to: CHTMLNodeDump.self),
            htmlReadMemory: unsafeBitCast(dlsym(handle, "htmlReadMemory"), to: CHTMLReadMemory.self))
    }()

}

/// An HTML page internalized into a logical tree structure. A tree can have
/// many child nodes but only one element, the root element.
public final class HTMLTree {

    /// Options you can use to control the parser's treatment of HTML.
    // libxml/HTMLparser.h
    public struct ParseOptions: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }
        /// Relaxed parsing
        public static let relaxed = ParseOptions(rawValue: 1 << 0)
        /// do not default a doctype if not found
        public static let noDefaultDocType = ParseOptions(rawValue: 1 << 2)
        /// suppress error reports
        public static let noErrors = ParseOptions(rawValue: 1 << 5)
        /// suppress warning reports
        public static let noWarnings = ParseOptions(rawValue: 1 << 6)
        /// pedantic error reporting
        public static let pedanticErrors = ParseOptions(rawValue: 1 << 7)
        /// remove blank nodes
        public static let noBlankNodes = ParseOptions(rawValue: 1 << 8)
        /// Forbid network access
        public static let noNetworkAccess = ParseOptions(rawValue: 1 << 11)
        /// Do not add implied html/body... elements
        public static let noImpliedRootElements = ParseOptions(rawValue: 1 << 13)
        /// compact small text nodes
        public static let compact = ParseOptions(rawValue: 1 << 16)
        /// ignore internal document encoding hint
        public static let ignoreDocumentEncoding = ParseOptions(rawValue: 1 << 21)
    }

    fileprivate let handle: UnsafeMutableRawPointer?

    /// Parses the HTML contents of a string source
    public init<String: StringProtocol>(parsedFrom string: String, options: ParseOptions = []) {
        handle = string.withCString {
            XML2.shared.htmlReadMemory($0, Int32(strlen($0)), nil, "UTF-8", options.rawValue)
        }
    }

    deinit {
        guard let handle = handle else { return }
        XML2.shared.docFree(handle)
    }

}

extension HTMLTree {

    /// Element nodes in an tree structure. An element may have child nodes,
    /// specifically element nodes, text nodes, comment nodes, or
    /// processing-instruction nodes. It may also have subscript attributes.
    public struct Node {

        fileprivate let handle: UnsafeRawPointer

        /// A strong back-reference to the containing document.
        fileprivate let owner: HTMLTree

        fileprivate init(_ handle: UnsafeRawPointer, in owner: HTMLTree) {
            self.handle = handle
            self.owner = owner
        }

    }

    /// The root node of the receiver.
    public var root: Node? {
        guard let rootHandle = handle.flatMap({ XML2.shared.docGetRootElement($0) }) else { return nil }
        return Node(rootHandle, in: self)
    }

}

extension HTMLTree: CustomReflectable {

    public var customMirror: Mirror {
        return Mirror(self, children: [ "root": root as Any ], displayStyle: .class)
    }

}

extension HTMLTree.Node {

    /// The different element types carried by an XML tree.
    /// See http://www.w3.org/TR/REC-DOM-Level-1/
    // libxml/tree.h
    public enum Kind: Int32 {
        case element = 1
        case attribute = 2
        case text = 3
        case characterDataSection = 4
        case entityReference = 5
        case entity = 6
        case processingInstruction = 7
        case comment = 8
        case document = 9
        case documentType = 10
        case documentFragment = 11
        case notation = 12
        case htmlDocument = 13
        case documentTypeDefinition = 14
        case elementDeclaration = 15
        case attributeDeclaration = 16
        case entityDeclaration = 17
        case namespaceDeclaration = 18
        case includeStart = 19
        case includeEnd = 20
    }

    /// The natural type of this element.
    /// See also [the W3C](http://www.w3.org/TR/REC-DOM-Level-1/).
    public var kind: Kind {
        // xmlNodePtr->type
        return Kind(rawValue: handle.load(fromByteOffset: MemoryLayout<Int>.stride, as: Int32.self))!
    }

    /// The element tag. (ex: for `<foo />`, `"foo"`)
    public var name: String {
        // xmlNodePtr->name
        return String(cString: handle.load(fromByteOffset: MemoryLayout<Int>.stride * 2, as: UnsafePointer<CChar>.self))
    }

    /// If the node is a text node, the text carried directly by the node.
    /// Otherwise, the aggregrate string of the values carried by this node.
	public var content: String {
        let buffer = XML2.shared.nodeCopyContent(handle)
        defer { buffer.deallocate() }
        return String(cString: buffer)
	}

    /// Request the content of the attribute `key`.
    public subscript(key: String) -> String? {
        guard let buffer = XML2.shared.nodeCopyProperty(handle, key) else { return nil }
        defer { buffer.deallocate() }
        return String(cString: buffer)
    }

}

extension HTMLTree.Node: BidirectionalCollection {

    public struct Index {
        fileprivate var handle: UnsafeRawPointer?
        fileprivate var offset: Int
    }

    public var startIndex: Index {
        // xmlNodePtr->children
        let nextHandle = handle.load(fromByteOffset: MemoryLayout<Int>.stride * 3, as: UnsafeRawPointer?.self)
        return Index(handle: nextHandle, offset: 0)
    }

    public var endIndex: Index {
        return Index(handle: nil, offset: count)
    }

    public subscript(position: Index) -> HTMLTree.Node {
        return HTMLTree.Node(position.handle!, in: owner)
    }

    public var count: Int {
        var nextHandle = handle.load(fromByteOffset: MemoryLayout<Int>.stride * 3, as: UnsafeRawPointer?.self)
        var result = 0
        while let handle = nextHandle {
            // xmlNodePtr->next
            nextHandle = handle.load(fromByteOffset: MemoryLayout<Int>.stride * 6, as: UnsafeRawPointer?.self)
            result += 1
        }
        return result
    }

    public func index(after i: Index) -> Index {
        // xmlNodePtr->next
        let nextHandle = i.handle?.load(fromByteOffset: MemoryLayout<Int>.stride * 6, as: UnsafeRawPointer?.self)
        return Index(handle: nextHandle, offset: i.offset + 1)
    }

    public func index(before i: Index) -> Index {
        // xmlNodePtr->prev; xmlNodePtr->last
        let previousHandle = i.handle?.load(fromByteOffset: MemoryLayout<Int>.stride * 7, as: UnsafeRawPointer?.self)
            ?? handle.load(fromByteOffset: MemoryLayout<Int>.stride * 4, as: UnsafeRawPointer?.self)
        return Index(handle: previousHandle, offset: i.offset - 1)
    }

}

extension HTMLTree.Node.Index: Comparable {

    public static func == (lhs: HTMLTree.Node.Index, rhs: HTMLTree.Node.Index) -> Bool {
        return lhs.handle == rhs.handle
    }

    public static func < (lhs: HTMLTree.Node.Index, rhs: HTMLTree.Node.Index) -> Bool {
        switch (lhs.handle != nil, rhs.handle != nil) {
        case (true, true):
            return lhs.offset < rhs.offset
        case (true, _):
            return true
        default:
            return false
        }
    }

}

extension HTMLTree.Node: CustomDebugStringConvertible, CustomReflectable {

    /// An HTML representation of `self`, suitable for debugging.
    public var debugDescription: String {
        guard let ownerHandle = owner.handle else { return "" }

        let buffer = XML2.shared.bufferCreate()
        defer { XML2.shared.bufferFree(buffer) }

        _ = XML2.shared.htmlNodeDump(buffer, ownerHandle, handle)

        return String(cString: XML2.shared.bufferGetContent(buffer))
    }

    public var customMirror: Mirror {
        return Mirror(self, unlabeledChildren: self, displayStyle: .collection)
    }

}
