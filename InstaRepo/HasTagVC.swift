//
//  HasTagVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 17/02/33.
//

import UIKit
import TagListView
import GoogleMobileAds

class HasTagVC: BaseViewController, TagListViewDelegate {

    @IBOutlet var tagListView : TagListView!

    var tagsStr = ""
    
    var selectedTags : [String] = []

    var adLoader = GADAdLoader()
    var nativeAdsArray = NSMutableArray()

    @IBOutlet weak var nativeAdView: GADNativeAdView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nativeAdView.isHidden = true
        
        self.tagListView.removeAllTags()
        let tagList = tagsStr.components(separatedBy: " ")
        self.tagListView.addTags(tagList)
        self.tagListView.textFont = UIFont(name: "AvenirNext-Medium", size: 15.0)!
        self.tagListView.alignment = .center
        self.tagListView.delegate = self
        self.tagListView.isMultipleTouchEnabled = true
        
        for tagview in self.tagListView.tagViews
        {
            if self.selectedTags.contains(tagview.titleLabel!.text ?? "")
            {
                tagview.isSelected = true
            }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            self.LoadBannerView()
        } else {
            bannerViewHeight.constant = 0
        }
    }
    func setAdonView(nativeAd: GADNativeAd)
    {
        nativeAdView.isHidden = false
        nativeAdView?.nativeAd = nativeAd
        (nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline

        if UIDevice.current.userInterfaceIdiom == .pad {
            (nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline! + "\n" + nativeAd.body!
        }
        (nativeAdView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image
    }

    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        if selectedTags.contains(title)
        {
            selectedTags.remove(object: title)
            tagView.isSelected = false
        }
        else
        {
            selectedTags.append(title)
            tagView.isSelected = true
        }
        sender.reloadInputViews()
    }
    
    @IBAction func btnCopyPress(_ sender : UIButton)
    {
        self.selectedType = 1
        if appDelegate.interstitial != nil
        {
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        else
        {
            let tags = self.selectedTags
            
            if tags.count == 0
            {
                Toast.show(message: "No HashTags Selected!", controller: self)
                return
            }
            
            UIPasteboard.general.string = tags.joined(separator: " ")
            Toast.show(message: "HashTags Copied!", controller: self)
        }
    }
    
    @IBAction func btnCopyAllPress(_ sender : UIButton)
    {
        self.selectedType = 2

        if appDelegate.interstitial != nil
        {
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        else
        {
            let tagList = tagsStr.components(separatedBy: " ")
            
            self.selectedTags = tagList
            
            UIPasteboard.general.string = tagsStr
            
            Toast.show(message: "HashTags Copied!", controller: self)
            
            tagListView.reloadInputViews()
        }
    }
}

extension HasTagVC : GADNativeAdLoaderDelegate
{
    func adLoadNativeAd()
    {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        
        adLoader = GADAdLoader(adUnitID: APPNATIVEAD, rootViewController: self, adTypes: [GADAdLoaderAdType.native], options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("Finish loading ")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print(error)
        print("Error",error)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd)
    {
        nativeAdView.isHidden = false
        self.setAdonView(nativeAd: nativeAd)
        
        print("didReceive GADNativeAd")
    }
}

extension HasTagVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        
        if self.selectedType == 1
        {
            let tags = self.selectedTags
            
            if tags.count == 0
            {
                Toast.show(message: "No HashTags Selected!", controller: self)
                return
            }
            
            UIPasteboard.general.string = tags.joined(separator: " ")
            Toast.show(message: "HashTags Copied!", controller: self)
        }
        else if self.selectedType == 2
        {
            let tagList = tagsStr.components(separatedBy: " ")
            
            self.selectedTags = tagList
            
            UIPasteboard.general.string = tagsStr
            
            Toast.show(message: "HashTags Copied!", controller: self)
            
            tagListView.reloadInputViews()
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
            let tags = self.selectedTags
            
            if tags.count == 0
            {
                Toast.show(message: "No HashTags Selected!", controller: self)
                return
            }
            
            UIPasteboard.general.string = tags.joined(separator: " ")
            Toast.show(message: "HashTags Copied!", controller: self)
        }
        else if self.selectedType == 2
        {
            let tagList = tagsStr.components(separatedBy: " ")
            
            self.selectedTags = tagList
            
            UIPasteboard.general.string = tagsStr
            
            Toast.show(message: "HashTags Copied!", controller: self)
            
            tagListView.reloadInputViews()
        }
        appDelegate.LoadGADInterstitialAd()
        
    }
}

