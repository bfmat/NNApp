import UIKit

// The view controller that displays the neurons and weights of a neural network
public class NeuralNetworkViewController : UIViewController {
    
    // The type of the diagnostic information provided
    public typealias DiagnosticInformation = Int
    
    // The duration over which the neurons and weights fade in and out
    private let fadeDuration: TimeInterval = 1
    // The duration over which the neurons animate to new positions
    private let moveDuration: TimeInterval = 1.5
    
    // The currently chosen dataset, which should never be nil except at the very beginning
    private var chosenDataset: Dataset! = nil
    // Called to get the numbers of neurons in the hidden layers that will be compatible with any dataset (excluding bias units)
    private var hiddenLayers: (() -> [Int])!
    // Used to get all of the layers of the network, not including bias units
    private var layersWithoutBias: [Int] { return [chosenDataset.inputElements] + hiddenLayers() + [chosenDataset.outputElements] }
    // The neural network represented by this view controller
    private var neuralNetwork: NeuralNetwork! = nil
    // The graphical representations of neurons
    private var neurons = [VisualNeuron]()
    // The lines that connect each pair of neurons, representing weights; organized into sub-arrays each containing the weights that start at a specific layer, so there are one less sub-arrays than there are layers in the network
    private var weights = [[VisualWeight]]()
    
    // Initializer which takes a function to get the number of hidden layers, and sets the global variable
    public convenience init(hiddenLayers: @escaping () -> [Int]) {
        self.init()
        self.hiddenLayers = hiddenLayers
    }
    
    // Blank initializer that calls up to the superclass
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required storyboard initializer that calls the main initializer
    public required convenience init(coder _: NSCoder) {
        self.init()
    }
    
    // Set the dataset and overwrite the graphical network
    public func setDataset(_ dataset: Dataset) {
        chosenDataset = dataset
        overwriteNetwork()
    }
    
    // Train the neural network with the selected dataset, for a specified number of epochs, and with a specified learning rate; can be iterated over for diagnostic data
    func train(epochs: Int, learningRate: Float) -> DiagnosticTrainingIterator {
        // Get the full training iterator from training the neural network
        let fullTrainingIterator = neuralNetwork.train(inputs: chosenDataset.inputs, groundTruths: chosenDataset.groundTruths, epochs: epochs, learningRate: learningRate)
        // Turn it into a diagnostic training iterator, with a reference to this view controller, and return it
        return DiagnosticTrainingIterator(neuralNetworkViewController: self, fullTrainingIterator: fullTrainingIterator)
    }
    
    // Iterates over the full training iterator, hands weights off to be displayed in the neural network view controller, and returns diagnostic data required for display to the user
    class DiagnosticTrainingIterator : IteratorProtocol, Sequence {
        
        // A reference to the neural network view controller
        let neuralNetworkViewController: NeuralNetworkViewController
        // An instance of the full training iterator
        var fullTrainingIterator: NeuralNetwork.FullTrainingIterator
        
        // An initializer that sets the neural network view controller and training iterator
        init(neuralNetworkViewController: NeuralNetworkViewController, fullTrainingIterator: NeuralNetwork.FullTrainingIterator) {
            self.neuralNetworkViewController = neuralNetworkViewController
            self.fullTrainingIterator = fullTrainingIterator
        }
        
        // Iteration function that returns diagnostic data
        func next() -> DiagnosticInformation? {
            // Get the next value out of the full training iterator, returning nil if the value is nil
            guard let (epoch, weightMatrices, averageActivations) = fullTrainingIterator.next() else {
                return nil
            }
            // Modify the user interface in the main thread (this is run in the background)
            DispatchQueue.main.async {
                // Iterate over the weight matrices and corresponding sets of visual weights
                for (weightMatrix, visualWeights) in zip(weightMatrices, self.neuralNetworkViewController.weights) {
                    // Iterate over each weight value and corresponding visual weight; these correspond as one would expect, since the weights are grouped together by input neuron both in the weight matrix and the visual weight array
                    for (weightValue, visualWeight) in zip(weightMatrix, visualWeights) {
                        // Set the strength of the visual weight according to the weight value
                        visualWeight.setStrength(weightValue)
                    }
                }
                
                // Flatten the arrays of average activations for each of the layers into a single array
                let averageActivationsFlat = averageActivations.reduce([], +)
                // Iterate over the numbers of neurons in each layer, creating an array of the indices of the bias neurons that should be ignored, starting at 0
                // Skip the last two layers, because the last layer does not have a bias unit, and there is no layer after it
                var biasNeurons = [0]
                for numNeurons in self.neuralNetworkViewController.layersWithoutBias[0..<(self.neuralNetworkViewController.layersWithoutBias.count - 2)] {
                    // Skip over the number of neurons in the current layer, and then add one more than that to the list (which corresponds to the first neuron of the next layer)
                    biasNeurons.append(biasNeurons.last! + numNeurons + 1)
                }
                // Copy the list of visual neurons and remove the bias units, iterating in reverse so the indices do not change during iteration
                var visualNeuronsWithoutBias = self.neuralNetworkViewController.neurons
                for biasNeuronIndex in biasNeurons.reversed() {
                    visualNeuronsWithoutBias.remove(at: biasNeuronIndex)
                }
                // Iterate over each of the non-bias neurons and corresponding average activations, setting the visual appearance of the neurons accordingly
                for (visualNeuron, averageActivation) in zip(visualNeuronsWithoutBias, averageActivationsFlat) {
                    visualNeuron.setActivation(averageActivation)
                }
            }
            // Return the epoch number, without the weight matrices
            return epoch
        }
    }
    
    // Overwrite the neural network with the global dataset and hidden layers and rearrange the graphical representation
    private func overwriteNetwork() {
        // Remove all of the weights; they are re-created after every change
        for layerWeights in weights {
            for weight in layerWeights {
                weight.fadeOut(withDuration: fadeDuration)
            }
        }
        // Clear the list of weights (new weights will be added immediately)
        weights = []
        // Combine the hidden layers with the input and output layers, adding one to the number of input elements and the hidden layers to represent bias units
        let layersWithBias = layersWithoutBias.prefix(layersWithoutBias.count - 1).map {$0 + 1} + [layersWithoutBias.last!]
        // Create a new network with the original layer numbers (the network handles bias internally)
        neuralNetwork = NeuralNetwork(layers: layersWithoutBias)
        // Get the number of neurons going into this transition
        let previousNumNeurons = neurons.count
        // The numbers of spaces between the layers, and of spaces between the maximum number of neurons in a layer, are one greater than the actual numbers of layers and neurons
        // The maximum number of neurons is used because every layer must be spaced equally, and smaller layers will be narrower
        let numLayers = layersWithBias.count
        let numLayerSpaces = numLayers + 1
        let maxNumNeuronSpaces = layersWithBias.max()!
        // Get the spacing in points between the neurons and the layers
        let distanceBetweenNeurons = view.bounds.width / CGFloat(maxNumNeuronSpaces)
        let distanceBetweenLayers = view.bounds.height / CGFloat(numLayerSpaces)
        // Create an array to hold the positions of the neurons in the previous layer
        var previousLayerNeuronPositions = [CGPoint]()
        // Iterate over each of the layers, adding them to the view
        for layerIndex in 0..<numLayers {
            // This layer should be vertically positioned based on the number of spaces such that the first layer is one space below the top and the last layer is one space above the bottom
            let verticalPosition = (CGFloat(layerIndex) + 1) * distanceBetweenLayers
            // Create an array for the neurons in this layer
            var currentLayerWeights = [VisualWeight]()
            // Iterate over the number of neurons in this layer, adding their positions to an array
            let numNeuronsInLayer = layersWithBias[layerIndex]
            var currentLayerNeuronPositions = [CGPoint]()
            for neuronIndex in 0..<numNeuronsInLayer {
                // Calculate the vertical position of this neuron by dividing the neuron index by the number of neuron spaces and adding 1, so that the first neuron is one space away from the left side and the last neuron is one space away from the right side
                let numNeuronSpacesInLayer = numNeuronsInLayer + 1
                let offsetNeuronSpaceIndex = CGFloat(neuronIndex) - (CGFloat(numNeuronSpacesInLayer) / 2) + 1
                let horizontalPosition = (offsetNeuronSpaceIndex * distanceBetweenNeurons) + (view.bounds.width / 2)
                // Position the neuron using the computed horizontal position and the vertical position of this layer
                let neuronPosition = CGPoint(x: horizontalPosition, y: verticalPosition)
                // Add the position to the list of positions for this layer
                currentLayerNeuronPositions.append(neuronPosition)
                // Calculate the index of this neuron within the entire network by adding up all previous layers and the current neuron index
                let neuronIndexInNetwork = layersWithBias[..<layerIndex].reduce(0, +) + neuronIndex
                // If the index of this neuron is within the number of neurons there were in the view going into this transition
                if neuronIndexInNetwork < previousNumNeurons {
                    // Animate the center of the neuron with this index to the new position
                    self.neurons[neuronIndexInNetwork].move(to: neuronPosition, withDuration: moveDuration)
                } else {
                    // Create a neuron view with a radius of 10
                    let neuron = VisualNeuron(at: neuronPosition, radius: 10, fadeDuration: fadeDuration)
                    // Add the finished neuron to the global array, and to the neural network view
                    neurons.append(neuron)
                    view.addSubview(neuron)
                }
                // Draw weights unless this is the first neuron in the layer (which is a bias unit) and it is not the output layer (which does not have a bias unit)
                if !(neuronIndex == 0 && layerIndex != numLayers - 1) {
                    // Iterate over the neuron positions in the previous layer, drawing lines between this neuron and the ones in the last layer
                    for previousLayerNeuronPosition in previousLayerNeuronPositions {
                        // Fade in a weight between this neuron and the current one in the previous layer
                        let weight = VisualWeight(from: neuronPosition, to: previousLayerNeuronPosition, fadeDuration: fadeDuration)
                        // Add it to the list of weights, and to the current view's layer
                        currentLayerWeights.append(weight)
                        view.layer.addSublayer(weight)
                    }
                }
            }
            // Add the list of weights for this layer to the list of all weights, if we are not on the first layer (which has no previous layer to add weights connecting to)
            if (layerIndex != 0) {
                weights.append(currentLayerWeights)
            }
            // Set the array of neuron positions in the previous layer to the positions of the neurons in this layer
            previousLayerNeuronPositions = currentLayerNeuronPositions
        }
        // Remove all neurons in the global array past the number in the new network and fade them out
        let currentNumNeurons = layersWithBias.reduce(0, +)
        for oldNeuron in neurons[currentNumNeurons...] {
            oldNeuron.fadeOut(withDuration: fadeDuration)
        }
        neurons = Array(neurons[0..<currentNumNeurons])
    }
}
