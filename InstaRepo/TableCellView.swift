//
//  TableCellView.swift
//  Repost2
//
//  Created by Tejas Vaghasiya on 01/12/21.
//

import UIKit

class RepostTableCell : UITableViewCell
{
    @IBOutlet var viewMain : UIView!
    
    @IBOutlet var imgRepost : UIImageView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblPostText : UILabel!
    @IBOutlet var lblTime : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


class ScheduledPostCell : UITableViewCell
{
    @IBOutlet var viewMain : UIView!
    
    @IBOutlet var imgRepost : UIImageView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblPostText : UILabel!
    @IBOutlet var lblTime : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

class AttributionCell : UITableViewCell
{
    @IBOutlet var imgIcon : UIImageView!
    @IBOutlet var imgSelected : UIImageView!
    @IBOutlet var lblName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

class HashTagCell : UITableViewCell
{
    @IBOutlet var imgIcon : UIImageView!
    @IBOutlet var lblName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

class SettingCell : UITableViewCell
{
    @IBOutlet var imgLogo : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblVersion : UILabel!
}

    
