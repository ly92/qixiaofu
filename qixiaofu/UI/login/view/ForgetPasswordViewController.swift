//
//  ForgetPasswordViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/19.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ForgetPasswordViewController: BaseViewController {
    class func spwan() -> ForgetPasswordViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! ForgetPasswordViewController
    }
    
    var isChangePayPwd = false//重置支付密码
    
    var isForgetEpLoginPwd = false//忘记了企业登录密码
    var phone : String? //忘记登录密码的手机号
    
    
    fileprivate var timer = Timer()//
    fileprivate var codeTime : Int = 60
    
    
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var eyeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isChangePayPwd{
            self.navigationItem.title = "重置支付密码"
            self.pwdTF.placeholder = "请输入6位数字密码"
            self.pwdTF.keyboardType = .numberPad
        }else{
            if self.isForgetEpLoginPwd{
                self.navigationItem.title = "重置企业版登录密码"
            }else{
                self.navigationItem.title = "重置个人版登录密码"
            }
            
        }
        self.saveBtn.layer.cornerRadius = 20;
        if LocalData.getYesOrNotValue(key: IsLogin) || LocalData.getYesOrNotValue(key: IsEPLogin){
            self.phoneTF.text = self.phone == nil ? LocalData.getUserPhone() : self.phone
            self.phoneTF.isEnabled = false
        }else{
            self.phoneTF.isEnabled = true
            self.phoneTF.text = self.phone == nil ? LocalData.getUserPhone() : self.phone
        }
        
        self.view.addTapActionBlock {
            self.endEditing()
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnAction(_ btn: UIButton) {
        switch btn.tag {
        case 11:
            //验证码
            self.getCodeAction()
        case 22:
            //密码可见
            self.pwdTF.isSecureTextEntry = !self.pwdTF.isSecureTextEntry
            self.eyeBtn.isSelected = !self.eyeBtn.isSelected
        case 33:
            if self.isChangePayPwd{
                //重置支付密码
                self.saveAction(3)
            }else{
                if self.isForgetEpLoginPwd{
                    //重置企业密码
                    self.saveAction(2)
                }else{
                    //重置个人密码
                    self.saveAction(1)
                }
            }
        default:
            print("default")
        }
    }
    
}

extension ForgetPasswordViewController{
    //获取验证码
    func getCodeAction() {
        let phone = self.phoneTF.text
        if !(phone?.isMobelPhone())!{
            LYProgressHUD.showError("请输入正确手机号码！")
            return
        }
        self.codeBtn.isEnabled = false
        var params : [String : Any] = [:]
        var url = ""
        params["mobile"] = phone!
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion) || self.isForgetEpLoginPwd{
            url = EnterpriseVerificationCodeApi
            if self.isChangePayPwd{
                params["type"] = "3"
            }else{
                params["type"] = "2"
            }
        }else{
            params["t"] = "2"
            url = VerificationCodeApi
        }
        
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultDict, error) in
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
    
    //保存密码 type 1:personal  2:enterprise 3:重置支付密码
    func saveAction(_ type : Int) {

        let phone = self.phoneTF.text
        let code = self.codeTF.text
        let pwd = self.pwdTF.text
        
        if !(phone?.isMobelPhone())!{
            LYProgressHUD.showError("请输入正确手机号码！")
            return
        }
        if (code?.isEmpty)!{
            LYProgressHUD.showError("请输入验证码！")
            return
        }
        
        if (pwd?.isEmpty)!{
            LYProgressHUD.showError("密码不可为空！")
            return
        }
        
        var url = ForgetPwdApi
        
        if self.isChangePayPwd{
            
            //重置企业支付密码
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self.resetEpPayPwd(pwd!,code!)
                return
            }
            
            if (pwd?.count)! != 6 {
                LYProgressHUD.showError("请输入6位数字密码")
                return
            }
            url = ResetPayPwdApi
        }else{
            
            //重设企业登录密码
            if type == 2{
                self.resetEpLoginPwd(pwd!, code!)
                return
            }
            if (pwd?.count)! < 6 {
                LYProgressHUD.showError("请输入至少6位密码")
                return
            }
        }
        
        let params :[String:Any] = ["phone" : phone!, "verif" : code!, "password" : pwd!]
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultDict, error) in
            if self.isChangePayPwd{
                //重置支付密码
                self.resetPayPwd(pwd!)
            }else{
                LYProgressHUD.showSuccess("设置成功！")
                self.navigationController?.popToRootViewController(animated: true)
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //重置个人支付密码
    func resetPayPwd(_ pwd : String) {
        var params : [String : Any] = [:]
        params["paypwd"] = pwd
        NetTools.requestData(type: .post, urlString: SetPayPwdApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("设置成功！")
            self.navigationController?.popViewController(animated: true)
        }, failure: { (error) in
            LYProgressHUD.showError(error!)
        })
    }
    
    
    //重置企业支付密码
    func resetEpPayPwd(_ pwd : String, _ code : String) {
        var params : [String : Any] = [:]
        params["mobile"] = self.phoneTF.text!
        params["verif"] = code
        params["new_paypassword"] = pwd.md5String()
        NetTools.requestData(type: .post, urlString: EnterpriseForgetPayPwdApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("设置成功！")
            self.navigationController?.popViewController(animated: true)
        }, failure: { (error) in
            LYProgressHUD.showError(error!)
        })
    }
    
    //重置企业登录密码
    func resetEpLoginPwd(_ pwd : String, _ code : String) {
        if pwd.count < 8 {
            LYProgressHUD.showError("请输入至少8位密码")
            return
        }
        if !checkEpPwd(pwd){
            return
        }
        var params : [String : Any] = [:]
        params["mobile"] = self.phoneTF.text!
        params["verif"] = code
        params["password"] = pwd.md5String()
        NetTools.requestData(type: .post, urlString: EnterpriseVertifiForgetPwdApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("设置成功！")
            self.navigationController?.popToRootViewController(animated: true)
        }, failure: { (error) in
            LYProgressHUD.showError(error!)
        })
    }
 
    
}


@available(iOS 10.0, *)
extension ForgetPasswordViewController{
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

extension ForgetPasswordViewController{
    func setUpCodeTimer2() {
        self.codeTime = 60
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(ForgetPasswordViewController.changeCodeBtnTitle), userInfo: nil, repeats: true)
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







