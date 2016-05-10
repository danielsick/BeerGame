import Foundation
import ObjectMapper

public class PlaysheetEntry: Mappable {
    
    var available: Int?
    var backorder: Int?
    var cost: Double?
    var game: Game!
    var id: PlaysheetEntryID!
    var incomingDelivery: Int?
    var incomingOrder: Int?
    var inventory: Int?
    var outgoingDelivery: Int?
    var requestedOrder: Int!
    var toShip: Int?
    var user: User!
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        available <- map["available"]
        backorder <- map["backorder"]
        cost <- map["cost"]
        game <- map["game"]
        id <- map["id"]
        incomingDelivery <- map["incomingDelivery"]
        incomingOrder <- map["incomingOrder"]
        inventory <- map["inventory"]
        outgoingDelivery <- map["outgoingDelivery"]
        requestedOrder <- map["requestedOrder"]
        toShip <- map["toShip"]
        user <- map["user"]
    }
}
