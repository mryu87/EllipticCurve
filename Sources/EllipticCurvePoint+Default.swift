//

import Foundation

extension EllipticCurvePoint {

    public static var Infinity: Self {
        get {
            return Self(isInfinity: true)
        }
    }

    public var isInfinity: Bool {
        get {
            return y == nil
        }
    }

    public var description: String {
        guard y != nil else {
            return "Point Infinity"
        }

        return "Point (\(x), \(y!)) on Curve y^2 = x^3 + \(Self.a)*x + \(Self.b)"
    }

    public static func verifyEquation(forPoint point: Self) -> Bool {
        if point.y == nil {
            return false
        }
        let lhs: NumericType = point.y! * point.y!
        let rhs: NumericType = point.x * point.x * point.x + Self.a * point.x + Self.b

        return lhs == rhs
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        if lhs.y == nil {
            return rhs.y == nil
        }
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public static func +(lhs: Self, rhs: Self) -> Self {
        if lhs.y == nil {
            return rhs
        }
        if rhs.y == nil {
            return lhs
        }
        if lhs.x == rhs.x && lhs.y != rhs.y {
            return Self(isInfinity: true)
        }

        let s: NumericType

        // when two points are the same point on the curve
        // we need to calculate the tangiential, and use it
        // as the slope
        if lhs == rhs {
            s = (3 * (lhs.x * lhs.x) + Self.a) / (2 * lhs.y!)
        } else {
            s = (rhs.y! - lhs.y!) / (rhs.x - lhs.x)
        }

        let newX = s * s - lhs.x - rhs.x
        let newY = s * (lhs.x - newX) - lhs.y!

        return Self(x: newX, y: newY)
    }

    public static func *<T>(lhs: T, rhs: Self) -> Self where T: FixedWidthInteger {
        var coefficient = lhs
        let bitLength = coefficient.bitWidth - coefficient.leadingZeroBitCount
        var partialCoefficient: T = 1
        var partialResult: Self = rhs
        var trail: [(T, Self)] = []

        for _ in 0..<bitLength {
            trail.append((partialCoefficient, partialResult))
            partialCoefficient <<= 1
            partialResult = partialResult + partialResult
        }

        var result = Self.Infinity

        for (coef, res) in trail.reversed() {
            if coefficient >= coef {
                coefficient = coefficient - coef
                result = result + res
            }
        }

        return result
    }
}
