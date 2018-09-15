//
//  SignInViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/27.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignInViewController: BaseViewController {
    class func spwan() -> SignInViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! SignInViewController
    }
    
    
    @IBOutlet weak var signDayLbl: UILabel!
    @IBOutlet weak var signLbl: UILabel!
    @IBOutlet weak var signBtn: UIButton!
    @IBOutlet weak var signLogoImgV: UIImageView!
    @IBOutlet weak var creditsLbl: UILabel!
    @IBOutlet weak var ruleView: UIView!
    @IBOutlet weak var subRuleView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载当前签到状态
        self.loadSignState()
        
        self.navigationItem.title = "签到"
        
        self.subRuleView.layer.cornerRadius = 5
        
        self.ruleView.addTapAction(action: #selector(SignInViewController.showRuleAction), target: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //签到
    @IBAction func signAction() {
        var params : [String : Any] = [:]
        params["sign_time"] = Date.phpTimestamp()
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: SignApi, parameters: params, succeed: { (result, msg) in
            self.setUpUIData(result: result)
            LYProgressHUD.dismiss()
        }) { (error) in
            self.signBtn.isEnabled = true
            self.signLbl.text = "签到"
            LYProgressHUD.showError(error!)
        }

    }
    
    //展示或者隐藏签到规则
    @IBAction func showRuleAction() {
        self.ruleView.isHidden = !self.ruleView.isHidden
    }

    //当前签到状态
    func loadSignState() {
        var params : [String : Any] = [:]
        params["sign_time"] = Date.phpTimestamp()
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: CheckSignStateApi, parameters: params, succeed: { (result, msg) in
            self.setUpUIData(result: result)
            LYProgressHUD.dismiss()
        }) { (error) in
            self.signBtn.isEnabled = true
            self.signLbl.text = "签到"
            LYProgressHUD.showError(error!)
        }
    }
    
    //显示签到信息数据
    func setUpUIData(result : JSON) {
        self.creditsLbl.text = "总积分：" + result["jifen"].stringValue + "积分"
        self.signDayLbl.text = "连续" + result["continuous_sign_day"].stringValue + "天"
        if result["is_sign"].stringValue.intValue == 0{
            self.signBtn.isEnabled = true
            self.signLbl.text = "签到"
        }else{
            self.signBtn.isEnabled = false
            self.signLbl.text = "已签到"
        }
        if result["sign_day"].stringValue.intValue >= 0 && result["sign_day"].stringValue.intValue < 8{
            self.signLogoImgV.image = UIImage(named:"sign_logo_" + result["sign_day"].stringValue)
        }else{
            self.signLogoImgV.image = #imageLiteral(resourceName: "sign_logo_0")
        }
    }

}
