import UIKit

class InfoTableViewController: UITableViewController {
    
    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            fetchPlayersAndHost()
        }
    }
    var host: User?
    var users = [User]()
    
    // MARK: - Controller Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.game == nil {
            self.game = (super.tabBarController as! PlayTabBarController).game
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
                let maximalWeek = game?.maximalWeek!
                data = "Number of Weeks: \(maximalWeek!)"
            case 2:
                let backorderCost = game?.backorderCost!
                data = "Backorder Cost: \(backorderCost!)$"
            case 3:
                let inventoryCost = game?.inventoryCost!
                data = "Inventory Cost: \(inventoryCost!)$"
            default:
                data = "faulty"
            }
        }
        else {
            let currentUser = users[indexPath.row]
            data = "\(currentUser.name!)"
        }
        
        let dequeued: AnyObject = tableView.dequeueReusableCellWithIdentifier("PlayersCell", forIndexPath: indexPath)
        let cell = dequeued as! UITableViewCell
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
        case 0: return 4
        case 1: return users.count
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: - Private Methods
    /**
    Loads playerlist and host from the currently selected game.
    */
    private func fetchPlayersAndHost() {
        let gameId = game?.gameId!
        
        BeergameAPI.getUsersOfGame(gameId!) { (response) -> Void in            
            switch response.result {
            case .Success(let usersOfGame):
                // 200 OK
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
                // Error handling
                let error = "Couldn't fetch players."
                self.log(error)
                return
            }
        }
    }
    
    /**
     Logs error message.
    */
    private func log(whatToLog: AnyObject) {
        debugPrint("InfoTableViewController: \(whatToLog)")
    }
}
