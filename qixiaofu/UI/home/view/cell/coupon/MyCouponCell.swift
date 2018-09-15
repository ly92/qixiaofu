//
//  MyCouponCell.swift
//  qixiaofu
//
//  Created by ly on 2018/3/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyCouponCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var brandLbl: UILabel!
    @IBOutlet weak var rightTopImgV: UIImageView!
    @IBOutlet weak var couponBgImgV: UIImageView!
    @IBOutlet weak var moneyLogoLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var selectedBtnW: NSLayoutConstraint!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var limitLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var countBg: UIImageView!
    @IBOutlet weak var countView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.btnView.layer.cornerRadius = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var subJson = JSON(){
        didSet{
            self.selectedBtnW.constant = 0
            self.nameLbl.text = subJson["coupon_name"].stringValue
            self.timeLbl.text = "有效期至：" + Date.dateStringFromDate(format: Date.dateFormatString(), timeStamps: subJson["end_time"].stringValue)
            self.priceLbl.text = subJson["coupon_price"].stringValue.replacingOccurrences(of: ".00", with: "")
            self.countLbl.text = subJson["count"].stringValue + "张"
            self.limitLbl.text = "满" + subJson["full_reduction"].stringValue + "可用"
            let sys_info = subJson["sys_info"].arrayValue
            if sys_info.count > 0{
                var arr : Array<String> = Array<String>()
                if sys_info.count > 2{
                    for i in 0...1{
                        let json = sys_info[i]
                        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                            arr.append(json["gc_name"].stringValue)
                        }else{
                            arr.append(json["sys_name"].stringValue)
                        }
                    }
                }else{
                    for json in sys_info{
                        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                            arr.append(json["gc_name"].stringValue)
                        }else{
                            arr.append(json["sys_name"].stringValue)
                        }
                    }
                }
                self.brandLbl.text = arr.joined(separator: ",") + "等"
            }else{
                self.brandLbl.text = "全品类"
            }
            var collorStr = "fa8f18"
            self.rightTopImgV.isHidden = true
            //type 1：未使用 2:已使用 3：已过期
            if subJson["type"].stringValue.intValue == 1{
                //未使用
                // coupon_type 1代测 2代卖 3代存 4商城优惠券
                if subJson["coupon_type"].intValue == 1{
                    self.couponBgImgV.image = #imageLiteral(resourceName: "coupon_bg_1")
                    self.countBg.image = #imageLiteral(resourceName: "coupon_count_icon1")
                    collorStr = "ff9600"
                }else if subJson["coupon_type"].intValue == 2{
                    self.couponBgImgV.image = #imageLiteral(resourceName: "coupon_bg_2")
                    self.countBg.image = #imageLiteral(resourceName: "coupon_count_icon2")
                    collorStr = "00ccff"
                }else if subJson["coupon_type"].intValue == 3{
                    self.couponBgImgV.image = #imageLiteral(resourceName: "coupon_bg_3")
                    self.countBg.image = #imageLiteral(resourceName: "coupon_count_icon3")
                    collorStr = "ff5400"
                }else if subJson["coupon_type"].intValue == 4{
                    self.couponBgImgV.image = #imageLiteral(resourceName: "coupon_bg_5")
                    self.countBg.image = #imageLiteral(resourceName: "coupon_count_icon5")
                    collorStr = "ff0054"
                }
            }else if subJson["type"].stringValue.intValue == 2{
                //已使用
                self.couponBgImgV.image = #imageLiteral(resourceName: "coupon_bg_4")
                self.countBg.image = #imageLiteral(resourceName: "coupon_count_icon4")
                collorStr = "7d7d7d"
                self.rightTopImgV.image = #imageLiteral(resourceName: "coupon_used_icon")
                self.rightTopImgV.isHidden = false
            }else if subJson["type"].stringValue.intValue == 3{
                //已过期
                self.couponBgImgV.image = #imageLiteral(resourceName: "coupon_bg_4")
                self.countBg.image = #imageLiteral(resourceName: "coupon_count_icon4")
                collorStr = "7d7d7d"
            }
            
//            //
//            if subJson["is_have"].intValue == 1{
//                self.rightTopImgV.image = #imageLiteral(resourceName: "coupon_receive")
//                self.rightTopImgV.isHidden = false
//            }else{
//                self.rightTopImgV.isHidden = true
//            }
            self.nameLbl.textColor = UIColor.colorHex(hex: collorStr)
            self.priceLbl.textColor = UIColor.colorHex(hex: collorStr)
            self.timeLbl.textColor = UIColor.colorHex(hex: collorStr)
            self.brandLbl.textColor = UIColor.colorHex(hex: collorStr)
            self.moneyLogoLbl.textColor = UIColor.colorHex(hex: collorStr)
            self.categoryBtn.setTitleColor(UIColor.colorHex(hex: collorStr), for: .normal)
            self.btnView.backgroundColor = UIColor.colorHex(hex: collorStr)
            self.limitLbl.textColor = UIColor.colorHex(hex: collorStr)
        }
    }
    
    @IBAction func categoryAction() {
        let sys_info = subJson["sys_info"].arrayValue
        var arr : Array<String> = Array<String>()
        if sys_info.count > 0{
            for json in sys_info{
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    arr.append(json["gc_name"].stringValue)
                }else{
                    arr.append(json["sys_name"].stringValue)
                }
            }
        }else{
            arr.append("全品类")
        }
        let dict1 = ["title" : "可用类型", "desc" : arr.joined(separator: ",")]
        NoticeView.showWithText("提示",[dict1])
    }
    
}
