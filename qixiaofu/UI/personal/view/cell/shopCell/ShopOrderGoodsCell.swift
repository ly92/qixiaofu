//
//  ShopOrderGoodsCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/15.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopOrderGoodsCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var afterSaleBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    
    var orderState = ""//订单状态
    var orderId = ""
    var parentVC : UIViewController?
    
    var subJson : JSON = []{
        didSet{
            self.iconImgV.setImageUrlStr(subJson["goods_img"].stringValue)
            self.priceLbl.text = "¥" + subJson["goods_pay_price"].stringValue
            self.countLbl.text = "x" + subJson["goods_num"].stringValue
            self.nameLbl.text = subJson["goods_name"].stringValue
            if subJson["seller_type"].intValue == 2 && self.orderState.intValue == 4{//2表示代卖的商品
                if subJson["is_remit"].intValue != 1{//1   不可申请售后  0可以申请
                    if subJson["is_aftersale"].intValue == 1{
                        self.afterSaleBtn.setTitle("确认解决", for: .normal)
                    }else{
                        self.afterSaleBtn.setTitle("申请售后", for: .normal)
                    }
                    self.afterSaleBtn.isHidden = false
                }else{
                    self.afterSaleBtn.isHidden = true
                }
            }else{
                self.afterSaleBtn.isHidden = true
            }
            
            
            //自营商品-已发货，已收货，退换货展示测报按钮
            self.reportBtn.isHidden = true
            if subJson["seller_type"].intValue != 2{
                if self.orderState.intValue == 3 || self.orderState.intValue == 4 || self.orderState.intValue == 6{
                    self.reportBtn.isHidden = false
                }
            }
            
        }
    }
    
    
    @IBAction func afterSaleAction() {
        if subJson["is_aftersale"].intValue == 1{
            LYAlertView.show("提示", "问题是否已解决？","未解决","已解决",{
                var params : [String : Any] = [:]
                params["goods_id"] = self.subJson["determinand_id"].stringValue
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: EndAfterSaleApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("提交成功，等待卖家处理！")
                    //刷新列表和详情的通知
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
                }, failure: { (error) in
                    LYProgressHUD.showError("操作失败，请重试！")
                })
            })
        }else{
            let afterSaleVC = AfterSaleServiceViewController.spwan()
            afterSaleVC.goodsJson = self.subJson
            self.parentVC?.navigationController?.pushViewController(afterSaleVC, animated: true)
        }
        
    }
    
    @IBAction func reportBtnAction() {
        let reportVC = TestReportPictureViewController.spwan()
        reportVC.order_id = self.orderId
        reportVC.goods_id = self.subJson["goods_id"].stringValue
        self.parentVC?.navigationController?.pushViewController(reportVC, animated: true)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
