import Darwin

private struct XML2 {

    typealias CBufferCreate = @convention(c) () -> UnsafeMutableRawPointer?
    typealias CBufferFree = @convention(c) (UnsafeMutableRawPointer?) -> Void
    typealias CBufferGetContent = @convention(c) (UnsafeRawPointer?) -> UnsafePointer<CChar>
    typealias CDocFree = @convention(c) (UnsafeMutableRawPointer) -> Void
    typealias CDocAddFragment = @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?
    typealias CDocGetRootElement = @convention(c) (UnsafeRawPointer) -> UnsafeMutableRawPointer?
    typealias CNodeAddChild = @convention(c) (_ parent: UnsafeMutableRawPointer, _ cur: UnsafeRawPointer) -> UnsafeMutableRawPointer?
    typealias CNodeUnlink = @convention(c) (UnsafeRawPointer) -> Void
    typealias CNodeCopyProperty = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?
    typealias CNodeCopyContent = @convention(c) (UnsafeRawPointer) -> UnsafeMutablePointer<CChar>?
    typealias CHTMLNodeDump = @convention(c) (UnsafeMutableRawPointer?, UnsafeRawPointer, UnsafeRawPointer) -> Int32
    typealias CHTMLReadMemory = @convention(c) (UnsafePointer<CChar>?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> UnsafeMutableRawPointer?

    // libxml/tree.h
    let bufferCreate: CBufferCreate
    let bufferFree: CBufferFree
    let bufferGetContent: CBufferGetContent
    let docFree: CDocFree
    let docAddFragment: CDocAddFragment
    let docGetRootElement: CDocGetRootElement
    let nodeAddChild: CNodeAddChild
    let nodeUnlink: CNodeUnlink
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
            bufferFree: unsafeBitCast(dlsym(handle, "xmlBufferFree"), to: CBufferFree.self),
            bufferGetContent: unsafeBitCast(dlsym(handle, "xmlBufferContent"), to: CBufferGetContent.self),
            docFree: unsafeBitCast(dlsym(handle, "xmlFreeDoc"), to: CDocFree.self),
            docAddFragment: unsafeBitCast(dlsym(handle, "xmlNewDocFragment"), to: CDocAddFragment.self),
            docGetRootElement: unsafeBitCast(dlsym(handle, "xmlDocGetRootElement"), to: CDocGetRootElement.self),
            nodeAddChild: unsafeBitCast(dlsym(handle, "xmlAddChild"), to: CNodeAddChild.self),
            nodeUnlink: unsafeBitCast(dlsym(handle, "xmlUnlinkNode"), to: CNodeUnlink.self),
            nodeCopyProperty: unsafeBitCast(dlsym(handle, "xmlGetProp"), to: CNodeCopyProperty.self),
            nodeCopyContent: unsafeBitCast(dlsym(handle, "xmlNodeGetContent"), to: CNodeCopyContent.self),
            htmlNodeDump: unsafeBitCast(dlsym(handle, "htmlNodeDump"), to: CHTMLNodeDump.self),
            htmlReadMemory: unsafeBitCast(dlsym(handle, "htmlReadMemory"), to: CHTMLReadMemory.self))
    }()

}

/// A fragment of HTML parsed into a logical tree structure. A tree can have
/// many child nodes but only one element, the root element.
public final class HTMLDocument {

    /// Element nodes in an tree structure. An element may have child nodes,
    /// specifically element nodes, text nodes, comment nodes, or
    /// processing-instruction nodes. It may also have subscript attributes.
    public struct Node {
        public struct Index {
            fileprivate let variant: IndexVariant
        }

        /// A strong back-reference to the containing document.
        public let document: HTMLDocument
        fileprivate let handle: UnsafeRawPointer
    }

    /// Options you can use to control the parser's treatment of HTML.
    private struct ParseOptions: OptionSet {
        let rawValue: Int32
        init(rawValue: Int32) { self.rawValue = rawValue }

        // libxml/HTMLparser.h
        /// Relaxed parsing
        static let relaxedParsing = ParseOptions(rawValue: 1 << 0)
        /// suppress error reports
        static let noErrors = ParseOptions(rawValue: 1 << 5)
        /// suppress warning reports
        static let noWarnings = ParseOptions(rawValue: 1 << 6)
        /// remove blank nodes
        static let noBlankNodes = ParseOptions(rawValue: 1 << 8)
        /// Forbid network access
        static let noNetworkAccess = ParseOptions(rawValue: 1 << 11)
        /// Do not add implied html/body... elements
        static let noImpliedElements = ParseOptions(rawValue: 1 << 13)
    }

    fileprivate let handle: UnsafeMutableRawPointer

    fileprivate init?<Input>(parsing input: Input) where Input: StringProtocol {
        let options = [
            .relaxedParsing, .noErrors, .noWarnings, .noBlankNodes,
            .noNetworkAccess, .noImpliedElements
        ] as ParseOptions

        guard let handle = input.withCString({ (cString) in
            XML2.shared.htmlReadMemory(cString, Int32(strlen(cString)), nil, "UTF-8", options.rawValue)
        }) else { return nil }

        self.handle = handle
    }

    deinit {
        XML2.shared.docFree(handle)
    }

}

extension HTMLDocument {

    /// Parses the HTML contents of a string source, such as "<p>Hello.</p>"
    public static func parse<Input>(_ input: Input) -> Node? where Input: StringProtocol {
        return HTMLDocument(parsing: input)?.root
    }

    /// Parses the HTML contents of an escaped string source, such as "&lt;p&gt;Hello.&lt;/p&gt;".
    public static func parseFragment<Input>(_ input: Input) -> Node? where Input: StringProtocol {
        guard let document = HTMLDocument(parsing: "<html><body>\(input)"),
            let textNode = document.root?.first?.first, textNode.kind == .text,
            let rootNode = parse("<root>\(textNode.content)") else { return nil }

        if let onlyChild = rootNode.first, rootNode.dropFirst().isEmpty {
            return onlyChild
        } else if let fragment = XML2.shared.docAddFragment(rootNode.document.handle) {
            for child in rootNode {
                XML2.shared.nodeUnlink(child.handle)
                XML2.shared.nodeAddChild(fragment, child.handle)
            }
            return Node(document: rootNode.document, handle: fragment)
        } else {
            return nil
        }
    }

    /// The root node of the receiver.
    public var root: Node? {
        guard let rootHandle = XML2.shared.docGetRootElement(handle) else { return nil }
        return Node(document: self, handle: rootHandle)
    }

}

// MARK: - Node

extension HTMLDocument.Node {

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
        guard let pointer = handle.load(fromByteOffset: MemoryLayout<Int>.stride * 2, as: UnsafePointer<CChar>?.self) else { return "" }
        return String(cString: pointer)
    }

    /// If the node is a text node, the text carried directly by the node.
    /// Otherwise, the aggregrate string of the values carried by this node.
    public var content: String {
        guard let buffer = XML2.shared.nodeCopyContent(handle) else { return "" }
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

extension HTMLDocument.Node: Collection {

    fileprivate enum IndexVariant: Equatable {
        case valid(UnsafeRawPointer, offset: Int)
        case invalid
    }

    public var startIndex: Index {
        // xmlNodePtr->children
        guard let firstHandle = handle.load(fromByteOffset: MemoryLayout<Int>.stride * 3, as: UnsafeRawPointer?.self) else { return Index(variant: .invalid) }
        return Index(variant: .valid(firstHandle, offset: 0))
    }

    public var endIndex: Index {
        return Index(variant: .invalid)
    }

    public subscript(position: Index) -> HTMLDocument.Node {
        guard case .valid(let handle, _) = position.variant else { preconditionFailure("Index out of bounds") }
        return HTMLDocument.Node(document: document, handle: handle)
    }

    public func index(after position: Index) -> Index {
        // xmlNodePtr->next
        guard case .valid(let handle, let offset) = position.variant,
            let nextHandle = handle.load(fromByteOffset: MemoryLayout<Int>.stride * 6, as: UnsafeRawPointer?.self) else { return Index(variant: .invalid) }
        let nextOffset = offset + 1
        return Index(variant: .valid(nextHandle, offset: nextOffset))
    }

}

extension HTMLDocument.Node: CustomDebugStringConvertible {

    public var debugDescription: String {
        let buffer = XML2.shared.bufferCreate()
        defer { XML2.shared.bufferFree(buffer) }

        _ = XML2.shared.htmlNodeDump(buffer, document.handle, handle)
        return String(cString: XML2.shared.bufferGetContent(buffer))
    }

}

extension HTMLDocument.Node: CustomReflectable {

    public var customMirror: Mirror {
        // Always use the debugDescription for `po`, none of this "▿" stuff.
        return Mirror(self, unlabeledChildren: self, displayStyle: .struct)
    }

}

// MARK: - Node Index


extension HTMLDocument.Node.Index: Comparable {

    public static func == (lhs: HTMLDocument.Node.Index, rhs: HTMLDocument.Node.Index) -> Bool {
        return lhs.variant == rhs.variant
    }

    public static func < (lhs: HTMLDocument.Node.Index, rhs: HTMLDocument.Node.Index) -> Bool {
        switch (lhs.variant, rhs.variant) {
        case (.valid(_, let lhs), .valid(_, let rhs)):
            return lhs < rhs
        case (.valid, .invalid):
            return true
        default:
            return false
        }
    }

}
