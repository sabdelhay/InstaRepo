//
//  ViewController.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 01/12/21.
//

import UIKit
import SDWebImage
import GoogleMobileAds


class RepostVC: BaseViewController {
    
    @IBOutlet var tblRepost : UITableView!
    @IBOutlet var txtLinkPaste : UITextField!
    
    @IBOutlet var myView: UIView!
    var dbManager = DBManager()
    
    var arrPosts : [Post] = []
    var arrPostsData = NSArray()
    var selectedPost : Post? = nil
    
    
    let textView = UITextView()
    let button = UIButton()
    let stackView = UIStackView()
    
    
    let instaURL = "https://instagram.com/"
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()

        
        dbManager = DBManager.init(databaseFilename: "RepostDB.sqlite")
        
        self.tblRepost.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver( self, selector: #selector(pasteLink(_:)), name: UIApplication.willEnterForegroundNotification, object: nil )
        
        button.addTarget(self, action:#selector(self.btnInsta), for: .touchUpInside)
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnInsta(_ sender: Any) {
            if let url = URL(string: instaURL), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // display error ?
            }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Date().description  => ", Date().description)
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            self.LoadBannerView()
        } else {
            bannerViewHeight.constant = 0
        }
        self.GetDatabaseData()
    }
    
    @IBAction func OpenInstagram()
    {
        print("instagram")
        
        if let instagramUrl = URL(string: "instagram://")
        {
            if UIApplication.shared.canOpenURL(instagramUrl)
            {
                UIApplication.shared.open(instagramUrl)
            }
            else
            {
                UIApplication.shared.open(URL(string: "https://instagram.com/")!)
            }
        }
    }
    
    @IBAction func OpenSettings()
    {
        print("settings")
        
        let controller = storyBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func GetDatabaseData()
    {
        
        self.arrPostsData = dbManager.loadData(fromDB: String.init(format: "select * from Reposts ORDER BY id DESC"))! as NSArray
        
        // Showing or not showing textview
        if(arrPostsData.count == 0){
            
            showTextView()
            
        }else{
            
            hideTextView()
        }
        
        self.arrPosts = []
        
        print( "postData -> \(self.arrPostsData)")
        
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
            
            print("Desc -> ", post?.desc ?? "")
            print("dataDic -> ", dataDic)
            
            arrPosts.append(post!)
            
        }
        
        self.tblRepost.reloadData()
        
    }
    
    @objc func pasteLink(_ notification: Notification)
    {
        let link = UIPasteboard.general.string
        guard let theString = link else {return}
        
        if theString.contains("https://www.instagram.com/") {
            checkLink(theString)
        }
    }
    
    @IBAction func btnPasteLinkClick(_ sender: UIButton)
    {
        self.selectedType = 1
        
        appDelegate.adClickCount = appDelegate.adClickCount + 1
        
        if appDelegate.interstitial != nil
        {
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        else
        {
            let link = self.txtLinkPaste.text
            guard let theString = link else {return}
            
            if theString.contains("https://www.instagram.com/") {
                checkLink(theString)
            }
        }
    }
    
    func checkLink(_ link: String)
    {
        
        guard let link = Network.checkLink(link) else { return }
        
        print("Link -> ", link )
        
        Network.getPost(with: link) { success, post  in
            
            if success
            {
                print("Link -> Sucesssss")
                guard let post = post else { return }
                self.showMediaPost(post)
            }
            else
            {
                print("Link -> Failtedddd")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title:"Sorry!", message: "This post is private , so can not add to the list.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func showMediaPost(_ post: Post)
    {
        self.txtLinkPaste.text = ""
        
        let desc = post.desc.replacingOccurrences(of: "'", with: "''")
        
        if post.isVideo
        {
            let insert =  String.init(format: "INSERT INTO Reposts (username,avatarUrl,imageUrl,videoUrl,isVideo,dateTime,desc,isScheduled,scheduleTime) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@')", post.user.username,
                                      post.user.avatarUrl.absoluteString,
                                      post.imageUrl.absoluteString,
                                      post.videoUrl!.absoluteString ,
                                      "1",
                                      Date().description,
                                      desc,
                                      "false",
                                      "0")
            
            dbManager.executeQuery(insert)
        }
        else
        {
            let insert =  String.init(format: "INSERT INTO Reposts (username,avatarUrl,imageUrl,videoUrl,isVideo,dateTime,desc,isScheduled,scheduleTime) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@')", post.user.username,
                                      post.user.avatarUrl.absoluteString,
                                      post.imageUrl.absoluteString,
                                      "",
                                      "0",
                                      Date().description,
                                      desc,
                                      "false",
                                      "0")
            
            dbManager.executeQuery(insert)
        }
        
        UIPasteboard.general.string = ""
        GetDatabaseData()
    }
}

extension RepostVC : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        self.view.endEditing(true)
        
        return true
    }
}

extension RepostVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete)
        {
            let deleteId = (self.arrPostsData[indexPath.row] as! NSArray)[0] as! String
            
            let deleteQuery = String.init(format: "DELETE FROM Reposts WHERE id='%@'", deleteId)
            dbManager.executeQuery(deleteQuery)
            
            self.GetDatabaseData()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (rowAction, indexPath) in
            
            let deleteId = (self.arrPostsData[indexPath.row] as! NSArray)[0] as! String
            
            let deleteQuery = String.init(format: "DELETE FROM Reposts WHERE id='%@'", deleteId)
            self.dbManager.executeQuery(deleteQuery)
            
            self.GetDatabaseData()
        }
        deleteAction.backgroundColor = ThemeColor2
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let post = self.arrPosts[indexPath.row]
        self.selectedPost = post
        
        self.selectedType = 2
        
        appDelegate.adClickCount = appDelegate.adClickCount + 1
        
        if appDelegate.interstitial != nil && appDelegate.adClickCount >= maxClick
        {
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        else
        {
            Network.getImage(url: post.user.avatarUrl) { avatarImage in
                post.user.avatarImage = avatarImage
                
                Network.getImage(url: post.imageUrl) { image in
                    post.image = image
                    
                    let controller = storyBoard.instantiateViewController(withIdentifier: "RepostHandlerVC") as! RepostHandlerVC
                    controller.post = post
                    controller.dbManager = self.dbManager
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}


extension RepostVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        
        if self.selectedType == 1
        {
            let link = self.txtLinkPaste.text
            guard let theString = link else {return}
            
            if theString.contains("https://www.instagram.com/") {
                checkLink(theString)
            }
        }
        else if self.selectedType == 2
        {
            appDelegate.adClickCount = 0
            
            Network.getImage(url: self.selectedPost!.user.avatarUrl) { avatarImage in
                self.selectedPost!.user.avatarImage = avatarImage
                
                Network.getImage(url: self.selectedPost!.imageUrl) { image in
                    self.selectedPost!.image = image
                    
                    let controller = storyBoard.instantiateViewController(withIdentifier: "RepostHandlerVC") as! RepostHandlerVC
                    controller.post = self.selectedPost
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
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
        
        if self.selectedType == 1
        {
            let link = self.txtLinkPaste.text
            guard let theString = link else {return}
            
            if theString.contains("https://www.instagram.com/") {
                checkLink(theString)
            }
        }
        else if self.selectedType == 2
        {
            appDelegate.adClickCount = 0
            
            Network.getImage(url: self.selectedPost!.user.avatarUrl) { avatarImage in
                self.selectedPost!.user.avatarImage = avatarImage
                
                Network.getImage(url: self.selectedPost!.imageUrl) { image in
                    self.selectedPost!.image = image
                    
                    let controller = storyBoard.instantiateViewController(withIdentifier: "RepostHandlerVC") as! RepostHandlerVC
                    controller.post = self.selectedPost
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
        
        appDelegate.LoadGADInterstitialAd()
    }
    
    func showTextView(){
        
        // Creating StackView
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 15.0
        
        textView.contentInsetAdjustmentBehavior = .automatic
        //textView.center = self.view.center
        textView.textAlignment = NSTextAlignment.justified
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.white
        textView.isSelectable = true
        textView.isEditable = false
        
        // Make UITextView corners rounded
        textView.layer.cornerRadius = 10
        
        //self.view.centerYAnchor
        // Adding the TextView Constrains(Aka drawing or shapping it)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 280 ).isActive = true
        
//        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        //textView.isScrollEnabled = false
        // Adding text to the UITextView
        textView.text = "How To Repost?" + "\n" + "1. Open Instagram " + "\n" + "2. Find the photo or video you want to repost. " + "\n" + "3. Tap'...' button in the top right corner and select Copy Link'. " + "\n" + "4. Return the Repost and wait for the post to show up!"
        
        // The text body to use for formatting
        let textStr = "\n" + "1. Open Instagram " + "\n" + "2. Find the photo or video you want to repost. " + "\n" + "3. Tap'...' button in the top right corner and select Copy Link'. " + "\n" + "4. Return the Repost and wait for the post to show up!"
        
        // Creating attributed Text
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText!)
        
        // Use NSString so the result of rangeOfString is an NSRange.
        let text = textView.text! as NSString
        
        // Handle bold
        let boldRange = text.range(of: "How To Repost?")
        let boldFont = UIFont(name: "Helvetica-bold", size: 25.0) as Any
        attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: boldRange)
        
        // Handle small.
        let smallRange = text.range(of: textStr)
        let smallFont = UIFont(name: "Helvetica", size: 15.0) as Any
        attributedText.addAttribute(NSAttributedString.Key.font, value: smallFont, range: smallRange)
        
        // Handle line spacing
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()

        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 16 // Whatever line spacing you want in points

        // *** Apply attribute to string ***
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
//        if let font = UIFont(name: "AvenirNextCondensed-Regular", size: font_size) {
//            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedString.length))
//        }

        
        textView.attributedText = attributedText

        // Creating UIButton
        button.setTitle("Open Instagram", for: .normal)
        button.setTitleColor(.white,
                             for: .normal)
        button.titleLabel!.font =  UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor.systemBlue
        
        button.widthAnchor.constraint(equalToConstant: 180).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(button)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        //Constraints
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
      
    }
    
    func hideTextView(){
        textView.isHidden = true
        button.isHidden = true
    }
}

