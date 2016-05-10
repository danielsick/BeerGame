import UIKit

class JoinGameDetailTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            fetchPlayersAndHost()
        }
    }
    var host: User?
    var users = [User]()
    
    // MARK: - Actions
    @IBAction func joinButtonPressed(sender: UIBarButtonItem) {
        let gameId = (game?.gameId)!
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        
        BeergameAPI.addPlayerToGame(gameId, userId: userId) { (response) -> Void in
            switch response.result {
            case .Success:
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            case .Failure:
                // TODO: Error handling
                return
            }
        }
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    /**
     Loads playerlist and host from the currently selected game.
    */
    private func fetchPlayersAndHost() {
        let gameId = game?.gameId!
        
        BeergameAPI.getUsersOfGame(gameId!) { (response) -> Void in
            switch response.result {
            case .Success(let usersOfGame):
                if usersOfGame.count > 0 {
                    // Save users & host in model
                    self.users.removeAll()
                    for user in usersOfGame {
                        self.users.insert(user, atIndex: 0)
                    }
                    
                    self.users = self.users.reverse()
                    self.host = self.users[0]
                    
                    // Update table view
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            case .Failure:
                let error = "Couldn't fetch players."
                self.log(error)
            }
        }
    }
    
    // MARK: - UITableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var data = ""
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if let hostUsername = host?.name {
                    data = "Host: \(hostUsername)"
                }
            case 1:
                data = "Number of Weeks: \((game?.maximalWeek!)!)"
            case 2:
                data = "Starting Inventory: \((game?.startingInventory)!)"
            case 3:
                data = "Backorder Cost: \((game?.backorderCost!)!)$"
            case 4:
                data = "Inventory Cost: \((game?.inventoryCost!)!)$"
            default:
                data = "faulty"
            }
        }
        else {
            let currentUser = users[indexPath.row]
            data = "\(currentUser.name!)"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("JoinGameInfoCell", forIndexPath: indexPath)
        cell.textLabel?.text = data
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Info"
        case 1: return "Players"
        default: return ""
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 5
        case 1: return users.count
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    /**
     Logs error message.
    */
    private func log(whatToLog: AnyObject) {
        debugPrint("JoinGameDetailTableViewController: \(whatToLog)")
    }
}
