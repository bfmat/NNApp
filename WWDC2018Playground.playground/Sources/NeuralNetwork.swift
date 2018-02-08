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
    
    // Run inference using an array of floating-point arrays, each of which is one input
    public func infer(input: [[Float]]) -> [[Float]] {
        // Append each of the input arrays to a single-dimensional array that can be used with Accelerate
        let inputSingleDimensionalArray = input.reduce([], +)
        // Create an array to hold the output of one layer at a time as they are executed; initialize it with the transpose of the input array
        let numExamples = input.count
        let exampleLength = input[0].count
        var workingOutput = [Float](repeating: 0, count: numExamples * exampleLength)
        vDSP_mtrans(inputSingleDimensionalArray, 1, &workingOutput, 1, vDSP_Length(exampleLength), vDSP_Length(numExamples))
        print(workingOutput)
        // For each of the weight matrices (represented as one-dimensional arrays) and their corresponding shapes
        for (weightMatrix, shape) in zip(weightMatrices, weightMatrixShapes) {
            print(shape)
            // The length of the output column vector is equal to the height of the weight matrix times the number of input examples
            var output = [Float](repeating: 0, count: shape.1 * numExamples)
            // Multiply the weight matrix by the current working output as a row vector
            vDSP_mmul(weightMatrix, 1, workingOutput, 1, &output, 1, vDSP_Length(shape.0), vDSP_Length(exampleLength), vDSP_Length(output.count))
            // Update the working output with this value
            workingOutput = output
            print(workingOutput)
        }
        // Transpose the final working output so that it can be divided into output arrays for each example
        var outputTranspose = [Float](repeating: 0, count: workingOutput.count)
        vDSP_mtrans(workingOutput, 1, &outputTranspose, 1, vDSP_Length(numExamples), vDSP_Length(exampleLength))
        // Create an output array of arrays to add the example outputs to
        var outputExamples = [[Float]]()
        // Stride over the length of the output array by the length of the output for one example
        let outputExampleLength = outputTranspose.count / numExamples
        for exampleStartIndex in stride(from: 0, to: outputTranspose.count, by: outputExampleLength) {
            // Get the range of the transposed array from the starting index to the starting index plus the length of an example
            let outputExample = outputTranspose[exampleStartIndex..<exampleStartIndex + outputExampleLength]
            // Append the list to the list of output examples
            outputExamples.append(Array(outputExample))
        }
        // Return the list of output examples
        return outputExamples
    }
}
