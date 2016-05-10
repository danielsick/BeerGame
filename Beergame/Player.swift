import Foundation
import ObjectMapper

public class Player: Mappable {
    var userId: Int!
    var gameId: Int!
    var role: Int!
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        userId <- map["userId"]
        gameId <- map["gameId"]
        role <- map["role"]
    }
}