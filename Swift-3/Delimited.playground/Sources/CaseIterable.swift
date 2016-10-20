/// A type (usually an enum) whose static members have a strict ordering.
public protocol CaseIterable: Hashable {

    /// An ordered traversal of the cases in the type.
    associatedtype List: Sequence = AnySequence<Self>

    /// A getter for the ordered cases of this type.
    static var all: Self.List { get }

    associatedtype Count: SignedInteger = Int

    /// The number of elements in `all`.
    static var count: Count { get }

}

extension CaseIterable where List: Collection, Count == List.IndexDistance {

    public static var count: List.IndexDistance {
        return all.count
    }

}

extension CaseIterable where Self: RawRepresentable, Self.RawValue: Strideable {

    public func distance(to other: Self) -> RawValue.Stride {
        return rawValue.distance(to: other.rawValue)
    }

    public func advanced(by n: RawValue.Stride) -> Self {
        return Self(rawValue: rawValue.advanced(by: n))!
    }
    
}
