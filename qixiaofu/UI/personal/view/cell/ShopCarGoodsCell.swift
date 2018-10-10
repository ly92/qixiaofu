//
//  ShopCarGoodsCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/31.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ShopCarGoodsCellBlock = (Int) -> Void

class ShopCarGoodsCell: UITableViewCell {
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var reduceBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var invalidationLbl: UILabel!
    @IBOutlet weak var invalidationDescLbl: UILabel!
    
    var parentVC = UIViewController()
    var reduceBlock : ShopCarGoodsCellBlock?
    var plusBlock : ShopCarGoodsCellBlock?
    var selectBlock :ShopCarGoodsCellBlock?
    
    var subJson : JSON = []{
        didSet{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self.iconImgV.setImageUrlStr(subJson["goods_image"].stringValue)
                if subJson["goods_price"].stringValue.floatValue > 0{
                    self.priceLbl.text = "¥ " + subJson["goods_price"].stringValue
                }else{
                    self.priceLbl.text = ""
                }
                self.countLbl.text = subJson["goods_num"].stringValue
                self.nameLbl.text = subJson["goods_name"].stringValue
            }else{
                self.iconImgV.setImageUrlStr(subJson["goods_image_url"].stringValue)
                if subJson["goods_price"].stringValue.floatValue > 0{
                    self.priceLbl.text = "¥ " + subJson["goods_price"].stringValue
                }else{
                    self.priceLbl.text = ""
                }
                self.priceLbl.text = "¥ " + subJson["goods_price"].stringValue
                self.countLbl.text = subJson["goods_num"].stringValue
                self.nameLbl.text = subJson["goods_name"].stringValue
            }
            
            
//            self.reduceBtn.isEnabled = subJson["goods_num"].stringValue.intValue > 1
            
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.invalidationLbl.layer.cornerRadius = 5
        
        self.invalidationDescLbl.addTapActionBlock {
            //客服
            esmobChat(self.parentVC, "kefu1", 1)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func countAction(_ btn: UIButton) {
        var count = subJson["goods_num"].stringValue.intValue
        var minOrPlus : Int = 0
        if btn.tag == 11{
            //加
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                if count == subJson["goods_storage"].stringValue.intValue{
                    LYProgressHUD.showError("库存不足\(count + 1)个")
                    return
                }
            }else{
                if count == subJson["sum"].stringValue.intValue{
                    LYProgressHUD.showError("库存不足\(count + 1)个")
                    return
                }
            }
            minOrPlus = 1
            count += 1
        }else{
            //减
            if count == 1{
                LYProgressHUD.showError("不能再少啦！")
                return
            }
            minOrPlus = -1
            count -= 1
        }
        
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            var params : [String : Any] = [:]
            params["goods_commonid"] = subJson["goods_commonid"].stringValue.intValue
            params["goods_num"] = minOrPlus
            NetTools.requestData(type: .post, urlString: EPAddGoodsToCarApi, parameters: params, succeed: { (resultJson, msg) in
                if btn.tag == 11{
                    //加
                    if self.plusBlock != nil{
                        self.plusBlock!(count)
                    }
                }else{
                    //减
                    if self.plusBlock != nil{
                        self.plusBlock!(count)
                    }
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        }else{
            var params : [String : Any] = [:]
            params["store_id"] = "1";
            params["cart_id"] = subJson["cart_id"].stringValue.intValue
            params["quantity"] = count
            NetTools.requestData(type: .post, urlString: ShopCarEditCountApi , parameters: params, succeed: { (resultJson, msg) in
                if btn.tag == 11{
                    //加
                    if self.plusBlock != nil{
                        self.plusBlock!(count)
                    }
                }else{
                    //减
                    if self.plusBlock != nil{
                        self.plusBlock!(count)
                    }
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        }
    }
    
    
    
    @IBAction func selectedAction() {
        if self.selectBlock != nil{
            self.selectBlock!(0)
        }
    }
    
    
}
