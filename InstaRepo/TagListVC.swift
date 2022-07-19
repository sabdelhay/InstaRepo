//
//  TagListVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 17/02/33.
//

import UIKit
import GoogleMobileAds

class TagListVC: BaseViewController {

    @IBOutlet var tblTags : UITableView!
    var dbManager = DBManager()

    var selectedCat = ""
    var arrHasTags = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblTags.tableFooterView = UIView()
        dbManager = DBManager.init(databaseFilename: "InstaTag.db")

        self.arrHasTags = dbManager.loadData(fromDB: String.init(format: "SELECT * from sub_category WHERE cat_id = \(selectedCat)"))! as NSArray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            self.LoadBannerView()
        }  else {
            bannerViewHeight.constant = 0
        }
    }
}

extension TagListVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrHasTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HashTagCell", for: indexPath) as! HashTagCell
        
        let dic = self.arrHasTags[indexPath.row] as! NSArray
        cell.lblName.text = dic[1] as? String ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedType = indexPath.row
        
        if appDelegate.interstitial != nil
        {
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        else
        {
            let controller = storyBoard.instantiateViewController(withIdentifier: "HasTagVC") as! HasTagVC
            let dic = self.arrHasTags[indexPath.row] as! NSArray
            controller.tagsStr = dic[1] as? String ?? ""
            controller.title = self.title
            self.navigationController?.pushViewController(controller, animated: true)
        }

    }
}

extension TagListVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        
        let controller = storyBoard.instantiateViewController(withIdentifier: "HasTagVC") as! HasTagVC
        let dic = self.arrHasTags[self.selectedType] as! NSArray
        controller.tagsStr = dic[1] as? String ?? ""
        controller.title = self.title
        self.navigationController?.pushViewController(controller, animated: true)
        
        appDelegate.LoadGADInterstitialAd()
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        let controller = storyBoard.instantiateViewController(withIdentifier: "HasTagVC") as! HasTagVC
        let dic = self.arrHasTags[self.selectedType] as! NSArray
        controller.tagsStr = dic[1] as? String ?? ""
        controller.title = self.title
        self.navigationController?.pushViewController(controller, animated: true)
        
        appDelegate.LoadGADInterstitialAd()
    }
}

