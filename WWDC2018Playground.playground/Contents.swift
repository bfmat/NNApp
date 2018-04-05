//: A Swift Playground designed to teach people about neural networks and allow them to experiment with training and inference

import UIKit
import PlaygroundSupport

// The view controller that contains the neural network and related controls
private class MainViewController : UIViewController {
    
    // The amount of space in points to be left around UI elements
    private let uiSpacing: CGFloat = 10
    // The neural network view controller that will take up much of the main view
    private let neuralNetworkViewController = NeuralNetworkViewController()
    // The segmented control that allows the user to choose between training and testing modes
    private let modeSegmentedControl = UISegmentedControl(items: ["Train", "Test"])
    // The mode-specific views that are displayed below the dataset selection view and display settings and information for training and testing
    private let trainViewController: TrainViewController
    private let testViewController = TestViewController()
    
    // Initialize the train view controller, which requires a reference to the neural network view controller
    init() {
        trainViewController = TrainViewController(neuralNetworkViewController: neuralNetworkViewController)
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required storyboard initializer that simply calls the main initializer
    required convenience init(coder _: NSCoder) {
        self.init()
    }
    
    // Run when the view is loaded
    override func loadView() {
        // Create the view and set its size and background color
        view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .white
        
        // Add the neural network view to the current view
        let neuralNetworkView = neuralNetworkViewController.view!
        view.addSubview(neuralNetworkViewController.view)
        // Anchor the neural network view to the top of the screen, and leave space at the bottom of the screen for other controls
        neuralNetworkView.topAnchor.constraint(equalTo: view.topAnchor, constant: uiSpacing).isActive = true
        neuralNetworkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300).isActive = true

        // Locate the segmented control below the neural network view
        view.addSubview(modeSegmentedControl)
        modeSegmentedControl.topAnchor.constraint(equalTo: neuralNetworkView.bottomAnchor, constant: uiSpacing).isActive = true
        // Set train as the default option
        modeSegmentedControl.selectedSegmentIndex = 0
        // Register the mode update function to be run when the mode is changed
        modeSegmentedControl.addTarget(self, action: #selector(onModeUpdate), for: .valueChanged)
        
        // Both the train and test views should be below the mode selector
        for viewController in [trainViewController, testViewController] {
            let subview = viewController.view!
            view.addSubview(subview)
            subview.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: uiSpacing).isActive = true
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -uiSpacing).isActive = true
        }
        
        // All subviews should be centered; enable autoresizing to constraints and set constraints to the sides of the screen
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: uiSpacing).isActive = true
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -uiSpacing).isActive = true
        }
        
        // Update the mode immediately so that the train view is loaded by default
        onModeUpdate()
    }
    
    // Called when the mode segmented control is updated
    @objc private func onModeUpdate() {
        // Convert the integer index to a Boolean representing whether or not we are in test mode
        let inTestMode = modeSegmentedControl.selectedSegmentIndex != 0
        // Enable or disable the train and test views accordingly
        trainViewController.view.isHidden = inTestMode
        testViewController.view.isHidden = !inTestMode
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MainViewController()
