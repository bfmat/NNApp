import UIKit

// A circular view that represents a neuron in the network, managing its weights when its position is changed
class VisualNeuron : UIView {
    
    // Fade in the neuron provided a center position
    init(at centerPosition: CGPoint, radius: CGFloat, fadeDuration: TimeInterval) {
        // Calculate the size of the neuron
        let diameter = radius * 2
        let size = CGSize(width: diameter, height: diameter)
        // Get the position of the top left corner by offsetting the center position by half of the size
        let cornerPosition = CGPoint(x: centerPosition.x - (size.width / 2), y: centerPosition.y - size.height / 2)
        // Initialize the superclass with the computed size and position
        super.init(frame: CGRect(origin: cornerPosition, size: size))
        // Set the rounded corner radius to the radius of the neuron, so that it is actually a circle
        layer.cornerRadius = CGFloat(radius)
        // Set the color of the neuron to black (temporary)
        backgroundColor = .black
        // Set the opacity to 0 initially
        alpha = 0
        // Fade the opacity to 1 over the provided duration
        UIView.animate(withDuration: fadeDuration) {
            self.alpha = 1
        }
    }
    
    // Required initializer that sets the position on both axes and radius to 0, fading in immediately
    required convenience init(coder: NSCoder) {
        self.init(at: CGPoint.zero, radius: 0, fadeDuration: 0)
    }
    
    // Move this neuron to a position over a period of time
    func move(to position: CGPoint, withDuration duration: TimeInterval) {
        // Move the center of this view to the provided position over the provided duration
        UIView.animate(withDuration: duration) {
            self.center = position
        }
    }
    
    // Fade out this neuron over a provided period of time, destroying it afterwards
    func fadeOut(withDuration duration: TimeInterval) {
        // Gradually decrease the opacity of this view to 0 over the provided duration
        UIView.animate(withDuration: duration) {
            self.alpha = 0
        }
        // Destroy this view after the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.removeFromSuperview()
        }
    }
}
