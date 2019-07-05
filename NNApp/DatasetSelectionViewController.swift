import UIKit

// The view controller that contains a text box that uses a picker view for input; it is used to select the dataset that will be used for training or testing
public class DatasetSelectionViewController : UIViewController {
    
    // The button that allows the user to select which dataset to train or test the network with
    private let datasetButton = UIButton(type: .system)
    // A function that sets the currently chosen dataset
    private let setDataset: (Dataset) -> Void
    
    // Initializer that accepts a function to set the current dataset
    public init(setDataset: @escaping (Dataset) -> Void) {
        self.setDataset = setDataset
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required initializer that puts in place a function that does nothing as the dataset setter
    public required convenience init(coder _: NSCoder) {
        self.init(setDataset: { _ in })
    }
    
    // Run when the view is loaded
    public override func loadView() {
        // Load all of the datasets into the array so they can be used
        Dataset.loadDatasets()
        
        // Create the view and set the background color
        view = UIView()
        view.backgroundColor = .white
        // The dataset button should take up the entire view
        view.addSubview(datasetButton)
        datasetButton.translatesAutoresizingMaskIntoConstraints = false
        datasetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        datasetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        datasetButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        datasetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        // Register the selection function to run when the button is pressed
        datasetButton.addTarget(self, action: #selector(selectDataset), for: UIControl.Event.touchUpInside)
        // Set the button's text, prompting the user to choose a dataset
        setButtonText("Choose a Dataset")
    }
    
    // Run after the view is displayed
    public override func viewDidAppear(_: Bool) {
        // Choose the first dataset by default
        setDataset(Dataset.datasets.first!)
    }
    
    // Run when the selection button is pressed
    @objc private func selectDataset() {
        // Create an alert controller that will display an action sheet
        let alertController = UIAlertController(title: "Choose a Dataset", message: nil, preferredStyle: .actionSheet)
        // Create a cancel action which will not change the dataset
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // For each of the available datasets
        for dataset in Dataset.datasets {
            // Add an action that sets the currently chosen dataset
            let action = UIAlertAction(title: dataset.description, style: .default) { _ in
                // Call the external function that sets the dataset
                self.setDataset(dataset)
                // Set the button's text accordingly
                self.setButtonText("Chosen Dataset: \(dataset.description)")
            }
            alertController.addAction(action)
        }
        // Display the action sheet to the user
        present(alertController, animated: true)
    }
    
    // Set the button's text with the normal state
    private func setButtonText(_ text: String) {
        // Update the button text with the newly selected dataset
        datasetButton.setTitle(text, for: .normal)
    }
}
