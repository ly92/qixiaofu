//
//  AuthorizedEnrollerController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/4.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthorizedEnrollerController: BaseTableViewController {

    var successBlock : (() -> Void)?
    var billId = ""
    
    fileprivate var resultJson : JSON = []
    fileprivate var selectedId = ""
    fileprivate var selectedJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "报名列表"
        
        self.tableView.register(UINib.init(nibName: "EnrollEngineerCell", bundle: Bundle.main), forCellReuseIdentifier: "EnrollEngineerCell")
        self.tableView.separatorStyle = .none
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", target: self, action: #selector(AuthorizedEnrollerController.rightItemAction))
        
        self.loadData()
        
        self.tableView.es.addPullToRefresh {
            self.loadData()
            self.tableView.es.stopPullToRefresh()
        }
    }
    
    //指定工程师
    @objc func rightItemAction() {
        if self.selectedId.isEmpty{
            LYProgressHUD.showError("请选择工程师！")
            return
        }
        func enroll(_ isWallet : String){
            var params : [String : String] = [:]
            params["is_wallet"] = isWallet
            params["member_paypwd"] = ""
            params["payment_id"] = ""
            params["offer_price"] = self.selectedJson["offer_price"].stringValue
            params["bill_id"] = self.billId
            params["ot_user_id"] = self.selectedId
            
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: AuthorizedEngPayApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("指定接单成功！")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    //刷新列表和详情
                    if self.successBlock != nil{
                        self.successBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                })
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
        
        let price = self.selectedJson["supply_price"].stringValue
        if price.isEmpty || price.floatValue == 0{
            enroll("")
        }else{
            if price.floatValue < 0{
                enroll("1")
            }else{
                //去支付
                let payVC = PaySendTaskViewController.spwan()
                payVC.isJustPay = true
                payVC.totalMoney = price.doubleValue
                payVC.enrollJson = self.selectedJson
                payVC.orderId = self.billId
                payVC.rePayOrderSuccessBlock = {() in
                    //刷新列表和详情
                    if self.successBlock != nil{
                        self.successBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }
                self.navigationController?.pushViewController(payVC, animated: true)
            }
        }
        
        
        
        
        
        
        
        
        
//        var params : [String : String] = [:]
//        params["bill_id"] = self.billId
//        params["ot_user_id"] = self.selectedId
//        LYProgressHUD.showLoading()
//        NetTools.requestData(type: .post, urlString: AuthorizedEngApi, parameters: params, succeed: { (result, msg) in
//            LYProgressHUD.showSuccess("指定接单成功！")
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
//                //刷新列表和详情
//                if self.successBlock != nil{
//                    self.successBlock!()
//                }
//                self.navigationController?.popViewController(animated: true)
//            })
//        }) { (error) in
//            LYProgressHUD.showError(error!)
//        }
    }
    
    
    //加载报名的工程师列表
    func loadData() {
        var params : [String : String] = [:]
        params["bill_id"] = self.billId
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: EnrollEngineerListApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            self.resultJson = result
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.resultJson.arrayValue.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnrollEngineerCell", for: indexPath) as! EnrollEngineerCell
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            cell.jsonModel = subJson
            
            if self.selectedId == subJson["ot_user_id"].stringValue{
                cell.selectedBtn.isSelected = true
            }else{
                cell.selectedBtn.isSelected = false
            }
            
            cell.selectedActionBlock = {() in
                if self.selectedId != subJson["ot_user_id"].stringValue{
                    self.selectedId = subJson["ot_user_id"].stringValue
                    self.selectedJson = subJson
                    self.tableView.reloadData()
                }
            }
            
            cell.detailActionBlock = {() in
                let engineerDetailVC = EngineerDetailViewController()
                engineerDetailVC.member_id = subJson["ot_user_id"].stringValue
                self.navigationController?.pushViewController(engineerDetailVC, animated: true)
            }
            
            cell.chatActionBlock = {() in
                //聊天
                //登录环信
                esmobLogin()
                let chatVC = EaseMessageViewController.init(conversationChatter: subJson["phone_num"].stringValue, conversationType: EMConversationType.init(0))
                //保存聊天页面数据
                LocalData.saveChatUserInfo(name: subJson["ot_user_name"].stringValue, icon: subJson["ot_user_avatar"].stringValue, key: subJson["phone_num"].stringValue)
                chatVC?.title = subJson["ot_user_name"].stringValue
                self.navigationController?.pushViewController(chatVC!, animated: true)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            //聊天
            //登录环信
            esmobLogin()
            let chatVC = EaseMessageViewController.init(conversationChatter: subJson["phone_num"].stringValue, conversationType: EMConversationType.init(0))
            //保存聊天页面数据
            LocalData.saveChatUserInfo(name: subJson["ot_user_name"].stringValue, icon: subJson["ot_user_avatar"].stringValue, key: subJson["phone_num"].stringValue)
            chatVC?.title = subJson["ot_user_name"].stringValue
            self.navigationController?.pushViewController(chatVC!, animated: true)
        }
    }


}
