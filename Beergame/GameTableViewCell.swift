import UIKit

class GameTableViewCell: UITableViewCell {
    
    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var gameStatusImage: UIImageView!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var gameNameLabel: UILabel!
    
    // MARK: - Private Methods
    /**
     Updates the content of the cell with appropriate images and text, depending on game status.
    */
    private func updateUI() {
        // load new information if there is any
        if let game = self.game {
            switch game.status {
            case Game.GameStatus.Waiting.rawValue:
                // Show waiting for players icon when game status is WAITING
                gameStatusImage?.image = UIImage(named: "hourglassPlayer.png")
                gameStatusLabel.text = "Waiting for other players to join"
                
            case Game.GameStatus.Running.rawValue:
                BeergameAPI.getNextUser(game.gameId!) { (response) -> Void in                    
                    switch response.result {
                    case .Success(let player):
                        // 200 OK
                        if player.userId == (PreferencesManager.loadValueForKey("userid") as! Int) {
                            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                //Show your turn icon when game status is RUNNING and it's your turn
                                self.gameStatusImage?.image = UIImage(named: "yourTurn.png")
                                self.gameStatusLabel.text = "It's your turn"
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue()) {
                                //Show waiting icon when game status is RUNNING and it's not your turn
                                self.gameStatusImage?.image = UIImage(named: "hourglass.png")
                                self.gameStatusLabel.text = "Waiting for other players to play"
                            }
                        }
                    case .Failure:
                        // Error handling
                        //The server returns 404 or 400 when the game does not exist or is not running
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.gameStatusImage?.image = UIImage(named: "info.png")
                            self.gameStatusLabel.text = "The game is not running"
                        }
                    }
                }
            case Game.GameStatus.Ended.rawValue:
                // If the game status is ENDED, the game should not show up in this list
                gameStatusImage?.image = UIImage(named: "info.png")
                gameStatusLabel.text = "This game is over"
                
            default:
                let error = "Unexpected game status."
                self.log(error)
            }
            
            gameNameLabel?.text = game.name
        }
    }
    
    /**
     Logs error message.
    */
    private func log(whatToLog: AnyObject) {
        debugPrint("GameTableViewCell: \(whatToLog)")
    }
}
