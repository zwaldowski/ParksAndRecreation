/// A codec for [UTF-16](http://www.unicode.org/glossary/#UTF_16) that does
/// byte-swapping to or from Little Endian if necessary.
public struct UTF16LE: UnicodeCodecType {
    
    private var codec = UTF16()
    
    public init() { }
    
    /// Start or continue decoding a UTF sequence.
    ///
    /// In order to decode a code unit sequence completely, this function should
    /// be called repeatedly until it returns `UnicodeDecodingResult.EmptyInput`.
    /// Checking that the generator was exhausted is not sufficient.  The decoder
    /// can have an internal buffer that is pre-filled with data from the input
    /// generator.
    ///
    /// Because of buffering, it is impossible to find the corresponing position
    /// in the generator for a given returned `UnicodeScalar` or an error.
    ///
    /// - parameter next: A *generator* of code units to be decoded.
    public mutating func decode<G : GeneratorType where G.Element == UTF16.CodeUnit>(inout input: G) -> UnicodeDecodingResult {
        var wrappedGenerator = anyGenerator {
            input.next().map { UTF16.CodeUnit(littleEndian: $0) }
        }
        return codec.decode(&wrappedGenerator)
    }
    
    /// Encode a `UnicodeScalar` as a series of `CodeUnit`s by
    /// `put`'ing each `CodeUnit` to `output`.
    public static func encode(input: UnicodeScalar, output: UTF16.CodeUnit -> ()) {
        UTF16.encode(input) { output($0.littleEndian) }
    }
    
}

/// A codec for [UTF-16](http://www.unicode.org/glossary/#UTF_16) that does
/// byte-swapping to or from Big Endian if necessary.
public struct UTF16BE: UnicodeCodecType {
    
    private var codec = UTF16()
    
    public init() { }
    
    /// Start or continue decoding a UTF sequence.
    ///
    /// In order to decode a code unit sequence completely, this function should
    /// be called repeatedly until it returns `UnicodeDecodingResult.EmptyInput`.
    /// Checking that the generator was exhausted is not sufficient.  The decoder
    /// can have an internal buffer that is pre-filled with data from the input
    /// generator.
    ///
    /// Because of buffering, it is impossible to find the corresponing position
    /// in the generator for a given returned `UnicodeScalar` or an error.
    ///
    /// - parameter next: A *generator* of code units to be decoded.
    public mutating func decode<G : GeneratorType where G.Element == UTF16.CodeUnit>(inout input: G) -> UnicodeDecodingResult {
        var wrappedGenerator = anyGenerator {
            input.next().map { UTF16.CodeUnit(bigEndian: $0) }
        }
        return codec.decode(&wrappedGenerator)
    }
    
    /// Encode a `UnicodeScalar` as a series of `CodeUnit`s by
    /// `put`'ing each `CodeUnit` to `output`.
    public static func encode(input: UnicodeScalar, output: UTF16.CodeUnit -> ()) {
        UTF16.encode(input) { output($0.bigEndian) }
    }
    
}

/// A codec for [UTF-32](http://www.unicode.org/glossary/#UTF_32) that does
/// byte-swapping to or from Little Endian if necessary.
public struct UTF32LE: UnicodeCodecType {
    
    private var codec = UTF32()

    public init() { }
    
    /// Start or continue decoding a UTF sequence.
    ///
    /// In order to decode a code unit sequence completely, this function should
    /// be called repeatedly until it returns `UnicodeDecodingResult.EmptyInput`.
    /// Checking that the generator was exhausted is not sufficient.  The decoder
    /// can have an internal buffer that is pre-filled with data from the input
    /// generator.
    ///
    /// Because of buffering, it is impossible to find the corresponing position
    /// in the generator for a given returned `UnicodeScalar` or an error.
    ///
    /// - parameter next: A *generator* of code units to be decoded.
    public mutating func decode<G : GeneratorType where G.Element == UTF32.CodeUnit>(inout input: G) -> UnicodeDecodingResult {
        var wrappedGenerator = anyGenerator {
            input.next().map { UTF32.CodeUnit(littleEndian: $0) }
        }
        return codec.decode(&wrappedGenerator)
    }
    
    /// Encode a `UnicodeScalar` as a series of `CodeUnit`s by
    /// `put`'ing each `CodeUnit` to `output`.
    public static func encode(input: UnicodeScalar, output: UTF32.CodeUnit -> ()) {
        UTF32.encode(input) { output($0.littleEndian) }
    }
    
}

/// A codec for [UTF-32](http://www.unicode.org/glossary/#UTF_32) that does
/// byte-swapping to or from Big Endian if necessary.
public struct UTF32BE: UnicodeCodecType {
    
    private var codec = UTF32()
    
    public init() { }
    
    /// Start or continue decoding a UTF sequence.
    ///
    /// In order to decode a code unit sequence completely, this function should
    /// be called repeatedly until it returns `UnicodeDecodingResult.EmptyInput`.
    /// Checking that the generator was exhausted is not sufficient.  The decoder
    /// can have an internal buffer that is pre-filled with data from the input
    /// generator.
    ///
    /// Because of buffering, it is impossible to find the corresponing position
    /// in the generator for a given returned `UnicodeScalar` or an error.
    ///
    /// - parameter next: A *generator* of code units to be decoded.
    public mutating func decode<G : GeneratorType where G.Element == UTF32.CodeUnit>(inout input: G) -> UnicodeDecodingResult {
        var wrappedGenerator = anyGenerator {
            input.next().map { UTF32.CodeUnit(bigEndian: $0) }
        }
        return codec.decode(&wrappedGenerator)
    }
    
    /// Encode a `UnicodeScalar` as a series of `CodeUnit`s by
    /// `put`'ing each `CodeUnit` to `output`.
    public static func encode(input: UnicodeScalar, output: UTF32.CodeUnit -> ()) {
        UTF32.encode(input) { output($0.bigEndian) }
    }
    
}
