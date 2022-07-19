//
//  Constant.swift

import UIKit
import Foundation
import CoreLocation
import QuartzCore
import CoreGraphics
import SystemConfiguration
import SVProgressHUD

typealias CompletionWithImage = (UIImage) -> Void
typealias CompletePayment = ([String : Any]) -> Void

private var __maxLengths = [UITextField: Int]()

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
let appDelegate = UIApplication.shared.delegate as! AppDelegate

var bottomPadding: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
var topPadding: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0

let BGColor = UIColor(named: "BGColor")!
let FontColor = UIColor(named: "FontColor")!
let ShadowColor = UIColor(named: "ShadowColor")!
let ThemeColor = UIColor(named: "ThemeColor")!
let ThemeColor2 = UIColor(named: "ThemeColor2")!
let FontColorLight = UIColor(named: "FontColorLight")!

var maxClick = 5

// Test Ad //
let APPOPENADID = "ca-app-pub-3940256099942544/5662855259"
let FULL_ADID = "ca-app-pub-3940256099942544/4411468910"
let BANNER_ADID = "ca-app-pub-3940256099942544/2934735716"
let APPNATIVEAD = "ca-app-pub-3940256099942544/3986624511"


let APP_ID = "app id"
let RateURL : String = "https://apps.apple.com/us/app/instarepo/id1623046541"
let DeveloperURL : String = "https://apps.apple.com/us/app/instarepo/id1623046541"
let APP_NAME = "Instant Save"
let Mail_ID = "spiromo.com@gmail.com"

// In App Purcashes

let InApp_ProductId_Weekly = "com.meet.instant.save.week"
let InApp_ProductId_Monthly = "com.meet.instant.save.monthly"
let InApp_ProductId_Yearly = "com.meet.instant.save.yearly"

let removeAdsUserKey = "remove_ads"
let isSendBox = "isSendBox"

func loaderShow() {
    DispatchQueue.main.async {
        SVProgressHUD.show()
    }
}

func loaderHide () {
    DispatchQueue.main.async {
        SVProgressHUD.dismiss()
    }
}

class Constant: NSObject {
    
    static func removeNSNull(from dict: [String: Any]) -> [String: Any] {
        
        var mutableDict = dict
        let keysWithEmptString = dict.filter { $0.1 is NSNull }.map { $0.0 }
        
        for key in keysWithEmptString {
            mutableDict[key] = ""
        }
        
        return mutableDict
    }
    
    static func dateUTCToLocal(selectedDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation:"UTC")! as TimeZone
        let utcTime = dateFormatter.date(from: selectedDate)! as NSDate
        
        let dateFormatFrom = DateFormatter()
        dateFormatFrom.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatFrom.timeZone = TimeZone(abbreviation: "UTC")
        let currentDate = dateFormatFrom.string(from: utcTime as Date)

        let localTime = self.timeAgoSinceDate(date: utcTime, numericDates: false)
        return localTime
    }
    
    static func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        
        let dateFormatFrom = DateFormatter()
        dateFormatFrom.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatFrom.timeZone = TimeZone(abbreviation: "UTC")
        let currentDate = dateFormatFrom.string(from: Date())
        let currentdt  = dateFormatFrom.date(from: currentDate)
        
        print("Current Date :\(currentdt)")
        print("Added Date :\(date)")
        
        
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = currentdt as! NSDate
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        print("Latest Date :\(latest)")
        print("============")
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) mins ago"
        } else if (components.minute! >= 1){
            if (numericDates) {
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) secs ago"
        } else {
            return "Just now"
        }
    }
}

extension CGFloat {
  var toRadians: CGFloat { return self * .pi / 180 }
  var toDegrees: CGFloat { return self * 180 / .pi }
}


@IBDesignable class DottedVertical: UIView {

    @IBInspectable var dotColor: UIColor = UIColor.black
    @IBInspectable var lowerHalfOnly: Bool = false

    override func draw(_ rect: CGRect) {

        // say you want 8 dots, with perfect fenceposting:
        let totalCount = 8 + 8 - 1
        let fullHeight = bounds.size.height
        let width = bounds.size.width
        let itemLength = fullHeight / CGFloat(totalCount)

        let path = UIBezierPath()

        let beginFromTop = CGFloat(0.0)
        let top = CGPoint(x: width/2, y: beginFromTop)
        let bottom = CGPoint(x: width/2, y: fullHeight)

        path.move(to: top)
        path.addLine(to: bottom)

        path.lineWidth = width

        let dashes: [CGFloat] = [itemLength, itemLength]
        path.setLineDash(dashes, count: dashes.count, phase: 0)

        // for ROUNDED dots, simply change to....
        //let dashes: [CGFloat] = [0.0, itemLength * 2.0]
        //path.lineCapStyle = CGLineCap.round

        dotColor.setStroke()
        path.stroke()
    }
}
    


extension UITextField {
    
    @IBInspectable var textInsets: CGPoint {
        get {
            return CGPoint.zero
        }
        set {
            layer.sublayerTransform = CATransform3DMakeTranslation(newValue.x, newValue.y, 0);
        }
    }
    
    
    
    
    func setImageInLeftView(image: UIImage) {
        
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
        
        leftView.backgroundColor = UIColor.clear
        
        let imgView = UIImageView.init(frame: CGRect(x: 8, y: (self.frame.size.height - 20) / 2 , width: 20, height: 20))
        imgView.layer.cornerRadius = 10.0
        imgView.layer.masksToBounds = true
        imgView.image = image
        imgView.center = leftView.center
        leftView.addSubview(imgView)
        
        self.leftView = leftView
        self.leftViewMode = .always
    }
    
    func setImageInLeftView() {
        
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.size.height))
        
        leftView.backgroundColor = UIColor.clear
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        
        self.leftView = leftView
        self.leftViewMode = .always
    }
    
    func setBlankView() {
        
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.size.height))
        leftView.backgroundColor = UIColor.clear
                
        self.leftView = leftView
        self.leftViewMode = .always
        
        self.rightView = leftView
        self.rightViewMode = .always
    }
    
    
    func setImageInRightView(image: UIImage) {
        
        let rightView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
        
        rightView.backgroundColor = UIColor.clear
        
        let imgView = UIImageView.init(frame: CGRect(x: 0, y: (self.frame.size.height / 2) - 8, width: 40, height: 16))
        imgView.contentMode = .scaleAspectFit
        imgView.image = image
        imgView.center = rightView.center
        
        rightView.addSubview(imgView)
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        
        self.rightView = rightView
        self.rightViewMode = .always
        
    }
    
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension UIImageView {
    func setImageColor(image: UIImage, color: UIColor) {
    let templateImage = image.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}

//MARK:- UiView
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}



extension Date
{
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    
    func DateToTimeOnly() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: self)
    }
}


extension UIImageView {
    func imageFromServerURL(urlString: String) {
        self.image = nil
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
        }).resume()
    }
}

extension UIView {

    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}


extension URL
{
    var queryParameters: QueryParameters { return QueryParameters(url: self) }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
        print(queryItems)
    }
    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}


func convertImageToBase64(image: UIImage) -> String {
    let imageData = image.pngData()!
    return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
}

func convertBase64ToImage(imageString: String) -> UIImage {
    let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
    return UIImage(data: imageData)!
}


@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}



extension TimeInterval {
    
    private var seconds: Int
    {
        if self >= 0
        {
            return Int(self) % 60
        }
        return 0
    }

    private var minutes: Int
    {
        if self >= 0
        {
            return (Int(self) / 60 ) % 60
        }
        return 0
    }

    private var hours: Int
    {
        if self >= 0
        {
            return Int(self) / 3600
        }
        return 0
    }

    var stringTime: String {
        
//        if hours != 0 {
//            return "\(hours)Hr \(minutes)Min \(seconds)Sec"
//        } else
        
        if minutes != 0
        {
            return String.init(format: "  %dm Away  ", minutes) //"\(minutes)Min \(seconds)Sec"
        }
        else
        {
            return String.init(format: "  %ds Away  ", seconds)  //"\(seconds)Sec"
        }
    }
    
    var stringTime2: String {
        
        if minutes != 0
        {
            return String.init(format: "%d-Min", minutes) //"\(minutes)Min \(seconds)Sec"
        }
        else
        {
            return String.init(format: "%d-Sec", seconds)  //"\(seconds)Sec"
        }
    }
}
