//
//  EPShopPayWayViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class EPShopPayWayViewController: BaseTableViewController {
    class func spwan() -> EPShopPayWayViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPShopPayWayViewController
    }
    
    @IBOutlet weak var offlineLbl: UILabel!
    @IBOutlet weak var wechatLbl: UILabel!
    @IBOutlet weak var aliLbl: UILabel!
    @IBOutlet weak var walletLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    
    var totalMoney : CGFloat = 0
    var choosePayWayBlock : ((Int) -> Void)?//1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
    
    
    
    fileprivate var walletUseful = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "支付方式"
        self.checkPayPassword()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //检查是否设置了密码
    func checkPayPassword() {
        NetTools.requestData(type: .post, urlString: EPCheckPayPwdApi, succeed: { (resultJson, error) in
            if resultJson["statu"].stringValue.intValue != 1{
                LYAlertView.show("提示", "您还未设置支付密码，将会影响您的支付体验", "先等等","去设置",{
                    //设置支付密码
                    let changePayPwdVc = ChangePasswordViewController.spwan()
                    changePayPwdVc.type = .setPayPwd
                    self.navigationController?.pushViewController(changePayPwdVc, animated: true)
                })
                self.walletLbl.text = "不可用"
            }
            
            //1时候为签约用户  0为普通用户
            let offlineState = resultJson["is_cooperation_company"].stringValue.intValue
            if offlineState == 1{
                self.offlineLbl.text = "可用"
            }else{
                self.offlineLbl.text = "不可用"
            }
            
            let money = resultJson["available_predeposit"].stringValue.floatValue
            if CGFloat(money) < self.totalMoney{
                self.walletLbl.text = "不可用"
                self.walletUseful = false
            }else{
                self.walletUseful = true
                self.walletLbl.text = "可用"
            }
            self.moneyLbl.text = "(剩余¥" + resultJson["available_predeposit"].stringValue + ")"
        }) { (error) in
        }
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var type = 3//1:线下支付 2:微信支付。3:支付宝支付 4:钱包支付
        if indexPath.row == 0{
            if self.offlineLbl.text == "可用"{
                type = 1
            }else{
                LYProgressHUD.showError("此方式不可用!")
                return
            }
        }else if indexPath.row == 2{
            type = 2
        }else if indexPath.row == 3{
            type = 3
        }else if indexPath.row == 4{
            if self.walletLbl.text == "可用"{
                type = 4
            }else{
                LYProgressHUD.showError("此方式不可用!")
                return
            }
        }
        
        if self.choosePayWayBlock != nil{
            self.choosePayWayBlock!(type)
        }
        self.navigationController?.popViewController(animated: true)
    }
    

}
