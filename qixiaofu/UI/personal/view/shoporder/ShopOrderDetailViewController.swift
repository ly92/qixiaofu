//
//  ShopOrderDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/15.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopOrderDetailViewController: BaseTableViewController {
    
    var orderId = ""
    
    fileprivate var subJson : JSON = []
    
    var isFromPay = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "订单详情"
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        
        self.tableView.register(UINib.init(nibName: "ShopOrderAddressCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderAddressCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderStateCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderStateCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderGoodsCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderMoneyCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderMoneyCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderMessageCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderBtnCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderBtnCell")
        
        self.loadOrderData()
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named:"btn_back"), target: self, action: #selector(ShopOrderDetailViewController.backClick))
        
        //刷新列表和详情的通知
        NotificationCenter.default.addObserver(self, selector: #selector(ShopOrderDetailViewController.loadOrderData), name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
    }
    
    @objc func backClick(){
        if self.isFromPay{
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func loadOrderData() {
        var params : [String : Any] = [:]
        params["order_id"] = self.orderId
        params["store_id"] = "1"
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: ShopOrderDetailApi, parameters: params, succeed: { (result, msg) in
            
            self.subJson = result
            
            self.tableView.reloadData()
            
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
            if error!.hasPrefix("该订单不存在"){
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


extension ShopOrderDetailViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4//0:地址和状态  1:商品  2:金额，btn，订单信息，物流，备注  3:sn码
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            return self.subJson["goods_list"].arrayValue.count
        }else if section == 2{
            return 6
        }else if section == 3{
            return self.subJson["goods_sn_type"].arrayValue.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderAddressCell", for:indexPath) as! ShopOrderAddressCell
                cell.nameLbl.text = self.subJson["true_name"].stringValue
                cell.addressLbl.text = self.subJson["address"].stringValue
                cell.phoneLbl.text = self.subJson["mob_phone"].stringValue
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderStateCell", for: indexPath) as! ShopOrderStateCell
                cell.subJson = self.subJson
                return cell
            }
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderGoodsCell", for: indexPath) as! ShopOrderGoodsCell
            if self.subJson["goods_list"].arrayValue.count > indexPath.row{
                cell.orderState = self.subJson["state_type"].stringValue
                cell.orderId = self.orderId
                cell.subJson = self.subJson["goods_list"].arrayValue[indexPath.row]
            }
            cell.parentVC = self
            return cell
        }else if indexPath.section == 2{
            if indexPath.row == 0 {
                //金额
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderMoneyCell", for: indexPath) as! ShopOrderMoneyCell
                cell.moneyLbl.text = "¥" + self.subJson["order_price"].stringValue
                return cell
            }else if indexPath.row == 1 {
                //btn
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderBtnCell", for: indexPath) as! ShopOrderBtnCell
                cell.subJson = self.subJson
                cell.isDetail = true
                cell.orderId = self.orderId
                cell.parentVC = self
                return cell
            }else if indexPath.row == 2 {
                //订单信息
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderMessageCell", for: indexPath) as! ShopOrderMessageCell
                cell.numLbl.text = self.subJson["order_sn"].stringValue
                cell.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: self.subJson["add_time"].stringValue)
                cell.payWayLbl.text = self.subJson["payment_name"].stringValue
                return cell
            }else if indexPath.row == 3 {
                //物流
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderStateCell", for: indexPath) as! ShopOrderStateCell
                cell.stateLbl.textColor = Text_Color
                cell.stateLbl.textAlignment = .left
                cell.stateLbl.text = "查看物流"
                cell.rightArrow.isHidden = false
                cell.bottomDis.constant = 8
                return cell
            }else if indexPath.row == 4 {
                //客服手机号
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderStateCell", for: indexPath) as! ShopOrderStateCell
                cell.stateLbl.textColor = Text_Color
                cell.stateLbl.textAlignment = .left
                cell.stateLbl.text = "技术支持:" + self.subJson["phone"].stringValue
                cell.rightArrow.isHidden = false
                cell.bottomDis.constant = 8
                return cell
            }else if indexPath.row == 5 {
                //备注
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderStateCell", for: indexPath) as! ShopOrderStateCell
                cell.stateLbl.textColor = Text_Color
                cell.stateLbl.textAlignment = .left
                cell.stateLbl.text = "备注：" + self.subJson["order_beizhu"].stringValue
                cell.rightArrow.isHidden = true
                cell.bottomDis.constant = 8
                return cell
            }
        }else if indexPath.section == 3{
            if self.subJson["goods_sn_type"].arrayValue.count > indexPath.row{
                //sn号
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderStateCell", for: indexPath) as! ShopOrderStateCell
                cell.stateLbl.textColor = Text_Color
                cell.stateLbl.textAlignment = .left
                cell.stateLbl.text = "sn码：" + self.subJson["goods_sn_type"].arrayValue[indexPath.row]["goods_sn"].stringValue
                cell.rightArrow.isHidden = true
                cell.bottomDis.constant = 0
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0 {
                return 75
            }else{
                return 30
            }
        }else if indexPath.section == 1{
            return 65
        }else if indexPath.section == 2{
            if indexPath.row == 0 {
                //金额
                return 38
            }else if indexPath.row == 1 {
                //btn
                return 44
            }else if indexPath.row == 2 {
                //订单信息
                return 80
            }else if indexPath.row == 3 {
                //物流
                return 44
            }else if indexPath.row == 4 {
                //客服手机号
                return 44
            }else if indexPath.row == 5 {
                //备注
                let str = "备注：" + self.subJson["order_beizhu"].stringValue
                let size = str.sizeFit(width: kScreenW-16, height: CGFloat(MAXFLOAT), fontSize: 14.0)
                if size.height > 20{
                    return 23 + size.height
                }
                return 44
            }
        }else if indexPath.section == 3{
            //sn码
            return 30
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            //商品详情
            if self.subJson["goods_list"].arrayValue.count > indexPath.row{
                let detailVC = GoodsDetailViewController.spwan()
                detailVC.goodsId = self.subJson["goods_list"].arrayValue[indexPath.row]["goods_id"].stringValue
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }else if indexPath.section == 2{
            if indexPath.row == 3 {
                //物流
                let logisticsVC = LogisticsInfoViewController()
                logisticsVC.number = self.subJson["courier_number"].stringValue
                self.navigationController?.pushViewController(logisticsVC, animated: true)
            }else if indexPath.row == 4 {
                //call phone
                var tel  = self.subJson["phone"].stringValue
                if tel.isEmpty{
                    tel = "15600923777"
                }
                UIApplication.shared.openURL(URL(string: "telprompt:" + tel)!)
            }
        }
    }
    
    
    
}
