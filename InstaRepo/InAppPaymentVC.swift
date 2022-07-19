//
//  InAppPaymentVC.swift
//  Repost2
//
//  Created by dev on 5/7/22.
//

import UIKit
import StoreKit
import SVProgressHUD

class InAppPaymentVC: UIViewController {

    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var bestValue: UIButton!
    
    @IBOutlet weak var weekLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    
    @IBOutlet weak var weekMoneyLbl: UILabel!
    @IBOutlet weak var yearMonyLbl: UILabel!
    @IBOutlet weak var monthMoneyLbl: UILabel!
    
    var option = 1
    
    var myProduct: SKProduct?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        continueBtn.clipsToBounds = true
        continueBtn.layer.cornerRadius = continueBtn.frame.height / 2
        
        bestValue.layer.cornerRadius = 10
        
        monthView.layer.borderColor = ThemeColor2.cgColor
        yearView.layer.borderColor = ThemeColor2.cgColor
        weekView.layer.borderColor = ThemeColor2.cgColor
        
        monthView.cornerRadius = 10
        yearView.cornerRadius = 10
        weekView.cornerRadius = 10
        
        setPlan(option : option)
        
    }
    
    @IBAction func planSelectAction(_ sender: UIButton) {
        
        option = sender.tag
        setPlan(option : option)
       
        
    }
    
    @IBAction func continueToPay ( _ sender : UIButton! ) {
        payPopUP()
    }
    
    func payPopUP() {
        loaderShow()
        guard let myProduct = myProduct else {
            loaderHide()
            return
        }
        if SKPaymentQueue.canMakePayments() {
            
            let payment = SKPayment(product: myProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            
            loaderHide()
            
            let alert = UIAlertController(title: "Failed", message: "Your device is does not support!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setPlan(option : Int) {
        
        if option == 1 {
            
            weekView.backgroundColor = .white
            yearView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.8666666667, alpha: 1)
            monthView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.8666666667, alpha: 1)
            
            weekLbl.textColor = .black
            weekMoneyLbl.textColor = .black
            
            yearLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            yearMonyLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            
            monthLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            monthMoneyLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            
            weekView.layer.borderWidth = 3
            yearView.layer.borderWidth = 0
            monthView.layer.borderWidth = 0
            
        }
        else if option == 2 {
            weekView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.8666666667, alpha: 1)
            yearView.backgroundColor = .white
            monthView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.8666666667, alpha: 1)
            
            weekLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            weekMoneyLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            
            yearLbl.textColor = .black
            yearMonyLbl.textColor = .black
            
            monthLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            monthMoneyLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            
            weekView.layer.borderWidth = 0
            yearView.layer.borderWidth = 3
            monthView.layer.borderWidth = 0
        }
        else if option == 3 {
            
            weekView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.8666666667, alpha: 1)
            yearView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.8666666667, alpha: 1)
            monthView.backgroundColor = .white
            
            weekLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            weekMoneyLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            
            yearLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            yearMonyLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            
            monthLbl.textColor = .black
            monthMoneyLbl.textColor = .black
            
            weekView.layer.borderWidth = 0
            yearView.layer.borderWidth = 0
            monthView.layer.borderWidth = 3
        }
        
        if option == 1 {
            
            let request = SKProductsRequest(productIdentifiers: [InApp_ProductId_Weekly])
            request.delegate = self
            request.start()
            
        } else if option == 2 {
            
            let request = SKProductsRequest(productIdentifiers: [InApp_ProductId_Yearly])
            request.delegate = self
            request.start()
        } else if option == 3 {
            
            let request = SKProductsRequest(productIdentifiers: [InApp_ProductId_Monthly])
            request.delegate = self
            request.start()
        }
    }
    
    
    
    @IBAction func close( _ sender : UIButton! ){
        self.dismiss(animated: true, completion: nil)
    }
  
   

}

extension InAppPaymentVC : SKProductsRequestDelegate , SKPaymentTransactionObserver {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if let product = response.products.first {
            myProduct = product
            print("Identifier -> ", product.productIdentifier)
            print("Amount -> ", product.price)
            print("Currency -> ", product.priceLocale)
            print("LocalizedTitle -> " , product.localizedTitle)
            print("LocalizedTitle -> " , product.localizedDescription)
        }
    
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
            
                case .purchasing :
                    
                    //SKPaymentQueue.default().finishTransaction(transaction)
                    //SKPaymentQueue.default().remove(self)
                    // no op
                    break
                
                case .restored :
                
                    loaderHide()
                    UserDefaults.standard.set(true, forKey: removeAdsUserKey)
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                
                    // sucessTrantion()
                    
    //                    let receiptData = self.readReceipt()
    //
    //                    UserDefaults.standard.set(receiptData.IsSandbox , forKey: isSendBox)
                
                    self.dismiss(animated: true, completion: nil)
                
                    break
                
                case .purchased :
                    
                    loaderHide()
                    UserDefaults.standard.set(true, forKey: removeAdsUserKey)
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    inAppReceiptValidation()
                    // sucessTrantion()
                    
//                    let receiptData = self.readReceipt()
//                    
//                    UserDefaults.standard.set(receiptData.IsSandbox , forKey: isSendBox)
                
                    self.dismiss(animated: true, completion: nil)
                
                    break
                
                case .failed, .deferred :
                    loaderHide()
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    break
                
            }
        }
    }
    
    func sucessTrantion() {
        
        let alert = UIAlertController(title: "Sucess", message: "Transaction sucessfully completed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
   
    
    
}

extension InAppPaymentVC {
    
    func readReceipt() -> (Receipt: Data, IsSandbox: Bool) {
        let receiptURL = Bundle.main.appStoreReceiptURL!
        
        // We are running in sandbox when receipt URL ends with 'sandboxReceipt'
        let isSandbox = receiptURL.absoluteString.hasSuffix("sandboxReceipt")
        let receiptData = try! Data(contentsOf: receiptURL)
            
        return(receiptData, isSandbox)
    }
    
    func inAppReceiptValidation   () {
        //handle puchse Notification
        // store.rquest
        
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
                            
                            //let dt  = formatter.date(from: T##String)
                            
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
