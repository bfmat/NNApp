import Accelerate

// A structure that builds a neural network given hyperparameters and can run training and inference
public struct NeuralNetwork {
    // An array of arrays containing the floating-point weights of the network
    private let weightMatrices: [[Float]]
    // An array of tuples containing the shapes of the weight matrices
    private let weightMatrixShapes: [(Int, Int)]
    
    // Initializer accepts an array whose length is equivalent to the number of layers and whose values represent the number of neurons in the corresponding layers; the beginning of the array is the input layer and the end is the output layer
    // A value that tells the network whether or not to include a bias unit in each of the layers is also provided; this bias unit is not included in the number of neurons for each layer
    public init(layers: [Int]) {
        // Create mutable lists to add all of the weight matrices and their shapes to
        var weightMatrices = [[Float]]()
        var weightMatrixShapes = [(Int, Int)]()
        // For each of the layers in the network except for the output layer
        for layerIndex in 0..<layers.count - 1 {
            // The shape of this matrix should be the number of neurons in this layer by the number of neurons in the next layer; the number of neurons in this layer should be increased by one to accomodate the bias unit
            let shape = (layers[layerIndex] + 1, layers[layerIndex + 1])
            weightMatrixShapes.append(shape)
            
            // Create an array to hold the weights for this layer
            var layerWeights = [Float]()
            // Iterate over both dimensions of the shape
            for _ in 0..<(shape.0 * shape.1) {
                let randomWeight = Float(drand48())
                layerWeights.append(randomWeight)
            }
            // Add the weights for this layer to the list of lists of weights
            weightMatrices.append(layerWeights)
        }
        // Set the global lists of weight matrices and shapes, and the global bias flag
        self.weightMatrices = weightMatrices
        self.weightMatrixShapes = weightMatrixShapes
    }
    
    // Run forward propagation and reshape the output so it can be used
    public func infer(inputs: [[Float]]) -> [[Float]] {
        // Prepare the inputs and run forward propagation
        let inputsPrepared = prepareInput(inputs)
        let numExamples = inputs.count
        let outputsSingleDimensional = forwardPropagate(inputsSingleDimensional: inputsPrepared, numExamples: numExamples)
        // Transpose the final working output so that it can be divided into output arrays for each example
        let numOutputs = outputsSingleDimensional.count
        let outputExampleLength = numOutputs / numExamples
        var outputTranspose = [Float](repeating: 0, count: numOutputs)
        vDSP_mtrans(outputsSingleDimensional, 1, &outputTranspose, 1, vDSP_Length(numExamples), vDSP_Length(outputExampleLength))
        // Create an output array of arrays to add the example outputs to
        var outputExamples = [[Float]]()
        // Stride over the length of the output array by the length of the output for one example
        for exampleStartIndex in stride(from: 0, to: outputTranspose.count, by: outputExampleLength) {
            // Get the range of the transposed array from the starting index to the starting index plus the length of an example
            let outputExample = outputTranspose[exampleStartIndex..<exampleStartIndex + outputExampleLength]
            // Append the list to the list of output examples
            outputExamples.append(Array(outputExample))
        }
        // Return the list of output examples
        return outputExamples
    }
    
    // Transpose and flatten a two-dimensional matrix in preparation for forward or back propagation
    private func flattenAndTranspose(_ matrix: [[Float]]) -> [Float] {
        // Append each of the arrays to a single-dimensional array that can be used with Accelerate
        let matrixFlat = matrix.reduce([], +)
        // Transpose the single-dimensional array so it can be used by Accelerate's linear algebra routines
        let numVectors = matrix.count
        let vectorLength = matrix[0].count
        var matrixTranspose = [Float](repeating: 0, count: numVectors * vectorLength)
        vDSP_mtrans(matrixFlat, 1, &matrixTranspose, 1, vDSP_Length(vectorLength), vDSP_Length(numVectors))
        return matrixTranspose
    }
    
    // Run forward propagation using a transposed array of examples and the number of examples
    private func forwardPropagate(inputsSingleDimensional: [Float], numExamples: Int) -> [Float] {
        // Copy the inputs array so it can be modified during each iteration
        var workingOutput = inputsSingleDimensional
        // For each of the weight matrices (represented as one-dimensional arrays) and their corresponding shapes
        for (weightMatrix, shape) in zip(weightMatrices, weightMatrixShapes) {
            // Get the number of input and output neurons of this layer from the shape of the weight matrix
            let (inputNeurons, outputNeurons) = shape
            // Add a bias feature to the end of the working output which consists of the constant 1 repeating
            let biasFeature = [Float](repeating: 1, count: numExamples)
            workingOutput.append(contentsOf: biasFeature)
            // The length of the output column vector is equal to the number of output neurons times the number of examples
            var output = [Float](repeating: 0, count: outputNeurons * numExamples)
            // Multiply the weight matrix by the current working output
            vDSP_mmul(weightMatrix, 1, workingOutput, 1, &output, 1, vDSP_Length(outputNeurons), vDSP_Length(numExamples), vDSP_Length(inputNeurons))
            // Update the working output with this value
            workingOutput = output
        }
        // Return the final working output as the raw single-dimensional transposed matrix
        return workingOutput
    }
    
    // Train the neural network, provided inputs, ground truth outputs, and other training parameters
    public func train(inputs: [[Float]], groundTruths: [[Float]], epochs: Int, learningRate: Float) {
        // Prepare the input values for forward propagation
        let inputsFlat = flattenAndTranspose(inputs)
        // Transpose and flatten the ground truths for backpropagation
        let groundTruthsFlat = flattenAndTranspose(groundTruths)
        // Repeat the training loop for each epoch
        for epoch in 0..<epochs {
            // Run forwatrd propagation to compute a hypothesis
            let outputsSingleDimensional = forwardPropagate(inputsSingleDimensional: inputsFlat, numExamples: inputs.count)
            // Subtract the outputs from the corresponding ground truth to get an error
        }
    }
    
    // Calculate the mean squared error function with a single-dimensional list of ground truths and corresponding hypotheses
    private func cost(groundTruthsFlat: [Float], hypothesesFlat: [Float]) -> Float {
        // Multiply the hypotheses matrix by -1 and add it to the ground truths matrix to get a matrix of errors
        let numValues = hypothesesFlat.count
        var negativeHypothesesFlat = [Float](repeating: 0, count: numValues)
        var multiplier: Float = -1
        vDSP_vsmul(hypothesesFlat, 1, &multiplier, &negativeHypothesesFlat, 1, vDSP_Length(numValues))
        var errors = [Float](repeating: 0, count: numValues)
        vDSP_vadd(groundTruthsFlat, 1, hypothesesFlat, 1, &errors, 1, vDSP_Length(numValues))
        // Calculate the dot product of the errors vector with itself, which is equivalent to the sum of the square of each element
        var totalSquaredError: Float = 0
        vDSP_dotpr(errors, 1, errors, 1, &totalSquaredError, vDSP_Length(numValues))
        // Return the total squared error divided by the number of elements, which is the mean squared error
        return totalSquaredError / Float(numValues)
    }
    
    // Run back propagation and update the weights of the network provided the transposed error matrix for the last layer and the learning rate
    private func backPropagate(errorsFlat: [Float], learningRate: Float) {
        
    }
}
