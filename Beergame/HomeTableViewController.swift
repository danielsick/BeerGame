import UIKit

class HomeTableViewController: UITableViewController {
    
    // MARK: - Model
    // Public API, then private
    var games = [Game]()
    
    private var username: String? {
        didSet {
            usernameLabel.text = username
        }
    }
    
    private struct Storyboard {
        struct Strings {
            static let EmptyTableView = "You aren't playing any games at the moment.\n Press host or join to get started! 🍺"
        }
        
        struct TableView
        {
            static let SectionTitle1 = "Host"
            static let SectionTitle2 = "Play"
            static let CellReuseIdentifier = "Game"
        }
        
        struct SegueIdentifiers {
            static let GameDetail = "showGameDetail"
            static let AdminGameDetail = "showAdminGameDetail"
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        username = PreferencesManager.loadValueForKey("username") as? String
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            
            switch identifier {
            case Storyboard.SegueIdentifiers.GameDetail:
                fallthrough
            case Storyboard.SegueIdentifiers.AdminGameDetail:
                if let tvc = sender as? GameTableViewCell {
                    let destinationTabBar = segue.destinationViewController as! PlayTabBarController
                    destinationTabBar.game = tvc.game
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
        if let userId = PreferencesManager.loadValueForKey("userid") as? Int {
            BeergameAPI.getGamesOfUser(userId) { (response) -> Void in                
                switch response.result {
                case .Success(let newGames):
                    // 200 OK
                    // If there are any games, add them to our model
                    if newGames.count > 0 {
                        self.games.removeAll()
                        for game in newGames {
                            if game.status == "WAITING" || game.status == "RUNNING" {
                                self.games.insert(game, atIndex: 0)
                            }
                        }
                        
                        // Update table view and stop refresher
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                    }
                case .Failure:
                    // Error handling
                    // Stop refresher
                    dispatch_async(dispatch_get_main_queue()) {
                        sender?.endRefreshing()
                    }
                }
            }
        }
    }
    
    // MARK: - UITableView Data Source    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableView.CellReuseIdentifier, forIndexPath: indexPath) as! GameTableViewCell
        
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        
        let game = indexPath.section == 0 ? games.filter { $0.host.userId == userId }[indexPath.row] :
            games.filter { $0.host.userId != userId }[indexPath.row]
        cell.game = game
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0: performSegueWithIdentifier(Storyboard.SegueIdentifiers.AdminGameDetail, sender: tableView.cellForRowAtIndexPath(indexPath)!)
        case 1: performSegueWithIdentifier(Storyboard.SegueIdentifiers.GameDetail, sender: tableView.cellForRowAtIndexPath(indexPath)!)
        default: return
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let userId = PreferencesManager.loadValueForKey("userid") as? Int else {
            return 0
        }
        
        let numberOfHostedGames = games.filter { $0.host.userId == userId }.count
        let numberOfPlayingGames = games.filter { $0.host.userId != userId }.count
    
        // Count of sections.
        // 0 = The user didn't host or join any games yet. 1 = The user is only playing games he hosted himself. 2 = The user hosts and/or plays a game.
        var numberOfSections = 0
        if numberOfHostedGames > 0 {
            numberOfSections = 1
        }
        if numberOfPlayingGames > 0 {
            numberOfSections = 2
        }
        
        // If the user didn't host or join any games yet, display a label.
        if numberOfSections == 0 {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            messageLabel.text = Storyboard.Strings.EmptyTableView
            messageLabel.numberOfLines = 0
            messageLabel.textColor = UIColor.lightGrayColor()
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        } else { // Disable the label when there are games to display.
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        
        return numberOfSections
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        switch section {
        case 0: return games.filter { $0.host.userId == userId }.count == 0 ? nil : Storyboard.TableView.SectionTitle1
        case 1: return Storyboard.TableView.SectionTitle2
        default: return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        
        switch section {
        case 0: return games.filter { $0.host.userId == userId }.count
        case 1: return games.filter { $0.host.userId != userId }.count
        default: return 0
        }
    }
}