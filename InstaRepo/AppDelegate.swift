//
//  AppDelegate.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 01/12/21.
//

import UIKit
import UserNotifications
import AppTrackingTransparency
import GoogleMobileAds
import AdSupport
import SwiftRater
import IQKeyboardManager
import SwiftInstagram

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?

    var interstitial: GADInterstitialAd?
    var appOpenAd: GADAppOpenAd?
    
    var loadTime : Date?
    var animationView = UIView()

    var adClickCount = 0
    var selectedValue:Bool = false

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        
        
        Thread.sleep(forTimeInterval: 0)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
       
        // Override point for customization after application launch.
//        var navBar = self.navigationController?.navigationBar
//        navBar.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navBar.navigationBar.shadowImage = UIImage()
//        navBar.navigationBar.isTranslucent = true
//        navBar.navigationBar.backgroundColor = UIColor.clear
        
        if #available(iOS 13.0, *) {
                    let appearance = UINavigationBarAppearance()
                    appearance.backgroundColor = .red
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
                    UINavigationBar.appearance().tintColor = .white
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().compactAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                } else {
                    UINavigationBar.appearance().tintColor = .white
                    UINavigationBar.appearance().barTintColor = .red
                    UINavigationBar.appearance().isTranslucent = false
}
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 17.0)!, NSAttributedString.Key.foregroundColor : FontColor]
                
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        
        UITabBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().backgroundColor = BGColor
        UINavigationBar.appearance().tintColor = FontColor

       // UINavigationBar.appearance().barTintColor = BGColor
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 17.0)!, NSAttributedString.Key.foregroundColor : FontColor], for: .normal)
        
        UINavigationController().interactivePopGestureRecognizer?.isEnabled = true
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            if error != nil {
                print("Request authorization failed!")
            } else {
                print("Request authorization succeeded!")
            }
        }
                
        UITableViewCell.appearance().selectionStyle = .none
        
        UserDefaults.standard.set(false, forKey: removeAdsUserKey)
        
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            // show ads
           
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            
            self.LoadGADInterstitialAd()
            
        } else {
            //inAppReceiptValidation()
        }
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                if status == .authorized {
                    
                }
            }
        }
        
        if UserDefaults.standard.bool(forKey: "sdr4dfgdgd") == false{
            UserDefaults.standard.set(0, forKey: "firstscreenad")
            print("first")
            UserDefaults.standard.set(true, forKey: "sdr4dfgdgd")
        }else{
            print("another")
            
        }

        SwiftRater.daysUntilPrompt = 4
        SwiftRater.usesUntilPrompt = 5
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.debugMode = false
        SwiftRater.appLaunched()
    
        return true
    }

    
    func requestAppOpenAd() {
        appOpenAd = nil
        GADAppOpenAd.load(
            withAdUnitID: APPOPENADID,
            request: GADRequest(),
            orientation: UIInterfaceOrientation.portrait,
            completionHandler: { [self] appOpenAd, error in
                if let error = error {
                    print("Failed to load app open ad: \(error)")
                    return
                }
                self.appOpenAd = appOpenAd
                loadTime = Date()
            })
    }
    
    func tryToPresentAd() {
        let ad = appOpenAd
        appOpenAd = nil
        if ad != nil && wasLoadTimeLessThanNHoursAgo(2) {
            let rootController = self.window!.rootViewController
            ad!.present(fromRootViewController: rootController!)
        } else {
            requestAppOpenAd()
        }
    }
    
    func wasLoadTimeLessThanNHoursAgo(_ n: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(loadTime!)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(n)
    }

    func LoadGADInterstitialAd(){
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: FULL_ADID, request: request, completionHandler: { (ad, error) in
            if let error = error {
                self.hideAdsView()
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            print("Receive ad")
            self.interstitial = ad!
            
            // call only first time
            if !self.selectedValue
            {
                self.interstitial?.fullScreenContentDelegate = self
                var f_ad = UserDefaults.standard.integer(forKey: "firstscreenad")
                if f_ad%2 == 0
                {
                    if self.interstitial != nil
                    {
                        self.hideAdsView()
                        self.interstitial!.present(fromRootViewController: (self.window?.rootViewController)!)
                    }
                    else
                    {
                        print("Ad wasn't ready")
                        self.hideAdsView()
                    }
                }else{
                    self.hideAdsView()
                }
                f_ad = f_ad + 1
                UserDefaults.standard.set(f_ad, forKey: "firstscreenad")
                self.selectedValue = true
            }
        })
    }
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "spalsh_bg")
        return imageView
    }()
    
    func loadMainView(){
       
        if animationView.frame != self.window!.bounds {
            animationView.frame = self.window!.bounds
            self.window?.addSubview(animationView)
            animationView.backgroundColor = .systemBackground
            animationView.addSubview(imageView)
            let logoAnimationView = LogoAnimationView()
            animationView.addSubview(logoAnimationView)
            self.window?.bringSubviewToFront(animationView)
            logoAnimationView.pinEdgesToSuperView()
            logoAnimationView.logoGifImageView.startAnimatingGif()
        }
    }
    
    func hideAdsView(){
        animationView.isHidden = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            self.tryToPresentAd()
        }

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                if status == .authorized {
                    
                }
            }
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate
{
    //Handle Notification Center Delegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let identifier = response.notification.request.identifier
        
        print(identifier)
        completionHandler()
    }
}


extension AppDelegate : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        hideAdsView()
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        hideAdsView()
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            LoadGADInterstitialAd()
        }
    }
}

extension AppDelegate {
    
    func readReceipt() -> (Receipt: Data, IsSandbox: Bool) {
        let receiptURL = Bundle.main.appStoreReceiptURL!
        
        // We are running in sandbox when receipt URL ends with 'sandboxReceipt'
        let isSandbox = receiptURL.absoluteString.hasSuffix("sandboxReceipt")
        let receiptData = try! Data(contentsOf: receiptURL)
            
        return(receiptData, isSandbox)
    }
    
    func inAppReceiptValidation   () {
        
        guard let receiptFileURL = Bundle.main.appStoreReceiptURL else { return }
        
        let isSandbox = receiptFileURL.absoluteString.hasSuffix("sandboxReceipt")
        
        let verifyReceiptURL = isSandbox ? "https://sandbox.itunes.apple.com/verifyReceipt" : "https://buy.itunes.apple.com/verifyReceipt"
        
        let receiptData = try? Data(contentsOf: receiptFileURL)
        let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString! as AnyObject, "password" : "b79b48b8bb614fdd8936bb5604cef7ac" as AnyObject]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let storeURL = URL(string: verifyReceiptURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                
                do {
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary{
                        print("Response :",jsonResponse)
                        
                        if let date = self?.getExpirationDateFromResponse(jsonResponse) {
                            print("ExpiredData -> ", date )
                            
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                            
                            //let dt  = formatter.date(from: <#T##String#>)
                            
//                            if let expiresDate = lastReceipt["expires_date"] as? String {
//                                return formatter.date(from: expiresDate)
                            
                            if Date() > date {
                                //UserDefaults.standard.set(false, forKey: removeAdsUserKey)
                                print("Today date is greater")
                            }
                        }
                    }
                } catch let parseError {
                    print(parseError)
                }
            })
            task.resume()
        } catch let parseError {
            print(parseError)
        }
        
    }
    
    
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
            
            if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
                
                let lastReceipt = receiptInfo.lastObject as! NSDictionary
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                
                if let expiresDate = lastReceipt["expires_date"] as? String {
                    return formatter.date(from: expiresDate)
                }
                
                return nil
            }
            else {
                return nil
            }
        }
    
    
}
extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        var st = self;
        if (self.count % 4 <= 2){
            st += String(repeating: "=", count: (self.count % 4))
        }
        guard let data = Data(base64Encoded: st) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    
}


struct ReceiptData: Codable {
    let receipt: String
    let sandbox: Bool
}
    
struct AppStoreValidationResult: Codable {
    let status: Int
    let environment: String
}


