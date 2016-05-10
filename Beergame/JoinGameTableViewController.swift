import UIKit

class JoinGameTableViewController: UITableViewController {
    
    // MARK: - Model
    // Public API, then private
    var games = [Game]()
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Game"
        
        struct Identifiers {
            static let JoinGameDetail = "showJoinGameDetail"
        }
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            
            switch identifier {
            case Storyboard.Identifiers.JoinGameDetail:
                if let tvc = sender as? GameTableViewCell {
                    let destination = segue.destinationViewController as! JoinGameDetailTableViewController
                    destination.title = tvc.game?.name
                    destination.game = tvc.game
                }
            default: break
            }
        }
    }
    
    // MARK: - Refreshing
    private func refresh() {
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        // Load userid from logged in user
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        
        BeergameAPI.getGames(Game.GameStatus.Waiting) { (response) -> Void in
            switch response.result {
            case .Success(var newGames):
                // 200 OK
                // If there are any games, filter all the games in which the user is already in and then add them to our model
                if newGames.count > 0 {
                    self.games.removeAll()
                    
                    BeergameAPI.getGamesOfUser(userId) { (response) -> Void in
                        switch response.result {
                        case .Success(let gamesOfUser):
                            // 200 OK
                            // Now filter all the games in which the user is already in
                            newGames = newGames.filter { (game) -> Bool in
                                !gamesOfUser.contains { $0.gameId == game.gameId }
                            }
                            
                            // Add the rest to our model
                            for game in newGames {
                                self.games.insert(game, atIndex: 0)
                            }
                            
                            // Update table view
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                                sender?.endRefreshing()
                            }
                        case .Failure:
                            dispatch_async(dispatch_get_main_queue()) {
                                sender?.endRefreshing()
                            }
                            // Error handling
                        }
                    }
                }
            case .Failure:
                dispatch_async(dispatch_get_main_queue()) {
                    sender?.endRefreshing()
                    // Error handling
                }
            }
        }
    }

    // MARK: - UITableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! GameTableViewCell
        
        let game = games[indexPath.row]
        cell.game = game
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Storyboard.Identifiers.JoinGameDetail, sender: tableView.cellForRowAtIndexPath(indexPath)!)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    // MARK: - Private Methods
    
    private func log(whatToLog: AnyObject) {
        debugPrint("JoinGameTableViewController: \(whatToLog)")
    }
}
