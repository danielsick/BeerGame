import Foundation
import ObjectMapper

public class PlaysheetEntryID: Mappable {
    var gameId: Int!
    var userId: Int!
    var week: Int!
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        gameId <- map["gameId"]
        userId <- map["userId"]
        week <- map["week"]
    }
}
