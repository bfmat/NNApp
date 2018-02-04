import UIKit

// The view controller that displays the neurons and weights of a neural network
public class DatasetSelectionViewController : UIViewController {
    
    // The text box and corresponding picker view that allows the user to select which dataset to train or test the network with
    private let datasetTextBox = UITextField()
    private let datasetPickerView = UIPickerView()
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        let view = UIView()
        view.backgroundColor = .white
        
        // A label should take up the left part of the view
        let label = UILabel()
        label.text = "Dataset:"
        
        // The dataset text box should take up the right part of the view
        view.addSubview(datasetTextBox)
        datasetTextBox.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        print(datasetTextBox.bounds)
        datasetTextBox.borderStyle = .roundedRect
        // Use the picker view as the input view for the text box
        datasetTextBox.inputView = datasetPickerView
        
        // Set the view to be active in the current view controller
        self.view = view
    }
}
