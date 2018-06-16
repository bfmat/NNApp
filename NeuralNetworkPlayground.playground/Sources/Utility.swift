import UIKit

// Given a floating-point number over the range of all real numbers, interpolate between red and blue on a hyperbolic tangent curve
func interpolateRedToBlue(_ value: Float) -> UIColor {
    // Calculate the hyperbolic tangent of the value, shifting it up by 1 if it is less than 0 so it can be used in colors
    let hyperbolicTangent = tanh(CGFloat(value))
    let lessThanZero = hyperbolicTangent < 0
    let interpolationDistance = lessThanZero ? hyperbolicTangent + 1 : hyperbolicTangent
    // If the original value was less than 0, linearly interpolate the stroke and fill colors between red and green; otherwise, between green and blue
    let inverseInterpolationDistance = 1 - interpolationDistance
    return lessThanZero ? UIColor(red: inverseInterpolationDistance, green: interpolationDistance, blue: 0, alpha: 1) : UIColor(red: 0, green: inverseInterpolationDistance, blue: interpolationDistance, alpha: 1)
}
