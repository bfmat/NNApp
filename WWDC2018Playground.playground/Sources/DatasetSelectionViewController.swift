import UIKit

// The view controller that displays the neurons and weights of a neural network
public class DatasetSelectionViewController : UIViewController {
    
    // The text box and corresponding picker view that allows the user to select which dataset to train or test the network with
    private let datasetTextBox = UITextField()
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        let view = UIView()
        view.backgroundColor = .white
        
        // A label should take up the left part of the view
        let label = UILabel()
        view.addSubview(label)
        label.text = "Dataset: "
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70).isActive = true
        
        // The dataset text box should take up the right part of the view
        view.addSubview(datasetTextBox)
        datasetTextBox.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        datasetTextBox.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        datasetTextBox.borderStyle = .roundedRect
        
        // Create a picker view and use it as the input view for the text box
        let datasetPickerView = UIPickerView()
        datasetTextBox.inputView = datasetPickerView
        
        // Both elements should be aligned with the top and bottom of the view
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        // Set the view to be active in the current view controller
        self.view = view
    }
}
