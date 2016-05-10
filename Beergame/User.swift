import Foundation
import ObjectMapper

public class User: Mappable, CustomStringConvertible {
    var name: String!
    var password: String?
    var userId: Int!
    
    required public init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        name <- map["name"]
        userId <- map["userId"]
    }
    
    public var description: String {
        return "{\"name\":\"\(name)\",\"userId\":\(userId)}"
    }
}
