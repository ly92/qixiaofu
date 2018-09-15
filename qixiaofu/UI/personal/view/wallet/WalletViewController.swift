//
//  WalletViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/31.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class WalletViewController: BaseViewController {
    class func spwan() -> WalletViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! WalletViewController
    }
    
    var beanNum = 0
    var userId = ""

    
    @IBOutlet weak var backBtnDis: NSLayoutConstraint!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var payCodeImgV: UIImageView!
    @IBOutlet weak var walletSelImgV: UIImageView!
    @IBOutlet weak var beanSelImgV: UIImageView!
    @IBOutlet weak var selectePayView: UIView!
    @IBOutlet weak var selectedPayImgV: UIImageView!
    @IBOutlet weak var selectedPayNameLbl: UILabel!
    @IBOutlet weak var payCodeView: UIView!
    @IBOutlet weak var payCodeViewH: NSLayoutConstraint!
    @IBOutlet weak var beanNumLbl: UILabel!
    @IBOutlet weak var payWayView: UIView!
    @IBOutlet weak var depositLbl: UILabel!

    @IBOutlet weak var arrowImgV: UIImageView!
    @IBOutlet weak var payMemoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var payWayViewH: NSLayoutConstraint!
    
    

    
    
    fileprivate var money = ""
    fileprivate var payType = "1"
    fileprivate var gradientLayer : CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "零钱"
        
        
        self.payWayViewH.constant = 0
        self.payWayView.addTapActionBlock {
            self.hidePayWayView(!self.selectePayView.isHidden)
        }
        self.selectePayView.addTapActionBlock {
            self.hidePayWayView(true)
        }
        self.checkPayPassword()
        if iphoneType() == "iPhone X"{
            self.backBtnDis.constant = 35
            self.topViewH.constant = 246
        }
        if #available(iOS 11.0, *){
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.arrowImgV.image = #imageLiteral(resourceName: "down_arrow")
        self.payCodeViewH.constant = 0
        self.payCodeView.isHidden = true
        self.scrollContentView.layoutIfNeeded()
        self.payMemoView.addTapActionBlock {
            if self.payCodeView.isHidden{
                self.arrowImgV.image = #imageLiteral(resourceName: "up_arrow")
                self.payCodeView.isHidden = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.payCodeViewH.constant = 200
                    self.scrollContentView.layoutIfNeeded()
                    self.payCodeView.layoutIfNeeded()
                }, completion: { (completion) in
                    
                })
            }else{
                self.arrowImgV.image = #imageLiteral(resourceName: "down_arrow")
                UIView.animate(withDuration: 0.25, animations: {
                    self.payCodeViewH.constant = 0
                    self.scrollContentView.layoutIfNeeded()
                    self.payCodeView.layoutIfNeeded()
                }, completion: { (completion) in
                    self.payCodeView.isHidden = true
                })
            }
        }
    }
    
    func hidePayWayView(_ hide : Bool) {
        if hide{
            UIView.animate(withDuration: 0.25, animations: {
                self.payWayViewH.constant = 0
                self.selectePayView.layoutIfNeeded()
            }, completion: { (completion) in
                self.selectePayView.isHidden = true
            })
        }else{
            self.selectePayView.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                self.payWayViewH.constant = 240
                self.selectePayView.layoutIfNeeded()
            })
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.moneyLbl.text = LocalData.getWalletMoney() + "元"
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "", target: self, action: #selector(WalletViewController.backAction))
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.edgesForExtendedLayout = UIRectEdge.top
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NetTools.requestData(type: .post, urlString: WalletApi, succeed: { (result, msg) in
            self.money = result["remaining_balance"].stringValue
            self.moneyLbl.text = result["remaining_balance"].stringValue + "元"
            LocalData.saveWalletMoney(money: result["remaining_balance"].stringValue)
            self.depositLbl.text = result["min_prince"].stringValue
            
//            self.money = result["available_predeposit"].stringValue
//            self.moneyLbl.text = "¥" + result["available_predeposit"].stringValue
//            LocalData.saveWalletMoney(money: result["available_predeposit"].stringValue)
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.statusBarStyle = .default
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func preparePayAscii() {
        
        
        
        
        if self.userId.isEmpty{
            return
        }
        
        if LocalData.getLocalPayType() == "2" && self.beanNum > 0{
            self.payType = "2"
        }else{
            self.payType = "1"
        }
        self.beanNumLbl.text = "服豆" + String.init(format: "(%d)", self.beanNum)
        if self.payType == "1"{
            self.selectedPayImgV.image = #imageLiteral(resourceName: "wallet")
            self.selectedPayNameLbl.text = "钱包余额"
            self.walletSelImgV.isHidden = false
            self.beanSelImgV.isHidden = true
        }else if self.payType == "2"{
            self.selectedPayImgV.image = #imageLiteral(resourceName: "Take_beans")
            self.selectedPayNameLbl.text = "服豆"
            self.walletSelImgV.isHidden = true
            self.beanSelImgV.isHidden = false
        }
        
        let str = self.userId + "," + self.payType
        let data = str.data(using: String.Encoding.ascii)
        guard let filter = CIFilter.init(name: "CICode128BarcodeGenerator") else{
            return
        }
        filter.setValue(data, forKey: "inputMessage")
        //生成条形码
        guard let ciImg = filter.outputImage else {
            return
        }
        //4.调整清晰度
        //创建Transform
        let scale = (kScreenW - 40) / ciImg.extent.width
        let transform = CGAffineTransform.init(scaleX: scale, y: 90)
        //放大图片
        let bigImg = ciImg.transformed(by: transform)
        self.payCodeImgV.image = UIImage.init(ciImage: bigImg)
    }
    
    //检查是否设置了密码
    func checkPayPassword() {
        NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, succeed: { (resultJson, error) in
            if resultJson["statu"].stringValue.intValue == 1{
                self.preparePayAscii()
            }else{
                LYAlertView.show("提示", "未设置支付密码，无法展示支付条形码", "下次再说", "现在设置",{
                    //设置支付密码
                    let changePayPwdVc = ChangePasswordViewController.spwan()
                    changePayPwdVc.type = .setPayPwd
                    changePayPwdVc.setPayPwdSuccessBlock = {[weak self] () in
                        self?.checkPayPassword()
                    }
                    self.navigationController?.pushViewController(changePayPwdVc, animated: true)
                })
                
            }
        }) { (error) in
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        if sender.tag == 11{
            //明细
            let detailListVC = WalletDetailViewController.spwan()
            self.navigationController?.pushViewController(detailListVC, animated: true)
        }else if sender.tag == 22{
            //充值
            let rechargeVC = RechargeViewController.spwan()
            rechargeVC.vcType = 1
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        }else if sender.tag == 33{
            //提现
            let withDrawVC = RechargeViewController.spwan()
            withDrawVC.vcType = 2
            self.navigationController?.pushViewController(withDrawVC, animated: true)
        }
    }

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func selectPayAction(_ sender: UIButton) {
        if sender.tag == 11{
            //零钱
            LocalData.saveLocalPayType(type: "1")
        }else if sender.tag == 22{
            if self.beanNum > 0{
                //服豆
                LocalData.saveLocalPayType(type: "2")
            }else{
                LYProgressHUD.showInfo("您的服豆余额为0,请使用钱包余额支付")
            }
            
        }
        self.preparePayAscii()
        self.hidePayWayView(true)
    }

}
