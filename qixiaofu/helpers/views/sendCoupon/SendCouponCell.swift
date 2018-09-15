//
//  SendCouponCell.swift
//  qixiaofu
//
//  Created by ly on 2018/7/20.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SendCouponCell: UITableViewCell {

    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var fullPriceLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    var subJson = JSON(){
        didSet{
            // coupon_type 1代测 2代卖 3代存 4商城优惠券
            if subJson["coupon_type"].stringValue.intValue == 1{
                self.imgV.image = #imageLiteral(resourceName: "coupon_type_icon_1")
            }else if subJson["coupon_type"].stringValue.intValue == 2{
                self.imgV.image = #imageLiteral(resourceName: "coupon_type_icon_2")
            }else if subJson["coupon_type"].stringValue.intValue == 3{
                self.imgV.image = #imageLiteral(resourceName: "coupon_type_icon_3")
            }else if subJson["coupon_type"].stringValue.intValue == 4{
                self.imgV.image = #imageLiteral(resourceName: "coupon_type_icon_5")
            }else{
                self.imgV.image = #imageLiteral(resourceName: "placeholder_icon")
            }
            self.nameLbl.text = subJson["coupon_name"].stringValue
            self.timeLbl.text = "有效期至：" + Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: subJson["end_time"].stringValue)
            self.fullPriceLbl.text = "满" + subJson["full_reduction"].stringValue + "可用"
            self.priceLbl.text = subJson["coupon_price"].stringValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.subView.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
