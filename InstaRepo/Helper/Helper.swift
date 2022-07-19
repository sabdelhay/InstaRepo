import UIKit
import Alamofire

class Network {
    
    static func checkLink(_ link: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "^https://(www.)?instagram.com/.*/", options: .caseInsensitive)
        let matches = regex.matches(in: link, options: [], range: NSMakeRange(0, link.count))
        guard !matches.isEmpty else {
            return nil
        }
        guard let activeLink = link.components(separatedBy: "?").first else {
            return nil
        }
        return activeLink
    }
    
    static func getPost(with link: String, completion: @escaping (Bool,Post?) -> ()) {
        getJson(link) { success,json  in
            
            if !success
            {
                completion(false, nil)
                return
            }
            
            guard let json = json else {
                return
            }
            
            parseJson(json) { post in
                DispatchQueue.main.async {
                    completion(true, post)
                }
            }
        }
    }
    
    static func getJson(_ link: String, completion: @escaping (Bool,[String: Any]?) -> ()) {
        
        let url = URL(string: "\(link)?__a=1")!
        
        var request = URLRequest(url: url)
        
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "accept-language")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(false, [:])
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                
                do {
                    
                    let dt = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print("faidled Dt", dt)
                    
                }
                
                catch {
                    
                    print("main error -> " , error)
                    print("desc error -> " , error.localizedDescription)
                
                }
                
                completion(false, [:])
                return
            }
            
            completion(true, json)

        }.resume()
    }
    
    static func parseJson(_ json: [String: Any], completion: @escaping (Post?) -> ()) {
        guard let graph = json["graphql"] as? [String: Any],
            let media = graph["shortcode_media"] as? [String: Any],
            let owner = media["owner"] as? [String: Any] else {
                return
        }
        
        guard let graph1 = media["edge_media_to_caption"] as? [String: Any],
              let edges = (graph1["edges"] as? [[String: Any]]), edges.count > 0,
              let edges0 = edges[0] as? [String: Any],
              let node = edges0["node"] as? [String: Any] else {
                return
        }
        
        guard let username = owner["username"] as? String,
            let avatarUrl = (owner["profile_pic_url"] as? String)?.url else {
                return completion(nil)
        }
        
        let user = User(username: username, avatarUrl: avatarUrl)
        
        getImage(url: avatarUrl) { avatarImage in
            user.avatarImage = avatarImage
            
            guard let imageUrl = (media["display_url"] as? String)?.url else {
                return completion(nil)
            }
            
            getImage(url: imageUrl) { image in
                guard let image = image else {
                    return completion(nil)
                }
                
                let videoUrl = (media["video_url"] as? String)?.url
                
                let post = Post(user: user, imageUrl: imageUrl, videoUrl: videoUrl, desc: node["text"] as? String ?? "", time: "",isScheduled: "",dateTime : "")
                post.image = image
                
                completion(post)
            }
        }
    }
    
    static func getImage(url: URL, completion: @escaping (UIImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else {return}
                completion(UIImage(data: data))
            }
        }.resume()
    }

}

extension String {
    
    var url: URL? {
        return URL(string: self)
    }
}

extension UIColor {
    convenience init(hex hexString:String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
