import UIKit

class MenuTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var logoutTableViewCell: UIView!
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "logout":
                PreferencesManager.deleteValueForKey("username")
                PreferencesManager.deleteValueForKey("userid")
            default: break
            }
        }
    }

    // MARK: - UITableView Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
