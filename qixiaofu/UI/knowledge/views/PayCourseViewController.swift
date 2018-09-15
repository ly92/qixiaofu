//
//  PayCourseViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/12/12.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PayCourseViewController: BaseViewController {
    class func spwan() -> PayCourseViewController{
        return self.loadFromStoryBoard(storyBoard: "Knowledge") as! PayCourseViewController
    }
    
    var paySuccessBlock : ((Int) -> Void)?
    
    var resultJson : JSON = []
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var stimeLbl: UILabel!
    @IBOutlet weak var etimeLbl: UILabel!
    @IBOutlet weak var adressLbl: UILabel!
    @IBOutlet weak var walletBtn: UIButton!
    @IBOutlet weak var aliPayBtn: UIButton!
    @IBOutlet weak var wechatBtn: UIButton!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var lessionNumLbl: UILabel!
    
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    fileprivate var walletInfo : JSON = []
    fileprivate var price : Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "支付"
        
        self.prepareUIData()
        
        self.checkPayPassword()
    }
    
    func prepareUIData() {
        self.nameLbl.text = LocalData.getTrueUserName()
        self.imgV.setImageUrlStrAndPlaceholderImg(self.resultJson["lession_img"].stringValue, #imageLiteral(resourceName: "course_cover"))
        self.phoneLbl.text = LocalData.getUserPhone()
        if self.resultJson["lession_new_price"].stringValue.trim.isEmpty{
            self.priceLbl.text = "¥" + self.resultJson["lession_cost_price"].stringValue
            self.price = self.resultJson["lession_cost_price"].stringValue.floatValue
        }else{
            self.priceLbl.text = "¥" + self.resultJson["lession_new_price"].stringValue
            self.price = self.resultJson["lession_new_price"].stringValue.floatValue
        }
        self.titleLbl.text = self.resultJson["lession_name"].stringValue
        
        
        if self.resultJson["lession_end_time"].stringValue.intValue - self.resultJson["lession_start_time"].stringValue.intValue > 86400{
            let str1 = Date.dateStringFromDate(format: "yyyy年MM月dd日", timeStamps: self.resultJson["lession_start_time"].stringValue) + "-" + Date.dateStringFromDate(format: "dd日", timeStamps: self.resultJson["lession_end_time"].stringValue)
            let str2 = Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["lession_start_time"].stringValue) + "~" + Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["lession_end_time"].stringValue)
            self.stimeLbl.text = str1 + " " + str2
        }else{
            self.stimeLbl.text = Date.dateStringFromDate(format: "yyyy年MM月dd日 HH:mm", timeStamps: self.resultJson["lession_start_time"].stringValue) + "-" + Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["lession_end_time"].stringValue)
        }
            
            
//        self.stimeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: self.resultJson["lession_start_time"].stringValue)
//        self.etimeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: self.resultJson["lession_end_time"].stringValue)
        
            
            
        self.adressLbl.text = self.resultJson["lession_address"].stringValue
        self.moneyLbl.text = "共支付:" + self.priceLbl.text!
        if self.adressLbl.resizeHeight() > 21{
            self.topViewH.constant = 280 + self.adressLbl.resizeHeight()
        }else{
            self.topViewH.constant = 310
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNoti()
        //微信支付结果通知
        NotificationCenter.default.addObserver(self, selector: #selector(PayCourseViewController.wechatPayResult(_:)), name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
    }
    
    func removeNoti() {
        //移除微信支付结果通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNoti()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func payWayAction(_ sender: UIButton) {
        self.walletBtn.isSelected = false
        self.aliPayBtn.isSelected = false
        self.wechatBtn.isSelected = false
        sender.isSelected = true
    }
    
    @IBAction func payAction() {
        if self.walletBtn.isSelected{
            if self.walletInfo["statu"].stringValue.intValue == 1{
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
        }else if self.aliPayBtn.isSelected{
            self.payActionWithInfo(pwd: "")
        }else if self.wechatBtn.isSelected{
            self.payActionWithInfo(pwd: "")
        }
    }
    
    //检查是否设置了密码
    func checkPayPassword() {
        NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, succeed: { (resultJson, error) in
            self.walletInfo = resultJson
            self.balanceLbl.text = "余额:" + resultJson["available_predeposit"].stringValue
        }) { (error) in
        }
    }
    
    
    @IBAction func lessionChangeAction(_ sender: UIButton) {
        guard let lessNum = self.lessionNumLbl.text?.intValue else {
            return
        }
        if sender.tag == 11{
            if lessNum > 1{
                self.lessionNumLbl.text = String.init(format: "%d", lessNum-1)
            }else{
                LYProgressHUD.showError("不能再少了！")
            }
        }else if sender.tag == 22{
            if lessNum > 199{
                LYProgressHUD.showError("土豪，讲堂位置不够啦！")
            }else{
                self.lessionNumLbl.text = String.init(format: "%d", lessNum+1)
            }
        }
        
        
        guard let lessNum2 = self.lessionNumLbl.text?.intValue else {
            return
        }
        var str = String.init(format: "%.2f", Float(lessNum2) * self.price)
        if str.hasSuffix(".00"){
            str = str.replacingOccurrences(of: ".00", with: "")
        }
        self.moneyLbl.text = "共支付:¥" + str
    }
    

    func payActionWithInfo(pwd : String) {
        LYProgressHUD.showLoading()
        
        if self.price <= 0{
            LYProgressHUD.showError("出了点问题,请联系客服报名!")
            return
        }
        guard let lessNum = self.lessionNumLbl.text?.floatValue else {
            return
        }
        var params : [String : Any] = [:]
        if self.walletBtn.isSelected{
            params["member_paypwd"] = pwd.md5String()
            params["is_wallet"] = "1"
            params["wallet_price"] = self.price * lessNum
            params["payment_id"] = "7"
        }else if self.aliPayBtn.isSelected{
            params["is_wallet"] = "0"
            params["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            params["is_wallet"] = "0"
            params["payment_id"] = "6"
        }
        params["id"] = self.resultJson["lession_id"].stringValue
        params["price"] = self.price * lessNum
        params["lession_num"] = String.init(format: "%.0f", lessNum)
        
        NetTools.requestData(type: .post, urlString: KCoursePayApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliPayBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                
                if self.paySuccessBlock != nil{
                    self.paySuccessBlock!(Int(lessNum))
                }
                self.navigationController?.popViewController(animated: true)
            }
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    
    //使用钱包
    func payByWallet() {
        let pwdView = PayPasswordView()
        pwdView.parentVC = self
        pwdView.show { (pwd) in
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
            print(orderString)
            AlipaySDK.defaultService().payOrder(orderString, fromScheme: KAliPayScheme) { (resultDict) in
                self.aliPayResult(resultDict)
            }
        }
    }
    
    @objc func aliPayResult(_ resultDict:[AnyHashable:Any]?) {
        if resultDict == nil{
            return
        }
        if resultDict!["resultStatus"] as! String == "9000"{
            let lessNum = self.lessionNumLbl.text?.intValue ?? 1
            //支付成功
            if self.paySuccessBlock != nil{
                self.paySuccessBlock!(lessNum)
            }
            self.navigationController?.popViewController(animated: true)
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
            let lessNum = self.lessionNumLbl.text?.intValue ?? 1
            if self.paySuccessBlock != nil{
                self.paySuccessBlock!(lessNum)
            }
            self.navigationController?.popViewController(animated: true)
//            LYAlertView.show("提示", "下单成功，查看订单详情？", "返回首页", "查看", {
//
//            },{
//                //返回首页
//                self.navigationController?.popToRootViewController(animated: true)
//            })
        }else if resultDict["code"] == "-2"{
            //取消支付
            LYProgressHUD.showInfo("用户取消了支付")
        }else{
            //支付失败
            LYProgressHUD.showInfo(resultDict["error"]!)
        }
    }
}





