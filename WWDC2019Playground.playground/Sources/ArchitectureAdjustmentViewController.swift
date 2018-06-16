import UIKit

// The view controller that is modally presented over the main view and allows the user to adjust the network's architecture
public class ArchitectureAdjustmentViewController : UITableViewController {
    
    // Array containing the hidden layers of the network (not including bias units) and an associated external accessor
    private var hiddenLayersNeuronNumbers = [2]
    public func hiddenLayers() -> [Int] { return hiddenLayersNeuronNumbers }
    
    // Initializer which configures buttons and layer settings
    public init() {
        // Call the superclass initializer to create a plain table view
        super.init(style: .plain)
        // Disable scrolling (all layers should fit in the screen)
        tableView.isScrollEnabled = false
        // When this is presented modally, it should display over the existing context
        modalPresentationStyle = .overCurrentContext
    }
    
    // Required storyboard initializer that calls the main initializer
    public required convenience init?(coder _: NSCoder) {
        self.init()
    }
    
    // Provides the information that this table view will only have one sections
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Called to get the number of rows in this table view; return a hardcoded number which fits in the screen
    public override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 14
    }
    
    // Called to get the contents of each table cell
    public override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Switch on the row number of the index path, as there are certain special rows that have hardcoded elements
        switch indexPath.row {
        // The first row should contain a title label
        case 0:
            // Create a cell and get the associated label
            let titleCell = UITableViewCell()
            let titleCellLabel = titleCell.textLabel!
            // Set the text and align it in the center
            titleCellLabel.text = "Change Network Architecture"
            titleCellLabel.textAlignment = .center
            return titleCell
        default:
            return UITableViewCell()
        }
    }
}
