//
//  CouponListSubCell.swift
//  qixiaofu
//
//  Created by ly on 2018/3/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CouponListSubCell: UICollectionViewCell {
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var brandLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var subJson = JSON(){
        didSet{
            self.priceLbl.text = subJson["coupon_price"].stringValue.replacingOccurrences(of: ".00", with: "")
            self.descLbl.text = "满" + subJson["full_reduction"].stringValue.replacingOccurrences(of: ".00", with: "") + "可用"
            if subJson["is_have"].intValue == 1{
                self.coverView.isHidden = false
                self.stateLbl.text = "已领取"
            }else{
                self.coverView.isHidden = true
                self.stateLbl.text = "立即领取"
            }
//            self.stateLbl.text = subJson[""].stringValue
//            self.brandLbl.text = subJson[""].stringValue
        }
    }
}
