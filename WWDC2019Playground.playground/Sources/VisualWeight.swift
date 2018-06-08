import UIKit

// A shape layer that displays a line representing a weight in the neural network
class VisualWeight : CAShapeLayer {
    
    // Fade in the weight, provided two endpoints
    init(from startPoint: CGPoint, to endPoint: CGPoint, fadeDuration: TimeInterval) {
        // Call the superclass initializer, leaving everything default
        super.init()
        // Create a path from the start point to the end point
        let bezierPath = UIBezierPath()
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: endPoint)
        // Turn this path into a shape layer that can be drawn
        path = bezierPath.cgPath
        strokeColor = UIColor.black.cgColor
        fillColor = UIColor.black.cgColor
        lineWidth = 3
        // Animate the opacity of this layer from 0 to 1 over the provided duration
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0
        fadeAnimation.duration = fadeDuration
        add(fadeAnimation, forKey: "fadeIn")
        opacity = 1
    }
    
    // Required initializer that sets both points to (0, 0), fading in immediately
    required convenience init(coder: NSCoder) {
        self.init(from: CGPoint.zero, to: CGPoint.zero, fadeDuration: 0)
    }
    
    // Necessary initializer inherited from CALayer which calls the superclass initializer
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    // Fade out this weight over a provided period of time, destroying it afterwards
    func fadeOut(withDuration duration: TimeInterval) {
        // Animate the opacity of this layer to 0 over the provided duration
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue = 0
        fadeAnimation.duration = duration
        add(fadeAnimation, forKey: "fadeOut")
        // Destroy this view after the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: removeFromSuperlayer)
    }
    
    // Set the color of this weight according to a numeric strength value
    func setStrength(_ value: Float) {
        // Calculate the hyperbolic tangent of the value, shifting it up by 1 if it is less than 0 so it can be used in colors
        let hyperbolicTangent = tanh(CGFloat(value))
        let lessThanZero = hyperbolicTangent < 0
        let interpolationDistance = lessThanZero ? hyperbolicTangent + 1 : hyperbolicTangent
        // If the original value was less than 0, linearly interpolate the stroke and fill colors between red and green; otherwise, between green and blue
        let inverseInterpolationDistance = 1 - interpolationDistance
        let uiColor = lessThanZero ? UIColor(red: inverseInterpolationDistance, green: interpolationDistance, blue: 0, alpha: 1) : UIColor(red: 0, green: inverseInterpolationDistance, blue: interpolationDistance, alpha: 1)
        let cgColor = uiColor.cgColor
        fillColor = cgColor
        strokeColor = cgColor
    }
}
