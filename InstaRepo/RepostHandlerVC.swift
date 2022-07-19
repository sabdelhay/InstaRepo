//
//  RepostHandlerVC.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 02/12/21.
//

import UIKit
import AVKit
import SDWebImage
import Photos
import ColorSlider
import GoogleMobileAds

struct RepostAnnotation {
    let icon : String?
    let title : String?
    var isSelected : Bool?
}

class RepostHandlerVC: BaseViewController, UITextFieldDelegate {
    
    var myFinalVideoURL : URL?
    var selectedColor = String()
    var selectedPosition = String()
    var post: Post!
    var dbManager : DBManager?
    
    @IBOutlet var mainView : UIView!
    @IBOutlet var viewInner : UIView!
    @IBOutlet var viewInnerWidth : NSLayoutConstraint!
    @IBOutlet var viewInnerHeight : NSLayoutConstraint!
    @IBOutlet var viewInnerX : NSLayoutConstraint!
    @IBOutlet var viewInnerY : NSLayoutConstraint!
    
    @IBOutlet var ownerViewX : NSLayoutConstraint!
    @IBOutlet var ownerViewY : NSLayoutConstraint!
    
    @IBOutlet var imgPost : UIImageView!
    @IBOutlet var ownerView : UIView!
    @IBOutlet var ownerImage : UIImageView!
    @IBOutlet var ownerName : UILabel!
    @IBOutlet var ownerIcon : UIImageView!
    
    @IBOutlet var imgColor : UIImageView!
    @IBOutlet var lblPosition : UILabel!
    
    @IBOutlet var imgCopyCaption : UIImageView!
    
    @IBOutlet weak var attributeColl: UICollectionView!
    
    @IBOutlet weak var captionTextLbl: UILabel!
    @IBOutlet weak var captionTextField: UITextField!
    
    @IBOutlet weak var repostBtn: UIButton!
    @IBOutlet weak var collBckView: UIView!
    var player: AVPlayer!
    
    var avpController = AVPlayerViewController()
    
    var txtFieldEnable = false
    
    var attributesData = [
        ["icon" : "none", "title" : "None", "isSelected" : true ],
        ["icon" : "top_left", "title" : "Top Left", "isSelected" : false],
        ["icon" : "top_right", "title" : "Top Right", "isSelected" : false],
        ["icon" : "bottom_left", "title" : "Bottom Left", "isSelected" : false],
        ["icon" : "bottom_right", "title" : "Bottom Right", "isSelected" : false],
        ["icon" : "", "title" : "White", "isSelected" : true],
        ["icon" : "", "title" : "Black", "isSelected" : false]
    ]
    
    var attData = [RepostAnnotation]()
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.navigationItem.largeTitleDisplayMode = .never
        
        
        
        captionTextLbl.text = post.desc
        captionTextField.text = post.desc
    }
    
    func fillDataToAnnotation() {
        
        attData.append(RepostAnnotation(icon: "none", title: "None", isSelected: true))
        attData.append(RepostAnnotation(icon: "top_left", title: "Top Left", isSelected: false))
        attData.append(RepostAnnotation(icon: "top_right", title: "Top Right", isSelected: false))
        attData.append(RepostAnnotation(icon: "bottom_left", title: "Bottom Left", isSelected: false))
        attData.append(RepostAnnotation(icon: "bottom_right", title: "Bottom Right", isSelected: false))
        
        attData.append(RepostAnnotation(icon: "", title: "White", isSelected: true))
        attData.append(RepostAnnotation(icon: "", title: "Black", isSelected: false))
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        fillDataToAnnotation()
        self.LoadBannerView()
        
        
       
        self.imgPost.image = self.post.image
        
        captionTextField.delegate = self
        
        selectedColor = "White"
        selectedPosition = "Top Left"
        
        if selectedColor == "White"
        {
            self.imgColor.borderColor = ShadowColor
            self.imgColor.borderWidth = 2.0
            
            self.ownerView.backgroundColor = .white
            self.ownerName.textColor = .black
        }
        else
        {
            self.imgColor.backgroundColor = .black
            
            self.ownerView.backgroundColor = .black
            self.ownerName.textColor = .white
        }
        
        imgColor.borderColor = ShadowColor
        imgColor.borderWidth = 2.0
        
        lblPosition.text = selectedPosition
        
        self.imgCopyCaption.image = UIImage.init(named: "copy")
        
        self.imgCopyCaption.setImageTintColor(image: UIImage.init(named: "copy")!, color: UIColor.gray)
        
        let barButton = UIBarButtonItem.init(image: UIImage.init(named: "download"), style: .plain, target: self, action: #selector(self.DoneClick))
        barButton.tintColor = FontColor
        self.navigationItem.rightBarButtonItem = barButton
        
        self.title = "@\(self.post.user.username)"
        
        self.ownerName.text = self.post.user.username
        self.ownerImage.image = self.post.user.avatarImage
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.perform(#selector(self.frameSet), with: self, afterDelay: 0.3)
        
        if self.post.isVideo
        {
            self.perform(#selector(self.setupVideoPlayer), with: self, afterDelay: 0.5)
        }
        self.repostBtn.setTitleColor(UIColor.white, for: .normal)
        print("Post -> ")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(captionTextLblTargetAction))
        
        captionTextLbl.isUserInteractionEnabled = true
        captionTextLbl.addGestureRecognizer(tap)
        
        captionTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        
        captionTextField.delegate = self

    }
    
    @IBAction func changeCaptionAction(_ sender: UIButton) {
        
        txtFieldEnable = !txtFieldEnable
        self.captionTextLbl.isHidden = true
        if txtFieldEnable {
            self.captionTextField.isHidden = false
        } else {
            self.captionTextField.isHidden = false
        }
        
        self.captionTextField.becomeFirstResponder()
        
    }
    
    @objc func captionTextLblTargetAction() {
        UIPasteboard.general.string = captionTextLbl.text ?? ""
    }
    @objc func doneButtonClicked() {
        self.captionTextField.isHidden = true
        self.captionTextLbl.isHidden = false
    }
    @objc func DoneClick()
    {
        self.selectedType = 2
        
        appDelegate.adClickCount = appDelegate.adClickCount + 1
        
        if appDelegate.interstitial != nil && appDelegate.adClickCount >= maxClick
        {
            appDelegate.adClickCount = 0
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        else
        {
            let image = viewInner.TakeScreenshot()
            
            if post.isVideo
            {
                player.pause()
                self.DownloadVideo(image: image)
            }
            else
            {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                self.showAlertWithTitle(alertTitle: "", msg: "Image saved to album.")
            }
        }
        
    }
    
    @objc func frameSet()
    {
        DispatchQueue.main.async {
            let frame = AVMakeRect(aspectRatio: self.post.image!.size, insideRect: CGRect.init(origin: .zero, size: CGSize.init(width: SCREEN_WIDTH, height: SCREEN_WIDTH)))
            
            self.viewInnerWidth.constant = frame.width
            self.viewInnerHeight.constant = frame.height
            self.viewInnerX.constant = frame.origin.x
            self.viewInnerY.constant = frame.origin.y
            
            self.viewInner.updateConstraints()
            self.view.layoutSubviews()
        }
    }
    
    @IBAction func btnCopyClick(_ sender : UIButton)
    {
        
        self.imgCopyCaption.image = UIImage.init(named: "copyDone")
        
        self.imgCopyCaption.setImageTintColor(image: UIImage.init(named: "copyDone")!, color: UIColor.gray)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.imgCopyCaption.setImageTintColor(image: UIImage.init(named: "copy")!, color: UIColor.gray)
        }
        
        UIPasteboard.general.string = self.post.desc
        
        self.view.makeToast("caption copied successfully")
    }
    
    @IBAction func btnAttributionTap(_ sender : UIButton)
    {
        
        let controller = storyBoard.instantiateViewController(withIdentifier: "AttributionVC") as! AttributionVC
        controller.selectedColor = selectedColor
        controller.selectedPosition = selectedPosition
        controller.callbackColor = { value in
            
            self.selectedColor = value
            
            if value == "White"
            {
                self.imgColor.borderColor = ShadowColor
                self.imgColor.borderWidth = 2.0
                self.ownerView.backgroundColor = .white
                self.ownerName.textColor = .black
            }
            else
            {
                self.imgColor.backgroundColor = .black
                self.ownerView.backgroundColor = .black
                self.ownerName.textColor = .white
            }
            
        }
        
        controller.callbackPosition = { value in
            self.lblPosition.text = value
            self.selectedPosition = value
            self.ChangeLayout()
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @objc func setupVideoPlayer()
    {
        let frame = AVMakeRect(aspectRatio: self.post.image!.size, insideRect: self.mainView.bounds)
        
        self.player = AVPlayer(url: self.post.videoUrl!)
        self.player.play()
        self.player?.automaticallyWaitsToMinimizeStalling = false
        self.avpController.player = self.player
        self.avpController.showsPlaybackControls = false
        self.avpController.view.frame = frame
        self.addChild(self.avpController)
        self.mainView.addSubview(self.avpController.view)
        
        self.imgPost.isHidden = true
        self.mainView.bringSubviewToFront(self.viewInner)
    }
    
    //    @IBAction func btnShareClick(_ sender: UIButton)
    //    {
    //        self.selectedType = 5
    //
    //        appDelegate.adClickCount = appDelegate.adClickCount + 1
    //
    //        if appDelegate.interstitial != nil && appDelegate.adClickCount >= maxClick
    //        {
    //            appDelegate.adClickCount = 0
    //            appDelegate.interstitial?.fullScreenContentDelegate = self
    //            appDelegate.interstitial?.present(fromRootViewController: self)
    //        }
    //        else
    //        {
    //            let image = viewInner.TakeScreenshot()
    //
    //            if post.isVideo
    //            {
    //                player.pause()
    //                self.DownloadVideo(image: image)
    //            }
    //            else
    //            {
    //                DispatchQueue.main.async {
    //                    let textToShare = APP_NAME
    //
    //                    let activityItems: [Any] = [image as Any, textToShare]
    //                    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    //
    //                    activityController.popoverPresentationController?.sourceView = self.view
    //                    activityController.popoverPresentationController?.sourceRect = self.view.frame
    //
    //                    self.present(activityController, animated: true, completion: nil)
    //                }
    //
    //            }
    //        }
    //    }
    
    @IBAction func btnSaveClick(_ sender: UIButton)
    {
        self.selectedType = 1
        
        appDelegate.adClickCount = appDelegate.adClickCount + 1
        
        if appDelegate.interstitial != nil && appDelegate.adClickCount >= maxClick
        {
            appDelegate.adClickCount = 0
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }
        else
        {
            let image = viewInner.TakeScreenshot()
            
            if post.isVideo
            {
                player.pause()
                self.DownloadVideo(image: image)
            }
            else
            {
                postImageToInstagram(image: image)
                //                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                //                if let instagramUrl = URL(string: "instagram://share")
                //                {
                //                    if UIApplication.shared.canOpenURL(instagramUrl)
                //                    {
                //                        UIApplication.shared.open(instagramUrl)
                //                    }
                //                    else
                //                    {
                //                        self.showAlertWithTitle(alertTitle: "", msg: "Instagram is not installed.")
                //                    }
                //                }
            }
        }
    }
    
    func postImageToInstagram(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            print(error)
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let lastAsset = fetchResult.firstObject as? PHAsset {
            
            let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
            
            if UIApplication.shared.canOpenURL(url) {
                
                UIApplication.shared.open(url)
                
            } else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: "Instagram is not installed", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
            
        }
    }
    
    
    func ChangeLayout()
    {
        ownerView.isHidden = false
        
        if self.selectedPosition == "Top Left"
        {
            ownerView.frame = CGRect.init(x: 0, y: 0, width: ownerView.frame.width, height: 26)
            ownerViewX.constant = 0
            ownerViewY.constant = 0
        }
        else if self.selectedPosition == "Top Right"
        {
            ownerView.frame = CGRect.init(x: viewInner.frame.width - ownerView.frame.width, y: 0, width: ownerView.frame.width, height: 26)
            ownerViewX.constant = viewInner.frame.width - ownerView.frame.width
            ownerViewY.constant = 0
        }
        else if self.selectedPosition == "Bottom Left"
        {
            ownerView.frame = CGRect.init(x: 0, y: viewInner.frame.height - 26, width: ownerView.frame.width, height: 26)
            ownerViewX.constant = 0
            ownerViewY.constant = viewInner.frame.height - 26
        }
        else if self.selectedPosition == "Bottom Right"
        {
            ownerView.frame = CGRect.init(x: viewInner.frame.width - ownerView.frame.width, y: viewInner.frame.height - 40, width: ownerView.frame.width, height: 26)
            ownerViewX.constant = viewInner.frame.width - ownerView.frame.width
            ownerViewY.constant = viewInner.frame.height - 26
        }
        else
        {
            ownerView.isHidden = true
        }
        
        self.viewDidLayoutSubviews()
    }
    
    func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            post.desc = updatedText
            self.captionTextLbl.text = post.desc
            let query = "UPDATE Reposts SET desc = '\(updatedText)' WHERE dateTime = '\(post.time)'"
            //dbManager?.loadData(fromDB: String.init(format: "select * from Reposts ORDER BY id DESC"))! as NSArray
            dbManager?.executeQuery(query)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.captionTextField.isHidden = true
        self.captionTextLbl.isHidden = false
        return false
    }
    
}


extension RepostHandlerVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttributeCollCell", for: indexPath) as! AttributeCollCell
        
        let data = attData[indexPath.row]
        
        let img = (data.icon) ?? ""
        
        let isSelected = ( data.isSelected) ?? false
    
        cell.attributeImage.image = UIImage(named: img)

        cell.attributeImage.isHidden = false
        
        cell.index = indexPath.row
        
        if indexPath.row == 5
        {
            if isSelected {
                cell.contentView.backgroundColor = ThemeColor2
            } else if indexPath.row == 6 {
                cell.contentView.backgroundColor = .clear
            }
            
            cell.attributeImage.isHidden = true
            
            cell.isWhite = true
        }
        else if indexPath.row == 6
        {
            if isSelected {
                cell.contentView.backgroundColor = ThemeColor2
            } else if indexPath.row == 5 {
                cell.contentView.backgroundColor = .clear
            }
            
            cell.attributeImage.isHidden = true
            
            cell.isWhite = false
        
        } else {
            if isSelected {
                cell.contentView.backgroundColor = ThemeColor2
            } else {
                cell.contentView.backgroundColor = UIColor.clear
            }
        }
        
        cell.layoutIfNeeded()
        return cell
        
    }
    //let data = attData[indexPath.row]
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        appDelegate.adClickCount = appDelegate.adClickCount + 1
        
        if appDelegate.interstitial != nil && appDelegate.adClickCount >= maxClick
        {
            appDelegate.interstitial?.fullScreenContentDelegate = self
            appDelegate.interstitial?.present(fromRootViewController: self)
        }

        for (index, data ) in attData.enumerated() {
            
            if attData[indexPath.row].title == "White" && data.title == "White"  {
                
                attData[index].isSelected = true
                attData[index + 1].isSelected = false
                
                self.attributeColl.reloadItems(at: [IndexPath(row: index, section: 0)])
                self.attributeColl.reloadItems(at: [IndexPath(row: index + 1, section: 0)])
                
            } else if attData[indexPath.row].title == "Black" && data.title == "Black"  {
                
                attData[index].isSelected = true
                attData[index - 1].isSelected = false
                
                self.attributeColl.reloadItems(at: [IndexPath(row: index, section: 0)])
                self.attributeColl.reloadItems(at: [IndexPath(row: index - 1, section: 0)])

            } else {
                
                if index == indexPath.row {
                    attData[index].isSelected = true
                } else {
                    if (attData[indexPath.row].title != "White" && data.title == "White") || (attData[indexPath.row].title != "Black" && data.title == "Black") {
                        
                    } else {
                        attData[index].isSelected = false
                    }
                }
            }
        }
        // print("attData -> ", attData)
        self.attributeColl.reloadData()
        
        if ( attData[indexPath.row].title == "White" || attData[indexPath.row].title == "Black" )
        {
            let dic = self.attData[indexPath.row]
            let name = dic.title ?? ""
            self.selectedColor = name
            //callbackColor!(self.selectedColor)
            
            
            //self.selectedColor = value
            
            if attData[indexPath.row].title == "White"
            {
                self.imgColor.borderColor = ShadowColor
                self.imgColor.borderWidth = 2.0
                self.ownerView.backgroundColor = .white
                self.ownerName.textColor = .black
            }
            else
            {
                self.imgColor.backgroundColor = .black
                self.ownerView.backgroundColor = .black
                self.ownerName.textColor = .white
            }
        }
        else
        {
            let dic = self.attData[indexPath.row]
            let name = dic.title ?? ""
            self.lblPosition.text = name
            self.selectedPosition = name
            self.ChangeLayout()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize( width: 40, height: 40 )
    }
    
}

extension RepostHandlerVC
{
    func DownloadVideo(image : UIImage)
    {
        ProcessLoader.show(animated: true)
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.post.videoUrl?.absoluteString ?? ""),
               let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async
                {
                    urlData.write(toFile: filePath, atomically: true)
                    self.saveVideoTap(fileURL: URL.init(fileURLWithPath: filePath), image: image)
                }
            }
        }
    }
    
    func saveVideoTap(fileURL : URL, image : UIImage) {
        
        let composition = AVMutableComposition()
        let vidAsset = AVURLAsset(url: fileURL, options: nil)
        
        // get video track
        let vtrack =  vidAsset.tracks(withMediaType: AVMediaType.video)
        let videoTrack: AVAssetTrack = vtrack[0]
        let vid_timerange = CMTimeRangeMake(start: CMTime.zero, duration: vidAsset.duration)
        
        let tr: CMTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 10.0, preferredTimescale: 600))
        composition.insertEmptyTimeRange(tr)
        
        let trackID:CMPersistentTrackID = CMPersistentTrackID(kCMPersistentTrackID_Invalid)
        
        if let compositionvideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: trackID) {
            
            do {
                try compositionvideoTrack.insertTimeRange(vid_timerange, of: videoTrack, at: CMTime.zero)
            } catch {
                print("error")
            }
            
            compositionvideoTrack.preferredTransform = videoTrack.preferredTransform
            
        } else {
            print("unable to add video track")
            ProcessLoader.hide()
            return
        }
        
        // audio track
        let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: trackID)!
        
        let audioTracks =  vidAsset.tracks(withMediaType: AVMediaType.audio)
        for audioTrack in audioTracks {
            try! compositionAudioTrack.insertTimeRange(vid_timerange, of: audioTrack, at: CMTime.zero)
        }
        
        // Watermark Effect
        let size = videoTrack.naturalSize
        let imglogo = image.sd_resizedImage(with: size, scaleMode: .aspectFit)
        let imglayer = CALayer()
        imglayer.contents = imglogo?.cgImage
        imglayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        imglayer.opacity = 1.0
        
        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        parentlayer.addSublayer(imglayer)
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        
        // instruction for watermark
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
        let videotrack = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        instruction.layerInstructions = NSArray(object: layerinstruction) as [AnyObject] as! [AVVideoCompositionLayerInstruction]
        layercomposition.instructions = NSArray(object: instruction) as [AnyObject] as! [AVVideoCompositionInstructionProtocol]
        
        //  create new file to receive data
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        let movieFilePath = docsDir.appendingPathComponent("result.mov")
        let movieDestinationUrl = NSURL(fileURLWithPath: movieFilePath)
        
        // use AVAssetExportSession to export video
        let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality)
        assetExport?.outputFileType = AVFileType.mov
        assetExport?.videoComposition = layercomposition
        
        // Check exist and remove old file
        FileManager.default.removeItemIfExisted(movieDestinationUrl as URL)
        
        assetExport?.outputURL = movieDestinationUrl as URL
        assetExport?.exportAsynchronously(completionHandler: { [self] in
            switch assetExport!.status {
            case AVAssetExportSession.Status.failed:
                print("failed")
                ProcessLoader.hide()
                print(assetExport?.error ?? "unknown error")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled")
                ProcessLoader.hide()
                print(assetExport?.error ?? "unknown error")
            default:
                print("Movie complete")
                ProcessLoader.hide()
                self.myFinalVideoURL = movieDestinationUrl as URL
                
                
                if self.selectedType == 1
                {
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieDestinationUrl as URL)
                    }) { saved, error in
                        if saved {
                            print("Saved")
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                            
                            let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                            
                            if let lastAsset = fetchResult.firstObject as? PHAsset {
                                
                                let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
                                
                                if UIApplication.shared.canOpenURL(url) {
                                    DispatchQueue.main.async {
                                        UIApplication.shared.open(url)
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        let alertController = UIAlertController(title: "Error", message: "Instagram is not installed", preferredStyle: .alert)
                                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                }
                else if self.selectedType == 2
                {
                    //save
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieDestinationUrl as URL)
                    }) { saved, error in
                        if saved {
                            print("Saved")
                            
                            self.showAlertWithTitle(alertTitle: "", msg: "Video saved to album.")
                        }
                    }
                }
            }
        })
    }
}

extension FileManager
{
    func removeItemIfExisted(_ url:URL) -> Void {
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            }
            catch {
                print("Failed to delete file")
            }
        }
        
    }
}

extension RepostHandlerVC : GADFullScreenContentDelegate
{
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        
        print("Ad did fail to present full screen content.")
        
        if self.selectedType == 1
        {
            let image = viewInner.TakeScreenshot()
            
            if post.isVideo
            {
                player.pause()
                self.DownloadVideo(image: image)
            }
            else
            {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
                if let instagramUrl = URL(string: "instagram://share")
                {
                    if UIApplication.shared.canOpenURL(instagramUrl)
                    {
                        UIApplication.shared.open(instagramUrl)
                    }
                    else
                    {
                        self.showAlertWithTitle(alertTitle: "", msg: "Instagram is not installed.")
                    }
                }
            }
        }
        else if self.selectedType == 2
        {
            let image = viewInner.TakeScreenshot()
            
            if post.isVideo
            {
                player.pause()
                self.DownloadVideo(image: image)
            }
            else
            {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                self.showAlertWithTitle(alertTitle: "", msg: "Image saved to album.")
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
            let image = viewInner.TakeScreenshot()
            
            if post.isVideo
            {
                player.pause()
                self.DownloadVideo(image: image)
            }
            else
            {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
                if let instagramUrl = URL(string: "instagram://share")
                {
                    if UIApplication.shared.canOpenURL(instagramUrl)
                    {
                        UIApplication.shared.open(instagramUrl)
                    }
                    else
                    {
                        self.showAlertWithTitle(alertTitle: "", msg: "Instagram is not installed.")
                    }
                }
            }
        }
        else if self.selectedType == 2
        {
            let image = viewInner.TakeScreenshot()
            
            if post.isVideo
            {
                player.pause()
                self.DownloadVideo(image: image)
            }
            else
            {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                self.showAlertWithTitle(alertTitle: "", msg: "Image saved to album.")
            }
        }
        appDelegate.LoadGADInterstitialAd()
    }
}

