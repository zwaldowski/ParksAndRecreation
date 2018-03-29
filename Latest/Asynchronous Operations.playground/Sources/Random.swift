// Modeled after SE-0202: https://github.com/apple/swift/pull/12772

import Darwin

extension UnsignedInteger where Self: FixedWidthInteger {

    public static func random(upperBound: Self) -> Self {
        let max = Self.max % upperBound
        var random: Self = 0

        repeat {
            arc4random_buf(&random, MemoryLayout<Self>.size)
        } while random < max

        return random % upperBound
    }

}

extension Range where Bound: BinaryFloatingPoint, Bound.RawSignificand: FixedWidthInteger {

    public func random() -> Bound {
        precondition(lowerBound != upperBound)
        let delta = upperBound - lowerBound
        let randomBitPattern = Bound.RawSignificand.random(upperBound: 1 << Bound.significandBitCount)
        let unitRandom = Bound(sign: .plus, exponentBitPattern: (1 as Bound).exponentBitPattern, significandBitPattern: randomBitPattern) - 1
        return delta * unitRandom + lowerBound
    }

}
