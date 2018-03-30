import Foundation
import ObjectMapper

public struct ImageProduct: Mappable {
    public var src: String?
    public var id: Int?
    
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        src <- map["src"]
        id <- map["id"]
        
        
    }
    
    private func unwrapedDescription(value: Any?) -> String {
        if let value = value {
            return "\(value)"
        }
        return "[no data]"
    }
    
    
    
}


