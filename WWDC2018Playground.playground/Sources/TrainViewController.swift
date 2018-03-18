import UIKit

// The view controller that displays the options that can be used while training a neural network
public class TrainViewController : UIViewController {
    
    // The width and height of the title labels
    private let titleWidth: CGFloat = 120
    private let titleHeight: CGFloat = 30
    // The maximum and minimum exponents of 10 represented on the learning rate slider
    private let minLearningRateExponent: Float = -5
    private let maxLearningRateExponent: Float = -2
    
    // The text field that is used to input the number of epochs to train for
    private let epochsField = UITextField()
    // The slider that is used to input the learning rate
    private let learningRateSlider = UISlider()
    // The label that displays the selected learning rate
    private let learningRateLabel = UILabel()
    // The button that is tapped to initiate the training process, and displays the number of epochs completed
    private let trainButton = UIButton()
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        view = UIView()
        view.backgroundColor = .white
        
        // Configure the text field for inputting the number of epochs, so that it only takes numeric input
        epochsField.keyboardType = .numberPad
        view.addSubview(epochsField)
        // Configure the learning rate slider with the learning rate exponents
        learningRateSlider.minimumValue = minLearningRateExponent
        learningRateSlider.maximumValue = maxLearningRateExponent
        view.addSubview(learningRateSlider)
        // Create title labels for the epochs and learning rate inputs
        let epochsTitle = UILabel()
        epochsTitle.text = "Epochs:"
        view.addSubview(epochsTitle)
        let learningRateTitle = UILabel()
        learningRateTitle.text = "Learning rate:"
        view.addSubview(learningRateTitle)
        
        // Align the epochs title and text field with the top of the view
        for element in [epochsTitle, epochsField] as [UIView] {
            element.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            element.bottomAnchor.constraint(equalTo: view.topAnchor, constant: titleHeight).isActive = true
        }
        // Place the learning rate title and slider below them
        for element in [learningRateTitle, learningRateSlider] as [UIView] {
            element.topAnchor.constraint(equalTo: epochsTitle.bottomAnchor).isActive = true
            element.bottomAnchor.constraint(equalTo: epochsTitle.bottomAnchor, constant: titleHeight).isActive = true
        }
        // Align both titles and input views against the left edge, with their right edge a predefined distance away
        for title in [epochsTitle, learningRateTitle] {
            title.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            title.rightAnchor.constraint(equalTo: view.leftAnchor, constant: titleWidth).isActive = true
        }
        // Align both inputs against the right edge of the titles, and against the right edge of the view
        for input in [epochsField, learningRateSlider] as [UIView] {
            input.leftAnchor.constraint(equalTo: epochsTitle.rightAnchor).isActive = true
            input.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
        
        // Configure all subviews to autoresize to constraints
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    public override func viewDidAppear(_: Bool) {
        print(learningRateSlider.frame.size)
        print(learningRateSlider.center)
    }
}
