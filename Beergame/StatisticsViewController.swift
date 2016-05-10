import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}