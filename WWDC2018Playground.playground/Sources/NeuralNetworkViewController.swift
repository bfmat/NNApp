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
    var dataset: Dataset! = (3, 3, []) {
        didSet {
            overwriteNetwork()
        }
    }
    // The hidden layers that will be compatible with any dataset
    var hiddenLayers: [Int]! = [3] {
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
    
    // Overwrite the neural network with the global dataset and hidden layers and rearrange the graphical representation
    private func overwriteNetwork() {
        // Combine the hidden layers with the input and output layers
        let allLayers = [dataset.inputElements] + hiddenLayers + [dataset.outputElements]
        // Create a new network with the provided layers
        neuralNetwork = NeuralNetwork(layers: allLayers)
        
        let numLayers = allLayers.count
        let maxNumNeurons = allLayers.max()!
        let distanceBetweenNeurons = view.bounds.width / CGFloat(maxNumNeurons + 1)
        let distanceBetweenLayers = view.bounds.height / CGFloat(numLayers + 1)
        for layerIndex in 0..<numLayers {
            let verticalPosition = (CGFloat(layerIndex) - (CGFloat(numLayers) / 2)) * distanceBetweenLayers
            let numNeurons = allLayers[layerIndex]
            for neuronIndex in 0..<numNeurons {
                let neuron = UIView()
                let neuronDiameter = neuronRadius * 2
                neuron.frame.size = CGSize(width: neuronDiameter, height: neuronDiameter)
                let horizontalPosition = (CGFloat(neuronIndex) - (CGFloat(numNeurons) / 2)) * distanceBetweenNeurons
                let neuronPosition = CGPoint(x: horizontalPosition, y: verticalPosition)
                neuron.center = neuronPosition
                neuron.backgroundColor = .black
                neuron.layer.cornerRadius = CGFloat(neuronRadius)
                neuron.clipsToBounds = true
                view.addSubview(neuron)
            }
        }
    }
}
