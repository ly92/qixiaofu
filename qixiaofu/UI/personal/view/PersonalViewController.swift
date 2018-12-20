//
//  PersonalViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PersonalViewController: BaseTableViewController {
    class func spwan() -> PersonalViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! PersonalViewController
    }
    
    @IBOutlet weak var navViewH: NSLayoutConstraint!
    @IBOutlet weak var iconImgV : UIImageView!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var aouthBtn : UIButton!
    @IBOutlet weak var aouthLbl: UILabel!
    @IBOutlet weak var invoteLbl : UILabel!
    @IBOutlet weak var signLbl : UILabel!
    @IBOutlet weak var creditsLbl : UILabel!
    @IBOutlet weak var couponLbl : UILabel!
    @IBOutlet weak var walletLbl : UILabel!
    @IBOutlet weak var billLbl : UILabel!
    @IBOutlet weak var orderLbl : UILabel!
    @IBOutlet weak var creditsView : UIView!
    @IBOutlet weak var signView : UIView!
    @IBOutlet weak var couponView : UIView!
    @IBOutlet weak var messageNumLbl: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var levelImgV1: UIImageView!
    @IBOutlet weak var levelImgV2: UIImageView!
    @IBOutlet weak var levelImgV3: UIImageView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var levelLblLeftDis: NSLayoutConstraint!
    
    
    fileprivate var personalInfo : JSON = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconImgV.layer.cornerRadius = 35
        self.messageNumLbl.layer.cornerRadius = 9;

        //头像点击
        self.iconImgV.addTapActionBlock {
            self.imgvClickAction()
        }
        
        self.signView.addTapActionBlock {
            //签到
            let signVC = SignInViewController.spwan()
            self.navigationController?.pushViewController(signVC, animated: true)
        }
        self.creditsView.addTapActionBlock {
            //积分
            let creditsVC = CreditsViewController.spwan()
            self.navigationController?.pushViewController(creditsVC, animated: true)
        }
        self.couponView.addTapActionBlock {
            //服豆
            let couponVC = BeanViewController.spwan()
            couponVC.userId = self.personalInfo["member_id"].stringValue
            self.navigationController?.pushViewController(couponVC, animated: true)
        }
        self.levelView.addTapActionBlock {
            //等级
            let levelInfoVC = LevelInfoViewController.spwan()
            self.navigationController?.pushViewController(levelInfoVC, animated: true)
        }
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "", target: self, action: #selector(PersonalViewController.settingAction))
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "", target: self, action: #selector(PersonalViewController.qrCodeAction))
        
//        if UIDevice.current.systemVersion.hasPrefix("11") && iphoneType() != "iPhone X"{
//            self.tableView.contentInset = UIEdgeInsets.init(top: -20, left: 0, bottom: 0, right: 0)
//        }
        self.scrollViewDidScroll(self.tableView)
        
        
        if iphoneType() == "iPhone X"{
            self.navViewH.constant = 88
        }else{
            self.navViewH.constant = 64
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.edgesForExtendedLayout = UIRectEdge.top
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .lightContent
        self.loadMineInfoData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.statusBarStyle = .default
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMineInfoData() {
        NetTools.requestData(type: .post, urlString: PersonalInfoApi, succeed: { (resultJson, msg) in
            
            self.personalInfo = resultJson
            
            //保存是否实名
            if resultJson["is_real"].stringValue.intValue == 1{
                LocalData.saveYesOrNotValue(value: "1", key: IsTrueName)
                self.addRedits(type: "2")
                self.aouthBtn.setTitle("已实名认证", for: .normal)
                self.aouthLbl.text = " (已实名认证)"
            }else if resultJson["is_real"].stringValue.intValue == 2{
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
                self.aouthBtn.setTitle("实名信息审核中", for: .normal)
                self.aouthLbl.text = " (实名信息审核中)"
            }else{
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
                self.aouthBtn.setTitle("请实名认证", for: .normal)
                self.aouthLbl.text = " (请实名认证)"
            }
            //保存姓名
            LocalData.saveUserName(userName: resultJson["member_nik_name"].stringValue)
            LocalData.saveTrueUserName(userName: resultJson["member_truename"].stringValue)
            //简历
            LocalData.saveUserResume(resume: resultJson["resume_url"].stringValue)
            //是否为A用户
            if  resultJson["member_level"].stringValue == "A" || resultJson["member_level"].stringValue == "DA"{
                LocalData.saveYesOrNotValue(value: "1", key: IsALevelUser)
            }else{
                LocalData.saveYesOrNotValue(value: "0", key: IsALevelUser)
            }
            
            //保存邀请码
            LocalData.saveUserInviteCode(phone: resultJson["iv_code"].stringValue)
            
            if resultJson["count_bill"].stringValue == "1" && resultJson["count_bill_integral"].stringValue == "0"{
                self.addRedits(type: "3")
            }
            self.iconImgV.setHeadImageUrlStr(resultJson["member_avatar"].stringValue)
            if resultJson["member_nik_name"].stringValue.isEmpty{
                self.nameLbl.text = "请设置昵称"
            }else{
                self.nameLbl.text = resultJson["member_nik_name"].stringValue
            }
            if resultJson["member_level"].stringValue == "DA"{
                self.invoteLbl.text = ""
            }else{
                self.invoteLbl.text = "邀请码:" + resultJson["iv_code"].stringValue
            }
            self.signLbl.text = resultJson["sign_day"].stringValue
            self.creditsLbl.text = resultJson["jifen"].stringValue
            self.couponLbl.text = String.init(format: "%.0f", resultJson["member_fudou"].stringValue.floatValue)
            self.walletLbl.text = resultJson["balance"].stringValue + "元"
            self.billLbl.text = resultJson["send_count_bill"].stringValue + "单"
            self.orderLbl.text = resultJson["take_count_bill"].stringValue + "单"
            let level = resultJson["level"].stringValue
            UIImageView.setLevelImageView(imgV1: self.levelImgV1, imgV2: self.levelImgV2, imgV3: self.levelImgV3, level: level)
            self.levelLbl.text = level + "级"
            if level.intValue % 3 == 0{
               self.levelLblLeftDis.constant = CGFloat( 5 + 3 * 18)
            }else{
                self.levelLblLeftDis.constant = CGFloat( 5 + (level.intValue % 3) * 18)
            }
        }) { (error) in
        }
    }
    
    func addRedits(type:String) {
        //1:注册 2:实名认证 3:完成第一个订单加分
        var params : [String : Any] = [:]
        params["type"] = type
        NetTools.requestData(type: .post, urlString: AddReditsApi, parameters: params, succeed: { (json, msg) in
        }) { (error) in
        }
    }
    
    //MARK: - 点击事件
    //头像点击
    func imgvClickAction() {
        if self.iconImgV.image != nil{
            let photoBrowseVC = LYPhotoBrowseViewController()
            photoBrowseVC.imgArray = [self.iconImgV.image!]
            photoBrowseVC.showDeleteBtn = false
            UIApplication.shared.keyWindow?.addSubview(photoBrowseVC.view)
            photoBrowseVC.imgSingleTapBlock = {() in
                UIView.animate(withDuration: 0.25, animations: {
                    photoBrowseVC.view.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                }, completion: { (completion) in
                    photoBrowseVC.view.removeFromSuperview()
                })
            }
        }
    }
    
    //个人信息
    @IBAction func personalInfoAction() {
        let personalInfoVC = PersonalInfoTableViewController.spwan()
        personalInfoVC.personalInfo = self.personalInfo
        self.navigationController?.pushViewController(personalInfoVC, animated: true)
    }
    
    //消息
    @IBAction func settingAction() {
//        let messageVC = MessageViewController()
//        self.navigationController?.pushViewController(messageVC, animated: true)
    }
    //二维码
    @IBAction func qrCodeAction() {
        let urlStr = self.personalInfo["invite_url"].stringValue
        let qrcodeView = CreateQrcodeView.init(frame: nil, urlStr: urlStr, image: self.iconImgV.image)
        qrcodeView.show()
        qrcodeView.shareBlock = {() in
            ShareView.show(url: urlStr, title: "加入七小服", desc: "注册成为七小服用户", viewController: self)
        }
    }

    
}




//MARK: - 列表选择
extension PersonalViewController{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            if iphoneType() == "iPhone X"{
                return 191
            }
            return 167
//            if iphoneType() == "iPhone X"{
//                return 254
//            }
//            return 230
        }

        if indexPath.row == 7{
            return 0
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch (indexPath.row) {
        case 1:
            //钱包
            let moneyVC = MyMoneyViewController.spwan()
            self.navigationController?.pushViewController(moneyVC, animated: true)
//            let walletVC = WalletViewController.spwan()
//            walletVC.beanNum = self.personalInfo["member_fudou"].stringValue.intValue
//            walletVC.userId = self.personalInfo["member_id"].stringValue
//            self.navigationController?.pushViewController(walletVC, animated: true)
        case 2:
            //签到
            let signVC = SignInViewController.spwan()
            self.navigationController?.pushViewController(signVC, animated: true)
        case 3:
            //购物车
            let shopCarVC = ShopCarListViewController.spwan()
            self.navigationController?.pushViewController(shopCarVC, animated: true)
        case 4:
            //收藏
            let collectVC = CollectListViewController()
            collectVC.isCollect = true
            self.navigationController?.pushViewController(collectVC, animated: true)
        case 5:
            //我的发单
            let mySendVC = MySendOrderListViewController.spwan()
            mySendVC.titleArray = ["报名中","已接单","已完成","调价中","已取消","已失效"]
            mySendVC.stateArray = [1,2,3,6,5,4]
            self.navigationController?.pushViewController(mySendVC, animated: true)
        case 6:
            //我的接单
            let myReceiveVC = MySendOrderListViewController.spwan()
//            myReceiveVC.titleArray = ["报名中","已接单","已完成","已取消","调价中","补单"]
//            myReceiveVC.stateArray = [1,2,3,5,6,7]
            myReceiveVC.titleArray = ["报名中","已接单","已完成","已取消","调价中"]
            myReceiveVC.stateArray = [1,2,3,5,6]
            myReceiveVC.isMyReceive = true
            self.navigationController?.pushViewController(myReceiveVC, animated: true)
        
        case 7:
            //空闲时间
            let freeTimeVC = FreeTimeListViewController()
            self.navigationController?.pushViewController(freeTimeVC, animated: true)
        case 8:
            //商城订单
            let shopOrderVC = ShopOrderListViewController.spwan()
            self.navigationController?.pushViewController(shopOrderVC, animated: true)
        case 9:
            //软件购买记录----代测订单
            let testOrderListVC = TestServiceOrderListViewController.spwan()
            self.navigationController?.pushViewController(testOrderListVC, animated: true)
//            let pluginVC = PluginHistoryViewController()
//            self.navigationController?.pushViewController(pluginVC, animated: true)
            
//            //补单
//            if LocalData.getYesOrNotValue(key: IsALevelUser){
//                LYProgressHUD.showInfo("当前用户为A用户，不可补单！")
//                return
//            }
//            let redoOrderVC = SendTaskViewController.spwan()
//            redoOrderVC.isRepairOrder = true
//            self.navigationController?.pushViewController(redoOrderVC, animated: true)
        case 10:
            //代卖订单
            let sealOrderVC = AgencySealViewController.spwan()
            self.navigationController?.pushViewController(sealOrderVC, animated: true)
        case 11:
            //小库存
            let inventoryVC = InventoryListViewController()
            self.navigationController?.pushViewController(inventoryVC, animated: true)
        
        case 12:
            //联系客服
            esmobChat(self, "kefu1", 1)
//            let rechargeAlert = UIAlertController.init(title: "充值", message: "请输入充值金额", preferredStyle: .alert)
//            let tF = rechargeAlert.textFields?[0]
//            tF?.keyboardType = .numberPad
//            tF?.placeholder = "请输入整数"
//            rechargeAlert.show(self, sender: nil)
        case 13:
            //关联用户
            let associationVC = AssociationViewController()
            self.navigationController?.pushViewController(associationVC, animated: true)
        case 14:
            //设置
            let settingVC = SettingTableViewController()
            if self.personalInfo["is_paypwd"].stringValue.intValue == 1{
                settingVC.isSetPayPwd = true
            }
            if self.personalInfo["is_real"].stringValue.intValue == 1{
                settingVC.isReal = true
            }
            self.navigationController?.pushViewController(settingVC, animated: true)
        default:
            break;
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.contentOffset.y > 64{
//            self.navigationItem.rightBarButtonItem = nil
//            self.navigationItem.leftBarButtonItem = nil
//            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }else{
//            self.navigationController?.setNavigationBarHidden(false, animated: false)
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "", target: self, action: #selector(PersonalViewController.settingAction))
//            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "", target: self, action: #selector(PersonalViewController.qrCodeAction))
        }
    }
    
}
