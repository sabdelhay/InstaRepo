//
//  TimeScheduleVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 01/12/21.
//

import UIKit
import GoogleMobileAds

class TimeScheduleVC: BaseViewController {

    @IBOutlet var txtDate : UITextField!
    @IBOutlet var txtTime : UITextField!

    var dbManager = DBManager()

    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    var selectedPost = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Schedule Repost"
        dbManager = DBManager.init(databaseFilename: "RepostDB.sqlite")

        txtDate.delegate = self
        txtTime.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            self.LoadBannerView()
        }  else {
            bannerViewHeight.constant = 0
        }
    }

    func showDatePicker()
    {
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        let toolbar = UIToolbar();
        
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        txtDate.inputAccessoryView = toolbar
        txtDate.inputView = datePicker
        
        txtTime.inputAccessoryView = toolbar
        txtTime.inputView = datePicker
    }
    
    @objc func donedatePicker()
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        txtDate.text = formatter.string(from: datePicker.date)

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "hh:mm a"
        txtTime.text = formatter2.string(from: datePicker.date)
        self.view.endEditing(true)
        
        txtDate.delegate = self
        txtTime.delegate = self

    }
    
    @objc func cancelDatePicker()
    {
        self.view.endEditing(true)
        
        txtDate.delegate = self
        txtTime.delegate = self
    }
    
    @objc func doneTimePicker()
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        txtTime.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
        txtDate.delegate = self
        txtTime.delegate = self
    }
    
    @IBAction func btnAddClick(_ sender : UIButton)
    {        
//        if appDelegate.interstitial != nil
//        {
//            appDelegate.interstitial?.fullScreenContentDelegate = self
//            appDelegate.interstitial?.present(fromRootViewController: self)
//        }
//        else
//        {
            if txtTime.text == ""
            {
                Toast.show(message: "Select Date&Time.", controller: self)
            }
            else
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MMM-yyyy hh:mm a"
                let datenTime = formatter.string(from: datePicker.date)
                
                let updateId = self.selectedPost[0] as! String
                
                let updateQuery =  String.init(format: "UPDATE Reposts SET isScheduled='true',scheduleTime='\(datenTime)' WHERE id='%@'", updateId)
                
                dbManager.executeQuery(updateQuery)
                
                self.scheduleNotification(identifier: updateId)
                
                DispatchQueue.main.async {
                    Toast.show(message: "Respost Notification Scheduled.", controller: self)
                }
            }
//        }
    }
    
    func scheduleNotification(identifier: String) {
        
        let notificationCenter = UNUserNotificationCenter.current()

        //Compose New Notificaion
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.body = "It's time to repost. Click to repost scheduled post."
        content.badge = 1
        
        let interval = datePicker.date.timeIntervalSince(Date())
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
            else{
                DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                print("Notifiocation Scheduled.")
            }
            }
        }
    }
}


extension TimeScheduleVC : UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.showDatePicker()
    }
}

extension TimeScheduleVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        
        if txtTime.text == ""
        {
            Toast.show(message: "Select Date&Time.", controller: self)
        }
        else
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy hh:mm a"
            let datenTime = formatter.string(from: datePicker.date)
            
            let updateId = self.selectedPost[0] as! String
            
            let updateQuery =  String.init(format: "UPDATE Reposts SET isScheduled='true',scheduleTime='\(datenTime)' WHERE id='%@'", updateId)
            
            dbManager.executeQuery(updateQuery)
            
            self.scheduleNotification(identifier: updateId)
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
        
        if txtTime.text == ""
        {
            Toast.show(message: "Select Date&Time.", controller: self)
        }
        else
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy hh:mm a"
            let datenTime = formatter.string(from: datePicker.date)
            
            let updateId = self.selectedPost[0] as! String
            
            let updateQuery =  String.init(format: "UPDATE Reposts SET isScheduled='true',scheduleTime='\(datenTime)' WHERE id='%@'", updateId)
            
            dbManager.executeQuery(updateQuery)
            
            self.scheduleNotification(identifier: updateId)
        }
        appDelegate.LoadGADInterstitialAd()
    }
}
