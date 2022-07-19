//
//  SettingVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 04/12/21.
//

import UIKit
import MessageUI
import GoogleMobileAds

class SettingVC: BaseViewController {

    @IBOutlet var tblSetting : UITableView!
    
    var arrSetting : [[String : Any]] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

//        self.LoadBannerView()

        self.arrSetting = [["name" : "Feedback and suggestion" , "logo" : "feeback"],
                           ["name" : "Rate Us" , "logo" : "rate"],
                           ["name" : "Tell to Friends" , "logo" : "friend"],
                           ["name" : "Developer Apps" , "logo" : "developer"],
        ]
        
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            // show ads
            self.arrSetting.append(["name" : "Remove Ads" , "logo" : "remove_aads"])
        }
        
        self.arrSetting.append(["name" : "Version" , "logo" : "version"])
        
        // UserDefaults.standard.set(true, forKey: removeAdsUserKey)
        
    }
    
    @IBAction func btnBackClick(_ sender : UIButton)
    {
       
        self.navigationController?.popViewController(animated: true)
    }
}


extension SettingVC : UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSetting.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        
        let dic = self.arrSetting[indexPath.row]
        let name = dic["name"] as! String

        cell.imgLogo.image = UIImage.init(named: dic["logo"] as! String)
        cell.lblName.text = name
        
        cell.imgLogo.layer.cornerRadius = 5
        
        if name == "Version"
        {
            cell.lblVersion.isHidden = false
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            cell.lblVersion.text = appVersion
        }
        else
        {
            cell.lblVersion.isHidden = true
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = self.arrSetting[indexPath.row]

        let name = dic["name"] as! String
        
        if name == "Feedback and suggestion"
        {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([Mail_ID])
                mail.setSubject("Feedback From Instant Save")
                let systemVersion = UIDevice.current.systemVersion
                mail.setMessageBody("<p>You’re so awesome! <br><br>Software version : \(systemVersion)</p>", isHTML: true)
                self.present(mail, animated: true, completion: nil)
            } else {
                //Loaf("can't find the account", state: .error, sender: self).show()
            }
        }
        else if name == "Rate Us"
        {
            UIApplication.shared.open(URL(string: RateURL)! , options: [:], completionHandler: nil)
        }
        else if name == "Tell to Friends"
        {
            let text = "Its awesome,Check out this app! Download it for free at \(RateURL)"
            let textToShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.print]
            self.present(activityViewController, animated: true, completion: nil)
        }
        else if name == "Developer Apps"
        {
            UIApplication.shared.open(URL(string: DeveloperURL)!, options: [:], completionHandler: nil)
        }
        else if name == "Version"
        {
            
        }
        else if name == "Remove Ads"
        {
            let inAppVC = self.storyboard?.instantiateViewController(withIdentifier: "InAppPaymentVC") as! InAppPaymentVC
            self.present(inAppVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
