import UIKit

// The view controller that displays the neurons and weights of a neural network
public class TrainViewController : UIViewController {
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        let view = UIView()
        view.backgroundColor = .black
        
        // Set the view to be active in the current view controller
        self.view = view
    }
}
