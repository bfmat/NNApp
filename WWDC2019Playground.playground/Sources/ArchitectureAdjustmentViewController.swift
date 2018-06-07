import UIKit

// The view controller that is modally presented over the main view and allows the user to adjust the network's architecture
public class ArchitectureAdjustmentViewController : UITableViewController {
    
    // Initializer which configures buttons and layer settings
    public init() {
        // Call the superclass initializer to create a plain table view
        super.init(style: .plain)
        // Disable scrolling (all layers should fit in the screen)
        tableView.isScrollEnabled = false
        // When this is presented modally, it should display over the existing context
        modalPresentationStyle = .overCurrentContext
    }
    
    // Required storyboard initializer that just calls the main initializer
    public required convenience init?(coder _: NSCoder) {
        self.init()
    }
}
