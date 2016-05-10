import UIKit

class PlayTabBarController: UITabBarController {
    
    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            self.title = game?.name
        }
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        // Disable the order tab if the current user is not the next player
        BeergameAPI.getNextUser((game?.gameId)!) { (response) -> Void in
            switch response.result {
            case .Success(let player):
                // 200 OK
                if player.userId != (PreferencesManager.loadValueForKey("userid") as! Int) {
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if let items = self.tabBar.items {
                            items[1].enabled = false
                        }
                    }
                }
            case .Failure:
                // Error handling
                // The server returns 404 or 400 when the game does not exist or is not running
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if let items = self.tabBar.items {
                        items[1].enabled = false
                    }
                }
            }
        }
    }
}
