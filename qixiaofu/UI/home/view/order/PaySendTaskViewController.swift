//
//  PaySendTaskViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/6.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


class PaySendTaskViewController: BaseViewController,WXApiDelegate {
    class func spwan() -> PaySendTaskViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! PaySendTaskViewController
    }
    
    var rePayOrderSuccessBlock : (() -> Void)?
    
    var isRepairOrder = false//是否为补单
    var isFromPlugin = false//是否为购买插件
    var isPrepareToSeal = false//是否为代卖时的仓储费
    fileprivate var selectedCoupon : JSON? //选择的优惠券
    var sealPrice = ""//代卖的价格
    var isStorageMeal = false//是否为购买仓储套餐-续租仓储费
    var storageDays = ""//仓储套餐的天数
    var pluginOrderId = ""//插件购买单ID
    var systermPrice = ""//仓储套餐 按照类型区分的价格，json字符串
    var isJustPay = false
    var isFailRePay = false//支付失败时重新支付
    var totalMoney : Double = 0.0
    var orderId = ""
    var paySn = ""
    var enrollJson : JSON?//指定接单人需要付款的情况
    //调价参数
    var newPrice = ""//调新的价格
    var imgArray = Array<UIImage>()//上传的图片地址
    var top_price = "100"//置顶费
    var isSetPrice = false//先发单的定价操作
    
    
    @IBOutlet weak var serverContentLbl: UILabel!
    @IBOutlet weak var serverTimeLbl: UILabel!
    @IBOutlet weak var serverAreaLbl: UILabel!
    @IBOutlet weak var serverPriceLbl: UILabel!
    @IBOutlet weak var topView: UIView!//置顶信息
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var topPriceLbl: UILabel!
    
    @IBOutlet weak var walletLbl: UILabel!
    @IBOutlet weak var walletSwitch: UISwitch!
    @IBOutlet weak var aliIconImgV: UIImageView!
    @IBOutlet weak var wechatImgV: UIImageView!
    @IBOutlet weak var wechatBtn: UIButton!
    @IBOutlet weak var aliBtn: UIButton!
    @IBOutlet weak var totalMoneyLbl: UILabel!
    
    @IBOutlet weak var orderDescView: UIView!//发单信息
    @IBOutlet weak var orderDescViewH: NSLayoutConstraint!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var couponViewH: NSLayoutConstraint!
    
    
    fileprivate var haveSetPayPwd : Bool = false
    fileprivate var bill_id = ""
    fileprivate var walletPrice : Double = 0
    
    
    var paymentJson : JSON = []
    var params : [String : Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "支付"
        walletSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        //是否已设置密码
        self.checkPayPassword()
        
        //页面数据
        self.setUpSubViews()
        
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(PaySendTaskViewController.backClick))
        
        //是否可用优惠券
        if self.isPrepareToSeal || self.isStorageMeal{
            self.couponView.isHidden = false
            self.couponViewH.constant = 44
            self.couponView.addTapActionBlock(action: {
                let couponVC = MyCouponViewController.spwan()
                couponVC.isFromPay = true
                couponVC.couponType = "3"
                couponVC.systermPrice = self.systermPrice
                couponVC.selectedJson = self.selectedCoupon
                couponVC.selectedCouponBlock = {(coupon) in
                    self.selectedCoupon = coupon
                    if coupon == nil{
                        self.couponLbl.text = "请选择优惠券"
                        self.totalMoneyLbl.text = String.init(format: "共支付:¥%.2f元", self.totalMoney)
                    }else{
                        self.couponLbl.text = "1张"
                        let newPrice = self.totalMoney - Double(coupon!["coupon_price"].floatValue)
                        if newPrice > 0{
                            self.totalMoneyLbl.text = String.init(format: "共支付:¥%.2f元", newPrice)
                        }else{
                            self.totalMoneyLbl.text = "共支付:¥0元"
                        }
                    }
                }
                self.navigationController?.pushViewController(couponVC, animated: true)
            })
        }else{
            self.couponView.isHidden = true
            self.couponViewH.constant = 0
        }
        
        
    }
    
    //如果是发单时支付失败，返回时要询问是否取消单
    @objc func backClick() {
        if self.isFailRePay && !self.isJustPay{
            LYAlertView.show("提示", "确定要取消此次发单吗？", "先不取消", "确定取消",{
                var params : [String : Any] = [:]
                params["id"] = self.bill_id
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: CancelCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("取消成功！")
                    self.navigationController?.popViewController(animated: true)
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            },{
                self.navigationController?.popViewController(animated: true)
            })
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNoti()
        //微信支付结果通知
        NotificationCenter.default.addObserver(self, selector: #selector(PaySendTaskViewController.wechatPayResult(_:)), name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil)
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
    }
    
    func setUpSubViews() {
        if self.isJustPay || self.isFailRePay{
            self.orderDescView.isHidden = true
            self.orderDescViewH.constant = 0
            self.topView.isHidden = true
            self.topViewH.constant = 0
            self.totalMoneyLbl.text = String.init(format: "共支付:¥%.2f元", self.totalMoney)
        }else{
            self.serverContentLbl.text = (params["title"] as! String)
            self.serverTimeLbl.text = Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: params["service_stime"] as! String) + "-" + Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: params["service_etime"] as! String)
            self.serverAreaLbl.text = (params["service_address"] as! String)
            self.serverPriceLbl.text = "¥" + (params["service_price"] as! String) + "元"
            
            if params["top_day"] != nil{
                let top_day = (params["top_day"] as! String).doubleValue
                self.topPriceLbl.text = String.init(format: "¥%.2f元", top_day * self.top_price.doubleValue)
            }else{
                self.topView.isHidden = true
                self.topViewH.constant = 0
            }
            
            if params.keys.contains("top_day"){
                self.totalMoney = (params["service_price"] as! String).doubleValue + (params["top_day"] as! String).doubleValue * self.top_price.doubleValue
            }else{
                self.totalMoney = (params["service_price"] as! String).doubleValue
            }
            
            self.totalMoneyLbl.text = String.init(format: "共支付:¥%.2f元", self.totalMoney)
        }
    }
    //钱包支付
    @IBAction func walletSwitchAction() {
        if self.walletPrice < self.totalMoney{
            LYProgressHUD.showError("余额不足！")
            self.walletSwitch.isOn = false
            return
        }
        if self.walletSwitch.isOn{
            self.aliBtn.isSelected = false
            self.wechatBtn.isSelected = false
        }else{
            self.aliBtn.isSelected = true
            self.wechatBtn.isSelected = false
        }
    }
    //支付宝支付
    @IBAction func aliBtnAction() {
        self.walletSwitch.isOn = false
        self.aliBtn.isSelected = true
        self.wechatBtn.isSelected = false
    }
    //微信支付
    @IBAction func wechatBtnAction() {
        self.walletSwitch.isOn = false
        self.aliBtn.isSelected = false
        self.wechatBtn.isSelected = true
    }
    //MARK:支付
    @IBAction func payAction() {
        
        if self.walletSwitch.isOn{
            if self.haveSetPayPwd{
                self.payByWallet()
            }else{
                //设置支付密码
                let changePayPwdVc = ChangePasswordViewController.spwan()
                changePayPwdVc.type = .setPayPwd
                changePayPwdVc.setPayPwdSuccessBlock = {() in
                    self.checkPayPassword()
                }
                self.navigationController?.pushViewController(changePayPwdVc, animated: true)
            }
        }else {
            //支付密码正确
            if self.isJustPay || self.isFailRePay{
                if self.enrollJson != nil{
                    //指定接单人支付
                    self.enrollPay(pwd: "")
                }else if !self.newPrice.isEmpty{
                    //调价支付
                    self.changePricePay(pwd: "")
                }else if self.isFromPlugin{
                    //插件支付
                    self.pluginPay(pwd: "")
                }else if self.isStorageMeal{
                    //仓储支付
                    self.storagePay(pwd: "")
                }else if self.isPrepareToSeal{
                    //代卖仓储支付
                    self.sealStoragePay(pwd: "")
                }else if self.isSetPrice{
                    //先发单的定价操作
                    self.setPricePay(pwd: "")
                }else{
                    //普通支付
                    if self.paySn.isEmpty{
                        //未支付订单----再次支付成功
                        self.repayOrder(pwd: "")
                    }else{
                        //未支付商城订单----再次支付成功
                        self.repayShopOrder(pwd: "")
                    }
                }
            }else{
                //提交订单
                self.sendTaskRequest(pwd: "")
            }
        }
    }

}

extension PaySendTaskViewController{
    //检查是否设置了密码
    func checkPayPassword() {
        NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, succeed: { (resultJson, error) in
            self.walletLbl.text = "使用钱包付款(余额:¥" + resultJson["remaining_balance"].stringValue + "元)"
            self.walletPrice = resultJson["remaining_balance"].stringValue.doubleValue
//            self.walletLbl.text = "使用钱包付款(余额:¥" + resultJson["available_predeposit"].stringValue + ")"
            if resultJson["statu"].stringValue.intValue == 1{
                self.haveSetPayPwd = true
            }
        }) { (error) in
            self.walletLbl.text = "使用钱包付款(余额:¥0.00元)"
        }
    }
    
    //MARK:使用钱包
    func payByWallet() {
        let pwdView = PayPasswordView()
        pwdView.parentVC = self
        pwdView.show { (pwd) in
            var params : [String : Any] = [:]
            params["paypwd"] = pwd.md5String()
            NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, parameters: params, succeed: { (resultJson, error) in
                if resultJson["statu"].stringValue.intValue == 2{
                    //支付密码正确
                    if self.isJustPay || self.isFailRePay{
                        if self.enrollJson != nil{
                            //指定接单人支付
                            self.enrollPay(pwd: pwd)
                        }else if !self.newPrice.isEmpty{
                            //调价支付
                            self.changePricePay(pwd: pwd)
                        }else if self.isFromPlugin{
                            //插件支付
                            self.pluginPay(pwd: pwd)
                        }else if self.isStorageMeal{
                            //仓储支付
                            self.storagePay(pwd: pwd)
                        }else if self.isPrepareToSeal{
                            //代卖仓储支付
                            self.sealStoragePay(pwd: pwd)
                        }else if self.isSetPrice{
                            //先发单的定价操作
                            self.setPricePay(pwd: pwd)
                        }else{
                            //普通支付
                            if self.paySn.isEmpty{
                                //未支付订单----再次支付成功
                                self.repayOrder(pwd: pwd)
                            }else{
                                //未支付商城订单----再次支付成功
                                self.repayShopOrder(pwd: pwd)
                            }
                        }
                    }else{
                        //提交订单
                        self.sendTaskRequest(pwd: pwd)
                    }
                }else if resultJson["statu"].stringValue.intValue == 3{
                    LYProgressHUD.showError("支付密码错误！")
                    self.payByWallet()
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
    }
    
    //MARK:指定接单人的支付
    func pluginPay(pwd:String) {
        LYProgressHUD.showLoading()
        var pluginParams : [String : Any] = [:]
        if self.walletSwitch.isOn && !pwd.isEmpty{
            pluginParams["member_paypwd"] = pwd.md5String()
            pluginParams["is_wallet"] = "1"
            pluginParams["wallet_price"] = "\(totalMoney)"
            pluginParams["payment_id"] = "7"
        }else if self.aliBtn.isSelected{
            pluginParams["is_wallet"] = "0"
            pluginParams["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            pluginParams["is_wallet"] = "0"
            pluginParams["payment_id"] = "6"
        }
        pluginParams["id"] = self.pluginOrderId
        pluginParams["price"] = "\(totalMoney)"
        
        
        NetTools.requestData(type: .post, urlString: PluginPayApi, parameters: pluginParams, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                //支付成功
                //支付成功后返回
                LYProgressHUD.showSuccess("支付成功！")
                if self.rePayOrderSuccessBlock != nil{
                    self.rePayOrderSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //MARK:购买仓储套餐的支付
    func storagePay(pwd:String) {
        LYProgressHUD.showLoading()
        var storageParams : [String : Any] = [:]
        if self.walletSwitch.isOn && !pwd.isEmpty{
            storageParams["member_paypwd"] = pwd.md5String()
            storageParams["is_wallet"] = "1"
            storageParams["wallet_price"] = "\(totalMoney)"
            storageParams["payment_id"] = "7"
        }else if self.aliBtn.isSelected{
            storageParams["is_wallet"] = "0"
            storageParams["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            storageParams["is_wallet"] = "0"
            storageParams["payment_id"] = "6"
        }
        if self.selectedCoupon != nil{
            storageParams["coupon_id"] = self.selectedCoupon!["member_coupon_id"].stringValue
        }
        storageParams["id"] = self.orderId
        storageParams["storage_price"] = "\(totalMoney)"
        storageParams["storage_choice"] = self.storageDays
        
        NetTools.requestData(type: .post, urlString: StorageMealBuyApi, parameters: storageParams, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                //支付成功
                //支付成功后返回
                LYProgressHUD.showSuccess("支付成功！")
                if self.rePayOrderSuccessBlock != nil{
                    self.rePayOrderSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //MARK:去代卖设置价格购买仓储套餐的支付
    func sealStoragePay(pwd:String) {
        LYProgressHUD.showLoading()
        var storageParams : [String : Any] = [:]
        if self.walletSwitch.isOn && !pwd.isEmpty{
            storageParams["member_paypwd"] = pwd.md5String()
            storageParams["is_wallet"] = "1"
            storageParams["wallet_price"] = "\(totalMoney)"
            storageParams["payment_id"] = "7"
        }else if self.aliBtn.isSelected{
            storageParams["is_wallet"] = "0"
            storageParams["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            storageParams["is_wallet"] = "0"
            storageParams["payment_id"] = "6"
        }
        if self.selectedCoupon != nil{
            storageParams["coupon_id"] = self.selectedCoupon!["member_coupon_id"].stringValue
        }
        storageParams["id"] = self.orderId
        storageParams["storage_price"] = "\(totalMoney)"
        storageParams["storage_choice"] = self.storageDays
        storageParams["consignment_price"] = self.sealPrice
        
        NetTools.requestData(type: .post, urlString: TestPriceForSealGoodsApi, parameters: storageParams, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                //支付成功
                //支付成功后返回
                LYProgressHUD.showSuccess("支付成功！")
                if self.rePayOrderSuccessBlock != nil{
                    self.rePayOrderSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //MARK:去代卖设置价格购买仓储套餐的支付
    func setPricePay(pwd:String) {
        LYProgressHUD.showLoading()
        var storageParams : [String : Any] = [:]
        if self.walletSwitch.isOn && !pwd.isEmpty{
            storageParams["member_paypwd"] = pwd.md5String()
            storageParams["payment_id"] = "7"
        }else if self.aliBtn.isSelected{
            storageParams["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            storageParams["payment_id"] = "6"
        }
        storageParams["id"] = self.orderId
        storageParams["pricing_price"] = "\(totalMoney)"
        
        NetTools.requestData(type: .post, urlString: TaskSetPriceApi, parameters: storageParams, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                //支付成功
                //支付成功后返回
                LYProgressHUD.showSuccess("支付成功！")
                if self.rePayOrderSuccessBlock != nil{
                    self.rePayOrderSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    
    
    //MARK:插件支付
    func enrollPay(pwd:String) {
        LYProgressHUD.showLoading()
        var enrollParams : [String : Any] = [:]
        if self.walletSwitch.isOn && !pwd.isEmpty{
            enrollParams["member_paypwd"] = pwd.md5String()
            enrollParams["is_wallet"] = "1"
            enrollParams["wallet_price"] = "\(totalMoney)"
            enrollParams["payment_id"] = "7"
        }else if self.aliBtn.isSelected{
            enrollParams["is_wallet"] = "0"
            enrollParams["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            enrollParams["is_wallet"] = "0"
            enrollParams["payment_id"] = "6"
        }
        enrollParams["bill_id"] = self.orderId
        enrollParams["ot_user_id"] = self.enrollJson!["ot_user_id"].stringValue
        enrollParams["offer_price"] = self.enrollJson!["offer_price"].stringValue
        
        
        NetTools.requestData(type: .post, urlString: AuthorizedEngPayApi, parameters: enrollParams, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                //支付成功
                //支付成功后返回
                LYProgressHUD.showSuccess("支付成功！")
                if self.rePayOrderSuccessBlock != nil{
                    self.rePayOrderSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //MARK:调价支付
    func changePricePay(pwd:String) {
        
        
        func requestNet(_ images : String){
            var changePriceParams : [String : Any] = [:]
            if self.walletSwitch.isOn && !pwd.isEmpty{
                changePriceParams["member_paypwd"] = pwd.md5String()
                changePriceParams["is_wallet"] = "1"
                changePriceParams["wallet_price"] = "\(totalMoney)"
                changePriceParams["payment_id"] = "7"
            }else if self.aliBtn.isSelected{
                changePriceParams["is_wallet"] = "0"
                changePriceParams["payment_id"] = "2"
            }else if self.wechatBtn.isSelected{
                changePriceParams["is_wallet"] = "0"
                changePriceParams["payment_id"] = "6"
            }
            changePriceParams["id"] = self.orderId
            if self.imgArray.count > 0{
                changePriceParams["up_images"] = images
            }
            changePriceParams["service_up_price"] = self.newPrice
            
            NetTools.requestData(type: .post, urlString: ChangeUpPriceApi, parameters: changePriceParams, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                if result["is_pay"].stringValue.intValue == 1{
                    if self.aliBtn.isSelected{
                        self.payByAli(result)
                    }else if self.wechatBtn.isSelected{
                        self.payByWechat(result)
                    }
                }else{
                    //支付成功
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
        
        LYProgressHUD.showLoading()
        NetTools.upLoadImage(urlString : UploadAllImageApi,imgArray: self.imgArray, success: { (result) in
            requestNet(result)
        }, failture: { (error) in
            LYProgressHUD.showError("图片上传失败！")
        })
        
        
        
        
    }
    
    //MARK:未支付订单----再次支付成功
    func repayOrder(pwd:String) {
        LYProgressHUD.showLoading()
        var repayParams : [String : Any] = [:]
        if self.walletSwitch.isOn && !pwd.isEmpty{
            repayParams["member_paypwd"] = pwd.md5String()
            repayParams["is_wallet"] = "1"
            repayParams["wallet_price"] = "\(totalMoney)"
            repayParams["payment_id"] = "7"
        }else if self.aliBtn.isSelected{
            repayParams["is_wallet"] = "0"
            repayParams["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            repayParams["is_wallet"] = "0"
            repayParams["payment_id"] = "6"
        }
        repayParams["id"] = self.orderId
        
        
        NetTools.requestData(type: .post, urlString: RepayOrderApi, parameters: repayParams, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                //支付成功后返回
                if self.rePayOrderSuccessBlock != nil{
                    self.rePayOrderSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    
    //MARK:未支付商城订单----再次支付成功
    func repayShopOrder(pwd:String) {
        LYProgressHUD.showLoading()
        var repayParams : [String : Any] = [:]
        if self.walletSwitch.isOn && !pwd.isEmpty{
            repayParams["member_paypwd"] = pwd.md5String()
            repayParams["wallet_price"] = "\(totalMoney)"
            repayParams["payment_id"] = "7"
        }else if self.aliBtn.isSelected{
            repayParams["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            repayParams["payment_id"] = "6"
        }
        repayParams["store_id"] = "1"
        repayParams["pay_sn"] = self.paySn
        
        
        NetTools.requestData(type: .post, urlString: ShopOrderPayApi, parameters: repayParams, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if result["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(result)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(result)
                }
            }else{
                //支付成功后返回
                if self.rePayOrderSuccessBlock != nil{
                    self.rePayOrderSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    
    //MARK:提交订单
    func sendTaskRequest(pwd:String) {
        LYProgressHUD.showLoading()
        
        if self.walletSwitch.isOn && !pwd.isEmpty{
            params["member_paypwd"] = pwd.md5String()
            params["payment_id"] = "7"
            params["wallet_price"] = "\(totalMoney)"
        }else if self.aliBtn.isSelected{
            params["payment_id"] = "2"
        }else if self.wechatBtn.isSelected{
            params["payment_id"] = "6"
        }
        
        NetTools.requestData(type: .post, urlString: SendTaskApi,parameters: params, succeed: { (resultJson, error) in
            LYProgressHUD.showSuccess("发布成功！")
            
            self.bill_id = resultJson["bill_id"].stringValue
            
            if resultJson["is_pay"].stringValue.intValue == 1{
                if self.aliBtn.isSelected{
                    self.payByAli(resultJson)
                }else if self.wechatBtn.isSelected{
                    self.payByWechat(resultJson)
                }else{
                    print("---------------------------------------------PaySendTaskViewController-------------------------------------------")
                }
            }else{
                //提示匹配工程师
                self.matchEngineer(billId: resultJson["bill_id"].stringValue)
            }
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.dismiss()
            LYProgressHUD.showError(error!)
        }
        
    }
    
    
    //MARK:使用支付宝付款
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
    
    //支付宝支付结果
    func aliPayResult(_ resultDict:[AnyHashable:Any]?) {
        if resultDict == nil{
            return
        }
        if resultDict!["resultStatus"] as! String == "9000"{
            //支付成功
            if self.isJustPay{
                if self.enrollJson != nil{
                    //指定接单人支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if !self.newPrice.isEmpty{
                    //调价支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isFromPlugin{
                    //插件支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isStorageMeal{
                    //仓储支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isPrepareToSeal{
                    //代卖仓储支付
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isSetPrice{
                    //先发单的定价操作
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else{
                    //普通支付
                    if self.paySn.isEmpty{
                        //未支付订单----再次支付成功
                        self.matchEngineer(billId: self.bill_id)
                    }else{
                        //未支付商城订单----再次支付成功
                        //支付成功后返回
                        LYProgressHUD.showSuccess("支付成功！")
                        if self.rePayOrderSuccessBlock != nil{
                            self.rePayOrderSuccessBlock!()
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else{
                self.matchEngineer(billId: self.bill_id)
            }
        }else if resultDict!["resultStatus"] as! String == "6001"{
            //支付取消
            LYProgressHUD.showInfo("用户取消了支付")
            if !self.isFailRePay && !self.isJustPay{
                self.isFailRePay = true
                self.orderId = self.bill_id
                self.setUpSubViews()
            }
        }else{
            //支付失败
            LYProgressHUD.showInfo("支付失败！")
            if !self.isFailRePay && !self.isJustPay{
                self.isFailRePay = true
                self.orderId = self.bill_id
                self.setUpSubViews()
            }
        }
        
    }
    
    
    //MARK:使用微信付款
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
            if self.isJustPay{
                if self.enrollJson != nil{
                    //指定接单人支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if !self.newPrice.isEmpty{
                    //调价支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isFromPlugin{
                    //插件支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isStorageMeal{
                    //仓储支付
                    //支付成功后返回
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isPrepareToSeal{
                    //代卖仓储支付
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else if self.isSetPrice{
                    //先发单的定价操作
                    LYProgressHUD.showSuccess("支付成功！")
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else{
                    //普通支付
                    if self.paySn.isEmpty{
                        //未支付订单----再次支付成功
                        self.matchEngineer(billId: self.bill_id)
                    }else{
                        //未支付商城订单----再次支付成功
                        //支付成功后返回
                        LYProgressHUD.showSuccess("支付成功！")
                        if self.rePayOrderSuccessBlock != nil{
                            self.rePayOrderSuccessBlock!()
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else{
                self.matchEngineer(billId: self.bill_id)
            }
        }else if resultDict["code"] == "-2"{
            //取消支付
            LYProgressHUD.showInfo("用户取消了支付")
            if !self.isFailRePay && !self.isJustPay{
                self.isFailRePay = true
                self.orderId = self.bill_id
                self.setUpSubViews()
            }
        }else{
            //支付失败
            LYProgressHUD.showInfo(resultDict["error"]!)
            if !self.isFailRePay && !self.isJustPay{
                self.isFailRePay = true
                self.orderId = self.bill_id
                self.setUpSubViews()
            }
        }
    }
    
    
    //匹配工程师
    func matchEngineer(billId:String?) {
        
        if self.isRepairOrder{
            //如果是补单的话则不必匹配工程师
            LYProgressHUD.showSuccess("补单成功！")
            for VC in (self.navigationController?.viewControllers)! {
                if VC is MySendOrderListViewController{
                    //刷新列表和详情
                    //支付成功后返回
                    if self.rePayOrderSuccessBlock != nil{
                        self.rePayOrderSuccessBlock!()
                    }
                    self.navigationController?.popToViewController(VC, animated: true)
                }
            }
        }else{
            if billId != nil{
                self.bill_id = billId!
            }
            
            LYAlertView.show("发布成功！", "在首页“我的发单”中可查看订单记录", "返回首页" ,{
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            
//            LYAlertView.show("发布成功！", "匹配工程师，提醒工程师接单", "返回首页", "去匹配", {
//                let matchVC = MatchEngineerViewController.spwan()
//                matchVC.bill_id = self.bill_id
//                self.navigationController?.pushViewController(matchVC, animated: true)
//            },{
//                self.navigationController?.popToRootViewController(animated: true)
//            })
        }
        //如果是从我的发单／我的接单列表开始，则返回我的发单／我的接单列表
//        var haveVC = false
//        for VC in (self.navigationController?.viewControllers)! {
//            if VC is MySendOrderListViewController{
//                //刷新列表和详情的通知
//                
//                self.navigationController?.popToViewController(VC, animated: true)
//                haveVC = true
//            }
//        }
//        if !haveVC{
//            self.navigationController?.popToRootViewController(animated: true)
//        }
    }
    
}
