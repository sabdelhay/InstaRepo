//
//  AttributeCollCell.swift
//  Repost2
//
//  Created by dev on 5/23/22.
//

import UIKit

class AttributeCollCell: UICollectionViewCell {
    
    @IBOutlet weak var attributeImage : UIImageView!
    @IBOutlet weak var attributeImageBckView: UIView!
    
    var isWhite : Bool?
    var index : Int = 0

    override func layoutSubviews() {
        
        if isWhite != nil {
            
            layer.cornerRadius = 0
            
            if (index == 5 || index == 6) {
                if isWhite ?? false {
                    attributeImageBckViewWhite()
                } else {
                    attributeImageBckViewBlack()
                }
            }
            
        } else {
            layer.cornerRadius = 0
        }
    }
    
    func attributeImageBckViewWhite() {
        layer.cornerRadius = frame.height / 2
        attributeImageBckView.backgroundColor = .white
        attributeImageBckView.borderColor = ShadowColor
        attributeImageBckView.clipsToBounds = true
        attributeImageBckView.layer.cornerRadius = attributeImageBckView.frame.height / 2
    }
    
    func attributeImageBckViewBlack() {
        layer.cornerRadius = frame.height / 2
        attributeImageBckView.backgroundColor = .black
        attributeImageBckView.borderColor = ShadowColor
        attributeImageBckView.clipsToBounds = true
        attributeImageBckView.layer.cornerRadius = attributeImageBckView.frame.height / 2
    }
}
