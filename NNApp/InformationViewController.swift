import UIKit

// The view that displays information that is relevant while the neural network is training
public class InformationViewController : UIViewController {
    
    // A label that shows the number of epochs the network has been training for
    private let epochsLabel = UILabel()
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set the background color
        view = UIView()
        view.backgroundColor = .white
        
        // Configure the epochs label at the top of the view
        view.addSubview(epochsLabel)
        epochsLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        epochsLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        epochsLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        epochsLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        epochsLabel.translatesAutoresizingMaskIntoConstraints = false
        epochsLabel.textAlignment = .center
    }
    
    // Called by SettingsViewController during training to pass diagnostic information over
    func setDiagnosticInformation(_ diagnosticInformation: NeuralNetworkViewController.DiagnosticInformation) {
        // Make UI changes in the main thread
        DispatchQueue.main.async {
            // Set the text on the epochs label
            self.epochsLabel.text = "Epoch \(diagnosticInformation)"
        }
    }
}
