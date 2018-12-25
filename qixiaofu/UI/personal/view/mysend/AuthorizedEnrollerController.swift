//
//  AuthorizedEnrollerController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/4.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthorizedEnrollerController: BaseViewController {
    class func spwan() -> AuthorizedEnrollerController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! AuthorizedEnrollerController
    }
    
    var successBlock : (() -> Void)?
    var billId = ""
    var bill_type = ""//1.预付款  2.先发单
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    
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
        
        if self.bill_type.intValue == 2{
            self.topViewH.constant = 50
        }else{
            self.topViewH.constant = 0
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
        
    }
    
    @IBAction func setPayAction() {
        let customAlertView = UIAlertView.init(title: "我的定价", message: "请输入设定的价格", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        customAlertView.alertViewStyle = .plainTextInput
        let nameField = customAlertView.textField(at: 0)
        nameField?.keyboardType = .default
        nameField?.placeholder = "输入设定价格"
        customAlertView.show()
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


}

extension AuthorizedEnrollerController : UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.resultJson.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnrollEngineerCell", for: indexPath) as! EnrollEngineerCell
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            cell.bill_type = self.bill_type
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
                esmobChat(self, subJson["phone_num"].stringValue, 2, subJson["ot_user_name"].stringValue, subJson["ot_user_avatar"].stringValue)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            //聊天
            esmobChat(self, subJson["phone_num"].stringValue, 2, subJson["ot_user_name"].stringValue, subJson["ot_user_avatar"].stringValue)
        }
    }
}



extension AuthorizedEnrollerController : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            let nameField = alertView.textField(at: 0)
            guard let price = nameField?.text else{
                LYProgressHUD.showError("请重试！")
                return
            }
            if price.isEmpty{
                LYProgressHUD.showError("不可为空！")
                return
            }
            if price.floatValue <= 0{
                LYProgressHUD.showError("请输入大于0的正确的金额")
                return
            }
            
            
            //去支付
            let payVC = PaySendTaskViewController.spwan()
            payVC.isJustPay = true
            payVC.totalMoney = price.doubleValue
            payVC.orderId = self.billId
            payVC.isSetPrice = true
            payVC.rePayOrderSuccessBlock = {[weak self] () in
                //刷新数据
                self?.bill_type = "1"
                self?.topViewH.constant = 0
                self?.tableView.reloadData()
                //刷新列表和详情
                if self?.successBlock != nil{
                    self?.successBlock!()
                }
            }
            self.navigationController?.pushViewController(payVC, animated: true)
            
        }
    }
    
    
}
