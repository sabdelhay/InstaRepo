import UIKit

class User {
    
    let username: String
    
    let avatarUrl: URL
    
    var avatarImage: UIImage?
    
    init(username: String, avatarUrl: URL) {
        self.username = username
        self.avatarUrl = avatarUrl
    }
}

class Post {
    
    let user: User
    
    let imageUrl: URL
    
    let videoUrl: URL?
    
    var image: UIImage?
    
    var desc : String = ""
    var time : String = ""
    var isImage = Bool()

    var isScheduled : String = ""
    var dateTime : String = ""

    var isVideo: Bool {
        return videoUrl != nil
    }

    init(user: User, imageUrl: URL, videoUrl: URL?, desc : String, time : String,isScheduled : String,dateTime : String) {
        self.user = user
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.desc = desc
        self.time = time
        self.isScheduled = isScheduled
        self.dateTime = dateTime

    }
}
