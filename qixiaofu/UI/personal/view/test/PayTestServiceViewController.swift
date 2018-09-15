//
//  PayTestServiceViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/7.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PayTestServiceViewController: BaseViewController {
    class func spwan() -> PayTestServiceViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! PayTestServiceViewController
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalMoneyLbl: UILabel!
    
    fileprivate var paymentList : JSON = []
    fileprivate var consigneeAddress : JSON = []
    fileprivate var addressInfo : JSON = []//默认寄回地址
    fileprivate var walletInfo : JSON = []
    fileprivate var payType : Int = 7//7钱包 2支付宝 6微信
    fileprivate var selectedCoupon : JSON? //选择的优惠券
    
    var payRefreshBlock : (() -> Void)?
    
    var orderId = ""
    //还需支付的钱
    var price : CGFloat = 0
    var systermPrice = ""//按照类型区分的价格，json字符串
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "支付"
        self.sortPayment()
        
        self.tableView.register(UINib.init(nibName: "PayAddressCell", bundle: Bundle.main), forCellReuseIdentifier: "PayAddressCell")
        self.tableView.register(UINib.init(nibName: "PayWalletCell", bundle: Bundle.main), forCellReuseIdentifier: "PayWalletCell")
        self.tableView.register(UINib.init(nibName: "PayWayCell", bundle: Bundle.main), forCellReuseIdentifier: "PayWayCell")
        
        
        self.checkPayPassword()
        self.getDefaultAddress()
        self.totalMoneyLbl.text = "共支付:¥" + String.init(format: "%.2f", price)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNoti()
        //微信支付结果通知
        NotificationCenter.default.addObserver(self, selector: #selector(PayTestServiceViewController.wechatPayResult(_:)), name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
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
    
    
    //检查是否设置了密码
    func checkPayPassword() {
        NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, succeed: { (resultJson, error) in
            self.walletInfo = resultJson
            //加载其他数据
            self.tableView.reloadData()
        }) { (error) in
            //加载其他数据
        }
    }
    
    //对支付方式做一个重新排序，钱包-服豆-支付宝-微信
    func sortPayment() {
        let json1 : JSON = JSON(["is_default":"0","payment_img":"","payment_name":"","payment_desc":"","payment_id":"7"])
        let json2 : JSON = JSON(["is_default":"0","payment_img":"http://www.7xiaofu.com/UPLOAD/sys/a.png","payment_name":"支付宝","payment_desc":"","payment_id":"2"])
        let json3 : JSON = JSON(["is_default":"0","payment_img":"http://img1.2345.com/duoteimg/softImg/soft/11/1412053391_28.jpg","payment_name":"微信支付","payment_desc":"微信支付是腾讯公司的支付业务品牌,微信支付提供公众号支付、APP支付、扫码支付、刷卡支付等支付方式。微信支付结合微信公众账号,全面打通O2O生活消费领域,提供专业的...","payment_id":"6"])
        self.paymentList = [json1,json2,json3]
    }
    
    
    //七小服默认地址 & 默认寄回地址
    func getDefaultAddress() {
//        //七小服默认地址
//        NetTools.requestData(type: .post, urlString: TestChooseAdderessApi, succeed: { (resultJson, msg) in
//            if resultJson.arrayValue.count > 0{
//                self.consigneeAddress = resultJson.arrayValue[0]
//                self.tableView.reloadData()
//            }
//        }) { (error) in
//            LYProgressHUD.showError(error ?? "请求失败，请返回重试")
//        }
        //默认寄回地址
        var params : [String : Any] = [:]
        params["store_id"] = "1"
        NetTools.requestData(type: .post, urlString: AddressListApi,parameters: params, succeed: { (result, msg) in
            //停止刷新
            if result.arrayValue.count > 0{
                self.addressInfo = result.arrayValue[0]
                self.tableView.reloadData()
            }
        }) { (error) in
        }
        
        
        
    }
    


    @IBAction func goPay() {
        
        if self.payType == 7{
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
        }else if self.payType == 2{
            self.payActionWithInfo(pwd: "")
        }else if self.payType == 6{
            self.payActionWithInfo(pwd: "")
        }
        
        
        
    }
    
    func payActionWithInfo(pwd : String) {
        var params : [String : Any] = [:]
        if pwd.isEmpty{
            params["is_wallet"] = "0"
        }else{
            params["is_wallet"] = "1"
            params["member_paypwd"] = pwd.md5String()
            params["wallet_price"] = String.init(format: "%.2f", self.price)
        }
        if self.selectedCoupon != nil{
            params["coupon_id"] = self.selectedCoupon!["member_coupon_id"].stringValue
        }
        params["payment_id"] = self.payType
        params["id"] = self.orderId
        params["price"] = String.init(format: "%.2f", self.price)
        params["address_id"] = self.addressInfo["address_id"].stringValue
//        params["consignee_id"] = self.consigneeAddress["id"].stringValue
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: TestPayOrderApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            
            if self.payType == 7 && resultJson["is_pay"].stringValue.intValue == 0{//  选择的是使用钱包付款，那么钱包付全款
                //支付成功
                LYAlertView.show("提示", "支付成功，快去发货吧！", "知道了", {
                    if self.payRefreshBlock != nil{
                        self.payRefreshBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                })
                
            }else if self.payType == 2{
                //支付宝
                self.payByAli(resultJson)
            }else{
                //微信
                self.payByWechat(resultJson)
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        

//        NetTools.requestDataTest(urlString: TestPayOrderApi, parameters: params, succeed: { (result) in
//
//        }) { (error) in
//            LYProgressHUD.showError(error ?? "请求失败，请重试！")
//        }
//

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
    

    func aliPayResult(_ resultDict:[AnyHashable:Any]?) {
        if resultDict == nil{
            return
        }
        if resultDict!["resultStatus"] as! String == "9000"{
                //返回首页
            LYAlertView.show("提示", "支付成功，快去发货吧！", "知道了", {
                if self.payRefreshBlock != nil{
                    self.payRefreshBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            })
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
                //返回首页
            LYAlertView.show("提示", "支付成功，快去发货吧！", "知道了", {
                if self.payRefreshBlock != nil{
                    self.payRefreshBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            })
        }else if resultDict["code"] == "-2"{
            //取消支付
            LYProgressHUD.showInfo("用户取消了支付")
        }else{
            //支付失败
            LYProgressHUD.showInfo(resultDict["error"]!)
        }
    }
    
    
}


extension PayTestServiceViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else if section == 1{
            return 1
        }else if section == 2{
            return 1
        }else if section == 3{
            return self.paymentList.arrayValue.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            if self.consigneeAddress["id"].stringValue.isEmpty{
                var cell = tableView.dequeueReusableCell(withIdentifier: "TestPayNoAddressCell")
                if cell == nil{
                    cell = UITableViewCell.init(style: .value1, reuseIdentifier: "TestPayNoAddressCell")
                }
                cell?.textLabel?.text = "未选择收货地址"
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.textLabel?.textColor = UIColor.RGBS(s: 33)
                cell?.detailTextLabel?.text = "去选择"
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.detailTextLabel?.textColor = Normal_Color
                cell?.accessoryType = .disclosureIndicator
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PayAddressCell", for: indexPath) as! PayAddressCell
                cell.nameLbl.text = self.consigneeAddress["people"].stringValue
                cell.addressLbl.text = "收货地址:" + self.consigneeAddress["address"].stringValue
                cell.phoneLbl.text = self.consigneeAddress["phone"].stringValue
                cell.bottomView.isHidden = true
                cell.bottomViewH.constant = 0
                cell.arrowImgV.isHidden = false
                return cell
            }
        }else if indexPath.section == 1{
            if self.addressInfo["address_id"].stringValue.isEmpty{
                var cell = tableView.dequeueReusableCell(withIdentifier: "TestPayNoAddressCell")
                if cell == nil{
                    cell = UITableViewCell.init(style: .value1, reuseIdentifier: "TestPayNoAddressCell")
                }
                cell?.textLabel?.text = "未选择寄回地址"
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.textLabel?.textColor = UIColor.RGBS(s: 33)
                cell?.detailTextLabel?.text = "去选择"
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.detailTextLabel?.textColor = Normal_Color
                cell?.accessoryType = .disclosureIndicator
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PayAddressCell", for: indexPath) as! PayAddressCell
                cell.nameLbl.text = self.addressInfo["true_name"].stringValue
                cell.addressLbl.text = "收货地址:" + self.addressInfo["area_info"].stringValue + self.addressInfo["address"].stringValue
                cell.phoneLbl.text = self.addressInfo["mob_phone"].stringValue
                cell.bottomView.isHidden = true
                cell.bottomViewH.constant = 0
                cell.arrowImgV.isHidden = false
                return cell
            }
        }else if indexPath.section == 2{
            var cell = tableView.dequeueReusableCell(withIdentifier: "PayTestCouponCell")
            if cell == nil{
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "PayTestCouponCell")
            }
            cell?.textLabel?.text = "优惠券"
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell?.textLabel?.textColor = Text_Color
            cell?.accessoryType = .disclosureIndicator
            if self.selectedCoupon == nil{
                cell?.detailTextLabel?.text = "选择优惠券"
            }else{
                cell?.detailTextLabel?.text = "1张"
            }
            
            return cell!
        }else if indexPath.section == 3{
            
            if self.paymentList.arrayValue.count > indexPath.row{
                let subJson = self.paymentList.arrayValue[indexPath.row]
                if subJson["payment_id"].stringValue == "7"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PayWalletCell", for: indexPath) as! PayWalletCell
                    cell.moneyLbl.text = "(可用余额:¥" + self.walletInfo["remaining_balance"].stringValue + ")"
                    if self.payType == 7{
                        cell.walletSwitch.isOn = true
                    }else{
                        cell.walletSwitch.isOn = false
                    }
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PayWayCell", for: indexPath) as! PayWayCell
                    cell.imgV.setImageUrlStr(subJson["payment_img"].stringValue)
                    cell.nameLbl.text = subJson["payment_name"].stringValue
                    if self.payType == 2 && subJson["payment_id"].stringValue == "2"{
                        cell.selectedBtn.isSelected = true
                    }else if self.payType == 6 && subJson["payment_id"].stringValue == "6"{
                        cell.selectedBtn.isSelected = true
                    }else{
                        cell.selectedBtn.isSelected = false
                    }
                    return cell
                }
            }
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0{
            let chooseAdVC = TestChooseAddressViewController()
            chooseAdVC.chooseAddressBlock = {(json) in
                self.consigneeAddress = json
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(chooseAdVC, animated: true)
            
        }else if indexPath.section == 1{
//            if self.addressInfo["address_id"].stringValue.isEmpty{
//                let addAddressVC = AddAddressViewController.spwan()
//                addAddressVC.editAddressBlock = {[weak self] (json) in
//                    //添加成功,刷新数据
//                    self?.preparePayData()
//                }
//                self.navigationController?.pushViewController(addAddressVC, animated: true)
//            }else{
                //收货地址
                let addressVC = AddressListViewController()
                addressVC.isChooseAddress = true
                addressVC.chooseAddressBlock = {(json) in
                    self.addressInfo = json
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(addressVC, animated: true)
//            }
        }else if indexPath.section == 2{
            let couponVC = MyCouponViewController.spwan()
            couponVC.isFromPay = true
            couponVC.couponType = "1"
//            couponVC.payMoney = "\(self.price)"
            couponVC.systermPrice = self.systermPrice
            couponVC.selectedJson = self.selectedCoupon
            couponVC.selectedCouponBlock = {(coupon) in
                self.selectedCoupon = coupon
                if coupon == nil{
                    self.totalMoneyLbl.text = "共支付:¥" + String.init(format: "%.2f", self.price)
                }else{
                    let newPrice = self.price - CGFloat(coupon!["coupon_price"].floatValue)
                    if newPrice > 0{
                        self.totalMoneyLbl.text = "共支付:¥" + String.init(format: "%.2f", newPrice)
                    }else{
                        self.totalMoneyLbl.text = "共支付:¥0"
                    }
                }
                
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(couponVC, animated: true)
        }else if indexPath.section == 3{
            if indexPath.row == 0{
                if CGFloat(self.walletInfo["remaining_balance"].stringValue.floatValue) < self.price{
                    LYProgressHUD.showError("余额不足")
                }else{
                    self.payType = 7
                    self.tableView.reloadData()
                }
            }
            if indexPath.row == 1{
                self.payType = 2
                self.tableView.reloadData()
            }else if indexPath.row == 2{
                self.payType = 6
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if self.consigneeAddress["id"].stringValue.isEmpty{
                return 60
            }else{
                let str = "收货地址:" + self.consigneeAddress["address"].stringValue
                let height = str.sizeFit(width: kScreenW - 35, height: CGFloat(MAXFLOAT), fontSize: 13.0).height
                if height > 20{
                    return 45 + height
                }else{
                    return 60
                }
            }
        }else if indexPath.section == 1{
            if self.addressInfo["address_id"].stringValue.isEmpty{
                return 60
            }else{
                let str = "收货地址:" + self.addressInfo["area_info"].stringValue + self.addressInfo["address"].stringValue
                let height = str.sizeFit(width: kScreenW - 35, height: CGFloat(MAXFLOAT), fontSize: 13.0).height
                if height > 20{
                    return 45 + height
                }else{
                    return 60
                }
            }
        }else if indexPath.section == 2{
            //优惠券
            return 44
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1{
            return 0.0001
        }
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }

}

