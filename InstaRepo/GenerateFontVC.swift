//
//  GenerateFontVC.swift
//  Repost2
//
//  Created by dev on 5/28/22.
//


import UIKit
import MobileCoreServices
import StoreKit
import Toast_Swift

class GenerateFontVC: UIViewController, UITableViewDataSource , UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var generateBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var fonts = [String: [UIFont]]()
    var fontFamilyNames = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        generateBtn.setTitleColor(.white, for: .normal)
        // searchBar.text = "Neeraj Jangid"
        searchBar.delegate = self
        for familyName in UIFont.familyNames {
            var fontList = [UIFont]()
            for name in UIFont.fontNames(forFamilyName: familyName) {
                fontList.append(UIFont(name: name, size: 20)!)
            }
            fontFamilyNames.append(familyName)
            fonts[familyName] = fontList
        }
        
        print("fontFamilyNames -> ", fontFamilyNames)
        
        print("fonts -> ", fonts)
//        fontFamilyNames.sort()
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //searchBar.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(generateFontAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
       

           // ----- Copy ------
        

          // -------- Paste -------
//        let pb = UIPasteboard.general
//        let data = pb.data(forPasteboardType: kUTTypeRTF as String)

//        let pastedAttributedString = try! NSAttributedString(data: data!, options: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType], documentAttributes: nil)
        
        
        copyAttributedStringToPB()
    }
    
    func copyAttributedStringToPB() {

        let stringAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 29.0),
            NSAttributedString.Key.backgroundColor: UIColor.red,
        ]
        
        let attributedString = NSMutableAttributedString(string: "Hello world!", attributes: stringAttributes)

        do {
            let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf]
            let rtfData = try attributedString.data(from: NSMakeRange(0, attributedString.length), documentAttributes: documentAttributes)
//            let pb =
            UIPasteboard.general.setData(rtfData, forPasteboardType: kUTTypeRTF as String)
            
        }
        catch {
            print("error creating RTF from Attributed String")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (searchBar.text ?? "").isEmpty {
            return 0
        }
        return fontFamilyNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchBar.text ?? "").isEmpty {
            return 0
        }
        
        let familyName = fontFamilyNames[section]
        print("familyNameeeee \(familyName) \n /n")
        if let fontList = fonts[familyName] {
            print("fontList Count -> ", fontList.count)
            return fontList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (searchBar.text ?? "").isEmpty {
            return ""
        }
        return fontFamilyNames[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenerateFontCell") as! GenerateFontCell
        
        let familyName = fontFamilyNames[indexPath.section]
        print("familyName")
        if let fontList = fonts[familyName] {
            let font = fontList[indexPath.row]
            cell.label.text = searchBar.text ?? "" // font.fontName
            cell.label.font = font
//            cell.imageView?.image = #imageLiteral(resourceName: "Group")
            print("fonts -> \(familyName) \(indexPath.row)")
        }
        
        
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            if indexPath.section < 2 {
                cell.img.isHidden = true
            } else {
                cell.img.isHidden = false
            }
        } else {
            cell.img.isHidden = false
        }
       
        
        
        return cell
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchText \(searchText)")
        
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(String(describing: searchBar.text))")
    }
    
    @IBAction func generateFontAction(_ sender: Any) {
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var show = false
        if !UserDefaults.standard.bool(forKey: removeAdsUserKey) {
            if indexPath.section < 2 {
                show = true
            } else {
                show = false
            }
        } else {
           show = true
        }
    
        if show {
        
            let familyName = fontFamilyNames[indexPath.section]
        
            if let fontList = fonts[familyName] {
                
                let font = fontList[indexPath.row]
                
                let yourAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font]
                
                let formattedStr = NSAttributedString(string: searchBar.text ?? "", attributes: yourAttributes)
                
    //            UIPasteboard.setToPasteBoard(attributedString : formattedStr)
    //            let paste = UIPasteboard()
    //
    //            paste.setToPasteBoard(attributedString: formattedStr)
            
               // UIPasteboard.setToPasteBoard(attributedString: formattedStr)
                
                let tryStr = """
                <html>

                <head>

                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

                <meta http-equiv="Content-Style-Type" content="text/css">

                <title></title>

                <meta name="Generator" content="Cocoa HTML Writer">

                <style type="text/css">

                p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 17.0px '.SF UI Text'; color: #454545}

                span.s1 {font-family: '.SFUIText'; font-weight: normal; font-style: normal; font-size: 17.00pt}

                </style>

                </head>

                <body>

                <p class="p1"><span class="s1">Apple</span></p>

                </body>

                </html>
                """
                
    //            UIPformattedStrsteboard.value()   // .Type = kUTTypePlainText
                
                do {

    //                let data = Data(tryStr.utf8)

    //                    let data = try Data()
                
    //                    UIPasteboard.general.setMessageBody(tryStr, isHTML: true)
                
                    //UIPasteboard.general.

                    //  UIPasteboard.general.setData(data, forPasteboardType: kUTTypePlainText as String)
                    
                    var item = [kUTTypeUTF8PlainText as String : formattedStr.string as Any]

                    if let rtf = try? formattedStr.data(from: NSMakeRange(0, formattedStr.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtfd]) {
                        // The UTType constants are CFStrings that have to be
                        // downcast explicitly to String (which is one reason I
                        // defined item with a downcast in the first place)
                          item[kUTTypeFlatRTFD as String] = rtf
                    }

                    //UIPasteboard.general.items = [item]

                } catch {

                    print("error : \(error)")
                    
                }
                
                UIPasteboard.general.string = searchBar.text ?? ""
                //UIPasteboard.general.setToPasteBoard(attributedString: formattedStr)
                
            }
            
            // self.view.makeToast("\(self.searchBar.text ?? "") copied successfully")

            
            print("Pate Done")
        } else {
            let inAppVC = self.storyboard?.instantiateViewController(withIdentifier: "InAppPaymentVC") as! InAppPaymentVC
            self.present(inAppVC, animated: true, completion: nil)
        }
             
    }
    
}

import MobileCoreServices

extension UIPasteboard {
     func setToPasteBoard(attributedString: NSAttributedString) {
        do {
            let rtf = try attributedString.data(from: NSMakeRange(0, attributedString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf])
            items = [[kUTTypeRTF as String: NSString(data: rtf, encoding: String.Encoding.utf8.rawValue)!, kUTTypeUTF8PlainText as String: attributedString.string]]
        } catch {
        }
    }
}
