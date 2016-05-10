import UIKit

class StatisticsInfoTableViewController: UITableViewController {
    
    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            fetchPlayersAndHost()
        }
    }
    var host: User?
    var users = [User]()
    var bestPlayer: User?
    var worstPlayer: User?
    
    // MARK: - Controller Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.game == nil {
            self.game = (super.tabBarController as! StatisticsTabBarController).game
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
                } else { data = "Data not available" }
            case 1:
                let maximalWeek = game?.maximalWeek!
                data = "Number of Weeks: \(maximalWeek!)"
            case 2:
                let backorderCost = game?.backorderCost!
                data = "Backorder Cost: \(backorderCost!)$"
            case 3:
                let inventoryCost = game?.inventoryCost!
                data = "Inventory Cost: \(inventoryCost!)$"
            case 4:
                let startingInventory = (game?.startingInventory)!
                data = "Starting Inventory: \(startingInventory)"
            case 5:
                if let bestPlayerName = bestPlayer?.name {
                    data = "Best economy: \(bestPlayerName)"
                } else { data = "Data not available" }
            case 6:
                if let worstPlayerName = worstPlayer?.name {
                    data = "Worst economy: \(worstPlayerName)"
                } else { data = "Data not available" }
            default:
                data = "faulty"
            }
        }
        else {
            let currentUser = users[indexPath.row]
            data = "\(currentUser.name!)"
        }
        
        let dequeued: AnyObject = tableView.dequeueReusableCellWithIdentifier("SingleStatisticsCell", forIndexPath: indexPath)
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
        case 0: return 7
        case 1: return users.count
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: - Private Methods
    /**
    Gets players and hosts for the current game and saves them in model.
    Calls fetchBestWorstPlayer afterwards.
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
                        self.fetchBestWorstPlayer()
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
     Gets the best and the worst player of the current game and saves them in model.
     Reloads the table afterwards.
     */
    private func fetchBestWorstPlayer() {
        let gameId = game?.gameId
        
        BeergameAPI.getBestWorstPlayer(gameId!) { (response) -> Void in
            switch response.result {
            case .Success(let bestWorstPlayer):
                // 200 OK
                if bestWorstPlayer.count > 0 {
                    // Save users & host in model
                    self.bestPlayer = bestWorstPlayer[0]
                    self.worstPlayer = bestWorstPlayer[1]
                    
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
    
    private func log(whatToLog: AnyObject) {
        debugPrint("InfoTableViewController: \(whatToLog)")
    }
}
