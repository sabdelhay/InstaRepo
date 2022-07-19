//
//  AttributionVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 02/12/21.
//

import UIKit
import GoogleMobileAds

class AttributionVC: BaseViewController {

    var callbackColor : ((String) -> Void)?
    var callbackPosition : ((String) -> Void)?

    @IBOutlet var tblAttribution : UITableView!

    var arrColors : [[String : Any]] = []
    var arrPosition : [[String : Any]] = []
    
    var selectedColor = String()
    var selectedPosition = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Attribution Mask"
        self.navigationItem.backButtonTitle = "Back"
    
        arrColors = [["icon" : "", "title" : "White"],
                   ["icon" : "", "title" : "Black"]]
        
        arrPosition = [["icon" : "none", "title" : "None"],
                       ["icon" : "top_left", "title" : "Top Left"],
                       ["icon" : "top_right", "title" : "Top Right"],
                       ["icon" : "bottom_left", "title" : "Bottom Left"],
                       ["icon" : "bottom_right", "title" : "Bottom Right"]]

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            self.LoadBannerView()
        }  else {
            bannerViewHeight.constant = 0
        }
    }
}

extension AttributionVC : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return self.arrColors.count
        }
        else
        {
            return self.arrPosition.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell ( withIdentifier: "AttributionCell", for: indexPath ) as! AttributionCell
                
        if indexPath.section == 0
        {
            
            let dic = self.arrColors[indexPath.row]
            let name = dic["title"] as! String

            if indexPath.row == 0
            {
                cell.imgIcon.backgroundColor = .white
                cell.imgIcon.borderColor = ShadowColor
                cell.imgIcon.borderWidth = 2
                cell.imgIcon.cornerRadius = 2
            }
            else if indexPath.row == 1
            {
                cell.imgIcon.backgroundColor = .black
                cell.imgIcon.borderColor = ShadowColor
                cell.imgIcon.borderWidth = 2
                cell.imgIcon.cornerRadius = 2
            }
            
            if name == selectedColor
            {
                cell.imgSelected.isHidden = false
            }
            else
            {
                cell.imgSelected.isHidden = true
            }
            
            cell.lblName.text = name
            cell.imgIcon.image = UIImage()
        }
        else
        {
            let dic = self.arrPosition[indexPath.row]

            let name = dic["title"] as! String

            cell.imgIcon.image = UIImage.init(named: dic["icon"] as! String)
            cell.imgIcon.backgroundColor = .clear
            
            cell.imgIcon.borderWidth = 0
            cell.imgIcon.cornerRadius = 0
            
            if name == selectedPosition
            {
                cell.imgSelected.isHidden = false
            }
            else
            {
                cell.imgSelected.isHidden = true
            }
            cell.lblName.text = name
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        appDelegate.adClickCount = appDelegate.adClickCount + 1
        
        if appDelegate.interstitial != nil && appDelegate.adClickCount >= maxClick
        {
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        
        if indexPath.section == 0
        {
            let dic = self.arrColors[indexPath.row]
            let name = dic["title"] as! String
            self.selectedColor = name
            callbackColor!(self.selectedColor)
        }
        else
        {
            let dic = self.arrPosition[indexPath.row]
            let name = dic["title"] as! String
            self.selectedPosition = name
            callbackPosition!(self.selectedPosition)
        }
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        headerView.backgroundColor = BGColor
        
        let font = UIFont.init(name: "AvenirNext-Medium", size: 18.0)

        let headerLabel = UILabel.init(frame: CGRect.init(x: 16, y: 0, width: SCREEN_WIDTH, height: 50))
        headerLabel.backgroundColor = BGColor
        headerLabel.textColor = FontColorLight
        headerLabel.font = font
        
        if section == 0
        {
            headerLabel.text = "COLOR"
        }
        else
        {
            headerLabel.text = "POSITION"
        }
        
        headerView.addSubview(headerLabel)
        
        return headerView
    }
}

extension AttributionVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        
        appDelegate.adClickCount = 0
        appDelegate.LoadGADInterstitialAd()
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        appDelegate.adClickCount = 0
        appDelegate.LoadGADInterstitialAd()
    }
}
