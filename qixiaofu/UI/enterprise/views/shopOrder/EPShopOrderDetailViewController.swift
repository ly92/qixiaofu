//
//  EPShopOrderDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPShopOrderDetailViewController: BaseViewController {
    class func spwan() -> EPShopOrderDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPShopOrderDetailViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
        
    var refreshBlock : ((Int) -> Void)?
    var orderId = ""
    
    
    fileprivate var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "订单详情"
        self.tableView.register(UINib.init(nibName: "EPShopOrderDetailStateCell", bundle: Bundle.main), forCellReuseIdentifier: "EPShopOrderDetailStateCell")
        self.tableView.register(UINib.init(nibName: "EPShopOrderDetailGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "EPShopOrderDetailGoodsCell")
        self.tableView.register(UINib.init(nibName: "EPShopOrderDetailChatCell", bundle: Bundle.main), forCellReuseIdentifier: "EPShopOrderDetailChatCell")
        self.tableView.register(UINib.init(nibName: "PayAddressCell", bundle: Bundle.main), forCellReuseIdentifier: "PayAddressCell_detail")
        self.tableView.register(UINib.init(nibName: "EPShopOrderLeaveMsgCell", bundle: Bundle.main), forCellReuseIdentifier: "EPShopOrderLeaveMsgCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadOrderDetail()
    }

    //加载商品详情数据
    func loadOrderDetail() {
        LYProgressHUD.showLoading()
        var params : [String : String] = [:]
        params["order_id"] = self.orderId
        NetTools.requestData(type: .post, urlString: EPShopOrderDetailApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.resultJson = resultJson
            self.tableView.reloadData()
            
            self.leftBtn.isHidden = true
            self.rightBtn.isHidden = true
            let state = resultJson["order_state"].stringValue.intValue
            if state == 1{
                //待支付
                self.setBtnTitle(self.leftBtn, "取消")
                self.setBtnTitle(self.rightBtn, "去支付")
            }else if state == 2{
                //待发货
                let shipping_state = self.resultJson["shipping_state"].stringValue.intValue
                if shipping_state == 1{
                    //待发货
                    self.setBtnTitle(self.rightBtn, "取消")
                }else if shipping_state == 2{
                    //待收货
                    self.setBtnTitle(self.leftBtn, "查看物流")
                    self.setBtnTitle(self.rightBtn, "确认收货")
                }else if shipping_state == 3{
                    //部分发货
                    self.setBtnTitle(self.rightBtn, "联系客服")
                }
            }else if state == 4{
                //已完成
                self.setBtnTitle(self.leftBtn, "申请售后")
                self.setBtnTitle(self.rightBtn, "删除")
            }else if state == 5{
                //已取消
                self.setBtnTitle(self.rightBtn, "删除")
            }
            
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取信息失败，请重试！")
        }
    }
    
    func setBtnTitle(_ btn : UIButton, _ title : String) {
        btn.setTitle(title, for: .normal)
        btn.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAction(_ btn: UIButton) {
        let state = self.resultJson["order_state"].stringValue.intValue
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
                let shipping_state = self.resultJson["shipping_state"].stringValue.intValue
                if shipping_state == 2{
                    //待收货
                    if btn.tag == 11{
                        //查看物流
                        self.logisticsOrderAction()
                    }
                }
            }else if btn.tag == 22{
                //取消
                let shipping_state = self.resultJson["shipping_state"].stringValue.intValue
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
                    esmobChat(self, "kefu1", 1)
                }
            }
        }else if state == 4{
            //已完成
            if btn.tag == 11{
                //发起售后
                let afterSalerVC = EPAfterSalerChooseSnViewController.spwan()
                afterSalerVC.orderJson = self.resultJson
                self.navigationController?.pushViewController(afterSalerVC, animated: true)
            }else if btn.tag == 22{
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
            params["order_id"] = self.resultJson["order_id"].stringValue
            NetTools.requestData(type: .post, urlString: EPShopOrderDeleteApi, parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!(1)
                }
                LYProgressHUD.showSuccess("操作成功！")
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            }
        })
    }
    
    //取消订单
    func cancelOrderAction() {
        LYAlertView.show("提示", "是否确认取消此单？", "放弃取消", "确认取消",{
            var params : [String: String] = [:]
            params["order_id"] = self.resultJson["order_id"].stringValue
            NetTools.requestData(type: .post, urlString: EPShopOrderCancelApi, parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!(1)
                }
                self.loadOrderDetail()
            }) { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            }
        })
    }
    
    //查看物流
    func logisticsOrderAction() {
        var arr : Array<String> = Array<String>()
        for str in self.resultJson["invoice_no"].arrayValue{
            arr.append(str.stringValue)
        }
        
        if arr.count == 1{
            let logisticsVC = LogisticsInfoViewController()
            logisticsVC.number = arr[0]
            self.navigationController?.pushViewController(logisticsVC, animated: true)
        }else if arr.count > 1{
            LYPickerView.show(titles: arr) { (message, index) in
                let logisticsVC = LogisticsInfoViewController()
                logisticsVC.number = message
                self.navigationController?.pushViewController(logisticsVC, animated: true)
            }
        }
    }
    
    //去支付
    func goPayOrderAction() {
        let payVC = EPShopPayViewController.spwan()
        payVC.isFromOrderDetail = true
        payVC.orderJson = self.resultJson
        self.navigationController?.pushViewController(payVC, animated: true)
    }
    
    //确认收货
    func receiveOrderAction() {
        LYAlertView.show("提示", "是否确认已收到所有物品", "取消", "确认",{
            var params : [String: String] = [:]
            params["order_id"] = self.resultJson["order_id"].stringValue
            NetTools.requestData(type: .post, urlString: EPShopOrderReceiveApi, parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!(1)
                }
                self.loadOrderDetail()
            }) { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            }
        })
    }

}

extension EPShopOrderDetailViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            //留言
            let str = self.resultJson["leave_word"].stringValue
            if str.isEmpty{
                return 2
            }
            return 3
        }else if section == 1{
            return self.resultJson["goods"].arrayValue.count + 1
        }else if section == 2{
            return self.resultJson["goods_sn"].arrayValue.count
        }else if section == 3{
            if self.resultJson["return_pay_num"].stringValue.trim.isEmpty{
                return self.resultJson["operation"].arrayValue.count + 1
            }else{
                return self.resultJson["operation"].arrayValue.count + 2
            }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EPShopOrderDetailStateCell", for: indexPath) as! EPShopOrderDetailStateCell
                cell.subJson = self.resultJson
                return cell
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PayAddressCell_detail", for: indexPath) as! PayAddressCell
                cell.nameLbl.text = self.resultJson["address"]["company_true_name"].stringValue
                cell.addressLbl.text = "收货地址:" + self.resultJson["address"]["area_info"].stringValue + self.resultJson["address"]["address"].stringValue
                cell.phoneLbl.text = self.resultJson["address"]["mob_phone"].stringValue
                cell.bottomView.isHidden = true
                cell.bottomViewH.constant = 0
                cell.arrowImgV.isHidden = true
                cell.selectionStyle = .none
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EPShopOrderLeaveMsgCell", for: indexPath) as! EPShopOrderLeaveMsgCell
                cell.messageLbl.text = self.resultJson["leave_word"].stringValue
                return cell
            }
        }else if indexPath.section == 1{
            if indexPath.row == self.resultJson["goods"].arrayValue.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EPShopOrderDetailChatCell", for: indexPath) as! EPShopOrderDetailChatCell
                cell.subJson = self.resultJson
                cell.parentVC = self
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EPShopOrderDetailGoodsCell", for: indexPath) as! EPShopOrderDetailGoodsCell
                if indexPath.row < self.resultJson["goods"].arrayValue.count{
                    cell.subJson = self.resultJson["goods"].arrayValue[indexPath.row]
                }
                return cell
            }
        }else if indexPath.section == 2{
            var cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailNormalCell")
            if cell == nil{
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "orderDetailNormalCell")
            }
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.accessoryView = nil
            cell?.selectionStyle = .none
            if self.resultJson["goods_sn"].arrayValue.count > indexPath.row{
                cell?.textLabel?.text = "SN: " + self.resultJson["goods_sn"].arrayValue[indexPath.row].stringValue
            }
            
            return cell!
        }else if indexPath.section == 3{
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailNormalCell")
            if cell == nil{
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "orderDetailNormalCell")
            }
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.accessoryView = nil
            cell?.selectionStyle = .none
            if indexPath.row == 0{
                cell?.textLabel?.text = "订单编号：" + self.resultJson["order_number"].stringValue
                let imgV = UIImageView(frame: CGRect.init(x: 0, y: 2, width: 40, height: 20))
                imgV.image = #imageLiteral(resourceName: "ep_center_icon_6")
                cell?.accessoryView = imgV
                view.backgroundColor = UIColor.red
                
            }else{
                if self.resultJson["return_pay_num"].stringValue.trim.isEmpty{
                    if self.resultJson["operation"].arrayValue.count > indexPath.row - 1{
                        let json = self.resultJson["operation"].arrayValue[indexPath.row - 1]
                        let str = json["title"].stringValue + "：" + Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: json["time"].stringValue)
                        cell?.textLabel?.text = str
                    }
                }else{
                    if indexPath.row == 1{
                        cell?.textLabel?.text = "交易号：" + self.resultJson["return_pay_num"].stringValue
                    }else{
                        if self.resultJson["operation"].arrayValue.count > indexPath.row - 2{
                            let json = self.resultJson["operation"].arrayValue[indexPath.row - 2]
                            let str = json["title"].stringValue + "：" + Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: json["time"].stringValue)
                            cell?.textLabel?.text = str
                        }
                    }
                }
            }
            
            return cell!
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return 60
            }else if indexPath.row == 1{
                let str = "收货地址:" + self.resultJson["address"]["area_info"].stringValue + self.resultJson["address"]["address"].stringValue
                let height = str.sizeFit(width: kScreenW - 35, height: CGFloat(MAXFLOAT), fontSize: 13.0).height
                if height > 20{
                    return 45 + height
                }else{
                    return 60
                }
            }else if indexPath.row == 2{
                let str = self.resultJson["leave_word"].stringValue
                let height = str.sizeFit(width: kScreenW - 35, height: CGFloat(MAXFLOAT), fontSize: 13.0).height
                if height > 20{
                    return 40 + height
                }else{
                    return 60
                }
            }
        }else if indexPath.section == 1{
            if indexPath.row == self.resultJson["goods"].arrayValue.count{
                return 128
            }else{
                return 55
            }
        }else if indexPath.section == 2{
            return 20
        }else if indexPath.section == 3{
            return 20
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1{
            if indexPath.row < self.resultJson["goods"].arrayValue.count{
                let json = self.resultJson["goods"].arrayValue[indexPath.row]
                let detailVC = GoodsDetailViewController.spwan()
                detailVC.goodsId = json["goods_id"].stringValue
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }else if indexPath.section == 3{
            if indexPath.row == 0{
                UIPasteboard.general.string = self.resultJson["order_number"].stringValue
                LYProgressHUD.showSuccess("订单号复制成功！")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.001
        }else{
            return 8
        }
    }
}
