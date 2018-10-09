//
//  BindingAccountViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class BindingAccountViewController: BaseViewController {
    class func spwan() -> BindingAccountViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! BindingAccountViewController
    }
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    var wechatInfo = JSON()
    var wechatUserInfo = JSON()
    
    
    fileprivate var timer = Timer()//
    fileprivate var codeTime : Int = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "绑定账户"
        self.submitBtn.layer.cornerRadius = 20
        
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getWechatUserInfo()
    }
    
    
    //获取微信账户信息
    func getWechatUserInfo() {
        var params : [String : Any] = [:]
        params["access_token"] = self.wechatInfo["access_token"].stringValue
        params["openid"] = self.wechatInfo["openid"].stringValue
        NetTools.requestCustomerApi(type: .get, urlString: "https://api.weixin.qq.com/sns/userinfo", parameters: params, succeed: { (result) in
            LYProgressHUD.dismiss()
            self.wechatUserInfo = result
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取微信数据失败！")
        }
    }
    

    //确定绑定账户
    @IBAction func submitAction() {
        LYProgressHUD.showLoading()
        let phone = self.phoneTF.text
        let code = self.codeTF.text
        
        if !(phone?.isMobelPhone())!{
            LYProgressHUD.showError("请输入正确手机号码！")
            return
        }
        if (code?.isEmpty)!{
            LYProgressHUD.showError("请输入验证码！")
            return
        }

        var params :[String:Any] = [:]
        params["open_id"] = self.wechatUserInfo["openid"].stringValue
        params["phone"] = phone!
        params["headimgurl"] = self.wechatUserInfo["headimgurl"].stringValue
        params["nickname"] = self.wechatUserInfo["nickname"].stringValue
        params["verif"] = code!
        NetTools.requestData(type: .post, urlString: BinDingThirdAccountApi, parameters: params, succeed: { (resultDict, error) in
            LYProgressHUD.dismiss()
            //登录环信
            esmobLogin()
            //先记录环境
            LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
            //保存userid
            LocalData.saveUserId(userId: resultDict["userid"].stringValue)
            //保存user phone
            LocalData.saveUserPhone(phone: resultDict["phone"].stringValue)
            //记录已登录
            LocalData.saveYesOrNotValue(value: "1", key: IsLogin)
            //回到根页
            self.navigationController?.popToRootViewController(animated: true)
            //个人版
            AppDelegate.sharedInstance.resetRootViewController(1)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    

    
    //获取验证码
    @IBAction func codeBtnAction() {
        let phone = self.phoneTF.text
        if !(phone?.isMobelPhone())!{
            LYProgressHUD.showError("请输入正确手机号码！")
            return
        }
        self.codeBtn.isEnabled = false
        var params : [String : Any] = [:]
        params["mobile"] = phone!
        params["t"] = "3"
        
        NetTools.requestData(type: .post, urlString: VerificationCodeApi, parameters: params, succeed: { (resultDict, error) in
            if resultDict["code"].stringValue.isEmpty{
                self.codeBtn.isEnabled = true
            }else{
                if #available(iOS 10.0, *) {
                    self.setUpCodeTimer()
                } else {
                    self.setUpCodeTimer2()
                }
            }
        }) { (error) in
            self.codeBtn.isEnabled = true
            print(error ?? "没有数据")
            LYProgressHUD.showError(error!)
        }
    }
    
}


@available(iOS 10.0, *)
extension BindingAccountViewController{
    func setUpCodeTimer() {
        self.codeTime = 60
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.codeTime > 0{
                
                self.codeBtn.isEnabled = false
                self.codeBtn.setTitle("\(self.codeTime) 秒后重新获取", for: .disabled)
                self.codeTime -= 1
            }else{
                self.codeBtn.isEnabled = true
                self.codeBtn.setTitle("重新获取", for: .normal)
                
                timer.invalidate()
            }
        }
    }
}

extension BindingAccountViewController{
    func setUpCodeTimer2() {
        self.codeTime = 60
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(BindingAccountViewController.changeCodeBtnTitle), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .defaultRunLoopMode)
        timer.fire()
    }
    
    @objc func changeCodeBtnTitle() {
        if self.codeTime > 0{
            self.codeBtn.isEnabled = false
            self.codeBtn.setTitle("\(self.codeTime) 秒后重新获取", for: .disabled)
            self.codeTime -= 1
        }else{
            self.codeBtn.isEnabled = true
            self.codeBtn.setTitle("重新获取", for: .normal)
            self.timer.invalidate()
        }
        
    }
    
}
