//
//  LogoAnimationView.swift
//  AnimatedGifLaunchScreen-Example
//
//  Created by Amer Hukic on 13/09/2018.
//  Copyright © 2018 Amer Hukic. All rights reserved.
//

import UIKit
import SwiftyGif

class LogoAnimationView : UIView {
    
    let logoGifImageView : UIImageView = {
        guard let gifImage = try? UIImage(gifName: "logo1.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: -1)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        addSubview(logoGifImageView)
        
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
