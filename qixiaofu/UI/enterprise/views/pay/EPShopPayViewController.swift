
//
//  EPShopPayViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/26.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
class EPShopPayViewController: BaseViewController {
    class func spwan() -> EPShopPayViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPShopPayViewController
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var payMoneyLbl: UILabel!
    var isFromShopCar = false
    var goodsArray : Array<JSON> = Array<JSON>()
    fileprivate var addressInfo : JSON = JSON()
    fileprivate var payMessage = ""//买家留言
    fileprivate var couponMoney : CGFloat = 0//优惠券抵扣金额
    fileprivate var selectedCoupon : JSON?
    fileprivate var totalMoney : CGFloat = 0
    fileprivate var payWay = 3 //1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
    fileprivate var orderId = ""//订单ID
    
    var refreshBlock : (() -> Void)?
    
    var shouldToRoot = false//是否返回根目录
    
    /**
     从订单过来的支付
     */
    var isFromOrderDetail = false
    var orderJson = JSON(){
        didSet{
            self.orderId = orderJson["order_id"].stringValue.isEmpty ? orderJson["id"].stringValue : orderJson["order_id"].stringValue
            self.totalMoney = CGFloat(orderJson["total_amount"].stringValue.floatValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "支付"
        
        self.tableView.register(UINib.init(nibName: "PayAddressCell", bundle: Bundle.main), forCellReuseIdentifier: "PayAddressCell_pay")
        self.tableView.register(UINib.init(nibName: "PayGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "PayGoodsCell")
        self.tableView.register(UINib.init(nibName: "PayMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "PayMessageCell")
        self.tableView.register(UINib.init(nibName: "EPShopPayWalletCell", bundle: Bundle.main), forCellReuseIdentifier: "EPShopPayWalletCell")
        
        if self.isFromOrderDetail{
            self.payMoneyLbl.text = "¥" + self.orderJson["total_amount"].stringValue
        }else{
            self.calculateMoney()
        }
        
        //默认收货地址
        self.loadAddressList()
        
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldToRoot{
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.removeNoti()
            //微信支付结果通知
            NotificationCenter.default.addObserver(self, selector: #selector(EPShopPayViewController.wechatPayResult(_:)), name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNoti()
    }
    
    func removeNoti() {
        //移除微信支付结果通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //默认收货地址
    func loadAddressList() {
        NetTools.requestData(type: .post, urlString: EPAddressListApi, succeed: { (result, msg) in
            //停止刷新
            if result.arrayValue.count > 0{
                self.addressInfo = result.arrayValue[0]
                self.tableView.reloadData()
            }
        }) { (error) in
        }
    }
    
    //提交订单后自动调起支付
    @IBAction func submitOrderAction() {
        self.view.endEditing(true)
        if self.orderId.isEmpty{
            if self.totalMoney < 0{
                LYProgressHUD.showError("商品信息有误！")
                return
            }
            if self.addressInfo["company_address_id"].stringValue.isEmpty{
                LYProgressHUD.showError("请选择收货地址")
                return
            }
            if self.goodsArray.count == 0{
                LYProgressHUD.showError("未选择商品")
                return
            }
            var arr : Array<Dictionary<String,String>> = Array<Dictionary<String,String>>()
            for json in self.goodsArray{
                let dict = ["goods_commonid" : json["id"].stringValue, "goods_num" : json["count"].stringValue]
                arr.append(dict)
            }
            let goods_info = arr.jsonString()
            var params : [String:String] = [:]
            params["order_price"] = String.init(format: "%.2f", self.totalMoney)
            params["address_id"] = self.addressInfo["company_address_id"].stringValue
            params["leave_word"] = self.payMessage
            params["goods_info"] = goods_info
            if self.isFromShopCar{
                params["is_cart"] = "1"
            }else{
                params["is_cart"] = "0"
            }
            if self.selectedCoupon != nil{
                params["coupon_id"] = self.selectedCoupon!["id"].stringValue
            }
            NetTools.requestData(type: .post, urlString: EPShopBuyApi, parameters: params, succeed: { (resultJson, msg) in
                
                self.orderId = resultJson["order_id"].stringValue
                //1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
                if self.payWay == 1{
                    self.payOfflineAction()
                }else if self.payWay == 2 || self.payWay == 3{
                    self.payAliOrWechat()
                }else if self.payWay == 4{
                    self.payByWallet()
                }
            }) { (error) in
                LYProgressHUD.showError(error ?? "下单失败，请重试！")
            }
        }else{
            //1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
            if self.payWay == 1{
                self.payOfflineAction()
            }else if self.payWay == 2 || self.payWay == 3{
                self.payAliOrWechat()
            }else if self.payWay == 4{
                self.payByWallet()
            }
        }
    }
    
    //
    
    
    
    
}





extension EPShopPayViewController{
    //计算总价钱
    func calculateMoney() {
        self.totalMoney = 0
        for subJson in self.goodsArray {
            self.totalMoney += CGFloat(subJson["price"].stringValue.floatValue) * CGFloat(subJson["count"].stringValue.floatValue)
        }
        self.payMoneyLbl.text = "¥" + String.init(format: "%.2f", self.totalMoney) + "元"
    }
    

    //线下支付
    func payOfflineAction() {
        var params : [String:String] = [:]
        params["order_id"] = self.orderId
        NetTools.requestData(type: .post, urlString: EPShopPayOfflineApi, parameters: params, succeed: { (resultJson, msg) in
            self.seeOrderDetail()
        }) { (error) in
            LYProgressHUD.showError(error ?? "下单失败，请重试或者联系客服！")
        }
    }
    
    //使用钱包
    func payByWallet() {
        let pwdView = PayPasswordView()
        pwdView.parentVC = self
        pwdView.show { (pwd) in
            var params : [String : Any] = [:]
            params["paypwd"] = pwd.md5String()
            params["order_id"] = self.orderId
            if self.selectedCoupon != nil{
                let newPrice = self.totalMoney - CGFloat(self.selectedCoupon!["coupon_price"].floatValue)
                if newPrice > 0{
                    params["wallet_price"] = String.init(format: "%.2f", newPrice)
                }else{
                    params["wallet_price"] = "0"
                }
            }else{
                params["wallet_price"] = String.init(format: "%.2f", self.totalMoney)
            }
            NetTools.requestData(type: .post, urlString: EPShopPayWalletApi, parameters: params, succeed: { (resultJson, error) in
                //支付密码正确
                self.seeOrderDetail()
            }) { (error) in
                LYProgressHUD.showError(error ?? "下单失败，请重试或者联系客服！")
            }
            
//            NetTools.requestDataTest(urlString: EPShopPayWalletApi, parameters: params, succeed: { (result) in
//
//            }) { (error) in
//
//            }
        }
        
        
    }
    
    //第三方支付
    func payAliOrWechat() {
        var params : [String : Any] = [:]
        params["order_id"] = self.orderId
        if self.payWay == 2{
            params["pay_type"] = "1"//支付方式1微信2支付宝
        }else{
            params["pay_type"] = "2"
        }
        NetTools.requestData(type: .post, urlString: EPShopPayOnlineApi, parameters: params, succeed: { (resultJson, error) in
            //支付密码正确
            if self.payWay == 2{
                //微信
                self.payByWechat(resultJson)
            }else{
                //支付宝
                self.payByAli(resultJson)
            }
        }) { (error) in
            LYProgressHUD.showError(error ?? "下单失败，请重试或者联系客服！")
        }
    }
    
    //使用支付宝付款
    func payByAli(_ aliJson : JSON) {
        /**
         {
         "listData" : {
         "appid" : "wx2ed53eb2e7badfc7",
         "partnerid" : "1391844702",
         "timestamp" : 1499429016,
         "noncestr" : "dhBCoozirJcSVAT3qLWCt3X4PTtnMrSq",
         "bill_id" : "659",
         "order_title" : "七小服",
         "order_total" : 58,
         "is_pay" : 1,
         "pay_sn" : "800020170707200336U1005",
         "package" : "Sign=WXPay",
         "call_api_url" : "http:\/\/10.216.2.11\/tp.php\/Home\/Notify\/billOrder\/MSXOP\/alipay",
         "prepayid" : "wx20170707115931ca30c6fb650039602680",
         "sign" : "C65448E7B9725B14D78ED3600AF7B910"
         },
         "repMsg" : "",
         "repCode" : "00"
         }
         */
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
            //支付成功
            self.seeOrderDetail()
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
        
        /**
         {
         "listData" : {
         "appid" : "wx2ed53eb2e7badfc7",
         "partnerid" : "1391844702",
         "timestamp" : 1499363696,
         "noncestr" : "fYII50ZkDRPncMws0iVb2jMqO3W92nzH",
         "bill_id" : "653",
         "order_title" : "七小服",
         "order_total" : 255,
         "is_pay" : 1,
         "pay_sn" : "800020170707015455U1005",
         "package" : "Sign=WXPay",
         "call_api_url" : "http:\/\/10.216.2.11\/tp.php\/Home\/Notify\/billOrder\/MSXOP\/alipay",
         "prepayid" : "wx20170706175049be6a1c3f420712750979",
         "sign" : "BB537A378854D94A6FB1232322B96958"
         },
         "repMsg" : "",
         "repCode" : "00"
         }
         */
    }
    //微信支付结果
    @objc func wechatPayResult(_ noti:Notification) {
        guard let resultDict = noti.userInfo as? [String:String] else {
            return
        }
        if resultDict["code"] == "0"{
            //支付成功
            self.seeOrderDetail()
        }else if resultDict["code"] == "-2"{
            //取消支付
            LYProgressHUD.showInfo("用户取消了支付")
        }else{
            //支付失败
            LYProgressHUD.showInfo(resultDict["error"]!)
        }
    }
    
    //查看订单详情
    func seeOrderDetail() {
        if self.refreshBlock != nil{
            self.refreshBlock!()
        }
        LYAlertView.show("提示", "下单成功，查看订单详情？", "返回", "查看订单",{
            self.shouldToRoot = true
            let orderDetailVC = EPShopOrderDetailViewController.spwan()
            orderDetailVC.orderId = self.orderId
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        },{
            self.navigationController?.popToRootViewController(animated: true)
        })
        
    }
}



extension EPShopPayViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isFromOrderDetail{
            return 1
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFromOrderDetail{
            return 2
        }
        if section == 0{
            return 1
        }else if section == 1{
            return self.goodsArray.count
        }else if section == 2{
            return 2
        }else if section == 3{
            return 2
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isFromOrderDetail{
            if indexPath.row == 0{
                //支付方式
                var cell = tableView.dequeueReusableCell(withIdentifier: "EPPayWayCell")
                if cell == nil{
                    cell = UITableViewCell.init(style: .value1, reuseIdentifier: "EPPayWayCell")
                }
                cell?.textLabel?.text = "支付方式"
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.textLabel?.textColor = UIColor.RGBS(s: 33)
                //1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
                if self.payWay == 1{
                    cell?.detailTextLabel?.text = "线下支付"
                }else if self.payWay == 2{
                    cell?.detailTextLabel?.text = "微信支付"
                }else if self.payWay == 3{
                    cell?.detailTextLabel?.text = "支付宝支付"
                }else if self.payWay == 4{
                    cell?.detailTextLabel?.text = "钱包支付"
                }
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.detailTextLabel?.textColor = UIColor.RGBS(s: 33)
                cell?.accessoryType = .disclosureIndicator
                cell?.selectionStyle = .none
                return cell!
            }else if indexPath.row == 1{
                //金额
                let cell = tableView.dequeueReusableCell(withIdentifier: "EPShopPayWalletCell", for: indexPath) as! EPShopPayWalletCell
                cell.totalMoneyLbl.text = "¥" + self.orderJson["order_price"].stringValue + "元"
                cell.couponMoneyLbl.text = "¥" + self.orderJson["coupon_price"].stringValue + "元"
                return cell
            }
        }else{
            if indexPath.section == 0{
                if self.addressInfo["company_address_id"].stringValue.isEmpty{
                    var cell = tableView.dequeueReusableCell(withIdentifier: "EPPayNoAddressCell")
                    if cell == nil{
                        cell = UITableViewCell.init(style: .value1, reuseIdentifier: "EPPayNoAddressCell")
                    }
                    cell?.textLabel?.text = "未设置收货地址"
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.textLabel?.textColor = UIColor.RGBS(s: 33)
                    cell?.detailTextLabel?.text = "去添加"
                    cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.detailTextLabel?.textColor = Normal_Color
                    cell?.accessoryType = .disclosureIndicator
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PayAddressCell_pay", for: indexPath) as! PayAddressCell
                    cell.nameLbl.text = self.addressInfo["company_true_name"].stringValue
                    cell.addressLbl.text = "收货地址:" + self.addressInfo["area_info"].stringValue + self.addressInfo["address"].stringValue
                    cell.phoneLbl.text = self.addressInfo["mob_phone"].stringValue
                    cell.bottomView.isHidden = true
                    cell.bottomViewH.constant = 0
                    cell.arrowImgV.isHidden = false
                    cell.selectionStyle = .none
                    return cell
                }
            }else if indexPath.section == 1{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PayGoodsCell", for: indexPath) as! PayGoodsCell
                if self.goodsArray.count > indexPath.row{
                    let subJson = self.goodsArray[indexPath.row]
                    cell.goodsNameLbl.text = subJson["name"].stringValue
                    cell.goodsIcon.setImageUrlStr(subJson["icon"].stringValue)
                    cell.priceLbl.text = subJson["price"].stringValue
                    cell.countLbl.text = "数量 X " + subJson["count"].stringValue
                }
                cell.selectionStyle = .none
                return cell
            }else if indexPath.section == 2{
                if indexPath.row == 0{
                    //使用优惠券
                    var cell = tableView.dequeueReusableCell(withIdentifier: "EPPayCouponCell")
                    if cell == nil{
                        cell = UITableViewCell.init(style: .value1, reuseIdentifier: "EPPayCouponCell")
                    }
                    cell?.textLabel?.text = "优惠券"
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.textLabel?.textColor = UIColor.RGBS(s: 33)
                    if self.selectedCoupon == nil{
                        cell?.detailTextLabel?.text = "选择优惠券"
                    }else{
                        cell?.detailTextLabel?.text = "1张"
                    }
                    cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.detailTextLabel?.textColor = UIColor.RGBS(s: 33)
                    cell?.accessoryType = .disclosureIndicator
                    cell?.selectionStyle = .none
                    
                    let line = UIView(frame: CGRect.init(x: 0, y: 43, width: kScreenW, height: 1))
                    line.backgroundColor = BG_Color
                    cell?.addSubview(line)
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PayMessageCell", for: indexPath) as! PayMessageCell
                    cell.payMessageBlock = {(str) in
                        self.payMessage = str
                    }
                    cell.selectionStyle = .none
                    return cell
                }
            }else if indexPath.section == 3{
                if indexPath.row == 0{
                    //支付方式
                    var cell = tableView.dequeueReusableCell(withIdentifier: "EPPayWayCell")
                    if cell == nil{
                        cell = UITableViewCell.init(style: .value1, reuseIdentifier: "EPPayWayCell")
                    }
                    cell?.textLabel?.text = "支付方式"
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.textLabel?.textColor = UIColor.RGBS(s: 33)
                    //1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
                    if self.payWay == 1{
                        cell?.detailTextLabel?.text = "线下支付"
                    }else if self.payWay == 2{
                        cell?.detailTextLabel?.text = "微信支付"
                    }else if self.payWay == 3{
                        cell?.detailTextLabel?.text = "支付宝支付"
                    }else if self.payWay == 4{
                        cell?.detailTextLabel?.text = "钱包支付"
                    }
                    cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.detailTextLabel?.textColor = UIColor.RGBS(s: 33)
                    cell?.accessoryType = .disclosureIndicator
                    cell?.selectionStyle = .none
                    return cell!
                }else if indexPath.row == 1{
                    //金额
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EPShopPayWalletCell", for: indexPath) as! EPShopPayWalletCell
                    cell.totalMoneyLbl.text = "¥" + String.init(format: "%.2f", self.totalMoney) + "元"
                    if self.selectedCoupon == nil{
                        cell.couponMoneyLbl.text = "-¥0元"
                    }else{
                        cell.couponMoneyLbl.text = "-¥" + self.selectedCoupon!["coupon_price"].stringValue + "元"
                    }
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.isFromOrderDetail{
            if indexPath.row == 0{
                //支付方式
                let payWayVC = EPShopPayWayViewController.spwan()
                payWayVC.totalMoney = self.totalMoney
                payWayVC.choosePayWayBlock = {(type) in
                    //1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
                    self.payWay = type
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(payWayVC, animated: true)
            }
        }else{
            if indexPath.section == 0{
                //收货地址
                let addressVC = AddressListViewController()
                addressVC.isChooseAddress = true
                addressVC.chooseAddressBlock = {[weak self] (json) in
                    self?.addressInfo = json
                    self?.tableView.reloadData()
                }
                self.navigationController?.pushViewController(addressVC, animated: true)
            }else if indexPath.section == 2{
                if indexPath.row == 0{
                    //使用优惠券
                    let couponVC = EPMyCouponViewController.spwan()
                    couponVC.isFromPay = true
                    couponVC.shopOrderPrice = "\(totalMoney)"
                    couponVC.selectedJson = self.selectedCoupon
                    couponVC.selectedCouponBlock = {(coupon) in
                        self.selectedCoupon = coupon
                        if coupon == nil{
                            self.payMoneyLbl.text = "¥" + String.init(format: "%.2f", self.totalMoney) + "元"
                        }else{
                            let newPrice = self.totalMoney - CGFloat(coupon!["coupon_price"].floatValue)
                            if newPrice > 0{
                                self.payMoneyLbl.text = "共支付:¥" + String.init(format: "%.2f", newPrice)
                            }else{
                                self.payMoneyLbl.text = "共支付:¥0"
                            }
                        }
                        self.tableView.reloadData()
                    }
                    self.navigationController?.pushViewController(couponVC, animated: true)
                }
            }else if indexPath.section == 3{
                if indexPath.row == 0{
                    //支付方式
                    let payWayVC = EPShopPayWayViewController.spwan()
                    if self.selectedCoupon == nil{
                         payWayVC.totalMoney = self.totalMoney
                    }else{
                        let newPrice = self.totalMoney - CGFloat(self.selectedCoupon!["coupon_price"].floatValue)
                        if newPrice > 0{
                             payWayVC.totalMoney = newPrice
                        }else{
                             payWayVC.totalMoney = 0
                        }
                    }
                    payWayVC.choosePayWayBlock = {(type) in
                        //1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
                        self.payWay = type
                        self.tableView.reloadData()
                    }
                    self.navigationController?.pushViewController(payWayVC, animated: true)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isFromOrderDetail{
            if indexPath.row == 0{
                return 44
            }
            return 70
        }else{
            if indexPath.section == 0{
                if self.addressInfo["company_address_id"].stringValue.isEmpty{
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
            }else if indexPath.section == 2 || indexPath.section == 3{
                if indexPath.row == 0{
                    return 44
                }
                return 70
            }
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
