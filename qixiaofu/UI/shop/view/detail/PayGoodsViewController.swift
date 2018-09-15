//
//  PayGoodsViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/24.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PayGoodsViewController: BaseViewController {
    class func spwan() -> PayGoodsViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! PayGoodsViewController
    }
    
    var isFromShopCar = false
    var cartId = ""
    var goodsArray : Array<JSON> = Array<JSON>()
    fileprivate var payType : Int = 2//0钱包 2支付宝 3微信
    
    var orderId = ""//下单后的订单号
    fileprivate var isNeedRemoveOrder = false//只有在下单失败且重新下单的情况下才去取消原单
    fileprivate var selectedCoupon : JSON?
    
    
    //还需支付的钱
    var price : CGFloat = 0{
        didSet{
            self.payCountLbl.text = "共支付:¥" + String.init(format: "%.2f", price)
        }
    }
    

    @IBOutlet weak var payCountLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var resultJson : JSON = []
    fileprivate var paymentList : JSON = []
    fileprivate var addressInfo : JSON = []
    fileprivate var walletInfo : JSON = []
    fileprivate var addressId = ""
    fileprivate var beanNum = 0//服豆使用量
    fileprivate var payMessage = ""//买家留言
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "支付"
        
        self.tableView.register(UINib.init(nibName: "PayAddressCell", bundle: Bundle.main), forCellReuseIdentifier: "PayAddressCell_pay")
        self.tableView.register(UINib.init(nibName: "PayGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "PayGoodsCell")
        self.tableView.register(UINib.init(nibName: "PayWalletCell", bundle: Bundle.main), forCellReuseIdentifier: "PayWalletCell")
        self.tableView.register(UINib.init(nibName: "PayWayCell", bundle: Bundle.main), forCellReuseIdentifier: "PayWayCell")
        self.tableView.register(UINib.init(nibName: "PayFuBeanCell", bundle: Bundle.main), forCellReuseIdentifier: "PayFuBeanCell")
        self.tableView.register(UINib.init(nibName: "PayMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "PayMessageCell")
        
        self.checkPayPassword()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNoti()
        //微信支付结果通知
        NotificationCenter.default.addObserver(self, selector: #selector(PayGoodsViewController.wechatPayResult(_:)), name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNoti()
    }
    
    func removeNoti() {
        //移除微信支付结果通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
    }

    
    //检查是否设置了密码
    func checkPayPassword() {
        NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, succeed: { (resultJson, error) in
            self.walletInfo = resultJson
            
            //加载其他数据
            self.preparePayData()
            
        }) { (error) in
            //加载其他数据
            self.preparePayData()
        }
    }
    
    
    //预付款数据
    func preparePayData() {
        var params : [String : Any] = [:]
        params["store_id"] = "1"
        params["cart_id"] = self.cartId
        if self.isFromShopCar{
            params["ifcart"] = (1)//  结算方式 【1，购物车】 【0，立即购买】
        }else{
            params["ifcart"] = (0)//  结算方式 【1，购物车】 【0，立即购买】
            params["is_appPay"] = "1"
        }
        NetTools.requestData(type: .post, urlString: GoodsPreparePayDataApi, parameters: params, succeed: { (resultJson, msg) in
            self.resultJson = resultJson
            self.addressInfo = resultJson["address_info"]
            self.addressId = self.addressInfo["address_id"].stringValue
            self.sortPayment(json: resultJson["payment_list"])
            self.price = CGFloat(resultJson["goods_total"].stringValue.floatValue)
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    
    //对支付方式做一个重新排序，钱包-服豆-支付宝-微信
    func sortPayment(json : JSON) {
        var json1 : JSON = []
//        let json4 : JSON = ["payment_name" : "服豆", "payment_id" : "100"]
        var json2 : JSON = []
        var json3 : JSON = []
        let json5 : JSON = ["payment_name" : "优惠券", "payment_id" : "101"]
        
        if json.arrayValue.count > 0{
            for subJson in json.arrayValue {
                if subJson["payment_id"].stringValue == "7"{
                    json1 = subJson
                }else if subJson["payment_id"].stringValue == "2"{
                    json2 = subJson
                }else if subJson["payment_id"].stringValue == "6"{
                    json3 = subJson
                }
            }
        }
        
        //服豆
        /**
         "is_default" : "0",
         "payment_img" : "",
         "payment_name" : "钱包",
         "payment_desc" : "",
         "payment_id" : "7"
         */
//        json4["payment_name"] = JSON("服豆")
//        json4["payment_id"] = JSON("100")
        
//        self.paymentList = [json1,json2,json3]
        self.paymentList = [json1,json5,json2,json3]
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func payAction() {
        
        //付款失败，自动取消
        self.autoDeleteOrder(self.orderId)
        
        if self.payType == 0{
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
        }else if self.payType == 3{
            self.payActionWithInfo(pwd: "")
        }
    }
    
    func autoDeleteOrder(_ orderId : String) {
        //付款失败，自动取消
        if self.isNeedRemoveOrder && !orderId.isEmpty{
            self.isNeedRemoveOrder = false
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["order_id"] = orderId
            params["state_info"] = "付款失败，自动取消"
            NetTools.requestData(type: .post, urlString: ShopOrderCancelApi, parameters: params, succeed: { (result, msg) in
                var params2 : [String : Any] = [:]
                params2["store_id"] = "1"
                params2["order_id"] = orderId
                NetTools.requestData(type: .post, urlString: ShopOrderAfterDeliverApi, parameters: params, succeed: { (result, msg) in
                }, failure: { (error) in
                })
            }, failure: { (error) in
            })
        }
    }
}

extension PayGoodsViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return self.goodsArray.count
        }else if section == 2{
            return 1
        }else if section == 3{
            return self.paymentList.arrayValue.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            if self.addressInfo["address_id"].stringValue.isEmpty{
                var cell = tableView.dequeueReusableCell(withIdentifier: "PayNoAddressCell")
                if cell == nil{
                    cell = UITableViewCell.init(style: .value1, reuseIdentifier: "PayNoAddressCell")
                }
                cell?.textLabel?.text = "未设置收货地址"
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.textLabel?.textColor = UIColor.RGBS(s: 33)
                cell?.detailTextLabel?.text = "去添加"
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell?.detailTextLabel?.textColor = Normal_Color
                cell?.accessoryType = .disclosureIndicator
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PayAddressCell_pay", for: indexPath) as! PayAddressCell
                cell.nameLbl.text = self.addressInfo["true_name"].stringValue
                cell.addressLbl.text = "收货地址:" + self.addressInfo["area_info"].stringValue + self.addressInfo["address"].stringValue
                cell.phoneLbl.text = self.addressInfo["mob_phone"].stringValue
                cell.bottomView.isHidden = true
                cell.bottomViewH.constant = 0
                cell.arrowImgV.isHidden = false
                
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
            return cell
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayMessageCell", for: indexPath) as! PayMessageCell
            cell.payMessageBlock = {(str) in
                self.payMessage = str
            }
            return cell
        }else if indexPath.section == 3{
            
            if self.paymentList.arrayValue.count > indexPath.row{
                let subJson = self.paymentList.arrayValue[indexPath.row]
                if subJson["payment_id"].stringValue == "7"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PayWalletCell", for: indexPath) as! PayWalletCell
                    cell.moneyLbl.text = "(可用余额:¥" + self.walletInfo["remaining_balance"].stringValue + ")"
//                    cell.moneyLbl.text = "(可用余额:¥" + self.walletInfo["available_predeposit"].stringValue + ")"
                    if self.payType == 0{
                        cell.walletSwitch.isOn = true
                    }else{
                        cell.walletSwitch.isOn = false
                    }
                    return cell
                }else if subJson["payment_id"].stringValue == "100"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PayFuBeanCell", for: indexPath) as! PayFuBeanCell
//                    resultJson["goods_total"].stringValue
                    var availableBean : Float = 0
                    if self.resultJson["goods_total"].stringValue.floatValue * self.walletInfo["fudoubili"].stringValue.floatValue > self.walletInfo["member_fudou"].stringValue.floatValue{
                        availableBean = self.walletInfo["member_fudou"].stringValue.floatValue
                    }else{
                        availableBean = self.resultJson["goods_total"].stringValue.floatValue * self.walletInfo["fudoubili"].stringValue.floatValue
                    }
                    
                    cell.beanLbl.text = " (可用数量:" + String.init(format: "%.0f", availableBean) + ")"
                    cell.beanNum = Int(availableBean)
                    cell.numChangedBlock = {(num) in
                        self.price = self.price - CGFloat(num - self.beanNum)
                        self.beanNum = num
                        
                    }
                    return cell
                }else if subJson["payment_id"].stringValue == "101"{
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PayWayCell", for: indexPath) as! PayWayCell
                    cell.imgV.setImageUrlStr(subJson["payment_img"].stringValue)
                    cell.nameLbl.text = subJson["payment_name"].stringValue
                    if self.payType == 2 && subJson["payment_id"].stringValue == "2"{
                        cell.selectedBtn.isSelected = true
                    }else if self.payType == 3 && subJson["payment_id"].stringValue == "6"{
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
            if self.addressInfo["address_id"].stringValue.isEmpty{
                let addAddressVC = AddAddressViewController.spwan()
                addAddressVC.editAddressBlock = {[weak self] (json) in
                    //添加成功,刷新数据
                    self?.preparePayData()
                }
                self.navigationController?.pushViewController(addAddressVC, animated: true)
            }else{
                //收货地址
                let addressVC = AddressListViewController()
                addressVC.isChooseAddress = true
                addressVC.chooseAddressBlock = {[weak self] (json) in
                    self?.addressInfo = json
                    self?.addressId = json["address_id"].stringValue
                    self?.tableView.reloadData()
                }
                self.navigationController?.pushViewController(addressVC, animated: true)
            }
            
        }else if indexPath.section == 3 && self.payType != indexPath.row{
            
            var couponMoney : CGFloat = 0
            if self.selectedCoupon != nil{
                couponMoney = CGFloat(selectedCoupon!["coupon_price"].stringValue.floatValue)
            }
            if indexPath.row == 0{
                if CGFloat(self.walletInfo["remaining_balance"].stringValue.floatValue) < self.price - couponMoney{
//                if CGFloat(self.walletInfo["available_predeposit"].stringValue.floatValue) < self.price{
                    LYProgressHUD.showError("余额不足")
                    return
                }
            }
            if indexPath.row != 1{
                self.payType = indexPath.row
                self.tableView.reloadData()
            }else{
                //使用优惠券
                let couponVC = MyCouponViewController.spwan()
                couponVC.isFromPay = true
                couponVC.couponType = "4"
                couponVC.payMoney = self.price
                
                var sysArr : Array<String> = []
                for goods in self.goodsArray{
                    sysArr.append(goods["sys"].stringValue)
                }
                couponVC.paySys = sysArr.joined(separator: ",")
                couponVC.selectedJson = self.selectedCoupon
                couponVC.selectedCouponBlock = {(coupon) in
                    self.selectedCoupon = coupon
                    if coupon == nil{
                        self.payCountLbl.text = "共支付:¥" + String.init(format: "%.2f", self.price)
                    }else{
                        let newPrice = self.price - CGFloat(coupon!["coupon_price"].stringValue.floatValue)
                        if newPrice > 0{
                            self.payCountLbl.text = "共支付:¥" + String.init(format: "%.2f", newPrice)
                        }else{
                            self.payCountLbl.text = "共支付:¥0"
                        }
                    }
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(couponVC, animated: true)
                
                /**
                 服豆使用
                 guard let cell = tableView.cellForRow(at: indexPath) as? PayFuBeanCell else{
                 return
                 }
                 cell.beanTF.becomeFirstResponder()
                 */
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
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
        }
        if indexPath.section == 2{
            return 70
        }
        if indexPath.section == 3{
            if indexPath.row == 1{
                return 44
            }
        }
        return 60
        //        if indexPath.section == 0{
        //            return 100
        //        }else if indexPath.section == 1{
        //            return 60
        //        }else if indexPath.section == 2{
        //            return 60
        //        }
        //        return 0
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

extension PayGoodsViewController{
    
    func payActionWithInfo(pwd : String) {
        var params : [String : Any] = [:]
        
        if self.isFromShopCar{
            params["ifcart"] = (1)// 1 购物车结算  0，立即购买
        }else{
            params["ifcart"] = (0)// 1 购物车结算  0，立即购买
        }
        params["store_id"] = "1"//店铺ID
        params["cart_id"] = self.cartId//单个商品【购物车ID丨数量】 多个商品【购物车ID丨数量，购物车ID丨数量】
        if self.addressId.isEmpty{
            LYProgressHUD.showError("请添加收货地址")
        }else{
            params["address_id"] = self.addressId
        }
        params["vat_hash"] = self.resultJson["vat_hash"].stringValue //需要传的参数1
        params["offpay_hash"] = self.resultJson["offpay_hash"].stringValue//需要传的参数2
        params["offpay_hash_batch"] = self.resultJson["offpay_hash_batch"].stringValue//需要传的参数3
        if self.payType == 0{//  选择的是使用钱包付款，那么钱包付全款
            params["payment_id"] = (7) //  支付方式ID 1：货到付款 2：支付宝 6：微信
            params["wallet_price"] = String.init(format: "%.2f", self.price) //使用钱包的金额
            params["member_paypwd"] = pwd.md5String() //平台支付密码
        }else if self.payType == 2{
            params["payment_id"] = (2) //  支付方式ID 1：货到付款 2：支付宝 6：微信
        }else{
            params["payment_id"] = (6) //  支付方式ID 1：货到付款 2：支付宝 6：微信
        }
        if self.beanNum > 0{
            params["fudou_price"] = String.init(format: "%d", self.beanNum)//使用服豆
        }
        params["pay_name"] = "online"// 【online 在线付款】【offline 货到付款 】
        
        params["order_note"] = ""//订单备注
        params["invoice_id"] = ""  // 	发票ID
        params["distr_type"] = ""//配送方式【暂无】
        params["voucher"] = ""// 优惠券【优惠券ID丨固定1丨优惠券金额】
        params["postion"] = ""//是否使用积分 1，使用 0，不使用
        params["distribution_id"] = ""//配送方式IDz
        params["buyer_message"] = self.payMessage//买家留言
        if self.selectedCoupon != nil{
            params["coupon_id"] = self.selectedCoupon!["coupon_id"].stringValue// 优惠券id
        }
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: GoodsPayOrderApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            //记录订单号
            self.orderId = resultJson["order_id"].stringValue
            
            if self.payType == 0 && resultJson["is_pay"].stringValue.intValue == 0{//  选择的是使用钱包付款，那么钱包付全款
               //支付成功
                LYAlertView.show("提示", "下单成功，查看订单详情？", "返回首页", "查看", {
                    //查看订单详情
                    self.seeOrderDetail()
                },{
                    //返回首页
                    self.navigationController?.popToRootViewController(animated: true)
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
            LYAlertView.show("提示", "下单成功，查看订单详情？", "返回首页", "查看", {
                //查看订单详情
                self.seeOrderDetail()
            },{
                //返回首页
                self.navigationController?.popToRootViewController(animated: true)
            })
        }else if resultDict!["resultStatus"] as! String == "6001"{
            //支付取消
            LYProgressHUD.showInfo("用户取消了支付")
            self.isNeedRemoveOrder = true
        }else{
            //支付失败
            LYProgressHUD.showInfo("支付失败！")
            self.isNeedRemoveOrder = true
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
            LYAlertView.show("提示", "下单成功，查看订单详情？", "返回首页", "查看", {
                //查看订单详情
                self.seeOrderDetail()
            },{
                //返回首页
                self.navigationController?.popToRootViewController(animated: true)
            })
        }else if resultDict["code"] == "-2"{
            //取消支付
            LYProgressHUD.showInfo("用户取消了支付")
            self.isNeedRemoveOrder = true
        }else{
            //支付失败
            LYProgressHUD.showInfo(resultDict["error"]!)
            self.isNeedRemoveOrder = true
        }
    }
    
    //查看订单详情
    func seeOrderDetail() {
        
        let orderDetailVC = ShopOrderDetailViewController()
        orderDetailVC.orderId = self.orderId
        orderDetailVC.isFromPay = true
        self.navigationController?.pushViewController(orderDetailVC, animated: true)
    }
}

/**
 {
 "listData" : {
 "distribution_info" : [
 {
 "distribution_id" : "1",
 "distribution_info" : "送货上门"
 },
 {
 "distribution_id" : "2",
 "distribution_info" : "到店自取"
 }
 ],
 "preferential_price" : 0,
 "integral" : "0",
 "cart_show_ids" : "438|1",
 "allow_offpay" : 0,
 "inv_info" : {
 "inv_state" : "普通发票"
 },
 "offpay_hash" : null,
 "store_free_price" : 0,
 "goods_nums" : 1,
 "vat_hash" : "GRQbHtQ1N-L0Kd5FOfExTYTUkgHPRYU-z_Q",
 "store_name" : "",
 "actual_price" : 1400,
 "address_info" : {
 "address_id" : ""
 "address" : "小营桥",
 "area_info" : "北京北京市海淀区",
 "mob_phone" : "18612334016",
 "true_name" : "李勇",
 "address_id" : "19",
 "lng" : "116.3480237922",
 "lat" : "40.044706436284"
 },
 "goods_total" : "1400.00",
 "freight" : "0",
 "integral_money" : 0,
 "coupons" : 0,
 "payment_list" : [
 {
 "is_default" : "0",
 "payment_img" : "http:\/\/www.cpweb.gov.cn\/uploads\/allimg\/141203\/538-141203135F5E4.png",
 "payment_name" : "支付宝",
 "payment_desc" : "支付宝,全球领先的独立第三方支付平台,致力于为广大用户提供安全快速的电子支付\/网上支付\/安全支付\/手机支付体验,及转账收款\/水电煤缴费\/信用卡还款\/AA收款等生活...",
 "payment_id" : "2"
 },
 {
 "is_default" : "0",
 "payment_img" : "http:\/\/img1.2345.com\/duoteimg\/softImg\/soft\/11\/1412053391_28.jpg",
 "payment_name" : "微信支付",
 "payment_desc" : "微信支付是腾讯公司的支付业务品牌,微信支付提供公众号支付、APP支付、扫码支付、刷卡支付等支付方式。微信支付结合微信公众账号,全面打通O2O生活消费领域,提供专业的...",
 "payment_id" : "6"
 },
 {
 "is_default" : "0",
 "payment_img" : "",
 "payment_name" : "钱包",
 "payment_desc" : "",
 "payment_id" : "7"
 }
 ],
 "freight_hash" : "2x9K7d0NP2AmfrCZLHgcV_9UiON-mECgzz5zNsItoiGTNMEAWjDUrSxTF3_AzOERGCnEh6K8jDrrT1KFt4r7kmDHAdTDS_B8jFMHPkF9Ryf8-eeFw3Q0gcv",
 "offpay_hash_batch" : null,
 "goods_images" : [
 "http:\/\/www.7xiaofu.com\/data\/upload\/shop\/store\/goods\/1\/1_05530238616647117_240.jpg"
 ]
 },
 "repMsg" : "",
 "repCode" : "00"
 }
 
 */
