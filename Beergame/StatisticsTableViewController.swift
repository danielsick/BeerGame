import UIKit

class StatisticsTableViewController: UITableViewController {
    
    // MARK: - Model
    // Public API, then private
    var games = [Game]()
    var bestGame: Game?
    var worstGame: Game?
    
    var generalInformation: [String:String] = [:]
    
    private struct Storyboard {
        static let CellReuseIdentifier = "StatisticsCell"
        
        struct SegueIdentifiers {
            static let StatisticsDetail = "showStatisticsDetail"
        }
    }
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            
            switch identifier {
            case Storyboard.SegueIdentifiers.StatisticsDetail:
                if let tvc = sender as? StatisticsTableViewCell {
                    let destination = segue.destinationViewController as! StatisticsTabBarController
                    destination.title = tvc.game?.name
                    destination.game = tvc.game
                }
            default: break
            }
        }
    }
    
    // MARK: - Refreshing
    
    /**
     Refreshes model and table view with dynamic game data (game title, best/worst game)
    */
    private func refresh() {
        if let userId = PreferencesManager.loadValueForKey("userid") as? Int {
            // Refresh the game list and get the number of played and hosted games
            BeergameAPI.getGamesOfUser(userId, status: Game.GameStatus.Ended) { (response) -> Void in
                switch response.result {
                case .Success(let newGames):
                    // 200 OK
                    // If there are any games, add them to our model
                    if newGames.count > 0 {
                        self.games.removeAll()
                        
                        var playedGames = 0
                        var hostedGames = 0
                        
                        for game in newGames {
                            // Add games to the model
                            self.games.insert(game, atIndex: 0)
                            
                            // Increment counters for hosted and played games
                            if game.host.userId == userId {
                                hostedGames++
                            }
                            else {
                                playedGames++
                            }
                        }
                        
                        self.generalInformation.updateValue("\(playedGames)", forKey: "GamesPlayed")
                        self.generalInformation.updateValue("\(hostedGames)", forKey: "GamesHosted")
                        
                        // Update table view
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                    }
                case .Failure:
                    // Error handling
                    return
                }
            }
            
            // Get the best and worst game
            BeergameAPI.getGeneralStatistics(userId) { (response) -> Void in
                switch response.result {
                case .Success(let bestWorstGames):
                    // 200 OK
                    // Add best and worst game to our model
                    if bestWorstGames.count > 1 {
                        self.bestGame = bestWorstGames[0]
                        self.worstGame = bestWorstGames[1]
                    }
                        
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                case .Failure:
                    // Error handling
                    return
                }
            }
        }
    }
    
    // MARK: - UITableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var data = ""
        
        if indexPath.section == 0 {
            var newGame: Game?
            var accessoryType = UITableViewCellAccessoryType.None
            
            switch indexPath.row {
            case 0:
                if let gamesPlayed = generalInformation["GamesPlayed"] {
                    data = "Games played: \(gamesPlayed)"
                } else { data = "Data not available" }
            case 1:
                if let gamesHosted = generalInformation["GamesHosted"] {
                    data = "Games hosted: \(gamesHosted)"
                } else { data = "Data not available" }
            case 2:
                if let game = bestGame {
                    data = "Best game: \(game.name)"
                    newGame = game
                    accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                } else { data = "No best game so far" }
            case 3:
                if let game = worstGame {
                    data = "Worst game: \(game.name)"
                    newGame = game
                    accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                } else { data = "No worst game so far" }
            default:
                data = ""
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! StatisticsTableViewCell
            cell.textLabel!.text = data
            cell.accessoryType = accessoryType
            if let g = newGame {
                cell.game = g
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! StatisticsTableViewCell
            
            let game = games[indexPath.row]
            cell.game = game
            cell.textLabel!.text = game.name
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Storyboard.SegueIdentifiers.StatisticsDetail, sender: tableView.cellForRowAtIndexPath(indexPath)!)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "General"
        case 1: return "Recent Games"
        default: return ""
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return games.count
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            if indexPath.row < 2 || bestGame == nil {
                return false
            } else {
                return true
            }
        case 1: return true
        default: return false
        }
    }
}
