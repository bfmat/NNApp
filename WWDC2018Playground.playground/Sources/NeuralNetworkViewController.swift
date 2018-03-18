import UIKit

// The view controller that displays the neurons and weights of a neural network
public class NeuralNetworkViewController : UIViewController {
    
    // The duration over which the neurons and weights fade in and out
    private let fadeDuration: TimeInterval = 1
    // The duration over which the neurons animate to new positions
    private let moveDuration: TimeInterval = 1.5
    
    // The currently chosen dataset, which should never be nil except at the very beginning
    private var chosenDataset: Dataset! = nil
    // The hidden layers that will be compatible with any dataset
    private var hiddenLayers: [Int] = [2]
    // The neural network represented by this view controller
    private var neuralNetwork: NeuralNetwork! = nil
    // The graphical representations of neurons
    private var neurons = [VisualNeuron]()
    // The lines that connect each pair of neurons, representing weights; organized into sub-arrays each containing the weights that start at a specific layer, so there are one less sub-arrays than there are layers in the network
    private var weights = [[VisualWeight]]()
    
    // Set the dataset and overwrite the graphical network
    public func setDataset(_ dataset: Dataset) {
        chosenDataset = dataset
        overwriteNetwork()
    }
    
    // Train the neural network with the selected dataset, for a specified number of epochs, and with a specified learning rate
    func train(epochs: Int, learningRate: Float) {
        neuralNetwork.train(inputs: chosenDataset.inputs, groundTruths: chosenDataset.groundTruths, epochs: epochs, learningRate: learningRate)
    }
    
    // Overwrite the neural network with the global dataset and hidden layers and rearrange the graphical representation
    private func overwriteNetwork() {
        // Remove all of the weights; they are re-created after every change
        for layerWeights in weights {
            for weight in layerWeights {
                weight.fadeOut(withDuration: fadeDuration)
            }
        }
        // Combine the hidden layers with the input and output layers
        let allLayers = [chosenDataset.inputElements] + hiddenLayers + [chosenDataset.outputElements]
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
        // Create an array to hold the positions of the neurons in the previous layer
        var previousLayerNeuronPositions = [CGPoint]()
        // Iterate over each of the layers, adding them to the view
        for layerIndex in 0..<numLayers {
            // This layer should be vertically positioned based on the number of spaces such that the first layer is one space below the top and the last layer is one space above the bottom
            let verticalPosition = (CGFloat(layerIndex) + 1) * distanceBetweenLayers
            // Iterate over the number of neurons in this layer, adding their positions to an array
            let numNeuronsInLayer = allLayers[layerIndex]
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
                let neuronIndexInNetwork = allLayers[..<layerIndex].reduce(0, +) + neuronIndex
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
                // Iterate over the neuron positions in the previous layer, drawing lines between this neuron and the ones in the last layer, and adding the newly created weights to an array
                var currentLayerWeights = [VisualWeight]()
                for previousLayerNeuronPosition in previousLayerNeuronPositions {
                    // Fade in a weight between this neuron and the current one in the previous layer
                    let weight = VisualWeight(from: neuronPosition, to: previousLayerNeuronPosition, fadeDuration: fadeDuration)
                    // Add it to the list of weights, and to the current view's layer
                    currentLayerWeights.append(weight)
                    view.layer.addSublayer(weight)
                }
                // Add the list of weights for this layer to the list of all weights
                weights.append(currentLayerWeights)
            }
            // Set the array of neuron positions in the previous layer to the positions of the neurons in this layer
            previousLayerNeuronPositions = currentLayerNeuronPositions
        }
        // Remove all neurons in the global array past the number in the new network and fade them out
        let currentNumNeurons = allLayers.reduce(0, +)
        for oldNeuron in neurons[currentNumNeurons...] {
            oldNeuron.fadeOut(withDuration: fadeDuration)
        }
        neurons = Array(neurons[0..<currentNumNeurons])
    }
}
