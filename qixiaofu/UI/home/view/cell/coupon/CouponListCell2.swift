//
//  CouponListCell2.swift
//  qixiaofu
//
//  Created by ly on 2018/4/12.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CouponListCell2: UITableViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var limitLbl: UILabel!
    @IBOutlet weak var receiveBtn: UIButton!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var rightTopView: UIView!
    @IBOutlet weak var rightBottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.subView.layer.cornerRadius = 8
        self.rightTopView.layer.cornerRadius = 7.5
        self.rightBottomView.layer.cornerRadius = 7.5
        self.receiveBtn.layer.cornerRadius = 12.5
    }
    
    var subJson = JSON(){
        didSet{
            // coupon_type 1代测 2代卖 3代存
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
            
            self.titleLbl.text = subJson["coupon_name"].stringValue
            
            
            /**
             之前适用类别是按照sys_info来判断，现在用sys_parent_name
             
             let sys_info = subJson["sys_info"].arrayValue
             if sys_info.count > 0{
             var arr : Array<String> = Array<String>()
             if sys_info.count > 3{
             for i in 0...2{
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
             self.categoryLbl.text = arr.joined(separator: ",") + "等"
             }else{
             self.categoryLbl.text = "全品类"
             }
             
             */
            
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                let sys_info = subJson["sys_info"].arrayValue
                if sys_info.count > 0{
                    var arr : Array<String> = Array<String>()
                    if sys_info.count > 3{
                        for i in 0...2{
                            let json = sys_info[i]
                            arr.append(json["gc_name"].stringValue)
                        }
                    }else{
                        for json in sys_info{
                            arr.append(json["gc_name"].stringValue)
                        }
                    }
                    self.categoryLbl.text = arr.joined(separator: ",") + "等"
                }else{
                    self.categoryLbl.text = "全品类"
                }
            }else{
                let sys_info = subJson["sys_parent_name"].arrayValue
                if sys_info.count > 0{
                    var arr : Array<String> = Array<String>()
                    if sys_info.count > 3{
                        for i in 0...2{
                            let json = sys_info[i]
                            arr.append(json.stringValue)
                        }
                    }else{
                        for json in sys_info{
                            arr.append(json.stringValue)
                        }
                    }
                    self.categoryLbl.text = arr.joined(separator: ",") + "等"
                }else{
                    self.categoryLbl.text = "全品类"
                }
            }
            
            
            
            self.priceLbl.text = "¥" + subJson["coupon_price"].stringValue.replacingOccurrences(of: ".00", with: "")
            self.limitLbl.text = "满" + subJson["full_reduction"].stringValue.replacingOccurrences(of: ".00", with: "") + "可用"
            
            //剩余量
            if subJson["coupon_num"].stringValue.intValue > 0{
                if subJson["is_have"].stringValue.intValue == 1{
                    self.receiveBtn.backgroundColor = UIColor.RGBS(s: 170)
                    self.receiveBtn.setTitle("已领取", for: .normal)
                }else{
                    self.receiveBtn.backgroundColor = Normal_Color
                    self.receiveBtn.setTitle("立即领取", for: .normal)
                }
            }else{
                self.receiveBtn.backgroundColor = UIColor.RGBS(s: 170)
                self.receiveBtn.setTitle("已抢光", for: .normal)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func categoryAction() {
        var arr : Array<String> = Array<String>()
        
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            let sys_info = subJson["sys_info"].arrayValue
            if sys_info.count > 0{
                for json in sys_info{
                    arr.append(json["gc_name"].stringValue)
                }
            }else{
                arr.append("全品类")
            }
        }else{
            let sys_info = subJson["sys_parent_name"].arrayValue
            if sys_info.count > 0{
                for json in sys_info{
                    arr.append(json.stringValue)
                }
            }else{
                arr.append("全品类")
            }
        }
        
        let dict1 = ["title" : "可用类型", "desc" : arr.joined(separator: ",")]
        NoticeView.showWithText("提示",[dict1])
    }
    
    //领取优惠券
    @IBAction func receiveAction() {
        //剩余量
        if subJson["coupon_num"].stringValue.intValue > 0{
            if self.subJson["is_have"].intValue == 1{
                LYProgressHUD.showInfo("只可以领一张，不要贪心哦！")
                return
            }
            var params : [String : Any] = [:]
            var url = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                url = EPReceiveCouponApi
                params["id"] = self.subJson["id"].stringValue
            }else{
                url = CouponTakeApi
                params["coupon_id"] = self.subJson["id"].stringValue
                params["use_type"] = self.subJson["use_type"].stringValue
            }
            
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.showSuccess("领券成功！")
                self.receiveBtn.backgroundColor = UIColor.RGBS(s: 170)
                self.receiveBtn.setTitle("已领取", for: .normal)
            }) { (error) in
                LYProgressHUD.showError(error ?? "领取失败，请重试！")
            }
        }
    }
}
