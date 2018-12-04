//
//  RechargeViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/1.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class RechargeViewController: BaseTableViewController {
    class func spwan() -> RechargeViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! RechargeViewController
    }
    
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var moneyTF: UITextField!
    @IBOutlet weak var aliBtn: UIButton!
    @IBOutlet weak var wechatBtn: UIButton!
    @IBOutlet weak var aliAccountTF: UITextField!
    @IBOutlet weak var brankAccountTF: UITextField!
    @IBOutlet weak var bankNameTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var wechatView: UIView!
    
    var vcType = 1//1:充值零钱 2:提现 3:充值服豆
    var refreshBlock : (() -> Void)?
    
    fileprivate var paySn = ""//充值时的订单
    fileprivate var isSettedPayPwd = false
    fileprivate var enableMoney : Double = 0//可用余额

    fileprivate var isWechat = false//是否为通过微信
    fileprivate var zuidiedu : Double = 0//保证金额度
    
    fileprivate var rechargeLbl = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: kScreenW - 20, height: 21))//可提现金额
    fileprivate var rechargeDescLbl = UILabel.init(frame: CGRect.init(x: 10, y: 21, width: kScreenW - 20, height: 29))//保证金提醒
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.vcType == 1{
            self.navigationItem.title = "充值零钱"
            self.typeLbl.text = "充值金额(¥)"
            self.moneyTF.placeholder = "请输入充值金额"
        }else if self.vcType == 2{
            self.navigationItem.title = "提现"
            self.typeLbl.text = "提现金额(¥)"
            self.sureBtn.setTitle("提交", for: .normal)
            //是否设置了支付密码
            self.checkPayPassword()
        }else if self.vcType == 3{
            self.navigationItem.title = "充值服豆"
            self.typeLbl.text = "充值数量"
            self.moneyTF.placeholder = "请输入充值数量"
        }
        
        self.sureBtn.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNoti()
        //微信支付结果通知
        NotificationCenter.default.addObserver(self, selector: #selector(RechargeViewController.wechatPayResult(_:)), name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
    }
    
    func removeNoti() {
        //移除微信支付结果通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNoti()
    }


    @IBAction func payTypeAction(_ sender: UIButton) {
        if sender.isSelected{
            return
        }
        
        self.aliBtn.isSelected = false
        self.wechatBtn.isSelected = false
        sender.isSelected = true
        self.isWechat = self.wechatBtn.isSelected
        self.tableView.reloadData()
    }
    
    
    @IBAction func submitAction() {
        self.view.endEditing(true)
        
        if self.vcType == 1{
            //充值零钱
            self.rechargeAction()
        }else if self.vcType == 2{
            //提现
            self.withdrawAction()
        }else if self.vcType == 3{
            //充值服豆
            self.rechargeBeanAction()
        }
        
    }
    
    
    //检查是否设置了密码
    func checkPayPassword() {
        var url = ""
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPCheckPayPwdApi
        }else{
            url = HaveSetPayPasswordApi
        }
        NetTools.requestData(type: .post, urlString: url, succeed: { (resultJson, error) in
            self.zuidiedu = resultJson["zuidiedu"].stringValue.doubleValue
            if resultJson["statu"].stringValue.intValue == 1{
                self.isSettedPayPwd = true
            }
            var availableMoney = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                availableMoney = resultJson["available_predeposit"].stringValue
            }else{
                availableMoney = resultJson["remaining_balance"].stringValue
            }
            self.enableMoney = availableMoney.doubleValue
            if self.enableMoney <= 0{
                self.moneyTF.placeholder = "您的提现金额不足"
                self.rechargeLbl.text = "可提现金额:¥0"
            }else{
                self.moneyTF.placeholder = availableMoney
                self.rechargeLbl.text = "可提现金额:¥" + availableMoney
            }
//            self.enableMoney = resultJson["cash_available"].stringValue.doubleValue
//            if self.enableMoney <= 0{
//                self.moneyTF.placeholder = "您的提现金额不足"
//                self.rechargeLbl.text = "可提现金额:¥0"
//            }else{
//                self.moneyTF.placeholder = resultJson["cash_available"].stringValue
//                self.rechargeLbl.text = "可提现金额:¥" + resultJson["cash_available"].stringValue
//            }
            self.rechargeDescLbl.text = resultJson["explain"].stringValue
            
        }) { (error) in
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension RechargeViewController{

    //充值零钱
    func rechargeAction() {
        let money = self.moneyTF.text
        if (money?.isEmpty)! || money!.doubleValue <= 0{
            LYProgressHUD.showError("请输入不小于0的充值金额")
            return
        }
        LYProgressHUD.showLoading()
        var params : [String : Any] = [:]
        var url = ""
        params["price"] = money;
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            params["pay_id"] = self.isWechat ? "2" : "1"//1支付宝 2微信 3钱包 4线下支付
            url = EPMoneyRechargeApi
        }else{
            params["pay_name"] = self.isWechat ? "微信" : "支付宝"
            params["payment_id"] = self.isWechat ? "6" : "2"
            url = RechargeWalletApi
        }
        
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            
            self.paySn = result["pay_sn"].stringValue
            if self.isWechat{
                self.payByWechat(result)
            }else{
                self.payByAli(result)
            }
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    
    //充值服豆
    func rechargeBeanAction() {
        let money = self.moneyTF.text
        if (money?.isEmpty)! || money!.intValue <= 0{
            LYProgressHUD.showError("请输入不小于0的充值数量")
            return
        }
        if Float(money!.intValue) != money!.floatValue{
            LYProgressHUD.showError("请输入整数！")
            return
        }
        
        LYProgressHUD.showLoading()
        var params : [String : Any] = [:]
        params["fu_price"] = money;
        params["payment_id"] = self.isWechat ? "6" : "2"
        NetTools.requestData(type: .post, urlString: "tp.php/Home/Member/fudou_recharge", parameters: params, succeed: { (result, msg) in
            
            self.paySn = result["pay_sn"].stringValue
            if self.isWechat{
                self.payByWechat(result)
            }else{
                self.payByAli(result)
            }
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //仅在支付成功时调用
    func dealRecharge() {
        //刷新
        if self.refreshBlock != nil{
            self.refreshBlock!()
        }
        
        if self.vcType == 3{
            LYAlertView.show("提示", "充值成功！", "知道了",{
                self.navigationController?.popViewController(animated: true)
            },{
                self.navigationController?.popViewController(animated: true)
            })
        }else{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                LYAlertView.show("提示", "充值成功！", "知道了",{
                    self.navigationController?.popViewController(animated: true)
                },{
                    self.navigationController?.popViewController(animated: true)
                })
            }else{
                var params : [String : Any] = [:]
                params["MSXOP"] = self.isWechat ? "wxpay" : "alipay"
                params["pay_sn"] = self.paySn
                NetTools.requestData(type: .post, urlString: RechargeDealApi, parameters: params, succeed: { (result, msg) in
                    LYAlertView.show("提示", "充值成功！", "知道了",{
                        self.navigationController?.popViewController(animated: true)
                    },{
                        self.navigationController?.popViewController(animated: true)
                    })
                }) { (error) in
                }
            }
        }

    }
    
    //提现
    func withdrawAction() {
        let money = self.moneyTF.text
        if (money?.isEmpty)! || money!.doubleValue <= 0{
            LYProgressHUD.showError("请输入不小于0的提现金额")
            return
        }
        if self.enableMoney <= 0 || money!.doubleValue > self.enableMoney{
            LYProgressHUD.showError("你的提现金额不足")
            return
        }
        
        func withdraw(){
            if self.isWechat{
                let bankAc = self.brankAccountTF.text
                let bankName = self.bankNameTF.text
                let userName = self.userNameTF.text
                if (bankAc?.isEmpty)!{
                    LYProgressHUD.showError("请输入银行卡号")
                    return
                }
                if (bankName?.isEmpty)!{
                    LYProgressHUD.showError("请输入开户行名称")
                    return
                }
                if (userName?.isEmpty)!{
                    LYProgressHUD.showError("请输入开户人名称")
                    return
                }
            }else{
                let aliAc = self.aliAccountTF.text
                if (aliAc?.isEmpty)!{
                    LYProgressHUD.showError("请输入支付宝账号！")
                    return
                }
            }
            //是否已设置密码
            if self.isSettedPayPwd{
                self.payByWallet()
            }else{
                //设置支付密码
                let changePayPwdVc = ChangePasswordViewController.spwan()
                changePayPwdVc.type = .setPayPwd
                changePayPwdVc.setPayPwdSuccessBlock = {[weak self] () in
                    self?.checkPayPassword()
                }
                self.navigationController?.pushViewController(changePayPwdVc, animated: true)
            }
        }

        if self.enableMoney - money!.doubleValue < self.zuidiedu{//余额小于保证金
            LYAlertView.show("提示", "提现后您的余额将不足保证金，保证金不足时可能会降低客户对您的信任度！", "确定提现", "先不提现",{
                self.navigationController?.popViewController(animated: true)
            },{
                withdraw()
            })
        }else{
            withdraw()
        }
        
    }
    
    //使用钱包
    func payByWallet() {
        let pwdView = PayPasswordView()
        pwdView.parentVC = self
        pwdView.show { (pwd) in
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self.payActionWithInfo(pwd: pwd)
            }else{
                var params : [String : Any] = [:]
                params["paypwd"] = pwd.md5String()
                NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, parameters: params, succeed: { (resultJson, error) in
                    if resultJson["statu"].stringValue.intValue == 2{
                        //支付密码正确
                        //提交订单
                        self.payActionWithInfo(pwd: pwd)
                    }else if resultJson["statu"].stringValue.intValue == 3{
                        LYProgressHUD.showError("支付密码错误！")
                        self.payByWallet()
                    }
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
            }
        }
    }

    //提现申请
    func payActionWithInfo(pwd:String) {
        var params : [String : Any] = [:]
        var url = ""
        params["price"] = self.moneyTF.text//要提现的金额【大于100】
        params["member_paypwd"] = pwd.md5String()//支付密码 【MD5加密后32位字符串】
        params["payment_id"] = self.isWechat ? "6" : "2"//提现方式ID【2 支付宝】【6 微信】
        params["payment_name"] = self.isWechat ? self.bankNameTF.text : "支付宝"//提现银行名称【如：支付宝，建设银行】
        params["bank_no"] = self.isWechat ? self.brankAccountTF.text : self.aliAccountTF.text
        params["bank_user"] = self.isWechat ? self.userNameTF.text : self.moneyTF.text
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPMoneyWithdrawApi
        }else{
            url = WithDrawWalletApi
        }
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            //刷新
            if self.refreshBlock != nil{
                self.refreshBlock!()
            }
            LYAlertView.show("提示", "提现申请提交成功！", "知道了",{
                self.navigationController?.popViewController(animated: true)
            })
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    
    //使用支付宝付款
    func payByAli(_ aliJson : JSON) {
        let order = Order()
        order.app_id = KAliPayAppId
        order.notify_url = aliJson["call_api_url"].stringValue
        order.method = "alipay.trade.app.pay"
        order.charset = "utf-8"
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        order.timestamp = format.string(from: Date())
        order.version = "1.0"
        order.sign_type = "RSA"
        order.biz_content = BizContent()
        order.biz_content.body = aliJson["order_title"].stringValue
        order.biz_content.subject = aliJson["order_title"].stringValue
        order.biz_content.out_trade_no = aliJson["pay_sn"].stringValue
        order.biz_content.timeout_express = "30m"
        order.biz_content.total_amount = "\(aliJson["order_total"].doubleValue)"
        
        let orderInfo = order.orderInfoEncoded(false)
        let orderInfoEncoded = order.orderInfoEncoded(true)
        
        let signer =  RSADataSigner.init(privateKey: KAliPayPrivateKey)
        let signedString = signer?.sign(orderInfo, withRSA2: false)
        
        if !(signedString?.isEmpty)!{
            let orderString = orderInfoEncoded! + "&sign=" + signedString!
            
            AlipaySDK.defaultService().payOrder(orderString, fromScheme: KAliPayScheme) { (resultDict) in
                self.aliPayResult(resultDict)
            }
        }
    }

    func aliPayResult(_ resultDict:[AnyHashable:Any]?) {
        if resultDict == nil{
            return
        }
        if resultDict!["resultStatus"] as! String == "9000"{
            //支付成功
            self.dealRecharge()
        }else if resultDict!["resultStatus"] as! String == "6001"{
            //支付取消
            LYProgressHUD.showInfo("用户取消了支付")
        }else{
            //支付失败
            LYProgressHUD.showInfo("支付失败！")
        }
        
    }
    
    
    //使用微信付款
    func payByWechat(_ reqJson : JSON) {
        if WXApi.isWXAppInstalled(){
            let req = PayReq()
            req.openID = reqJson["appid"].stringValue
            req.partnerId = reqJson["partnerid"].stringValue
            req.prepayId = reqJson["prepayid"].stringValue
            req.nonceStr = reqJson["noncestr"].stringValue
            req.timeStamp = UInt32(reqJson["timestamp"].stringValue)!
            req.package = reqJson["package"].stringValue
            req.sign = reqJson["sign"].stringValue
            print(WXApi.send(req))
        }else{
            LYProgressHUD.showError("请先安装微信客户端！")
        }

    }
    //微信支付结果
    @objc func wechatPayResult(_ noti:Notification) {
        guard let resultDict = noti.userInfo as? [String:String] else {
            return
        }
        if resultDict["code"] == "0"{
            //支付成功
            self.dealRecharge()
            
        }else if resultDict["code"] == "-2"{
            //取消支付
            LYProgressHUD.showInfo("用户取消了支付")
        }else{
            //支付失败
            LYProgressHUD.showInfo(resultDict["error"]!)
        }
    }

}



extension RechargeViewController{

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }else if indexPath.section == 1{
            if self.vcType == 3 || self.vcType == 1{
                //充值服豆
                self.wechatView.isHidden = false
                return 114
            }else{
                self.wechatView.isHidden = true
                return 70
            }
        }else if indexPath.section == 2{
            if self.vcType == 1{
                //充值零钱
                
            }else if self.vcType == 2{
                //提现
                if self.isWechat{
                    if indexPath.row != 0{
                        return 44
                    }
                }else{
                    if indexPath.row == 0{
                        return 44
                    }
                }
            }else if self.vcType == 3{
                //充值服豆
                
            }
            
        }else{
            return 100
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            if self.vcType == 1{
                //充值零钱
                
            }else if self.vcType == 2{
                //提现
                cell.isHidden = false
                if self.isWechat{
                    if indexPath.row == 0{
                        cell.isHidden = true
                    }
                }else{
                    if indexPath.row != 0{
                        cell.isHidden = true
                    }
                }
            }else if self.vcType == 3{
                //充值服豆
                
            }
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        }
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && self.vcType == 2{
            return 50
        }
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 30))
            view.backgroundColor = BG_Color
            let lbl = UILabel.init(frame: CGRect.init(x: 10, y: 9, width: kScreenW - 20, height: 21))
            lbl.font = UIFont.systemFont(ofSize: 13.0)
            lbl.textColor = UIColor.RGBS(s: 50)
            if self.vcType == 1{
                //充值零钱
                lbl.text = "选择充值通道"
            }else if self.vcType == 2{
                //提现
                lbl.text = "选择提现通道"
            }else if self.vcType == 3{
                //充值服豆
                lbl.text = "选择充值通道"
            }
            view.addSubview(lbl)
            return view
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && self.vcType == 2{
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 30))
            view.backgroundColor = BG_Color
            
            self.rechargeLbl.font = UIFont.systemFont(ofSize: 12.0)
            self.rechargeLbl.textColor = UIColor.RGBS(s: 50)
            view.addSubview(self.rechargeLbl)
            
            self.rechargeDescLbl = UILabel.init(frame: CGRect.init(x: 10, y: 21, width: kScreenW - 20, height: 29))
            self.rechargeDescLbl.font = UIFont.systemFont(ofSize: 12.0)
            self.rechargeDescLbl.textColor = UIColor.RGBS(s: 50)
            self.rechargeDescLbl.numberOfLines = 0
            view.addSubview(self.rechargeDescLbl)
            
            return view
        }
        return UIView()
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.view.endEditing(true)
//    }
}


