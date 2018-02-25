import UIKit

// The view controller that displays the neurons and weights of a neural network
public class NeuralNetworkViewController : UIViewController {
    
    // The dataset used to train this neural network
    public typealias Dataset = (inputElements: Int, outputElements: Int, contents: [(input: [Float], groundTruth: [Float])])
    public var dataset: Dataset! = (8, 5, [])
    // The hidden layers that will be compatible with any dataset
    public var hiddenLayers: [Int]! = [2]
    
    // The neural network represented by this view controller
    private var neuralNetwork: NeuralNetwork? = nil
    // The graphical representations of neurons
    private var neurons = [VisualNeuron]()
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
    public func overwriteNetwork() {
        // Combine the hidden layers with the input and output layers
        let allLayers = [dataset.inputElements] + hiddenLayers + [dataset.outputElements]
        // Create a new network with the provided layers
        neuralNetwork = NeuralNetwork(layers: allLayers)
        // Get the number of neurons going into this transition
        let previousNumNeurons = neurons.count
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
                // Calculate the vertical position of this neuron by dividing the neuron index by the number of neuron spaces and adding 1, so that the first neuron is one space away from the left side and the last neuron is one space away from the right side
                let numNeuronSpacesInLayer = numNeuronsInLayer + 1
                let offsetNeuronSpaceIndex = CGFloat(neuronIndex) - (CGFloat(numNeuronSpacesInLayer) / 2) + 1
                let horizontalPosition = (offsetNeuronSpaceIndex * distanceBetweenNeurons) + (view.bounds.width / 2)
                // Position the neuron using the computed horizontal position and the vertical position of this layer
                let neuronPosition = CGPoint(x: horizontalPosition, y: verticalPosition)
                // Calculate the index of this neuron within the entire network by adding up all previous layers and the current neuron index
                let neuronIndexInNetwork = allLayers[..<layerIndex].reduce(0, +) + neuronIndex
                // If the index of this neuron is within the number of neurons there were in the view going into this transition
                if neuronIndexInNetwork < previousNumNeurons {
                    // Animate the center of the neuron with this index to the new position over a period of 1 second
                    UIView.animate(withDuration: 1) {
                        self.neurons[neuronIndexInNetwork].center = neuronPosition
                    }
                } else {
                    // Create a neuron view with a radius of 10
                    let neuron = VisualNeuron(at: neuronPosition, radius: 10)
                    // Add the finished neuron to the global array, and to the neural network view
                    neurons.append(neuron)
                    view.addSubview(neuron)
                }
            }
        }
        // Remove all neurons in the global array past the number in the new network
        let currentNumNeurons = allLayers.reduce(0, +)
        for oldNeuron in neurons[currentNumNeurons...] {
            oldNeuron.removeFromSuperview()
        }
        neurons = Array(neurons[0..<currentNumNeurons])
    }
}
