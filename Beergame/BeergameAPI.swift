import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


public class BeergameAPI {
    
    struct BeergameAPIEndpoints {
        static let Root = "https://beer.labs.isnetwork.de:1180/beergame/rest"
        static let Games = "\(BeergameAPIEndpoints.Root)/games"
        static let Users = "\(BeergameAPIEndpoints.Root)/users"
        static let Players = "\(BeergameAPIEndpoints.Root)/players"
        static let Playsheetentries = "\(BeergameAPIEndpoints.Root)/playsheetentries"
    }
    
    // MARK: - UserService
    
    /**
    Verifies login.
    - parameters:
        - username: Username.
        - password: Password.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - Wrong username.
    - 401 UNAUTHORIZED - Wrong password.
    */
    public static func login(username: String, password: String, completionHandler: (response: Response<User, NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Users)/login"
        
        var user = [String: String]()
        user["name"] = username
        user["password"] = password
        
        Alamofire.request(.POST, URL, parameters: user, encoding: .JSON)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Registers a new user.
    - parameters:
        - username: New username.
        - password: New password.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 409 CONFLICT - A user with that name already exists.
    - 500 INTERNAL SERVER ERROR - Error while hashing the password.
    */
    public static func register(username: String, password: String, completionHandler: (response: Response<User, NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Users)/register"
        
        var user = [String: String]()
        user["name"] = username
        user["password"] = password
        
        Alamofire.request(.POST, URL, parameters: user, encoding: .JSON)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Gets every game in the database. Can be filtered by game status.
    - parameters:
        - status: Game status for filtering (optional).
        - completionHandler: Callback method.
    */
    public static func getGames(status: Game.GameStatus?, completionHandler: (response: Response<[Game], NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/all"
        
        // send status if there is any
        if let stat = status {
            var parameters = [String: String]()
            parameters["status"] = stat.rawValue
            
            Alamofire.request(.GET, URL, parameters: parameters).responseArray { (response) in
                completionHandler(response: response)
            }
        } else { // if there isn't, send without parameters
            Alamofire.request(.GET, URL)
                .validate()
                .responseArray { (response) in
                completionHandler(response: response)
            }
        }
    }
    
    /**
    Gets the games of a user.
    - parameters:
        - userId: The user.
        - status: Game status for filtering (optional).
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - User doesn't exist.
    */
    public static func getGamesOfUser(userId: Int, status: Game.GameStatus? = nil, completionHandler: (response: Response<[Game], NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Users)/\(userId)/games"
        
        // send status if there is any
        if let stat = status {
            var parameters = [String: String]()
            parameters["status"] = stat.rawValue
            
            Alamofire.request(.GET, URL, parameters: parameters).responseArray { (response) in
                completionHandler(response: response)
            }
        } else { // if there isn't, send without parameters
            Alamofire.request(.GET, URL)
                .validate()
                .responseArray { (response) in
                    completionHandler(response: response)
            }
        }
    }
    
    /**
    Gets the players of a game.
    - parameters:
        - gameId: The game.
        - completionHandler: Callback method.
    */
    public static func getUsersOfGame(gameId: Int, completionHandler: (response: Response<[User], NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/users"
        
        Alamofire.request(.GET, URL)
            .validate()
            .responseArray { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Gets the best and worst game of a user.
    - parameters:
        - userId: The user.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - User doesn't exist.
    */
    public static func getGeneralStatistics(userId: Int, completionHandler: (response: Response<[Game], NSError>) -> Void) -> Void {
        let URL = "\(BeergameAPIEndpoints.Users)/\(userId)/generalstatistics"
        
        Alamofire.request(.GET, URL)
            .validate()
            .responseArray { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Changes the username of a user.
    - parameters:
        - userId: The user.
        - newName: New name of the user.
        - password: Password to confirm identity.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - User doesn't exist.
    - 400 BAD REQUEST - The new username equals the old username.
    - 409 CONFLICT - The provided new username is already taken.
    - 401 UNAUTHORIZED - The provided passsword was wrong.
    */
    public static func changeUsername(userId: Int, newName: String, password: String, completionHandler: (response: Response<User, NSError>) -> Void) -> Void {
        let URL = "\(BeergameAPIEndpoints.Users)/\(userId)/changeusername"
        
        var parameters = [String: String]()
        parameters["name"] = newName
        parameters["password"] = password
        
        Alamofire.request(.POST, URL, parameters: parameters, encoding: .JSON)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Changes the password of a user.
    - parameters:
        - userId: The user.
        - oldPassword: Old password to confirm identity.
        - newPassword: New password.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - The user doesn't exist.
    - 401 UNAUTHORIZED - The old password is wrong.
    - 400 BAD REQUEST - The new password equals the old password.
    - 500 INTERNAL SERVER ERROR - Password verification or hashing failed.
    */
    public static func changePassword(userId: Int, oldPassword: String, newPassword: String, completionHandler: (response: Response<User, NSError>) -> Void) -> Void {
        let URL = "\(BeergameAPIEndpoints.Users)/\(userId)/changepassword"
        
        var parameters = [String: String]()
        parameters["oldpassword"] = oldPassword
        parameters["newpassword"] = newPassword
        
        Alamofire.request(.POST, URL, parameters: parameters)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }
    // MARK: - GameService
    
    /**
    Creates a new game and sets a user as its host.
    - parameters:
        - userId: The host of the game.
        - game: Game object to be created.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - user doesn't exist.
    */
    public static func newGame(userId: Int, game: Game, completionHandler: (response: Response<Game, NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/new/\(userId)"
        
        var gameJson = [String: String]()
        gameJson["backorderCost"] = game.backorderCost.description
        gameJson["currentWeek"] = game.currentWeek.description
        gameJson["inventoryCost"] = game.inventoryCost.description
        gameJson["maximalPlayerCount"] = game.maximalPlayerCount.description
        gameJson["maximalWeek"] = game.maximalWeek.description
        gameJson["name"] = game.name
        gameJson["startingInventory"] = game.startingInventory.description
        gameJson["status"] = game.status
        
        Alamofire.request(.POST, URL, parameters: gameJson, encoding: .JSON)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Adds a player to a game if its status is WAITING.
    - parameters:
        - gameId: Game the player should be added to.
        - userId: Joining player.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - Game or user doesn't exist.
    - 400 BAD REQUEST - The games status isn't WAITING or the user is already a player of the game.
    */
    public static func addPlayerToGame(gameId: Int, userId: Int, completionHandler: (response: Response<String, NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/addplayer/\(userId)"
        
        Alamofire.request(.GET, URL)
            .validate()
            .responseString { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Orders beer in a game for a player. Also calculates the rest of the playsheet values for this week.
    - parameters:
        - gameId: The game that the player wants to order in.
        - userId: The player who wants to order.
        - order: The order amount.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - Game or user doesn't exist.
    - 400 BAD REQUEST - Game status isn't RUNNING.
    - 403 FORBIDDEN - It's not the users turn.
    */
    public static func order(gameId: Int, userId: Int, order: Int, completionHandler: (response: Response<PlaysheetEntry, NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/order/\(userId),\(order)"
        
        Alamofire.request(.GET, URL)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }
    
    /**
    Gets calculated playsheet values for the current week.
    The player needs these to decide how much he wants to order.
    - parameters:
        - gameId: The game the user wants its playsheet values for.
        - userId: The player who wants his playsheet values.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - Game or user doesn't exist.
    - 400 BAD REQUEST - Game status isn't RUNNING.
    - 403 FORBIDDEN - It's not the users turn.
    */
    public static func getPlaysheetValues(gameId: Int, userId: Int, completionHandler: (response: Response<PlaysheetEntry, NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/\(userId)"
        
        Alamofire.request(.GET, URL)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }

    /**
    Gets the current turn-holder of the game.
    - parameters:
        - gameId: Game.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - Game doesn't exist.
    - 400 BAD REQUEST - Game status isn't running.
    */
    public static func getNextUser(gameId: Int, completionHandler: (response: Response<Player, NSError>) -> Void) -> Void {
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/nextplayer"
        
        Alamofire.request(.GET, URL)
            .validate()
            .responseObject { (response) in
            completionHandler(response: response)
        }
    }

    /**
    Gets the history of a user in a game.
    - parameters:
        - gameId: Game.
        - userId: Owner of history.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - Game doesn't exist.
    - 400 BAD REQUEST - User isn't a player of the game.
    */
    public static func getHistoryOfUserOfGame(gameId: Int, userId: Int, completionHandler: (response: Response<[PlaysheetEntry], NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/history/\(userId)"
        
        Alamofire.request(.GET, URL)
            .validate()
            .responseArray { (response) in
            completionHandler(response: response)
        }

    }
    
    /**
    Gets the history of a game.
    - parameters:
        - gameId: Game.
        - completionHandler: Callback method.
    ----
    HTTP error codes:
    - 404 NOT FOUND - Game doesn't exist.
    */
    public static func getHistoryOfGame(gameId: Int, completionHandler: (response: Response<[PlaysheetEntry], NSError>) -> Void) -> Void {
     
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/history"
        Alamofire.request(.GET, URL)
            .validate()
            .responseArray { (response) in
                completionHandler(response: response)
        }
    }
    
    /**
     Gets the best and worst player of a game.
     - parameters:
        - gameId: Game
        - completionHandler: Callback method.
     -----
     HTTP error codes:
     - 404 NOT FOUND - Game doesn't exist.
     - 400 BAD REQUEST - Game status isn't ended.
     - 200 OK - JSON array of two users. Element 0 is the best user, element 1 the worst.
     */
    public static func getBestWorstPlayer(gameId: Int, completionHandler: (response: Response<[User], NSError>) -> Void) -> Void {
        
        let URL = "\(BeergameAPIEndpoints.Games)/\(gameId)/bestworstplayer"
        Alamofire.request(.GET, URL)
            .validate()
            .responseArray { (response) in
                completionHandler(response: response)
        }
    }
}