import UIKit

// The view controller that displays the neurons and weights of a neural network
public class NeuralNetworkViewController : UIViewController {
    
    // Radius of the circles that represent the neurons, in points
    let neuronRadius = 10
    
    // The neural network represented by this view controller
    private var neuralNetwork: NeuralNetwork? = nil
    
    // When either the dataset or the hidden layers are changed, overwrite the network and its visual representation
    // The dataset used to train this neural network
    typealias Dataset = (inputElements: Int, outputElements: Int, contents: [(input: [Float], groundTruth: [Float])])
    var dataset: Dataset! = (8, 5, []) {
        didSet {
            overwriteNetwork()
        }
    }
    // The hidden layers that will be compatible with any dataset
    var hiddenLayers: [Int]! = [2] {
        didSet {
            overwriteNetwork()
        }
    }
    
    // The graphical representations of neurons
    private var neurons = [UIView]()
    // The lines that connect each pair of neurons, representing weights
    private var weights = [UIView]()
    
    // Run when the view is loaded
    public override func loadView() {
        // Create the view and set it as active in the current view controller
        view = UIView()
    }
    
    // Run after the view is added to its superview and sized according to constraints
    public override func viewDidAppear(_: Bool) {
        // Overwrite the network and display it, now that the bounds of the view have been calculated
        overwriteNetwork()
    }
    
    // Overwrite the neural network with the global dataset and hidden layers and rearrange the graphical representation
    private func overwriteNetwork() {
        // Combine the hidden layers with the input and output layers
        let allLayers = [dataset.inputElements] + hiddenLayers + [dataset.outputElements]
        // Create a new network with the provided layers
        neuralNetwork = NeuralNetwork(layers: allLayers)
        
        // The numbers of spaces between the layers, and of spaces between the maximum number of neurons in a layer, are one greater than the actual numbers of layers and neurons
        // The maximum number of neurons is used because every layer must be spaced equally, and smaller layers will be narrower
        let numLayers = allLayers.count
        let numLayerSpaces = numLayers + 1
        let maxNumNeuronSpaces = allLayers.max()!
        // Get the spacing in points between the neurons and the layers
        let distanceBetweenNeurons = view.bounds.width / CGFloat(maxNumNeuronSpaces)
        let distanceBetweenLayers = view.bounds.height / CGFloat(numLayerSpaces)
        // Iterate over each of the layers, adding them to the view
        for layerIndex in 0..<numLayers {
            // This layer should be vertically positioned based on the number of spaces such that the first layer is one space below the top and the last layer is one space above the bottom
            let verticalPosition = (CGFloat(layerIndex) + 1) * distanceBetweenLayers
            // Iterate over the number of neurons in this layer
            let numNeuronsInLayer = allLayers[layerIndex]
            for neuronIndex in 0..<numNeuronsInLayer {
                // Create a neuron view and set its side length to the diameter of the circle
                let neuron = UIView()
                let neuronDiameter = neuronRadius * 2
                neuron.frame.size = CGSize(width: neuronDiameter, height: neuronDiameter)
                // Set the rounded corner radius to the radius of the neuron, so that it is actually a circle
                neuron.layer.cornerRadius = CGFloat(neuronRadius)
                neuron.clipsToBounds = true
                // Calculate the vertical position of this neuron by dividing the neuron index by the number of neuron spaces and adding 1, so that the first neuron is one space away from the left side and the last neuron is one space away from the right side
                let numNeuronSpacesInLayer = numNeuronsInLayer + 1
                let offsetNeuronSpaceIndex = CGFloat(neuronIndex) - (CGFloat(numNeuronSpacesInLayer) / 2) + 1
                let horizontalPosition = (offsetNeuronSpaceIndex * distanceBetweenNeurons) + (view.bounds.width / 2)
                // Position the neuron using the computed horizontal position and the vertical position of this layer
                let neuronPosition = CGPoint(x: horizontalPosition, y: verticalPosition)
                neuron.center = neuronPosition
                // Set the color of the neuron to black (temporary)
                neuron.backgroundColor = .black
                // Add the finished neuron to the neural network view
                view.addSubview(neuron)
            }
        }
    }
}
