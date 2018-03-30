import Alamofire
import Foundation
import ObjectMapper

public class Client {
    public static let sharedClient = Client()
    
    public var consumerKey: String?
    public var consumerSecret: String?
    public var siteURL: String?
    
    init() {}
    
    init(siteURL: String, consumerKey: String, consumerSecret: String) {
        self.siteURL = siteURL
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
    
    public func get<T: Mappable>(type: String, id: Int, completion: @escaping ( _ success: Bool,_ value: T?) -> Void) {
        let baseURL = URL(string: siteURL!)
        let requestURL = URL(string: "wc-api/v3/\(type)s/\(id)", relativeTo: baseURL)
        let requestURLString = requestURL!.absoluteString
        
        guard let user = consumerKey, let password = consumerSecret else {
            completion(false, nil)
            return
        }
        
       /* Alamofire.request(requestURLString)
            .authenticate(user: user, password: password)
            .responseJSON { response in
                if response.result.isSuccess {
                    let myAny = response.re
                    let object = Mapper<T>().map
                    completion(success: true, value: object)
                } else {
                    completion(false, nil)
                }
        }*/
    }
    
   
}

