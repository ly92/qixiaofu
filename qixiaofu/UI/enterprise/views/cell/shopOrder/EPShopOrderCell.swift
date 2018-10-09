//
//  EPShopOrderCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPShopOrderCell: UITableViewCell {

    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var singleImgV: UIImageView!
    @IBOutlet weak var singleNameLbl: UILabel!
    @IBOutlet weak var singleNumLbl: UILabel!
    @IBOutlet weak var scrllView: UIScrollView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    
    var refreshBlock : ((Int) -> Void)?//1刷新 2删除
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //order_state        订单状态  0全部  1待支付  2待发货  4已完成 5已取消
    //shipping_state 1待发货  2已发货 3部分发货
    

    var subJson = JSON(){
        didSet{
            self.leftBtn.isHidden = true
            self.rightBtn.isHidden = true
            
            if subJson["order_photo"].arrayValue.count == 1{
                self.scrllView.isHidden = true
                self.singleNameLbl.text = subJson["goods_name"].stringValue
                self.singleImgV.setImageUrlStr(subJson["order_photo"].arrayValue[0].stringValue)
                self.singleNumLbl.text = "x" + subJson["sumnumber"].stringValue
            }else if subJson["order_photo"].arrayValue.count > 1{
                self.scrllView.isHidden = false
                for view in self.scrllView.subviews{
                    view.removeFromSuperview()
                }
                
                for i in 0...subJson["order_photo"].arrayValue.count - 1{
                    let imgV = UIImageView(frame: CGRect.init(x: i * 52, y: 0, width: 50, height: 50))
                    imgV.setImageUrlStr(subJson["order_photo"].arrayValue[i].stringValue)
                    self.scrllView.addSubview(imgV)
                }
                self.scrllView.contentSize = CGSize.init(width: 50 * subJson["order_photo"].arrayValue.count, height: 50)
            }
            self.descLbl.text = "共" + subJson["sumnumber"].stringValue + "件商品 订单金额：" + subJson["total_amount"].stringValue
            let state = subJson["order_state"].stringValue.intValue
            if state == 1{
                //待支付
                self.stateLbl.text = "待支付"
                self.setBtnTitle(self.leftBtn, "取消")
                self.setBtnTitle(self.rightBtn, "去支付")
            }else if state == 2{
                //待发货
                let shipping_state = subJson["shipping_state"].stringValue.intValue
                if shipping_state == 1{
                    //待发货
                    self.stateLbl.text = "待发货"
                    self.setBtnTitle(self.rightBtn, "取消")
                }else if shipping_state == 2{
                    //待收货
                    self.stateLbl.text = "待收货"
                    self.setBtnTitle(self.leftBtn, "查看物流")
                    self.setBtnTitle(self.rightBtn, "确认收货")
                }else if shipping_state == 3{
                    //部分发货
                    self.stateLbl.text = "已分批发货"
                    self.setBtnTitle(self.rightBtn, "联系客服")
                }
                
            }else if state == 4{
                //已完成
                self.stateLbl.text = "已完成"
//                self.setBtnTitle(self.leftBtn, "申请售后")
                self.setBtnTitle(self.rightBtn, "删除")
            }else if state == 5{
                //已取消
                self.stateLbl.text = "已取消"
                self.setBtnTitle(self.rightBtn, "删除")
            }
        }
    }
    
    func setBtnTitle(_ btn : UIButton, _ title : String) {
        btn.setTitle(title, for: .normal)
        btn.isHidden = false
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnAction(_ btn: UIButton) {
        let state = subJson["order_state"].stringValue.intValue
        if state == 1{
            //待支付
            if btn.tag == 11{
                //取消
                self.cancelOrderAction()
            }else if btn.tag == 22{
                //去支付
                self.goPayOrderAction()
            }
        }else if state == 2{
            //待发货
            if btn.tag == 11{
                let shipping_state = subJson["shipping_state"].stringValue.intValue
                if shipping_state == 2{
                    //待收货
                    if btn.tag == 11{
                        //查看物流
                        self.logisticsOrderAction()
                    }
                }
            }else if btn.tag == 22{
                //取消
                let shipping_state = subJson["shipping_state"].stringValue.intValue
                if shipping_state == 1{
                    //待发货
                    self.cancelOrderAction()
                }else if shipping_state == 2{
                    //待收货
                   if btn.tag == 22{
                        //确认收货
                        self.receiveOrderAction()
                    }
                }else if shipping_state == 3{
                    //部分发货
                    //登录环信
                    esmobLogin()
                    let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
                    self.parentVC.navigationController?.pushViewController(chatVC!, animated: true)
                }
            }
        }else if state == 4{
            //已完成
            if btn.tag == 22{
                //删除
                self.deleteOrderAction()
            }
        }else if state == 5{
            //已取消
            if btn.tag == 11{
                //
            }else if btn.tag == 22{
                //删除
                self.deleteOrderAction()
            }
        }
    }
    
    
    //删除订单
    func deleteOrderAction() {
        LYAlertView.show("提示", "是否确认删除此单，删除后不可找回", "取消", "确认",{
            var params : [String: String] = [:]
            params["order_id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: EPShopOrderDeleteApi, parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!(1)
                }
                LYProgressHUD.showSuccess("操作成功！")
            }) { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            }
        })
    }
    
    //取消订单
    func cancelOrderAction() {
        LYAlertView.show("提示", "是否确认取消此单？", "放弃取消", "确认取消",{
            var params : [String: String] = [:]
            params["order_id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: EPShopOrderCancelApi, parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!(1)
                }
                LYProgressHUD.showSuccess("操作成功！")
            }) { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            }
        })
    }
    
    //查看物流
    func logisticsOrderAction() {
        var arr : Array<String> = Array<String>()
        for str in self.subJson["invoice_no"].arrayValue{
            arr.append(str.stringValue)
        }
        
        if arr.count == 1{
            let logisticsVC = LogisticsInfoViewController()
            logisticsVC.number = arr[0]
            self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
        }else if arr.count > 1{
            LYPickerView.show(titles: arr) { (message, index) in
                let logisticsVC = LogisticsInfoViewController()
                logisticsVC.number = message
                self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
            }
        }
    }
    
    //去支付
    func goPayOrderAction() {
        let payVC = EPShopPayViewController.spwan()
        payVC.isFromOrderDetail = true
        payVC.orderJson = self.subJson
        self.parentVC.navigationController?.pushViewController(payVC, animated: true)
    }
    
    //确认收货
    func receiveOrderAction() {
        LYAlertView.show("提示", "是否确认已收到所有物品", "取消", "确认",{
            var params : [String: String] = [:]
            params["order_id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: EPShopOrderReceiveApi, parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!(1)
                }
                LYProgressHUD.showSuccess("操作成功！")
            }) { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            }
        })
    }
    
}
