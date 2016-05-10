import Foundation
import ObjectMapper

public class Game: Mappable, CustomStringConvertible {
    var backorderCost: Double!
    var currentWeek: Int!
    var gameId: Int?
    var inventoryCost: Double!
    var maximalPlayerCount: Int!
    var maximalWeek: Int!
    var name: String!
    var startingInventory: Int!
    var host: User!
    var status: String!
    
    public enum GameStatus: String {
        case Waiting = "WAITING"
        case Running = "RUNNING"
        case Ended = "ENDED"
    }
    
    required public init(name: String, maximalPlayerCount: Int, maximalWeek: Int, startingInventory: Int, backorderCost: Double, inventoryCost: Double) {
        self.backorderCost = backorderCost
        self.currentWeek = 1
        self.inventoryCost = inventoryCost
        self.maximalPlayerCount = maximalPlayerCount
        self.maximalWeek = maximalWeek
        self.name = name
        self.startingInventory = startingInventory
        self.status = GameStatus.Waiting.rawValue
    }
    
    required public init?(_ map: Map) {
    }
    
    public func mapping(map: Map) {
        backorderCost <- map["backorderCost"]
        currentWeek <- map["currentWeek"]
        gameId <- map["gameId"]
        inventoryCost <- map["inventoryCost"]
        maximalPlayerCount <- map["maximalPlayerCount"]
        maximalWeek <- map["maximalWeek"]
        name <- map["name"]
        startingInventory <- map["startingInventory"]
        host <- map["host"]
        status <- map["status"]
    }
    
    public var description: String {
        return "{\"backorderCost\":\(backorderCost),\"currentWeek\":\(currentWeek),\"gameId\":\(gameId),\"inventoryCost\":\(inventoryCost),\"maximalPlayerCount\":\(maximalPlayerCount),\"maximalWeek\":\(maximalWeek),\"name\":\"\(name)\",\"startingInventory\":\(startingInventory),\"status\":\"\(status)\"}"
    }
}
