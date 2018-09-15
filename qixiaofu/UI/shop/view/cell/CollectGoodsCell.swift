//
//  CollectGoodsCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/14.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollectGoodsCell: UITableViewCell {

    var subJson : JSON = [] {
        didSet{
            self.imgV.setImageUrlStr(subJson["goods_image_url"].stringValue)
            self.nameLbl.text = subJson["goods_name"].stringValue
            self.priceLbl.text = "¥" + subJson["goods_price"].stringValue
//            self.inventoryLbl.text = "商品库存：" + subJson["goods_storage"].stringValue
            self.inventoryLbl.text = "销售量：" + subJson["goods_salenum"].stringValue
            self.areaLbl.text = subJson["area_name"].stringValue
            //是否打折
            if subJson["is_discount"].stringValue.intValue == 1{
                self.discountImgV.isHidden = false
                self.cuImgV.isHidden = false
                let oldPrice = "¥" + self.subJson["goods_discount_price"].stringValue
                self.oldPriceLbl.attributedText = NSAttributedString.init(string: oldPrice, attributes: [NSAttributedStringKey.strikethroughStyle : (1)])
            }else{
                self.discountImgV.isHidden = true
                self.cuImgV.isHidden = true
                self.oldPriceLbl.attributedText = NSAttributedString.init(string: "")
            }
            
            //是否为自营sale_type   出售类型(1自营  2代卖)
            if subJson["sale_type"].intValue == 1{
                self.selfSupportImgV.image = #imageLiteral(resourceName: "self_support")
            }else{
                self.selfSupportImgV.image = #imageLiteral(resourceName: "other_support")
            }
        }
    }
    
    var epSubJson : JSON = [] {
        didSet{
            self.imgV.setImageUrlStr(epSubJson["goods_image"].stringValue)
            self.nameLbl.text = epSubJson["goods_name"].stringValue
            self.priceLbl.text = "¥" + epSubJson["goods_price"].stringValue
            //            self.inventoryLbl.text = "商品库存：" + subJson["goods_storage"].stringValue
//            self.inventoryLbl.text = "销售量：" + epSubJson["goods_salenum"].stringValue
            self.areaLbl.text = epSubJson["area"].stringValue
            //是否打折
            if epSubJson["is_discount"].stringValue.intValue == 1{
                self.discountImgV.isHidden = false
                self.cuImgV.isHidden = false
                let oldPrice = "¥" + self.epSubJson["goods_discount_price"].stringValue
                self.oldPriceLbl.attributedText = NSAttributedString.init(string: oldPrice, attributes: [NSAttributedStringKey.strikethroughStyle : (1)])
            }else{
                self.discountImgV.isHidden = true
                self.cuImgV.isHidden = true
                self.oldPriceLbl.attributedText = NSAttributedString.init(string: "")
            }
            
            //是否为自营sale_type   出售类型(1自营  2代卖)
            if epSubJson["sale_type"].intValue == 1{
                self.selfSupportImgV.image = #imageLiteral(resourceName: "self_support")
            }else{
                self.selfSupportImgV.image = #imageLiteral(resourceName: "other_support")
            }
        }
    }
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var inventoryLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var discountImgV: UIImageView!
    @IBOutlet weak var oldPriceLbl: UILabel!
    @IBOutlet weak var cuImgV: UIImageView!
    @IBOutlet weak var selfSupportImgV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

/**
 {
 "is_presell" : "0",
 "is_fcode" : "0",
 "group_flag" : false,
 "goods_marketprice" : "999999.00",
 "goods_image" : "1_05435987692676985.jpg",
 "goods_name" : "IBM P7硬盘 74Y4900",
 "goods_salenum" : "36",
 "evaluation_good_star" : "5",
 "evaluation_count" : "0",
 "goods_image_url" : "http:\/\/10.216.2.11\/data\/upload\/shop\/store\/goods\/1\/1_05435987692676985_360.jpg",
 "xianshi_flag" : false,
 "area_name" : "北京",
 "goods_price" : "1300.00",
 "goods_id" : "427",
 "goods_img_laber" : "",
 "goods_storage" : "7",
 "areaid_1" : "1",
 "dizhi_name" : "北京",
 "area_id" : "1",
 "have_gift" : "0",
 "is_virtual" : "0"
 },
 */
