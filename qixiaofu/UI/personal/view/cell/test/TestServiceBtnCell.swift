//
//  TestServiceBtnCell.swift
//  qixiaofu
//
//  Created by ly on 2018/2/5.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestServiceBtnCell: UITableViewCell {
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    
    var refreshDeleteListBlock : (() -> Void)?
    var refreshListBlock : (() -> Void)?
    
    var parentVC = UIViewController()
    var state = "0"//订单状态  0：待审核  1：待支付 2：订单取消 3：测试中 4:测试完成 5:审核失败 6：商家待收货 7:待发货 8:客户待收货 9:订单完成
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var subJson : JSON = []{
        didSet{
            self.btn1.isHidden = true
            self.btn2.isHidden = true
            self.btn3.isHidden = true
            self.btn1.setTitle("", for: .normal)
            self.btn2.setTitle("", for: .normal)
            self.btn3.setTitle("", for: .normal)
            self.state = subJson["order_state"].stringValue
            switch self.state.intValue {
            case 0:
                //待审核
                self.setTitle(title: "取消", btn: self.btn3)
            case 1:
                //待支付
                self.setTitle(title: "取消", btn: self.btn3)
            //                self.setTitle(title: "去支付", btn: self.btn3)
            case 2:
                //订单取消
                self.setTitle(title: "删除", btn: self.btn3)
            case 3:
                //测试中
                self.setTitle(title: "我们将有2-5日的测试时间", btn: self.btn3)
            case 4:
                //测试完成
                self.setTitle(title: "查看详情", btn: self.btn3)
            case 5:
                //审核失败
                self.setTitle(title: "删除", btn: self.btn3)
            case 6:
                //商家待收货
                self.setTitle(title: "查看物流", btn: self.btn3)
            case 7:
                //待发货
                self.setTitle(title: "去发货", btn: self.btn3)
            case 8:
                //待收货
                 print("我去，这是什么")
//                self.setTitle(title: "查看物流", btn: self.btn2)
//                self.setTitle(title: "确认收货", btn: self.btn3)
            case 9:
                //订单完成
                self.setTitle(title: "删除", btn: self.btn3)
            default:
                //
                print("我去，这是什么")
            }
            
        }
    }
    
    
    
    func setTitle(title : String, btn : UIButton) {
        btn.isHidden = false
        btn.setTitle(title, for: .normal)
    }
    
    @IBAction func btn1Action() {
        switch self.state.intValue {
        case 0:
            //待审核
            print("我去，竟然点击出效果了")
        case 1:
            //待支付
            print("我去，竟然点击出效果了")
        case 2:
            //订单取消
            print("我去，竟然点击出效果了")
        case 3:
            //测试中
            print("我去，竟然点击出效果了")
        case 4:
            //测试完成
            print("我去，竟然点击出效果了")
        case 5:
            //审核失败
            print("我去，竟然点击出效果了")
        case 6:
            //商家待收货
            print("我去，竟然点击出效果了")
        case 7:
            //待发货
            print("我去，竟然点击出效果了")
        case 8:
            //待收货
            print("我去，竟然点击出效果了")
        case 9:
            //订单完成
            print("我去，竟然点击出效果了")
        default:
            //
            print("我去，这是什么")
        }
        
    }
    
    @IBAction func btn2Action() {
        var params : [String : Any] = [:]
        params["id"] = self.subJson["id"].stringValue
        switch self.state.intValue {
        case 0:
            //待审核
            print("我去，竟然点击出效果了")
        case 1:
            //待支付
            print("我去，竟然点击出效果了")
        case 2:
            //订单取消
            print("我去，竟然点击出效果了")
        case 3:
            //测试中
            print("我去，竟然点击出效果了")
        case 4:
            //测试完成
            print("我去，竟然点击出效果了")
        case 5:
            //审核失败
            print("我去，竟然点击出效果了")
        case 6:
            //商家待收货
            print("我去，竟然点击出效果了")
        case 7:
            //待发货
            print("我去，竟然点击出效果了")
        case 8:
            //待收货
            print("我去，竟然点击出效果了")
        case 9:
            //订单完成
            print("我去，竟然点击出效果了")
        default:
            //
            print("我去，竟然点击出效果了")
        }
    }
    
    @IBAction func btn3Action() {
        
        var params : [String : Any] = [:]
        params["id"] = self.subJson["id"].stringValue
        switch self.state.intValue {
        case 0:
            //待审核
            //取消单子
            self.cancelOrder()
        case 1:
            //待支付
            //取消单子
            self.cancelOrder()
        case 2:
            //订单取消
            //删除单子
            self.deleteOrder()
        case 3:
            //测试中
            print("我们将有2-5日的测试时间")
        case 4:
            //测试完成
            let orderDetailVC = TestOrderDetailViewController.spwan()
            orderDetailVC.orderId = self.subJson["id"].stringValue
            orderDetailVC.state = self.state
            self.parentVC.navigationController?.pushViewController(orderDetailVC, animated: true)
        case 5:
            //审核失败
            //删除单子
            self.deleteOrder()
        case 6:
            //商家待收货
            //物流
            self.checkLogistics(self.subJson["mailing_number"].stringValue)
        case 7:
            //待发货
            let logisticsVC = LogisticsNumberViewController.spwan()
            logisticsVC.orderId = self.subJson["id"].stringValue
            logisticsVC.isFromTestService = true
            logisticsVC.logisticsNumberSuccessBlock = {() in
                //刷新列表
                if self.refreshListBlock != nil{
                    self.refreshListBlock!()
                }
            }
            self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
        case 8:
            //待收货
            print("我去，竟然点击出效果了")
//            LYAlertView.show("提示", "是否确认已经收到所有物品", "取消", "确定",{
//                var params : [String : Any] = [:]
//                params["id"] = self.subJson["id"].stringValue
//                NetTools.requestData(type: .post, urlString: TestSureLogisticsApi,parameters: params, succeed: { (resultJson, msg) in
//                    if self.refreshListBlock != nil{
//                        self.refreshListBlock!()
//                    }
//                }, failure: { (error) in
//                    LYProgressHUD.showError(error ?? "取消失败！")
//                })
//            })
        case 9:
            //订单完成
            //删除单子
            self.deleteOrder()
        default:
            //
            print("我去，这是什么")
        }
    }
    
    
    //取消订单
    func cancelOrder() {
        LYAlertView.show("提示", "是否取消此单，取消操作不可逆", "放弃取消", "确定取消",{
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: TestServiceCancelOrderApi,parameters: params, succeed: { (resultJson, msg) in
                if self.refreshListBlock != nil{
                    self.refreshListBlock!()
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "取消失败！")
            })
        })
    }
    
    //删除订单
    func deleteOrder() {
        LYAlertView.show("提示", "是否删除此单，删除后不可找回", "取消", "删除",{
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: TestServiceDeleteAllApi,parameters: params, succeed: { (resultJson, msg) in
                if self.refreshDeleteListBlock != nil{
                    self.refreshDeleteListBlock!()
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "删除失败！")
            })
        })
    }
    
    
    //查看物流
    func checkLogistics(_ logistics : String) {
        let arr = logistics.components(separatedBy: ",")
        if arr.count == 1{
            let logisticsVC = LogisticsInfoViewController()
            logisticsVC.number = arr[0]
            self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
//            let webVC = BaseWebViewController.spwan()
//            webVC.titleStr = "查看物流"
//            webVC.urlStr = usedServer + "/shop/index.php?act=login&op=wuliuxiangqing&order_id=" + arr[0]
//            self.parentVC.navigationController?.pushViewController(webVC, animated: true)
        }else if arr.count > 1{
            LYPickerView.show(titles: arr) { (message, index) in
                let logisticsVC = LogisticsInfoViewController()
                logisticsVC.number = message
                self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
                
//                let webVC = BaseWebViewController.spwan()
//                webVC.titleStr = "查看物流"
//                webVC.urlStr = usedServer + "/shop/index.php?act=login&op=wuliuxiangqing&order_id=" + message
//                self.parentVC.navigationController?.pushViewController(webVC, animated: true)
            }
        }
        
    }
}
