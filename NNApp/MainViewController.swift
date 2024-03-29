//
//  ViewController.swift
//  NNApp
//
//  Created by Brendon Matusch on 2019-07-05.
//  Copyright © 2019 Brendon Matusch. All rights reserved.
//

import UIKit

// The view controller that contains the neural network and related controls
class MainViewController : UIViewController {
    
    // The amount of space in points to be left around UI elements
    private let uiSpacing: CGFloat = 10
    // The neural network view controller that will take up much of the main view; provided an accessor for the network's hidden layers
    private lazy var neuralNetworkViewController = NeuralNetworkViewController(hiddenLayers: architectureAdjustmentViewController.hiddenLayers)
    // The mode-specific views that are displayed below the dataset selection view and display settings and information
    private let informationViewController = InformationViewController()
    private lazy var settingsViewController = SettingsViewController(neuralNetworkViewController: neuralNetworkViewController, toggleSettingsOrInformation: toggleSettingsOrInformation, setDiagnosticInformation: informationViewController.setDiagnosticInformation)
    // The view controller that is used to adjust the network's architecture
    private let architectureAdjustmentViewController = ArchitectureAdjustmentViewController()
    
    // Blank initializer that calls up to the superclass
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required storyboard initializer that calls the main initializer
    required convenience init(coder _: NSCoder) {
        self.init()
    }
    
    // Run to create the main view
    override func loadView() {
        // Create the view and set its size and background color
        view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .white
    }
    
    // Run after the view is created to set up the UI
    override func viewDidLoad() {
        // Add the neural network view to the current view
        let neuralNetworkView = neuralNetworkViewController.view!
        view.addSubview(neuralNetworkView)
        // Anchor the neural network view to the top of the screen, and leave space at the bottom of the screen for other controls
        neuralNetworkView.topAnchor.constraint(equalTo: view.topAnchor, constant: uiSpacing).isActive = true
        neuralNetworkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300).isActive = true
        
        // Both the settings and information views should be below the neural network view
        for viewController in [settingsViewController, informationViewController] {
            let subview = viewController.view!
            view.addSubview(subview)
            subview.topAnchor.constraint(equalTo: neuralNetworkView.bottomAnchor, constant: uiSpacing).isActive = true
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -uiSpacing).isActive = true
        }
        // The information view should be hidden by default
        informationViewController.view.isHidden = true
        
        // All subviews should be centered; enable autoresizing to constraints and set constraints to the sides of the screen
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: uiSpacing).isActive = true
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -uiSpacing).isActive = true
        }
        
        // Register the architecture adjustment button
        settingsViewController.architectureButton.addTarget(self, action: #selector(presentArchitectureAdjustmentView), for: .touchUpInside)
    }
    
    // Called to switch between the settings and information view controllers
    private func toggleSettingsOrInformation() {
        // One of the two should always be hidden; switch which one it is
        let settingsViewHidden = settingsViewController.view.isHidden
        settingsViewController.view.isHidden = !settingsViewHidden
        informationViewController.view.isHidden = settingsViewHidden
    }
    
    // Called to modally present the architecture adjustment view
    @objc func presentArchitectureAdjustmentView() {
        present(architectureAdjustmentViewController, animated: true, completion: nil)
    }
}
