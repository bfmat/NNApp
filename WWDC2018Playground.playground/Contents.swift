//: A Swift Playground designed to teach people about neural networks and allow them to experiment with training and inference

import UIKit
import PlaygroundSupport

// The amount of space in points to be left around UI elements
private let uiSpacing: CGFloat = 10

// The view controller that contains the neural network and related controls
private class MainViewController : UIViewController {
    
    // The neural network view controller that will take up much of the main view
    private let neuralNetworkViewController = NeuralNetworkViewController()
    // The segmented control that allows the user to choose between training and testing modes
    private let modeSegmentedControl = UISegmentedControl(items: ["Train", "Test"])
    // The view controller that handles selection of the dataset used for training and testing
    private var datasetSelectionViewController: DatasetSelectionViewController!
    // The mode-specific views that are displayed below the dataset selection view and display settings and information for training and testing
    private let trainViewController = TrainViewController()
    private let testViewController = TestViewController()
    
    // Run when the view is loaded
    override func loadView() {
        // Create the view and set its size and background color
        let view = UIView()
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
        
        // The data selection view should be below the segmented control
        datasetSelectionViewController = DatasetSelectionViewController(setDataset: neuralNetworkViewController.setDataset)
        let datasetSelectionView = datasetSelectionViewController.view!
        view.addSubview(datasetSelectionView)
        datasetSelectionView.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: uiSpacing).isActive = true
        
        // Both the train and test views should be below the dataset selection view
        for viewController in [trainViewController, testViewController] {
            let subview = viewController.view!
            view.addSubview(subview)
            subview.topAnchor.constraint(equalTo: datasetSelectionView.bottomAnchor, constant: uiSpacing).isActive = true
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
        
        // Set the view to be active in the current view controller
        self.view = view
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
