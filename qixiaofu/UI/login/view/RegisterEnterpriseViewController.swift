//
//  RegisterEnterpriseViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit



class RegisterEnterpriseViewController: BaseViewController {
    class func spwan() -> RegisterEnterpriseViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! RegisterEnterpriseViewController
    }
    
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var pwdTF2: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var eyeBtn1: UIButton!
    @IBOutlet weak var eyeBtn2: UIButton!
    
    
    
    
    fileprivate var timer = Timer()//
    fileprivate var codeTime : Int = 60
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitBtn.layer.cornerRadius = 20
        
        self.navigationItem.title = "注册企业账户"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAction(_ btn: UIButton) {
        if btn.tag == 11{
            //退出编辑
            self.view.endEditing(true)
        }else if btn.tag == 22{
            //获取验证码
            self.getCode()
        }else if btn.tag == 33{
            //提交注册
            self.registerAction()
        }else if btn.tag == 44{
            //去登录
            self.navigationController?.popViewController(animated: true)
        }else if btn.tag == 55{
            //密码1
            self.eyeBtn1.isSelected = !self.eyeBtn1.isSelected
            self.pwdTF.isSecureTextEntry = !self.pwdTF.isSecureTextEntry
        }else if btn.tag == 66{
            //密码2
            self.eyeBtn2.isSelected = !self.eyeBtn2.isSelected
            self.pwdTF2.isSecureTextEntry = !self.pwdTF2.isSecureTextEntry
        }
        
    }
    
    
}

extension RegisterEnterpriseViewController{
    func getCode() {
        let account = self.phoneTF.text
        if !(account?.isMobelPhone())!{
            LYProgressHUD.showError( "请输入正确手机号码")
            return;
        }
        let params :[String:Any] = ["mobile" : account!, "type" : "1"]
        self.codeBtn.isEnabled = false
        NetTools.requestData(type: .post, urlString: EnterpriseVerificationCodeApi, parameters: params, succeed: { (resultDict, error) in
            if !resultDict["code"].stringValue.isEmpty{
                if #available(iOS 10.0, *) {
                    self.setUpCodeTimer()
                } else {
                    self.setUpCodeTimer2()
                }
            }else{
                self.codeBtn.isEnabled = true
            }
        }) { (error) in
            self.codeBtn.isEnabled = true
            print(error ?? "没有数据")
            LYProgressHUD.showError(error!)
        }
    }
    
    //注册
    func registerAction() {
        guard let account = self.phoneTF.text else {
            LYProgressHUD.showError( "请输入正确的手机号")
            return
        }
        guard let code = self.codeTF.text else {
            LYProgressHUD.showError( "请输入验证码")
            return
        }
        guard let pwd = self.pwdTF.text?.trim else {
            LYProgressHUD.showError("请输入密码")
            return
        }
        guard let pwd2 = self.pwdTF2.text?.trim else {
            LYProgressHUD.showError("请输入密码")
            return
        }
        
        if !account.isMobelPhone(){
            LYProgressHUD.showError( "请输入正确的手机号")
            return;
        }
        
        if code.isEmpty{
            LYProgressHUD.showError( "请输入验证码")
            return;
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
        
        DispatchQueue.global().async {
            //注册环信
            HChatClient.shared().register(withUsername: account, password: "11")
        }
        
        let params : [String:Any] = ["phone" : account, "verif" : code, "company_password" : pwd.md5String()]
        let step2VC = RegisterEnterpriseInfoViewController.spwan()
        step2VC.params = params
        self.navigationController?.pushViewController(step2VC, animated: true)
    }
    
}


@available(iOS 10.0, *)
extension RegisterEnterpriseViewController{
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

extension RegisterEnterpriseViewController{
    func setUpCodeTimer2() {
        self.codeTime = 60
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(RegisterViewController.changeCodeBtnTitle), userInfo: nil, repeats: true)
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

extension RegisterEnterpriseViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
/*
 extension RegisterEnterpriseViewController : UITextFieldDelegate{
 
 func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
 if textField == self.pwdTF || textField == self.pwdTF2{
 guard var pwd1 = self.pwdTF.text else {
 return true
 }
 guard var pwd2 = self.pwdTF2.text else {
 return true
 }
 if range.length == 0{
 //增加字符
 if textField == self.pwdTF{
 pwd1.append(string)
 }else{
 pwd2.append(string)
 }
 }else{
 //删除字符
 if textField == self.pwdTF{
 pwd1 = String(pwd1.prefix(upTo: pwd1.index(before: pwd1.endIndex)))
 }else{
 pwd2 = String(pwd2.prefix(upTo: pwd2.index(before: pwd2.endIndex)))
 }
 }
 }
 return true
 }
 
 func textFieldShouldClear(_ textField: UITextField) -> Bool {
 //清除输入框时不可登录
 
 return true
 }
 
 func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
 return true
 }
 
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 self.view.endEditing(true)
 return true
 }
 }
 */

