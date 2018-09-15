//
//  MyMoneyViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyMoneyViewController: BaseViewController {
    class func spwan() -> MyMoneyViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! MyMoneyViewController
    }
    
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var coffeLbl: UILabel!
    @IBOutlet weak var depositLbl: UILabel!
    
    fileprivate var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "钱包"
        
        self.loadWalletData()
    }
    
    //余额
    func loadWalletData() {
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: WalletInfoApi, succeed: { (result, msg) in
            self.resultJson = result
            self.moneyLbl.text = result["remaining_balance"].stringValue + "元"
            self.couponLbl.text = result["coupon_num"].stringValue + "张"
            self.codeLbl.text = result["jifen"].stringValue + "分"
            self.coffeLbl.text = result["member_fudou"].stringValue + "个"
            self.depositLbl.text = result["bail_account"].stringValue + "元"
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnAction(_ btn: UIButton) {
        if btn.tag == 11{
            //余额
            let walletVC = WalletViewController.spwan()
            walletVC.beanNum = self.resultJson["member_fudou"].intValue
            walletVC.userId = LocalData.getNotMd5UserId()
            self.navigationController?.pushViewController(walletVC, animated: true)
        }else if btn.tag == 22{
            //优惠券
            let couponVC = MyCouponViewController.spwan()
            self.navigationController?.pushViewController(couponVC, animated: true)
        }else if btn.tag == 33{
            //积分
            let creditsVC = CreditsViewController.spwan()
            self.navigationController?.pushViewController(creditsVC, animated: true)
        }else if btn.tag == 44{
            //服豆
            let couponVC = BeanViewController.spwan()
            couponVC.userId = LocalData.getNotMd5UserId()
            self.navigationController?.pushViewController(couponVC, animated: true)
        }else if btn.tag == 55{
            //保证金
            let noticeDetailVC = NoticeDetailViewController.spwan()
            noticeDetailVC.noticeId = "12"
            noticeDetailVC.noticeTitle = "关于保证金"
            self.navigationController?.pushViewController(noticeDetailVC, animated: true)
        }
    }
    

}


