import Foundation

// The structure that contains each dataset, along with a static array that contains all of the available datasets
struct Dataset {
    
    // Datasets consist of two-dimensional arrays of floating-point numbers for inputs and ground truths
    let inputs: [[Float]]
    let groundTruths: [[Float]]
    
    // A description string is attached, as a user-facing name for this dataset
    let description: String
    
    // Static array of all of the available datasets
    static var datasets = [Dataset]()
    
    // Load datasets from files and store them in the global array
    static func loadDatasets() {
        // Iterate over the descriptions and file names of each of the datasets
        for (fileName, description) in [("CaliforniaHousePrices1990", "House Prices")] {
            // Try to get the URL of the CSV data file in the folder of resources
            let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv")!
            // Load the contents of the file as a string
            let fileContents = try! String(contentsOf: fileURL)
            // Trim whitespace off of both ends of the file
            let fileContentsTrimmed = fileContents.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            // Split the contents of the file into its component lines
            let lines = fileContentsTrimmed.components(separatedBy: "\n")
            // Create arrays of inputs and ground truths for this dataset
            var inputs = [[Float]]()
            var groundTruths = [[Float]]()
            // Iterate over the lines, adding the contents to the array of examples
            for line in lines {
                // Split the line into inputs and ground truths, which are separated by semicolons
                let exampleComponents = line.components(separatedBy: ";")
                // For the inputs and the ground truths individually, process the values and add them to an array
                var exampleComponentsNumeric = [[Float]]()
                for component in exampleComponents {
                    // Split the component into individual string values, which are separated by commas
                    let componentStringValues = component.components(separatedBy: ",")
                    // Strip each of the values and convert them to floating-point numbers
                    let componentNumbers = componentStringValues.map {
                        Float($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    }
                    // Append the array of numbers to the array for this component of the dataset
                    exampleComponentsNumeric.append(componentNumbers)
                }
                // The first element of the example array represents the input for this example, and the second (last) represents the ground truth; add them to the corresponding arrays for this dataset
                inputs.append(exampleComponentsNumeric.first!)
                groundTruths.append(exampleComponentsNumeric.last!)
            }
            // Create a dataset using the inputs, ground truths, and description and add it to the array of datasets
            let dataset = Dataset(inputs: inputs, groundTruths: groundTruths, description: description)
            datasets.append(dataset)
        }
    }
}
