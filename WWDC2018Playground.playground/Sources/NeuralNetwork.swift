import Accelerate

// A structure that builds a neural network given hyperparameters and can run training and inference
public struct NeuralNetwork {
    // An array of arrays containing the floating-point weights of the network
    private let weightMatrices: [[Float]]
    // An array of tuples containing the shapes of the weight matrices
    private let weightMatrixShapes: [(Int, Int)]
    
    // Initializer accepts an array whose length is equivalent to the number of layers and whose values represent the number of neurons in the corresponding layers; the beginning of the array is the input layer and the end is the output layer
    public init(layers: [Int]) {
        // Create mutable lists to add all of the weight matrices and their shapes to
        var weightMatrices = [[Float]]()
        var weightMatrixShapes = [(Int, Int)]()
        // For each of the layers in the network except for the output layer
        for layerIndex in 0..<layers.count - 1 {
            // The shape of this matrix should be the number of neurons in this layer by the number of neurons in the next layer
            let shape = (layers[layerIndex], layers[layerIndex + 1])
            weightMatrixShapes.append(shape)
            
            // Create an array to hold the weights for this layer
            var layerWeights = [Float]()
            // Iterate over both dimensions of the shape
            for _ in 0..<(shape.0 * shape.1) {
                let randomWeight = (Float(drand48()) - 0.5) * 2
                layerWeights.append(randomWeight)
            }
            // Add the weights for this layer to the list of lists of weights
            weightMatrices.append(layerWeights)
        }
        // Set the global lists of weight matrices and shapes
        self.weightMatrices = weightMatrices
        self.weightMatrixShapes = weightMatrixShapes
    }
    
    // Run inference using a single-dimensional floating-point matrix as input
    public func infer(input: [Float]) -> [Float] {
        // Make sure that the length of the input is the same as the width of the first weight matrix
        precondition(input.count == weightMatrixShapes[0].0, "Invalid input shape")
        // Create an array to hold the output of one layer at a time as they are executed; initialize it with the input
        var workingOutput = input
        // For each of the weight matrices (represented as one-dimensional arrays) and their corresponding shapes
        for (weightMatrix, shape) in zip(weightMatrices, weightMatrixShapes) {
            // The length of the output column vector is equal to the height of the weight matrix
            var output = [Float](repeating: 0, count: shape.1)
            // Multiply the weight matrix by the current working output as a row vector
            vDSP_mmul(weightMatrix, 1, workingOutput, 1, &output, 1, vDSP_Length(shape.0), 1, vDSP_Length(output.count))
            // Update the working output with this value
            workingOutput = output
        }
        // Return the final working output, which is the output of the network
        return workingOutput
    }
}
