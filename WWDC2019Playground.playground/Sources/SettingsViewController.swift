import UIKit

// The view controller that displays the options that can be used while training a neural network
public class SettingsViewController : UIViewController {
    
    // The width and height of the title labels
    private let titleWidth: CGFloat = 120
    private let titleHeight: CGFloat = 30
    // The minimum and maximum numbers of epochs for training
    private let minEpochs: Float = 10
    private let maxEpochs: Float = 1000
    // The maximum and minimum exponents of 10 represented on the learning rate slider
    private let minLearningRateExponent: Float = -5
    private let maxLearningRateExponent: Float = -2
    
    // The view controller that handles selection of the dataset used for training and testing
    private var datasetSelectionViewController: DatasetSelectionViewController!
    // The labels that show the selected number of epochs, and the learning rate
    private let epochsLabel = UILabel()
    private let learningRateLabel = UILabel()
    // The sliders that are used to input the number of epochs to train for, and the learning rate
    private let epochsSlider = UISlider()
    private let learningRateSlider = UISlider()
    // The button that is used to initiate the training process
    private let trainButton = UIButton(type: .roundedRect)
    // The button that is used to open the architecture adjustment view
    public let architectureButton = UIButton(type: .roundedRect)
    
    // A reference to the neural network view controller, so training can be initiated and monitored
    private let neuralNetworkViewController: NeuralNetworkViewController!
    // A reference to the function that toggles the visibility of the settings and information views
    private let toggleSettingsOrInformation: (() -> Void)!
    
    // A flag that is only true after the dataset is set during initialization
    private var datasetInitiallySet = false
    
    // The main initializer, which sets the global references to the neural network view controller, architecture adjustment view controller, and the toggle function
    public init(neuralNetworkViewController: NeuralNetworkViewController, toggleSettingsOrInformation: @escaping () -> Void) {
        self.neuralNetworkViewController = neuralNetworkViewController
        self.toggleSettingsOrInformation = toggleSettingsOrInformation
        super.init(nibName: nil, bundle: nil)
    }
    
    // A storyboard initializer that sets the view controllers and toggle function to nil
    public required init?(coder _: NSCoder) {
        neuralNetworkViewController = nil
        toggleSettingsOrInformation = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        view = UIView()
        view.backgroundColor = .white
        
        // The dataset selector needs to be able to change the variable in the neural network view controller; when it does, it should also enable the training button
        datasetSelectionViewController = DatasetSelectionViewController { dataset in
            // The first time this is run, it should set the flag to true but not enable the training button
            if !self.datasetInitiallySet {
                self.datasetInitiallySet = true
            }
            // Otherwise, it should enable the training button
            else {
                self.trainButton.isEnabled = true
            }
            // Either way, configure the dataset
            self.neuralNetworkViewController.setDataset(dataset)
        }
        // Configure the epochs slider with a linear value
        epochsSlider.minimumValue = minEpochs
        epochsSlider.maximumValue = maxEpochs
        // Configure the learning rate slider with the learning rate exponents
        learningRateSlider.minimumValue = minLearningRateExponent
        learningRateSlider.maximumValue = maxLearningRateExponent
        // Update the labels when the sliders are changed
        epochsSlider.addTarget(self, action: #selector(updateEpochsLabel), for: .valueChanged)
        learningRateSlider.addTarget(self, action: #selector(updateLearningRateLabel), for: .valueChanged)
        // Configure the training button, disabled by default
        trainButton.setTitle("Start Training", for: .normal)
        trainButton.setTitle("Please Select a Dataset to Start Training", for: .disabled)
        trainButton.isEnabled = false
        trainButton.addTarget(self, action: #selector(startTraining), for: .touchUpInside)
        // Set the title of the architecture adjustment button
        architectureButton.setTitle("Change Network Architecture", for: .normal)
        
        // Iterate over all UI elements that should be stacked, creating an accumulator to hold the bottom anchor of the view above
        var lastVerticalAnchor = view.topAnchor
        for element in [datasetSelectionViewController.view!, architectureButton, epochsLabel, epochsSlider, learningRateLabel, learningRateSlider, trainButton] {
            // Add the element to the view
            view.addSubview(element)
            // Constrain the current element to stack against the last anchor, and extend a predefined distance below it
            element.topAnchor.constraint(equalTo: lastVerticalAnchor).isActive = true
            element.bottomAnchor.constraint(equalTo: lastVerticalAnchor, constant: titleHeight).isActive = true
            // Set the last bottom anchor to this element's bottom anchor, so it can be used on the next iteration
            lastVerticalAnchor = element.bottomAnchor
            // Constrain the current element horizontally to both sides of the view
            element.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            element.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            // Configure it to autoresize to constraints
            element.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // Accessor for the number of epochs, as an integer
    private var epochs: Int {
        return Int(epochsSlider.value)
    }
    // Accessor for the base 10 exponentiated learning rate value
    private var learningRate: Float {
        return pow(10, learningRateSlider.value)
    }
    
    // Functions which will update the text in the labels based on the values of the sliders
    @objc private func updateEpochsLabel() {
        epochsLabel.text = "Epochs: \(epochs)"
    }
    @objc private func updateLearningRateLabel() {
        learningRateLabel.text = "Learning rate: \(learningRate)"
    }
    
    // Run when the train button is pressed
    @objc private func startTraining() {
        // Run training in a background thread so it does not lock up the user interface
        DispatchQueue.global(qos: .utility).async {
            // Train the neural network with the selected number of epochs and learning rate, iterating over it to get diagnostic data
            for diagnosticData in self.neuralNetworkViewController.train(epochs: self.epochs, learningRate: self.learningRate) {
                // Output the epoch number (temporary)
                print("Epoch: \(diagnosticData)")
            }
        }
        // Toggle the activity of this view, switching to the information view
        toggleSettingsOrInformation()
    }
}
