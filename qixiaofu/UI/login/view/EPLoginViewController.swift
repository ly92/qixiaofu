//
//  EPLoginViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class EPLoginViewController: BaseViewController {
    class func spwan() -> EPLoginViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! EPLoginViewController
    }
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var pwd1TF: UITextField!
    @IBOutlet weak var pwd2TF: UITextField!
    @IBOutlet weak var pwdView: UIView!
    @IBOutlet weak var pwdSubView: UIView!
    @IBOutlet weak var contentViewH: NSLayoutConstraint!
    
    fileprivate var isBeginEditPwdTF = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "登录"
        self.loginBtn.layer.cornerRadius = 20
        self.pwdSubView.layer.cornerRadius = 10
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
        
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
        
        self.contentViewH.constant = kScreenH
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loginBtn.isEnabled = false
        self.pwdTF.text = ""
        guard let phone = self.phoneTF.text else {
            self.phoneTF.text = ""
            return
        }
        if phone.isEmpty{
            if LocalData.getUserPhone().isEmpty{
                self.phoneTF.text = ""
            }else{
                self.phoneTF.text = LocalData.getUserPhone()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eyeBtnAction() {
        self.eyeBtn.isSelected = !self.eyeBtn.isSelected
        self.pwdTF.isSecureTextEntry = !self.eyeBtn.isSelected
    }
    
    @IBAction func forgetBtnAction() {
        let forgetVC = ForgetPasswordViewController.spwan()
        forgetVC.isForgetEpLoginPwd = true
        forgetVC.phone = self.phoneTF.text
        self.navigationController?.pushViewController(forgetVC, animated: true)
    }
    
    @IBAction func loginBtnAction() {
        let account = self.phoneTF.text
        let pwd = self.pwdTF.text
        if !(account?.isMobelPhone())!{
            LYProgressHUD.showError("请输入正确手机号码")
            return;
        }

            if (pwd?.count)! < 8{
                LYProgressHUD.showError( "请输入至少8位密码")
                return;
            }
        if pwd! != "00000000"{
            if !checkEpPwd(pwd!){
                return
            }
        }
        
        //参数
        var params : [String:Any] = ["password" : (pwd?.md5String())!, "client" : "ios"]
        params["mobile"] = account!
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: EnterpriseLoginApi, parameters: params, succeed: { (resultDict, error) in
            LYProgressHUD.dismiss()
            //登录环信
            self.loginEasemob()
            
                //企业版
                LocalData.saveYesOrNotValue(value: "1", key: KEnterpriseVersion)
                //保存userid
                LocalData.saveEPUserId(userId: resultDict["userid"].stringValue)
                //保存user phone
                LocalData.saveUserPhone(phone: account!)
                //记录已登录
                LocalData.saveYesOrNotValue(value: "1", key: IsEPLogin)
                if pwd! == "00000000"{
                    //设置未登录
                    LocalData.saveYesOrNotValue(value: "0", key: IsEPLogin)
                    self.pwdView.isHidden = false
                }else{
                    self.navigationController?.popToRootViewController(animated: false)
                    AppDelegate.sharedInstance.resetRootViewController(2)
                }
            
        }) { (error) in
            LYProgressHUD.showError( error ?? "登录失败，请重试！")
        }
    }
    
    //环信//登录环信
    func loginEasemob() {
        DispatchQueue.global().async {
            HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
        }
    }
    
    @IBAction func registerAction() {
        //注册企业账户
        let registerEPVC = RegisterEnterpriseViewController.spwan()
        self.navigationController?.pushViewController(registerEPVC, animated: true)
    }
    
    @IBAction func sureAction() {
        guard let pwd = self.pwd1TF.text?.trim else {
            LYProgressHUD.showError("请输入密码")
            return
        }
        guard let pwd2 = self.pwd2TF.text?.trim else {
            LYProgressHUD.showError("请输入密码")
            return
        }
        
        if pwd != pwd2{
            LYProgressHUD.showError("两次输入的密码不一致！")
            return
        }
        if pwd.count < 8{
            LYProgressHUD.showError( "请设置不少于8位的密码")
            return;
        }
        if pwd.count > 16{
            LYProgressHUD.showError( "请设置不大于16位的密码")
            return;
        }
        
        if !checkEpPwd(pwd){
            return
        }
        
        LYProgressHUD.showLoading()
        var params : [String:Any] = [:]
        params["original_pass"] = "00000000".md5String()
        params["new_pass"] = pwd.md5String()
        NetTools.requestData(type: .post, urlString: EnterpriseVertifiPwdApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.showSuccess("设置成功！")
            //记录已登录
            LocalData.saveYesOrNotValue(value: "1", key: IsEPLogin)
            AppDelegate.sharedInstance.resetRootViewController(2)
            self.pwdView.isHidden = true
        }) { (error) in
            LYProgressHUD.showError(error ?? "修改失败，请重试！")
        }
    }
    
    
    
}


extension EPLoginViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var account = self.phoneTF.text else {
            return false
        }
        guard var pwd = self.pwdTF.text else {
            return false
        }
        
        if range.length == 0{
            //增加字符
            if textField == self.phoneTF{
                if account.count > 10{
                    return false
                }
                account.append(string)
            }else{
                if self.isBeginEditPwdTF{
                    pwd = string
                }else{
                    pwd.append(string)
                }
                self.isBeginEditPwdTF = false
            }
        }else{
            //删除字符
            if textField == self.phoneTF{
                account = String(account.prefix(upTo: account.index(before: account.endIndex)))
            }else{
                if self.isBeginEditPwdTF{
                    pwd = ""
                }else{
                    pwd = String(pwd.prefix(upTo: pwd.index(before: pwd.endIndex)))
                }
                self.isBeginEditPwdTF = false
            }
        }
        if account.isMobelPhone() && pwd.count > 5{
            self.loginBtn.isEnabled = true
        }else{
            self.loginBtn.isEnabled = false
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //清除输入框时不可登录
        self.loginBtn.isEnabled = false
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.isBeginEditPwdTF = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
