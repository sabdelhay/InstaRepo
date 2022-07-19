import UIKit
import GoogleMobileAds


class BaseViewController: UIViewController{
    
    @IBOutlet var bannerView : GADBannerView!
    @IBOutlet var bannerViewHeight : NSLayoutConstraint!

    var selectedType = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let gradientLayer = CAGradientLayer()
//
//        let layerY = -UIApplication.shared.statusBarFrame.size.height as CGFloat
//
//        let layerHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height as CGFloat
//
//        gradientLayer.frame = CGRect(x: 0, y: layerY, width: 1366, height: layerHeight)
//
//        gradientLayer.colors = [UIColor(red: 252/255, green: 0/255, blue: 16/255, alpha: 1.0).cgColor, UIColor(red: 29/255, green: 6/255, blue: 40/255, alpha: 1.0).cgColor]
//        self.navigationController?.navigationBar.layer.addSublayer(gradientLayer)
        
//        let gradientLayer = CAGradientLayer()
//
//                let layerY = -UIApplication.shared.statusBarFrame.size.height as CGFloat
//
//                let layerHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height as CGFloat
//
//                gradientLayer.frame = CGRect(x: 0, y: layerY, width: 1366, height: layerHeight)
//
//        gradientLayer.colors = [UIColor(red: 252/255, green: 0/255, blue: 16/255, alpha: 1.0).cgColor, UIColor(red: 29/255, green: 6/255, blue: 40/255, alpha: 1.0).cgColor]
//
//
//                self.navigationController?.navigationBar.layer.insertSublayer(gradientLayer, at: 0)
        
        //        gradientLayer.colors = [UIColor(red: 16/255.0, green: 57/255.0, blue: 82/255.0, alpha: 1.0).cgColor, UIColor(red: 17/255.0, green: 132/255.0, blue: 157/255.0, alpha: 1.0).cgColor]

    }
    
//    @objc func addTapped(_ button: UIButton){
//    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let navigationBar = self.navigationController?.navigationBar

        navigationBar?.shadowImage = nil
        navigationBar?.setBackgroundImage(nil, for: .default)
        navigationBar?.isTranslucent = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            if Core.shared.isNewUser(){
                // Show onboarding
                let vc = storyboard?.instantiateViewController(withIdentifier: "welcome") as! WelcomeViewController
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
    }
        
    
    func LoadBannerView()
    {
        if bannerViewHeight != nil
        {
            bannerViewHeight.constant = 0
        }
        
        if BANNER_ADID != ""
        {
            bannerView.adSize = kGADAdSizeBanner
            bannerView.rootViewController = self
            bannerView.delegate = self
            bannerView.adUnitID = BANNER_ADID
            bannerView.load(GADRequest())
        }
    }
    
    
}

extension BaseViewController : GADBannerViewDelegate
{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        
        if bannerViewHeight != nil
        {
            bannerViewHeight.constant = 50
        }
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error)
    {
        if bannerViewHeight != nil
        {
            bannerViewHeight.constant = 0
        }
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView)
    {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView)
    {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView)
    {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView)
    {
      print("bannerViewDidDismissScreen")
    }
}


class Core{
    static let shared = Core()
    
    func isNewUser() -> Bool{
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser(){
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
    
    
    
}


