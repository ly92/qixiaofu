//
//  RegisterViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/3.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterViewController: BaseViewController {

    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var inviteCodeTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var selecteBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    fileprivate var timer = Timer()//
    fileprivate var codeTime : Int = 60
    
    class func spwan() -> RegisterViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! RegisterViewController
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "注册"
        self.registerBtn.layer.cornerRadius = 20;
        self.view.addTapActionBlock {
            self.endEditing()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnAction(btn: UIButton) {
        switch btn.tag {
        case 11:
            self.getCode()
        case 22:
            btn.isSelected = !btn.isSelected
            self.pwdTF.isSecureTextEntry = !self.pwdTF.isSecureTextEntry
        case 33:
            print("rules")
            
            let webVC = BaseWebViewController.spwan()
//            webVC.openUrlInViewControllrt(url: RegisterRulesApi, title: "注册协议", vc: self)
            webVC.urlStr = RegisterRulesApi
            webVC.titleStr = "注册协议"
            self.navigationController?.pushViewController(webVC, animated: true)
            
        case 44:
            self.registerAction()
        case 55:
            self.selecteBtn.isSelected = !self.selecteBtn.isSelected
        default:
            print("default")
        }
    }
    

}

extension RegisterViewController{
    func getCode() {
        let account = self.phoneTF.text
        if !(account?.isMobelPhone())!{
            LYProgressHUD.showError( "请输入正确手机号码")
            return;
        }
        let params :[String:Any] = ["mobile" : account!, "t" : "1"]
        self.codeBtn.isEnabled = false
        NetTools.requestData(type: .post, urlString: VerificationCodeApi, parameters: params, succeed: { (resultDict, error) in
            if !resultDict["code"].stringValue.isEmpty{
                self.setUpCodeTimer()
                self.codeTF.becomeFirstResponder()
            }else{
                self.codeBtn.isEnabled = true
            }
        }) { (error) in
            self.codeBtn.isEnabled = true
            print(error ?? "没有数据")
            LYProgressHUD.showError(error!)
        }
        
    }
    
    func registerAction() {
        let account = self.phoneTF.text
        let code = self.codeTF.text
        let inviteCode = self.inviteCodeTF.text
        let pwd = self.pwdTF.text
        
        if !(account?.isMobelPhone())!{
            LYProgressHUD.showError( "请输入正确的手机号")
            return;
        }
        
        if (code?.isEmpty)!{
            LYProgressHUD.showError( "请输入验证码")
            return;
        }
        
        if (pwd?.count)! < 6{
            LYProgressHUD.showError( "请设置不少于6位的秘密")
            return;
        }
        
        if !self.selecteBtn.isSelected{
            LYProgressHUD.showError( "请同意用户注册协议")
            return;
        }
        
        var params :[String:Any] = ["phone" : account!, "verif" : code!, "password" : pwd!, "password_confirm" : pwd!]
        if !(inviteCode?.isEmpty)!{
            params["inviter_code"] = inviteCode
        }
        
        RegisterViewModel.registerAction(params: params) { (json) in
            let userId = json["userid"]
            let userPhone = json["phone"]
            //保存userid
            LocalData.saveUserId(userId: userId.stringValue)
            //保存user phone
            LocalData.saveUserPhone(phone: userPhone.stringValue)
            //记录已登录
            LocalData.saveYesOrNotValue(value: "1", key: IsLogin)
            self.navigationController?.popToRootViewController(animated: false)
            DispatchQueue.global().async {
                //注册环信
                esmobRegister(userPhone.stringValue)
            }

            
        }
        
    }
}


extension RegisterViewController{
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

