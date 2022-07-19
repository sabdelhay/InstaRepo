//
//  HashTahListVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 17/02/33.
//

import UIKit
import GoogleMobileAds

class HashTahListVC: BaseViewController {

    var dbManager = DBManager()

    @IBOutlet var tblCategory : UITableView!

    var arrImages : [String] = []
    var arrCategory = NSArray()
    var selectedArray = NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dbManager = DBManager.init(databaseFilename: "InstaTag.db")

        self.arrCategory = dbManager.loadData(fromDB: String.init(format: "select * from users"))! as NSArray
                
        arrImages = ["most_popular","family","fashion","weather","photography","celebrties","nature","food","holidays","travel","entertainment","electronic","countries","follow_like","other"]

        let barButton = UIBarButtonItem.init(image: UIImage.init(named: "setting"), style: .plain, target: self, action: #selector(self.OpenSettings))
        barButton.tintColor = FontColor
        self.navigationItem.leftBarButtonItem = barButton

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            self.LoadBannerView()
        }  else {
            bannerViewHeight.constant = 0
        }
    }
    
    @IBAction func OpenSettings()
    {
        print("settings")
        let controller = storyBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self.navigationController?.pushViewController(controller, animated: true)

    }

}

extension HashTahListVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HashTagCell", for: indexPath) as! HashTagCell
        
        let dic = self.arrCategory[indexPath.row] as! NSArray
        
        cell.lblName.text = dic[1] as? String ?? ""
        cell.imgIcon.image = UIImage.init(named: arrImages[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = self.arrCategory[indexPath.row] as! NSArray
        self.selectedArray = dic

        
        if appDelegate.interstitial != nil
        {
            //if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
                
            
                appDelegate.interstitial?.fullScreenContentDelegate = self
                appDelegate.interstitial?.present(fromRootViewController: self)
                
                
            //}
        }
        else
        {
            let controller = storyBoard.instantiateViewController(withIdentifier: "TagListVC") as! TagListVC
            controller.selectedCat = dic[0] as? String ?? ""
            controller.title = dic[1] as? String ?? ""
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension HashTahListVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        
        let controller = storyBoard.instantiateViewController(withIdentifier: "TagListVC") as! TagListVC
        controller.selectedCat = self.selectedArray[0] as? String ?? ""
        controller.title = self.selectedArray[1] as? String ?? ""
        self.navigationController?.pushViewController(controller, animated: true)

        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            appDelegate.LoadGADInterstitialAd()
        }
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        let controller = storyBoard.instantiateViewController(withIdentifier: "TagListVC") as! TagListVC
        controller.selectedCat = self.selectedArray[0] as? String ?? ""
        controller.title = self.selectedArray[1] as? String ?? ""
        self.navigationController?.pushViewController(controller, animated: true)

        //if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            appDelegate.LoadGADInterstitialAd()
        //}
    }
}
