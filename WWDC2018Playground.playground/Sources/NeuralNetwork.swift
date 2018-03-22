import Accelerate

// A structure that builds a neural network given hyperparameters and can run training and inference
class NeuralNetwork {
    
    // An array of arrays containing the floating-point weights of the network
    private var weightMatrices: [[Float]]
    // An array of tuples containing the shapes of the weight matrices
    private let weightMatrixShapes: [(Int, Int)]
    
    // Initializer accepts an array whose length is equivalent to the number of layers and whose values represent the number of neurons in the corresponding layers; the beginning of the array is the input layer and the end is the output layer
    // A value that tells the network whether or not to include a bias unit in each of the layers is also provided; this bias unit is not included in the number of neurons for each layer
    init(layers: [Int]) {
        // Create mutable lists to add all of the weight matrices and their shapes to
        var weightMatrices = [[Float]]()
        var weightMatrixShapes = [(Int, Int)]()
        // Seed the random number generator with the current time
        let time = Int(Date().timeIntervalSinceReferenceDate)
        srand48(time)
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
    func infer(inputs: [[Float]]) -> [[Float]] {
        // Prepare the inputs and run forward propagation, taking the outputs for the last layer only
        let inputsPrepared = NeuralNetwork.flattenAndTranspose(inputs)
        let numExamples = inputs.count
        let outputsSingleDimensional = forwardPropagate(inputsSingleDimensional: inputsPrepared, numExamples: numExamples).outputs.last!
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
    private static func flattenAndTranspose(_ matrix: [[Float]]) -> [Float] {
        // Append each of the arrays to a single-dimensional array
        let matrixFlat = matrix.reduce([], +)
        // Transpose the single-dimensional array so it can be used in matrix multiplications
        let numVectors = matrix.count
        let vectorLength = matrix[0].count
        var matrixTranspose = [Float](repeating: 0, count: numVectors * vectorLength)
        vDSP_mtrans(matrixFlat, 1, &matrixTranspose, 1, vDSP_Length(vectorLength), vDSP_Length(numVectors))
        return matrixTranspose
    }
    
    // Run forward propagation using a transposed array of examples and the number of examples, returning matrices of outputs and activations for each layer in the network
    private func forwardPropagate(inputsSingleDimensional: [Float], numExamples: Int) -> (outputs: [[Float]], activations: [[Float]]) {
        // Create an array to add the outputs for each layer to, before the activation function; initialize it to contain the input matrix
        var outputs = [inputsSingleDimensional]
        // Create a similar array for the activation vectors, also containing the inputs (since there is no activation function on the first layer)
        var activations = [inputsSingleDimensional]
        // Copy the inputs array so it can be modified during each iteration with the activations of each layer
        var workingActivation = inputsSingleDimensional
        // For each of the weight matrices (represented as one-dimensional arrays) and their corresponding shapes
        for (weightMatrix, shape) in zip(weightMatrices, weightMatrixShapes) {
            // Get the number of input and output neurons of this layer from the shape of the weight matrix
            let (inputNeurons, outputNeurons) = shape
            // Add a bias feature to the end of the working activation which consists of the constant 1 repeating
            let biasFeature = [Float](repeating: 1, count: numExamples)
            workingActivation.append(contentsOf: biasFeature)
            // The length of the output column vector is equal to the number of output neurons times the number of examples
            let numOutputs = outputNeurons * numExamples
            var output = [Float](repeating: 0, count: numOutputs)
            // Multiply the weight matrix by the current working activation
            vDSP_mmul(weightMatrix, 1, workingActivation, 1, &output, 1, vDSP_Length(outputNeurons), vDSP_Length(numExamples), vDSP_Length(inputNeurons))
            // Add the returned value to the list of outputs, without applying the activation function
            outputs.append(output)
            // Apply the hyperbolic tangent activation function to the matrix of outputs
            var activation = [Float](repeating: 0, count: numOutputs)
            var numOutputsMutable = Int32(numOutputs)
            vvtanhf(&activation, output, &numOutputsMutable)
            // Add it to the list of activation vectors
            activations.append(activation)
            // Update the working activation with this value
            workingActivation = activation
        }
        // Return the outputs and activations for each layer
        return (outputs, activations)
    }
    
    // Train the neural network, provided inputs, ground truth outputs, and other training parameters; this function returns an iterable sequence
    func train(inputs: [[Float]], groundTruths: [[Float]], epochs: Int, learningRate: Float) -> FullTrainingIterator {
        // Return a training iterator with the provided parameters, and a reference to this neural network
        return FullTrainingIterator(inputs: inputs, groundTruths: groundTruths, epochs: epochs, learningRate: learningRate, neuralNetwork: self)
    }
    
    // An iterator that runs training and returns weight matrices and other data for each epoch
    struct FullTrainingIterator : IteratorProtocol {
        
        // Training parameters (the number of epochs and the learning rate)
        private let epochs: Int
        private let learningRate: Float
        // A reference to the neural network so it can be modified
        private let neuralNetwork: NeuralNetwork
        // The flattened matrices of inputs and ground truths
        private let inputsFlat: [Float]
        private let groundTruthsFlat: [Float]
        // The number of examples, and the length of each example
        private let numExamples: Int
        private let outputExampleLength: Int
        
        // The number of epochs that have been run so far, incremented at the end of the epoch
        private var pastEpochs = 0
        
        // Initializer which prepares the network for training; it also takes a reference to the neural network
        fileprivate init(inputs: [[Float]], groundTruths: [[Float]], epochs: Int, learningRate: Float, neuralNetwork: NeuralNetwork) {
            // Set the global variables passed as parameters
            self.epochs = epochs
            self.learningRate = learningRate
            self.neuralNetwork = neuralNetwork
            // Prepare the input values for forward propagation
            inputsFlat = flattenAndTranspose(inputs)
            // Transpose and flatten the ground truths for backpropagation
            groundTruthsFlat = flattenAndTranspose(groundTruths)
            // Remember the dimensions of the example matrices, because they are saved only as single-dimensional arrays
            numExamples = groundTruths.count
            outputExampleLength = groundTruths[0].count
        }
        
        // Iterator function, which trains for a single epoch and returns associated data
        mutating func next() -> Int? {
            // If the number of completed epochs is equal to the total number of epochs, return nil (stopping iteration)
            if pastEpochs == epochs {
                return nil
            }
            // Run forward propagation to compute outputs and activations for each layer in the network
            let (outputs, activations) = neuralNetwork.forwardPropagate(inputsSingleDimensional: inputsFlat, numExamples: numExamples)
            // Get the outputs for the last layer, which are the hypotheses for the given training examples
            let hypothesesFlat = outputs.last!
            // Subtract the hypotheses from the ground truths to get a flat matrix of errors
            let errorsFlat = subtractMatrices(hypothesesFlat, from: groundTruthsFlat)
            // Transpose the flat matrix of errors so it can be divided up into training examples
            var errorsExampleOrdered = [Float](repeating: 0, count: numExamples * outputExampleLength)
            vDSP_mtrans(errorsFlat, 1, &errorsExampleOrdered, 1, vDSP_Length(numExamples), vDSP_Length(outputExampleLength))
            // Iterate over the list using the output example length as a stride, getting the starting index of each example in the matrix
            for exampleIndex in stride(from: 0, to: numExamples * outputExampleLength, by: outputExampleLength) {
                // Slice the array of errors to get the errors for this example only
                let exampleErrors = Array(errorsExampleOrdered[exampleIndex..<exampleIndex + outputExampleLength])
                // Run back propagation with the errors for this example, outputs and activations for all layers, and provided learning rate
                neuralNetwork.backPropagate(errors: exampleErrors, activations: activations, learningRate: learningRate)
            }
            // Increment the number of completed epochs
            pastEpochs += 1
            // Return one less than the number of past epochs, which is the index of this epoch
            return pastEpochs - 1
        }
    }
    
    // Calculate the half mean squared error function with a vector of errors between the ground truths and hypotheses
    private func cost(errors: [Float]) -> Float {
        // Calculate the dot product of the errors vector with itself, which is equivalent to the sum of the square of each element
        let numValues = errors.count
        var totalSquaredError: Float = 0
        vDSP_dotpr(errors, 1, errors, 1, &totalSquaredError, vDSP_Length(numValues))
        // Return the total squared error divided by the number of elements times two, which is half of the mean squared error
        return totalSquaredError / (Float(numValues) * 2)
    }
    
    // Subtract one single-dimensional floating-point matrix from another
    private static func subtractMatrices(_ array0: [Float], from array1: [Float]) -> [Float] {
        // Multiply the first array by -1 and add it to the second array
        let numValues = array0.count
        var negativeArray0 = [Float](repeating: 0, count: numValues)
        var multiplier: Float = -1
        vDSP_vsmul(array0, 1, &multiplier, &negativeArray0, 1, vDSP_Length(numValues))
        var output = [Float](repeating: 0, count: numValues)
        vDSP_vadd(negativeArray0, 1, array1, 1, &output, 1, vDSP_Length(numValues))
        return output
    }
    
    // Run back propagation and update the weights of the network provided a single error vector for the last layer, the outputs and activations of each layer of the network, and the learning rate
    private func backPropagate(errors: [Float], activations: [[Float]], learningRate: Float) {
        // Create an array of output gradients to update for each layer, initialized with the errors for the last layer
        var workingOutputGradients = errors
        // Iterate backwards over the indices of the weight matrices, not including the very first one
        for weightMatrixIndex in (0..<weightMatrices.count).reversed() {
            // Get the number of input and output neurons of this layer from the shape of the weight matrix
            let (inputNeurons, outputNeurons) = weightMatrixShapes[weightMatrixIndex]
            let numWeights = inputNeurons * outputNeurons
            // Get the gradients for the current weight matrix by calculating the matrix product of the output gradients and the activations for the current layer plus a bias unit
            let layerActivations = activations[weightMatrixIndex]
            let layerActivationsWithBias = layerActivations + [1]
            var weightGradients = [Float](repeating: 0, count: numWeights)
            vDSP_mmul(workingOutputGradients, 1, layerActivationsWithBias, 1, &weightGradients, 1, vDSP_Length(outputNeurons), vDSP_Length(inputNeurons), 1)
            // Multiply the matrix of gradients by the negative of the learning rate to get a matrix of steps for each of the weights
            var weightSteps = [Float](repeating: 0, count: numWeights)
            var learningRateMutable = learningRate
            vDSP_vsmul(weightGradients, 1, &learningRateMutable, &weightSteps, 1, vDSP_Length(numWeights))
            // Add the matrix of steps to the matrix of weights to complete the weight update
            var modifiedWeightMatrix = [Float](repeating: 0, count: numWeights)
            vDSP_vadd(weightMatrices[weightMatrixIndex], 1, weightSteps, 1, &modifiedWeightMatrix, 1, vDSP_Length(numWeights))
            weightMatrices[weightMatrixIndex] = modifiedWeightMatrix
            
            // Compute the transpose of this weight matrix so that it can be used to propagate backwards through this layer
            var weightMatrixTranspose = [Float](repeating: 0, count: numWeights)
            vDSP_mtrans(weightMatrices[weightMatrixIndex], 1, &weightMatrixTranspose, 1, vDSP_Length(outputNeurons), vDSP_Length(inputNeurons))
            // Multiply the weight matrix transpose by the output errors to get gradients for the activations of the preceding layer
            var activationGradients = [Float](repeating: 0, count: inputNeurons)
            vDSP_mmul(weightMatrixTranspose, 1, workingOutputGradients, 1, &activationGradients, 1, vDSP_Length(inputNeurons), 1, vDSP_Length(outputNeurons))
            // Calculate the derivative of the hyperbolic tangent activation function for the outputs of the preceding layer
            // The derivative of tanh(x) is 1 - (tanh(x) ^ 2), and tanh(x) has already been calculated; it is the activation corresponding to each output
            // This means the derivative of the activation with respect to the output is just 1 minus the square of the activation
            // The number of output neurons in the previous layer is one less than the number of input neurons of this layer, because it does not include the bias term
            let outputNeuronsPreviousLayer = inputNeurons - 1
            // Calculate the square of each element in the activation
            var activationSquares = [Float](repeating: 0, count: outputNeuronsPreviousLayer)
            vDSP_vsq(layerActivations, 1, &activationSquares, 1, vDSP_Length(outputNeuronsPreviousLayer))
            // Multiply the squares by -1
            var negativeActivationSquares = [Float](repeating: 0, count: outputNeuronsPreviousLayer)
            var negativeOne: Float = -1
            vDSP_vsmul(activationSquares, 1, &negativeOne, &negativeActivationSquares, 1, vDSP_Length(outputNeuronsPreviousLayer))
            // Add 1 to every element of the negative squares to get the derivatives of the activation function
            var activationFunctionDerivatives = [Float](repeating: 0, count: outputNeuronsPreviousLayer)
            var one: Float = 1
            vDSP_vsadd(negativeActivationSquares, 1, &one, &activationFunctionDerivatives, 1, vDSP_Length(outputNeuronsPreviousLayer))
            // Remove the last element, corresponding to the bias term, from the activation gradients; the new array will be the number of output neurons of the previous layer
            let activationGradientsWithoutBias = Array(activationGradients[0..<outputNeuronsPreviousLayer])
            // Element-wise multiply the activation gradients by the derivatives of the activation function; this produces the output gradients for the preceding layer, which will be used on the next iteration
            workingOutputGradients = [Float](repeating: 0, count: outputNeuronsPreviousLayer)
            vDSP_vmul(activationGradientsWithoutBias, 1, activationFunctionDerivatives, 1, &workingOutputGradients, 1, vDSP_Length(outputNeuronsPreviousLayer))
        }
    }
}
