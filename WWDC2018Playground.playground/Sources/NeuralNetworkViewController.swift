import UIKit

// The view controller that displays the neurons and weights of a neural network
public class NeuralNetworkViewController : UIViewController {
    
    // The neural network represented by this view controller
    private var neuralNetwork: NeuralNetwork? = nil
    // When either the dataset or the hidden layers are changed, update the network and its visual representation
    // The dataset used to train this neural network
    typealias Dataset = (inputElements: Int, outputElements: Int, contents: [(input: [Float], groundTruth: [Float])])
    var dataset: Dataset? = nil {
        didSet {
            updateNetwork()
        }
    }
    // The hidden layers that will be compatible with any dataset
    var hiddenLayers: [Int]? = nil {
        didSet {
            updateNetwork()
        }
    }
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set it as active in the current view controller
        view = UIView()
        // Update the network with the default values
        updateNetwork()
    }
    
    // Update the neural network with the global dataset and hidden layers and rearrange the graphical representation
    private func updateNetwork() {
        // Combine the hidden layers with the input and output layers, defaulting to 3 neurons for all, and 1 hidden layer, if the dataset or hidden layers are nil
        let datasetNotNil = dataset ?? (3, 3, [])
        let hiddenLayersNotNil = hiddenLayers ?? [3]
        let allLayers = [datasetNotNil.inputElements] + hiddenLayersNotNil + [datasetNotNil.outputElements]
        // Create a new network with the provided layers
        neuralNetwork = NeuralNetwork(layers: allLayers)
    }
}
