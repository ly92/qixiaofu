//
//  EnrollEngineerCell.swift
//  qixiaofu
//
//  Created by ly on 2017/9/4.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnrollEngineerCell: UITableViewCell {
    
    var selectedActionBlock : (() -> Void)?
    var detailActionBlock : (() -> Void)?
    var chatActionBlock : (() -> Void)?
    
    var bill_type = ""
    
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var levelImgV1: UIImageView!
    @IBOutlet weak var levelImgV2: UIImageView!
    @IBOutlet weak var levelImageV3: UIImageView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var levelLblLeftDis: NSLayoutConstraint!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var offerPriceLbl: UILabel!
    @IBOutlet weak var engXinImgV: UIImageView!
    @IBOutlet weak var chatBtn: UIButton!
    
    
    var jsonModel : JSON = [] {
        didSet{
            self.iconImgV.setHeadImageUrlStr(jsonModel["ot_user_avatar"].stringValue)
            self.nameLbl.text = jsonModel["ot_user_name"].stringValue
            
            let level = jsonModel["dengji"].stringValue
            UIImageView.setLevelImageView(imgV1: self.levelImgV1, imgV2: self.levelImgV2, imgV3: self.levelImageV3, level: level)
            self.levelLbl.text = level + "级"
            if level.intValue % 3 == 0{
                self.levelLblLeftDis.constant = CGFloat( 5 + 3 * 18)
            }else{
                self.levelLblLeftDis.constant = CGFloat( 5 + (level.intValue % 3) * 18)
            }
            
            let price = jsonModel["supply_price"].stringValue
            self.offerPriceLbl.text = "报价：¥" + jsonModel["offer_price"].stringValue + "元"
            if price.isEmpty || price.floatValue == 0{
                self.moneyLbl.text = ""
            }else{
                if price.floatValue < 0{
                    self.moneyLbl.text = String.init(format: "平台2～5工作日退还：¥%.2f元", -price.floatValue)
                }else{
                    self.moneyLbl.text = String.init(format: "指定时需支付：¥%.2f元", price.floatValue)
                }
            }
            
            //保证金
            if jsonModel["is_bail"].stringValue.intValue == 1{
                self.engXinImgV.image = UIImage.init(named: "eng_xin_icon2")
            }else{
                self.engXinImgV.image = UIImage.init(named: "eng_xin_icon1")
            }
            
            //是否可聊
            if self.bill_type.intValue == 2{
                self.chatBtn.setImage(UIImage.init(named: "enro_icon3"), for: .normal)
                self.chatBtn.setTitleColor(UIColor.colorHex(hex: "cccccc"), for: .normal)
            }else{
                self.chatBtn.setImage(UIImage.init(named: "enro_icon2"), for: .normal)
                self.chatBtn.setTitleColor(UIColor.colorHex(hex: "FF6700"), for: .normal)
            }
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.iconImgV.layer.cornerRadius = 20
        self.iconImgV.addTapActionBlock {
            if self.detailActionBlock != nil{
                self.detailActionBlock!()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectedAction() {
        if self.selectedActionBlock != nil{
            self.selectedActionBlock!()
        }
    }
    
    
    @IBAction func chatAction() {
        if self.bill_type.intValue == 2{
            LYProgressHUD.showError("您需要先定价才可联系工程师")
        }else{
            if self.chatActionBlock != nil{
                self.chatActionBlock!()
            }
        }
    }
    
    @IBAction func engDetailAction() {
        if self.detailActionBlock != nil{
            self.detailActionBlock!()
        }
    }
    
}
