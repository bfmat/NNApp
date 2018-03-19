import UIKit

// The view controller that displays the options that can be used while training a neural network
public class TrainViewController : UIViewController {
    
    // The width and height of the title labels
    private let titleWidth: CGFloat = 120
    private let titleHeight: CGFloat = 30
    // The minimum and maximum numbers of epochs for training
    private let minEpochs: Float = 10
    private let maxEpochs: Float = 1000
    // The maximum and minimum exponents of 10 represented on the learning rate slider
    private let minLearningRateExponent: Float = -5
    private let maxLearningRateExponent: Float = -2
    
    // The labels that show the selected number of epochs, and the learning rate
    private let epochsLabel = UILabel()
    private let learningRateLabel = UILabel()
    // The sliders that are used to input the number of epochs to train for, and the learning rate
    private let epochsSlider = UISlider()
    private let learningRateSlider = UISlider()
    
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        view = UIView()
        view.backgroundColor = .white
        
        // Configure the epochs slider with a linear value
        epochsSlider.minimumValue = minEpochs
        epochsSlider.maximumValue = maxEpochs
        // Configure the learning rate slider with the learning rate exponents
        learningRateSlider.minimumValue = minLearningRateExponent
        learningRateSlider.maximumValue = maxLearningRateExponent
        // Update the labels when the sliders are changed
        epochsSlider.addTarget(self, action: #selector(updateEpochsLabel), for: .valueChanged)
        learningRateSlider.addTarget(self, action: #selector(updateLearningRateLabel), for: .valueChanged)
        // Configure the button that is tapped to initiate the training process
        let trainButton = UIButton(type: .roundedRect)
        trainButton.setTitle("Start Training", for: .normal)
        trainButton.addTarget(self, action: #selector(train), for: .touchUpInside)
        
        // Iterate over all UI elements that should be stacked, creating an accumulator to hold the bottom anchor of the view above
        var lastVerticalAnchor = view.topAnchor
        for element in [epochsLabel, epochsSlider, learningRateLabel, learningRateSlider, trainButton] {
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
    
    // Accessor for the base 10 exponentiated learning rate value
    private var learningRate: Float {
        return pow(10, learningRateSlider.value)
    }
    
    // Functions which will update the text in the labels based on the values of the sliders
    @objc private func updateEpochsLabel() {
        epochsLabel.text = "Epochs: \(epochsSlider.value)"
    }
    @objc private func updateLearningRateLabel() {
        learningRateLabel.text = "Epochs: \(learningRate)"
    }
    
    // Run when the train button is pressed
    @objc private func train() {
        print("train")
    }
}
