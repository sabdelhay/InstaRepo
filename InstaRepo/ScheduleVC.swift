//
//  ScheduleVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 01/12/21.
//

import UIKit
import GoogleMobileAds

class ScheduleVC: BaseViewController {

    @IBOutlet var tblSchedule : UITableView!
    @IBOutlet var segSchedule : UISegmentedControl!

    var dbManager = DBManager()

    var arrPosts : [Post] = []
    var arrPostsData = NSArray()
    var selectedPost : Post? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        dbManager = DBManager.init(databaseFilename: "RepostDB.sqlite")
        
        self.tblSchedule.tableFooterView = UIView()
        
        let font = UIFont.init(name: "AvenirNext-Medium", size: 15.0)
        segSchedule.setTitleTextAttributes([NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor : FontColor], for: .normal)
        segSchedule.setTitleTextAttributes([NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor : FontColor], for: .selected)
        
        self.GetDatabaseData()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    @IBAction func segmentClick(_ sender : UISegmentedControl)
    {        
        if sender.selectedSegmentIndex == 0
        {
            self.GetDatabaseData()
        }
        else
        {
            self.GetScheduledDatabaseData()
        }
    }
    
    func GetDatabaseData()
    {
        self.arrPostsData = dbManager.loadData(fromDB: String.init(format: "select * from Reposts WHERE isScheduled == 'false' ORDER BY id DESC"))! as NSArray
        self.arrPosts = []
        
        for data in self.arrPostsData
        {
            let dataDic = data as! NSArray
            
            let user = User.init(username: dataDic[1] as? String ?? "", avatarUrl: URL.init(string: (dataDic[2] as! String))!)
            var post : Post? = nil
            
            if dataDic[3] as! String == ""
            {
                post = Post.init(user: user, imageUrl: URL.init(string: (dataDic[3] as! String))!, videoUrl: nil, desc: dataDic[7] as? String ?? "", time: dataDic[6] as? String ?? "",isScheduled: dataDic[8] as? String ?? "",dateTime : dataDic[9] as? String ?? "")
            }
            else
            {
                post = Post.init(user: user, imageUrl: URL.init(string: (dataDic[3] as! String))!, videoUrl: URL.init(string: (dataDic[4] as! String)), desc: dataDic[7] as? String ?? "", time: dataDic[6] as? String ?? "",isScheduled: dataDic[8] as? String ?? "",dateTime : dataDic[9] as? String ?? "")
            }
            arrPosts.append(post!)
        }
        self.tblSchedule.reloadData()
    }
    
    func GetScheduledDatabaseData()
    {
        self.arrPostsData = dbManager.loadData(fromDB: String.init(format: "select * from Reposts WHERE isScheduled == 'true' ORDER BY id DESC"))! as NSArray
        self.arrPosts = []
        
        for data in self.arrPostsData
        {
            let dataDic = data as! NSArray
            
            let user = User.init(username: dataDic[1] as? String ?? "", avatarUrl: URL.init(string: (dataDic[2] as! String))!)
            var post : Post? = nil
            
            if dataDic[3] as! String == ""
            {
                post = Post.init(user: user, imageUrl: URL.init(string: (dataDic[3] as! String))!, videoUrl: nil, desc: dataDic[7] as? String ?? "", time: dataDic[6] as? String ?? "",isScheduled: dataDic[8] as? String ?? "",dateTime : dataDic[9] as? String ?? "")
            }
            else
            {
                post = Post.init(user: user, imageUrl: URL.init(string: (dataDic[3] as! String))!, videoUrl: URL.init(string: (dataDic[4] as! String)), desc: dataDic[7] as? String ?? "", time: dataDic[6] as? String ?? "",isScheduled: dataDic[8] as? String ?? "",dateTime : dataDic[9] as? String ?? "")
            }
            arrPosts.append(post!)
        }
        self.tblSchedule.reloadData()
    }
}

extension ScheduleVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segSchedule.selectedSegmentIndex == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepostTableCell", for: indexPath) as! RepostTableCell
            
            let post = self.arrPosts[indexPath.row]
            
            cell.lblName.text = "@".appending(post.user.username)
            cell.imgUser.sd_setImage(with: post.user.avatarUrl)
            cell.imgRepost.sd_setImage(with: post.imageUrl)
            cell.lblPostText.text = post.desc
            
            let isoDate = post.time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = dateFormatter.date(from:isoDate)!
            
            cell.lblTime.text = TEZFunc().TimeAgoSinceDate(date: date as NSDate, numericDates: true)
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduledPostCell", for: indexPath) as! ScheduledPostCell
            
            let post = self.arrPosts[indexPath.row]
            
            cell.lblName.text = "@".appending(post.user.username)
            cell.imgUser.sd_setImage(with: post.user.avatarUrl)
            cell.imgRepost.sd_setImage(with: post.imageUrl)
            cell.lblPostText.text = post.desc
            
            let isoDate = post.dateTime
            
            cell.lblTime.text = isoDate
            
            return cell
        }
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
            if segSchedule.selectedSegmentIndex == 0
            {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "TimeScheduleVC") as! TimeScheduleVC
                controller.selectedPost = self.arrPostsData[indexPath.row] as! NSArray
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else
            {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "TimeScheduleVC") as! TimeScheduleVC
                controller.selectedPost = self.arrPostsData[indexPath.row] as! NSArray
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}


extension ScheduleVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        if segSchedule.selectedSegmentIndex == 0
        {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TimeScheduleVC") as! TimeScheduleVC
            controller.selectedPost = self.arrPostsData[self.selectedType] as! NSArray
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else
        {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TimeScheduleVC") as! TimeScheduleVC
            controller.selectedPost = self.arrPostsData[self.selectedType] as! NSArray
            self.navigationController?.pushViewController(controller, animated: true)
        }
        appDelegate.LoadGADInterstitialAd()
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        if segSchedule.selectedSegmentIndex == 0
        {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TimeScheduleVC") as! TimeScheduleVC
            controller.selectedPost = self.arrPostsData[self.selectedType] as! NSArray
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else
        {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TimeScheduleVC") as! TimeScheduleVC
            controller.selectedPost = self.arrPostsData[self.selectedType] as! NSArray
            self.navigationController?.pushViewController(controller, animated: true)
        }
        appDelegate.LoadGADInterstitialAd()
    }
}
