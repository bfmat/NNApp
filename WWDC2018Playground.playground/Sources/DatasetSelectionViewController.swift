import UIKit

// The view controller that contains a text box that uses a picker view for input; it is used to select the dataset that will be used for training or testing
public class DatasetSelectionViewController : UIViewController {
    
    // The currently chosen dataset, which starts at nil (representing that no dataset is chosen)
    private var chosenDatasetOrNil: Dataset? = nil
    
    // The button that allows the user to select which dataset to train or test the network with
    private let datasetButton = UIButton(type: .system)
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        self.view = UIView()
        view.backgroundColor = .white
        
        // The dataset button should take up the entire view
        view.addSubview(datasetButton)
        datasetButton.translatesAutoresizingMaskIntoConstraints = false
        datasetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        datasetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        datasetButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        datasetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        // Register the selection function to run when the button is pressed
        datasetButton.addTarget(self, action: #selector(selectDataset), for: UIControlEvents.touchUpInside)
        // Update the button text immediately
        updateButtonText()
        
        // Set the view to be active in the current view controller
        self.view = view
    }
    
    // Run when the selection button is pressed
    @objc private func selectDataset() {
        // Create an alert controller that will display an action sheet
        let alertController = UIAlertController(title: "Choose a Dataset", message: nil, preferredStyle: .actionSheet)
        // Create a cancel action which will not change the dataset
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // For each of the datasets to choose from
        for dataset in [Dataset.housePrices, Dataset.politicalPreferences] {
            // Add an action that sets the currently chosen dataset
            let action = UIAlertAction(title: dataset.rawValue, style: .default) { _ in
                self.chosenDatasetOrNil = dataset
                // Update the button text with the newly selected dataset
                self.updateButtonText()
            }
            alertController.addAction(action)
        }
        // Display the action sheet to the user
        present(alertController, animated: true)
    }
    
    // Update the button's text based on the chosen dataset
    private func updateButtonText() {
        // Create a string to hold the text
        let buttonText: String
        // If a dataset has been chosen, show its name on the button
        if let chosenDataset = chosenDatasetOrNil {
            buttonText = "Chosen Dataset: \(chosenDataset.rawValue)"
        }
        // Otherwise, encourage the user to choose a dataset
        else {
            buttonText = "Choose a Dataset"
        }
        // Set the text on the button
        datasetButton.setTitle(buttonText, for: .normal)
    }
    
    // An enumeration of the available datasets, with an attached description string
    private enum Dataset: String {
        case housePrices = "House Prices"
        case politicalPreferences = "Political Preferences"
    }
}
