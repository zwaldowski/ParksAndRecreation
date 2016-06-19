
extension SequenceType where Generator.Element == UnicodeScalar {
    
    public func encode<Encoding: UnicodeCodecType>(encoding: Encoding.Type) -> [Encoding.CodeUnit] {
        var units = Array<Encoding.CodeUnit>()
        units.reserveCapacity(underestimateCount())
        for scalar in self {
            encoding.encode(scalar) { units.append($0) }
        }
        return units
    }
    
}

extension SequenceType where Generator.Element: UnsignedIntegerType {
    
    public func decode<Encoding: UnicodeCodecType where Encoding.CodeUnit == Generator.Element>(encoding: Encoding.Type, stopOnError: Bool = false, minimumCapacity: Int = 0) -> String? {
        // The `underestimateCount()` is just a best estimate; we can't
        // enumerate through the sequence using UTF16.measure.
        var scalars = String.UnicodeScalarView()
        scalars.reserveCapacity(max(underestimateCount(), minimumCapacity))

        transcode(encoding, UTF32.self, generate(), {
            scalars.append(UnicodeScalar($0))
        }, stopOnError: stopOnError)
        
        return String(scalars)
    }
    
}

// multi-pass generators
extension SequenceType where Generator: SequenceType, Generator.Element: UnsignedIntegerType {

    // h/t Swift stdlib: https://github.com/apple/swift/blob/master/stdlib/public/core/StringBuffer.swift
    public func decode<Encoding: UnicodeCodecType where Encoding.CodeUnit == Generator.Element>(encoding: Encoding.Type, repairIllFormedSequences: Bool = false, minimumCapacity: Int = 0) -> String? {
        guard let (utf16Count, isAscii) = UTF16.measure(encoding, input: generate(), repairIllFormedSequences: repairIllFormedSequences) else {
            return nil
        }
        
        var scalars = String.UnicodeScalarView()
        scalars.reserveCapacity(max(utf16Count, minimumCapacity))
        
        transcode(encoding, UTF32.self, generate(), {
            scalars.append(UnicodeScalar($0))
        }, stopOnError: isAscii || !repairIllFormedSequences)
        
        return String(scalars)
    }
    
}