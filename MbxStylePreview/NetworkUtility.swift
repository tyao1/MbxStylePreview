import Foundation

let apiHost = "https://api.mapbox.com"
let stylePath = "styles"
let apiVersion = "v1"

protocol MapboxNetworking {
    static var owner: String { get set }
    static var accessToken: String { get set }
    static func fetchStyles(completionHandler: ([Style]) -> Void) -> Void
}

enum FetchResult {
    case Success([NSDictionary])
    case Failure(String)
}

class NetworkUtility: MapboxNetworking {
  
    // These should be set by the client
    static var owner = ""
    static var accessToken = ""
    
    class func fetchStyles(completionHandler: ([Style]) -> Void) {
        self.fetch(stylePath) { (result) -> Void in
            switch result {
            case .Success(let json):
                let styles = json.map({obj in
                    Style(name: obj["name"] as! String, owner: obj["owner"] as! String, uniqueID: obj["id"] as! String)
                })
                completionHandler(styles + generateDefaultStyles())
            case .Failure(let errorString):
                completionHandler(generateDefaultStyles())
                print(errorString)
            }
        }
    }
    
    private class func fetch(path: String, completionHandler: (FetchResult) -> Void) -> Void {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        let urlString = "\(apiHost)/\(path)/\(apiVersion)/\(owner)?access_token=\(accessToken)"
        let task = session.dataTaskWithURL(NSURL(string: urlString)!) { (responseData, response, error) -> Void in
            if (error != nil) {
                completionHandler(FetchResult.Failure("Request failed with error \(error)"))
            }
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if statusCode != 200 {
                completionHandler(FetchResult.Failure("Request failed with status code \(statusCode)"))
                return;
            }
            
            guard let data = responseData else {
                completionHandler(FetchResult.Failure("No data from fetch request"))
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [NSDictionary]
                completionHandler(FetchResult.Success(json))
            } catch {
                completionHandler(FetchResult.Failure("Could not parse JSON"))
            }
        }
        task.resume()
    }
    
    private class func generateDefaultStyles() -> [Style] {
        return [
            Style(name: "Streets", owner: "mapbox", uniqueID: "streets-v8"),
            Style(name: "Light", owner: "mapbox", uniqueID: "light-v8"),
            Style(name: "Dark", owner: "mapbox", uniqueID: "dark-v8"),
            Style(name: "Emerald", owner: "mapbox", uniqueID: "emerald-v8"),
            Style(name: "Satellite", owner: "mapbox", uniqueID: "satellite-v8"),
            Style(name: "Satellite-Hybrid", owner: "mapbox", uniqueID: "satellite-hybrid-v8")
        ]
    }
    
}
