//
//  EngineerDetailCell.swift
//  qixiaofu
//
//  Created by ly on 2017/6/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngineerDetailCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var authenticationImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var levelImgV1: UIImageView!
    @IBOutlet weak var levelImgV2: UIImageView!
    @IBOutlet weak var levelImageV3: UIImageView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var levelLblLeftDis: NSLayoutConstraint!
    @IBOutlet weak var engXinImgV: UIImageView!
    @IBOutlet weak var engXinLbl: UILabel!
    
    var jsonModel : JSON = [] {
        didSet{
            self.iconImgV.setHeadImageUrlStr(jsonModel["member_avatar"].stringValue)
            self.nameLbl.text = jsonModel["member_truename"].stringValue
            if jsonModel["is_real"].stringValue.intValue == 1{
                self.authenticationImgV.image = #imageLiteral(resourceName: "img_authentication")
            }else{
                self.authenticationImgV.isHidden = true
            }
            
            let level = jsonModel["dengji"].stringValue
            UIImageView.setLevelImageView(imgV1: self.levelImgV1, imgV2: self.levelImgV2, imgV3: self.levelImageV3, level: level)
            self.levelLbl.text = level + "级"
            if level.intValue % 3 == 0{
                self.levelLblLeftDis.constant = CGFloat( 5 + 3 * 18)
            }else{
                self.levelLblLeftDis.constant = CGFloat( 5 + (level.intValue % 3) * 18)
            }
            
            //保证金
            if jsonModel["is_bail"].stringValue.intValue == 1{
                self.engXinImgV.image = UIImage.init(named: "eng_xin_icon2")
                self.engXinLbl.text = "已在平台中缴纳保证金"
            }else{
                self.engXinImgV.image = UIImage.init(named: "eng_xin_icon1")
                self.engXinLbl.text = "未在平台中缴纳保证金"
            }
            
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.iconImgV.layer.cornerRadius = 22.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
