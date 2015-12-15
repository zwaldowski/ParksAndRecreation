extension Data {
    
    // FIXME: Figure out a better way to copy this in from UnicodeUtilities.
    // Data isn't safe to index (and thus can't be CollectionType), but can
    // be iterated without being consumed.
    public func decode<Encoding: UnicodeCodecType where Encoding.CodeUnit == T>(encoding: Encoding.Type, repairIllFormedSequences: Bool = false, minimumCapacity: Int = 0) -> String? {
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
