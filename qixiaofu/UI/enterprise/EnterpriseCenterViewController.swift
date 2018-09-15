//
//  EnterpriseCenterViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnterpriseCenterViewController: BaseTableViewController {
    class func spwan() -> EnterpriseCenterViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EnterpriseCenterViewController
    }
    /*
     is_real 企业会员是否实名 0未实名 1已实名 2实名审核中
      audit_state 企业审核状态  0待审核  1审核通过
     */
    
    @IBOutlet weak var epIconImgV: UIImageView!
    @IBOutlet weak var epNameLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var unpaidLbl: UILabel!
    @IBOutlet weak var unPaidView: UIView!
    @IBOutlet weak var prepaidLbl: UILabel!
    @IBOutlet weak var prepaidView: UIView!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var packageLbl: UILabel!
    @IBOutlet weak var testStandLbl: UILabel!
    @IBOutlet weak var epRealLbl: UILabel!
    @IBOutlet weak var realLbl: UILabel!
    @IBOutlet weak var carLbl: UILabel!
    @IBOutlet weak var numLbl1: UILabel!
    @IBOutlet weak var numLbl2: UILabel!
    @IBOutlet weak var numLbl3: UILabel!
    @IBOutlet weak var numLbl4: UILabel!
    
    
    fileprivate var epJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.epIconImgV.layer.cornerRadius = 25
        self.unPaidView.layer.cornerRadius = 3.5
        self.prepaidView.layer.cornerRadius = 3.5
        self.numLbl1.layer.cornerRadius = 7.5
        self.numLbl2.layer.cornerRadius = 7.5
        self.numLbl3.layer.cornerRadius = 7.5
        self.numLbl4.layer.cornerRadius = 7.5
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ep_center_icon_5"), target: self, action: #selector(EnterpriseCenterViewController.rightItemAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "home_meseage"), target: self, action: #selector(EnterpriseCenterViewController.rightItemAction))
        
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(EnterpriseCenterViewController.backClick))
        
        
        self.realLbl.addTapActionBlock {
            if self.epJson["is_real"].stringValue.intValue == 1{
                //已实名
            }else if self.epJson["is_real"].stringValue.intValue == 2{
                //实名审核中
            }else{
                //未实名
                let idVC = IdentityViewController.spwan()
                self.navigationController?.pushViewController(idVC, animated: true)
            }
        }
    }
    
    @objc func backClick() {
        AppDelegate.sharedInstance.resetRootViewController(1)
    }
    @objc func rightItemAction() {
        //消息
        let messageVC = SystemMessageViewController()
        messageVC.messageType = .epSystemMessageType
        self.navigationController?.pushViewController(messageVC, animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            //企业中心数据
            self.loadEnterpriseData()
        }
    }

    //企业中心数据
    func loadEnterpriseData() {
        NetTools.requestData(type: .post, urlString: EnterpriseCenterApi, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.epJson = resultJson
            
            self.epIconImgV.setImageUrlStr(resultJson["company_logo"].stringValue)
            self.epNameLbl.text = resultJson["company_name"].stringValue
            self.phoneLbl.text = resultJson["user_tel"].stringValue
            self.unpaidLbl.text = "¥" + resultJson["non_checkout_total"].stringValue
            self.prepaidLbl.text = "¥" + resultJson["account_checkout_total"].stringValue
            self.moneyLbl.text = "¥" + resultJson["available_predeposit"].stringValue
            self.couponLbl.text = resultJson["sumcoupon"].stringValue + "张"
            if resultJson["cart_sum"].stringValue.intValue > 0{
                self.carLbl.text = resultJson["cart_sum"].stringValue + "个"
            }else{
                self.carLbl.text = ""
            }
            self.packageLbl.text = resultJson["package_name"].stringValue
            self.testStandLbl.text = resultJson["test_name"].stringValue
            if resultJson["obligation_number"].stringValue.intValue > 0{
                self.numLbl1.text = resultJson["obligation_number"].stringValue
                self.numLbl1.isHidden = false
            }else{
                self.numLbl1.isHidden = true
            }
            if resultJson["pendingdelivery_number"].stringValue.intValue > 0{
                self.numLbl2.text = resultJson["pendingdelivery_number"].stringValue
                self.numLbl2.isHidden = false
            }else{
                self.numLbl2.isHidden = true
            }
            if resultJson["waiting_number"].stringValue.intValue > 0{
                self.numLbl3.text = resultJson["waiting_number"].stringValue
                self.numLbl3.isHidden = false
            }else{
                self.numLbl3.isHidden = true
            }
            if resultJson["return_number"].stringValue.intValue > 0{
                self.numLbl4.text = resultJson["return_number"].stringValue
                self.numLbl4.isHidden = false
            }else{
                self.numLbl4.isHidden = true
            }

            if resultJson["audit_state"].stringValue.intValue == 1{
                self.epRealLbl.text = ""
                LocalData.saveYesOrNotValue(value: "1", key: IsEPApproved)
            }else{
                self.epRealLbl.text = "(信息审核中)"
                LocalData.saveYesOrNotValue(value: "0", key: IsEPApproved)
            }
            if resultJson["is_real"].stringValue.intValue == 1{
                self.realLbl.text = "(已实名)"
                LocalData.saveYesOrNotValue(value: "1", key: IsTrueName)
            }else if resultJson["is_real"].stringValue.intValue == 2{
                self.realLbl.text = "(实名审核中)"
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
            }else{
                self.realLbl.text = "(未实名)"
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取信息失败！")
        }
    }
    
    @IBAction func orderBtnAction(_ btn: UIButton) {
        var state = 1
        if btn.tag == 11{
            //待付款
            state = 1
        }else if btn.tag == 22{
            //待发货
            state = 2
        }else if btn.tag == 33{
            //待收货
            state = 3
        }else if btn.tag == 44{
            //退款/售后
            let afterSallerVC = EPAfterSalerListViewController.spwan()
            self.navigationController?.pushViewController(afterSallerVC, animated: true)
            return
        }
        //我的订单
        let orderListVC = EPShopOrderListViewController.spwan()
        orderListVC.epCenterState = state
        self.navigationController?.pushViewController(orderListVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            //企业信息
            return 93
        }else if indexPath.row == 1{
            //账单
            return 59
        }else if indexPath.row == 2{
            //我的订单
            return 60
        }else if indexPath.row == 3{
            //订单状态
            return 80
        }else if indexPath.row == 7{
            //账户管理
            if self.epJson["parent_id"].stringValue != "0"{
                return 0
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            //企业信息
            let epInfoVC = EnterpriseInfoViewController.spwan()
            epInfoVC.business_id = self.epJson["business_id"].stringValue
            self.navigationController?.pushViewController(epInfoVC, animated: true)
        }else if indexPath.row == 1{
            //账单
            if self.epJson["parent_id"].stringValue != "0"{
                //子账户
                let billVC = EPBillListViewController()
                billVC.business_id = self.epJson["business_id"].stringValue
                self.navigationController?.pushViewController(billVC, animated: true)
            }else{
                //主账户
                let billVC = EPBillListViewController()
                billVC.business_id = self.epJson["business_id"].stringValue
                self.navigationController?.pushViewController(billVC, animated: true)
            }
        }else if indexPath.row == 2{
            //我的订单
            let orderListVC = EPShopOrderListViewController.spwan()
            self.navigationController?.pushViewController(orderListVC, animated: true)
        }else if indexPath.row == 3{
            //订单分类
        }else if indexPath.row == 4{
            //钱包
            let moneyVC = EPMoneyViewController.spwan()
            self.navigationController?.pushViewController(moneyVC, animated: true)
        }else if indexPath.row == 5{
            //优惠券
            let myCouponVC = EPMyCouponViewController.spwan()
            self.navigationController?.pushViewController(myCouponVC, animated: true)
        }else if indexPath.row == 6{
            //购物车
            let shopCarVC = ShopCarListViewController.spwan()
            self.navigationController?.pushViewController(shopCarVC, animated: true)
        }else if indexPath.row == 7{
            //账户管理
            let acountVC = EnterpriseAccountViewController.spwan()
            self.navigationController?.pushViewController(acountVC, animated: true)
        }else if indexPath.row == 8{
            //包装标准
            let standVC = StandardListViewController.spwan()
            standVC.isPackageStandard = true
            self.navigationController?.pushViewController(standVC, animated: true)
            
        }else if indexPath.row == 9{
            //测试标准
            let standVC = StandardListViewController.spwan()
            standVC.isPackageStandard = false
            self.navigationController?.pushViewController(standVC, animated: true)
        }else if indexPath.row == 10{
            //设置
            let settingVC = EPSettingTableViewController()
            settingVC.isReal = self.epJson["is_real"].stringValue.intValue
            settingVC.isEpReal = self.epJson["is_real"].stringValue.intValue == 1 ? true : false
            settingVC.isSetPayPwd = self.epJson["is_havepay"].stringValue.intValue == 1 ? true : false
            self.navigationController?.pushViewController(settingVC, animated: true)
        }
        
    }
}
