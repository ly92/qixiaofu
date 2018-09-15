//
//  ShopOrderBtnCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/14.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopOrderBtnCell: UITableViewCell {
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    
    var parentVC = UIViewController()
    var isDetail = false
    var orderId = ""
    
    var refreshBlock : (() -> Void)?
    
    
    
    var subJson : JSON = []{
        didSet{
            self.leftBtn.isHidden = true
            self.rightBtn.isHidden = true
            
            switch subJson["state_type"].stringValue.intValue {
            case 0:
                self.setTitleAndShow(btn: self.rightBtn, title: " 删除 ")
            case 1:
                self.setTitleAndShow(btn: self.leftBtn, title: " 取消 ")
                if subJson["order_end_time"].stringValue.intValue > 0{
                    self.setTitleAndShow(btn: self.rightBtn, title: " 支付 ")
                }else{
                    self.rightBtn.setTitle("", for: .normal)
                }
            case 2:
                self.setTitleAndShow(btn: self.rightBtn, title: " 提醒发货 ")
                self.setTitleAndShow(btn: self.leftBtn, title: " 取消 ")
            case 3:
                self.setTitleAndShow(btn: self.rightBtn, title: " 确认收货 ")
            case 4:
                self.setTitleAndShow(btn: self.rightBtn, title: " 删除 ")
                //自营
                self.setTitleAndShow(btn: self.leftBtn, title: " 申请退换货 ")
            case 5:
                self.setTitleAndShow(btn: self.rightBtn, title: " 删除 ")
            case 6:
                
                switch subJson["return_step_state"].stringValue.intValue {
                case 1:
                    self.setTitleAndShow(btn: self.rightBtn, title: "  等待商家审核  ")
                    
                case 2:
                    self.setTitleAndShow(btn: self.rightBtn, title: " 去发货 ")
                    
                case 3:
                    self.setTitleAndShow(btn: self.rightBtn, title: " 删除 ")
                    self.setTitleAndShow(btn: self.leftBtn, title: " 申请退换货 ")
                    
                case 4:
                    self.setTitleAndShow(btn: self.rightBtn, title: " 等待商家确认物流 ")
                    
                case 5:
                    if subJson["refund_type"].stringValue.intValue == 1{
                        self.setTitleAndShow(btn: self.rightBtn, title: " 确认完成退货 ")
                    }else{
                        self.setTitleAndShow(btn: self.rightBtn, title: " 确认完成换货 ")
                    }
                case 6:
//                    if subJson["refund_type"].stringValue.intValue == 1{
//                        self.setTitleAndShow(btn: self.rightBtn, title: " 删除 ")
//                    }else{
//                        self.stateLbl.text = "换货已收货"
//                    }
                    self.setTitleAndShow(btn: self.rightBtn, title: " 删除 ")
                    if subJson["total_goods_num"].stringValue.intValue > 0 && subJson["order_amount"].stringValue.floatValue > 0{
                        self.setTitleAndShow(btn: self.leftBtn, title: " 申请退换货 ")
                    }
                    
                default:
                    print("这又是个啥-btntitle")
                }
                
            case 21:
                print("这又是个啥-btntitle")
            default:
                print("这是个啥-btntitle")
            }
            
        }
    }
    
    //设置title并且显示出来
    func setTitleAndShow(btn:UIButton,title:String) {
        btn.isHidden = false
        btn.setTitle(title, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func leftBtnAction() {
        switch subJson["state_type"].stringValue.intValue {
        case 1:
            self.cancelOrderAction()
        case 2:
            self.deleteBeforeDeliverOrderAction()
        case 4:
            //自营
            self.changeOrRefundOrder()
        case 6:
            switch subJson["return_step_state"].stringValue.intValue {
            case 3:
                self.setTitleAndShow(btn: self.leftBtn, title: " 申请退换货 ")
            case 6:
                if subJson["total_goods_num"].stringValue.intValue > 0 && subJson["order_amount"].stringValue.floatValue > 0{
                    self.changeOrRefundOrder()
                }
            default:
                print("这又是个啥-left btn action")
            }
        case 21:
            print("这又是个啥-left btn action")
        default:
            print("这是个啥-left btn action")
        }
    }
    
    @IBAction func rightBtnAction() {
        switch subJson["state_type"].stringValue.intValue {
        case 0:
            self.deleteAfterDeliverOrderAction()
        case 1:
            if subJson["order_end_time"].stringValue.intValue > 0{
                self.payOrderAction()
            }
        case 2:
            self.remindDeliver()
        case 3:
            self.takeDeliver()
        case 4:
            self.deleteAfterDeliverOrderAction()
        case 5:
            self.deleteAfterDeliverOrderAction()
        case 6:
            switch subJson["return_step_state"].stringValue.intValue {
            case 2:
                self.changeOrRefundOrderLogistics()
            case 3:
                self.deleteAfterDeliverOrderAction()
            case 5:
                self.changeOrRefundOrderDone()
            case 6:
                self.deleteAfterDeliverOrderAction()
            default:
                print("这又是个啥-right btn action")
            }
        case 21:
            print("这又是个啥-right btn action")
        default:
            print("这是个啥-right btn action")
        }
    }
    
    //取消订单
    func cancelOrderAction() {
        LYAlertView.show("提示", "你确定要取消此订单吗", "放弃", "确定", {
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["order_id"] = self.orderId
            params["state_info"] = "此处的取消原因暂时未做功能"
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: ShopOrderCancelApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("取消成功！")
                //刷新列表和详情的通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
                //如果是详情页面的话则返回到列表
                if self.isDetail{
                    self.parentVC.navigationController?.popViewController(animated: false)
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
    }
    
    //发货前删除订单
    func deleteBeforeDeliverOrderAction() {
        LYPickerView.show(titles: ["我不想买了","地址等信息填写错误，重买","商品价格较贵","商品重复下单","未按约定时间配送","其他原因"]) { (message, index) in
            LYAlertView.show("提示", "你确定要删除此订单吗", "取消", "确认", {
                var params : [String : Any] = [:]
                params["store_id"] = "1"
                params["type"] = "1"
                params["order_id"] = self.orderId
                params["message"] = message
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: ShopOrderBreforeDeliverApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("删除成功！")
                    //刷新列表和详情的通知
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
                    //如果是详情页面的话则返回到列表
                    if self.isDetail{
                        self.parentVC.navigationController?.popViewController(animated: false)
                    }
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            })
        }
    }
    
    //发货后删除订单
    func deleteAfterDeliverOrderAction() {
        LYAlertView.show("提示", "你确定要删除此订单吗", "取消", "确认", {
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["order_id"] = self.orderId
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: ShopOrderAfterDeliverApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("删除成功！")
                //刷新列表和详情的通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
                //如果是详情页面的话则返回到列表
                if self.isDetail{
                    self.parentVC.navigationController?.popViewController(animated: false)
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
    }
    
    
    //支付订单
    func payOrderAction() {
        //去支付
        let payVC = PaySendTaskViewController.spwan()
        payVC.isJustPay = true
        payVC.totalMoney = subJson["order_amount"].stringValue.doubleValue
        payVC.paySn = subJson["pay_sn"].stringValue
        payVC.orderId = self.orderId
        payVC.rePayOrderSuccessBlock = {[weak self] () in
            //刷新列表和详情的通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
        }
        self.parentVC.navigationController?.pushViewController(payVC, animated: true)
    }
    
    //发起退换货
    func changeOrRefundOrder() {
        let exchangeVC = ExchangePurchaseViewController.spwan()
        exchangeVC.orderId = self.orderId
        self.parentVC.navigationController?.pushViewController(exchangeVC, animated: true)
    }

    
    //退换货-返货物流
    func changeOrRefundOrderLogistics() {
        let logisticsVC = LogisticsNumberViewController.spwan()
        logisticsVC.orderId = self.orderId
        logisticsVC.refund_type = self.subJson["refund_type"].stringValue
        logisticsVC.logisticsNumberSuccessBlock = {() in
            //刷新列表和详情的通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
        }
        self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
    }
    
    //退换货-完成订单
    func changeOrRefundOrderDone() {
        LYAlertView.show("提示", "确定已经完成退换货", "取消", "确认", {
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["order_id"] = self.orderId
            params["return_step_state"] = "5";
            params["refund_id"] = self.subJson["refund_id"].stringValue
            params["type"] = self.subJson["refund_type"].stringValue
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: ChangeOrRefundDoneApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("操作成功！")
                //刷新列表和详情的通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
    }
    
    //提醒发货
    func remindDeliver() {
        var params : [String : Any] = [:]
        params["store_id"] = "1"
        params["order_sn"] = self.subJson["order_sn"].stringValue
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: ShopOrderRemindDeliverApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("已经提醒成功！")
        }, failure: { (error) in
            LYProgressHUD.showError(error!)
        })
    }
    
    //确认收货
    func takeDeliver() {
        LYAlertView.show("提示", "确定收货", "取消", "确认", {
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["order_id"] = self.orderId
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: ShopOrderTakeDeliverApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("操作成功！")
                //刷新列表和详情的通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
            }, failure: { (error) in
                LYProgressHUD.showError("请求失败！")
            })
        })
    }
    
    
}
