//
//  ChangePasswordViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

typealias ChangePasswordViewControllerBlock = () -> Void

class ChangePasswordViewController: BaseViewController {
    class func spwan() -> ChangePasswordViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! ChangePasswordViewController
    }
    
    var setPayPwdSuccessBlock : ChangePasswordViewControllerBlock?
    
    
    enum ChangePasswordType : Int {
        
        case setPayPwd = 0
        case changePayPwd = 1
        case changePwd = 2
        case changeEPPwd = 3//企业登录密码
    }
    
    var type : ChangePasswordType = .setPayPwd
    
    
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var tf3: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var forgetPayBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置布局
        self.setUpMainUI()
        
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
        
    }
    
    //设置布局
    func setUpMainUI() {
        
        self.saveBtn.layer.cornerRadius = 20
        
        if self.type == .setPayPwd{
            self.navigationItem.title = "设置支付密码"
            self.bottomView.isHidden = true
            self.tf1.placeholder = "请输入6位数字密码"
            self.tf2.placeholder = "请再次输入密码"
            self.tf1.keyboardType = .numberPad
            self.tf2.keyboardType = .numberPad
            self.tf3.keyboardType = .numberPad
            
        }else if self.type == .changePayPwd{
            self.navigationItem.title = "修改支付密码"
            self.tf1.placeholder = "请输入原支付密码"
            self.tf2.placeholder = "请输入新支付密码"
            self.tf3.placeholder = "请再次输入新支付密码"
            self.tf1.keyboardType = .numberPad
            self.tf2.keyboardType = .numberPad
            self.tf3.keyboardType = .numberPad
            self.forgetPayBtn.isHidden = false
            
        }else if self.type == .changePwd{
            self.navigationItem.title = "修改登录密码"
            self.btn1.isHidden = true
            self.tf1.isSecureTextEntry = false
            self.tf1.keyboardType = .numberPad
            self.tf1.placeholder = "请输入身份证号码"
            self.tf2.placeholder = "请输入原登录密码"
            self.tf3.placeholder = "请输入6-16位密码"
        }else if self.type == .changeEPPwd{
            self.navigationItem.title = "修改登录密码"
            self.btn1.isHidden = true
            self.tf1.isSecureTextEntry = false
//            self.tf1.keyboardType = .numbersAndPunctuation
            self.tf1.placeholder = "请输入原登录密码"
            self.tf2.placeholder = "请输入新登录密码"
            self.tf3.placeholder = "请再次输入新登录密码"
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func seeAction(_ btn: UIButton) {
        if btn.tag == 11{
            self.tf1.isSecureTextEntry = !self.tf1.isSecureTextEntry
        }else if btn.tag == 22{
            self.tf2.isSecureTextEntry = !self.tf2.isSecureTextEntry
        }else{
            self.tf3.isSecureTextEntry = !self.tf3.isSecureTextEntry
        }
    }
    
    //忘记原支付密码
    @IBAction func forgetPayPwdAction() {
        let forgetVC = ForgetPasswordViewController.spwan()
        forgetVC.isChangePayPwd = true
        self.navigationController?.pushViewController(forgetVC, animated: true)
    }
    
    @IBAction func saveAction() {
        self.view.endEditing(true)
        
        
        let str1 = self.tf1.text
        let str2 = self.tf2.text
        let str3 = self.tf3.text
        if self.type == .setPayPwd{
            if (str1?.isEmpty)! || (str2?.isEmpty)! || str1 != str2{
                LYProgressHUD.showError("密码不可为空，且两次输入需要一致")
                return
            }
            var params : [String : Any] = [:]
            var url = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                params["paypassword"] = str1!.md5String()
                url = EnterpriseSetPayPwdApi
            }else{
                params["paypwd"] = str1
                url = SetPayPwdApi
            }
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                LYAlertView.show("设置成功", "设置支付密码成功，现在可以去支付了", "知道了", {
                    if self.setPayPwdSuccessBlock != nil{
                        self.setPayPwdSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                })
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        }else if self.type == .changePayPwd{
            if (str1?.isEmpty)! || (str2?.isEmpty)! || (str3?.isEmpty)!{
                LYProgressHUD.showError("密码不可为空!")
                return
            }
            if str2 != str3 || str1 == str2 || str1 == str3{
                LYProgressHUD.showError("新密码应保持一致，且与旧密码不同")
                return
            }
            //修改支付密码
            func changePayPwd(){
                var params : [String : Any] = [:]
                var url = ""
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    params["original_paypass"] = str1!.md5String()
                    params["new_paypass"] = str2!.md5String()
                    url = EnterpriseVertifiPayPwdApi
                }else{
                    params["old_paypwd"] = str1
                    params["paypwd"] = str2
                    url = ChangePayPwdApi
                }
                
                NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultJson, error) in
                    //修改支付密码成功
                    LYAlertView.show("修改成功", "支付密码修改成功，现在可以使用新密码了", "知道了", {
                        if self.setPayPwdSuccessBlock != nil{
                            self.setPayPwdSuccessBlock!()
                        }
                        self.navigationController?.popViewController(animated: true)
                    })
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
            }
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                 changePayPwd()
            }else{
                //验证是否已设置支付密码
                var params : [String : Any] = [:]
                params["paypwd"] = str1?.md5String()
                NetTools.requestData(type: .post, urlString: HaveSetPayPasswordApi, parameters: params, succeed: { (resultJson, error) in
                    if resultJson["statu"].stringValue.intValue == 2{
                        //支付密码正确
                        changePayPwd()
                    }else if resultJson["statu"].stringValue.intValue == 3{
                        LYProgressHUD.showError("原支付密码错误！")
                    }
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
            }
        }else if self.type == .changePwd{
            if !(str1?.isIdCard())!{
                LYProgressHUD.showError("请输入准确身份证号码")
                return
            }
            if (str2?.isEmpty)! || (str3?.isEmpty)! || str2 == str3{
                LYProgressHUD.showError("密码不可为空，且新密码与旧密码应当不同")
                return
            }
            var params : [String : Any] = [:]
            params["store_id"] = "1"//	店铺ID
            params["old_password"] = str2//原密码
            params["password"] = str3//	密码
            params["password_confirm"] = str3//	确认密码
            params["card"] = str1//身份证号
            NetTools.requestData(type: .post, urlString: ChangeLoginPwdApi, parameters: params, succeed: { (resultJson, error) in
                //支付密码正确
                LYAlertView.show("修改成功", "登录密码修改成功，重新登录使用app", "好的", {
                    //退出
                    logOut()
                },{
                    //退出
                    logOut()
                })
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
            func logOut(){
                func logoutOperation(){
                    self.navigationController?.popViewController(animated: true)
                    //登录页
                    showLoginController()
                }
                var params : [String : Any] = [:]
                params["username"] = LocalData.getUserPhone()
                NetTools.requestData(type: .post, urlString: LogoutApi, parameters: params, succeed: { (result, msg) in
                    logoutOperation()
                }) { (error) in
                    LYProgressHUD.dismiss()
                    LYAlertView.show("提示", "退出失败，是否强制退出？","取消","确定", {
                       logoutOperation()
                    })
                }
            }
        }else if self.type == .changeEPPwd{
            func logout(){
                func logoutOperation(){
                    //返回
                    self.navigationController?.popToRootViewController(animated: true)
                    //登录页
                    showLoginController()
                }
                
                var params : [String : Any] = [:]
                params["company_tel"] = LocalData.getUserPhone()
                params["client"] = "ios"
                NetTools.requestData(type: .post, urlString: EnterpriseLogoutApi, parameters: params, succeed: { (result, msg) in
                    logoutOperation()
                }) { (error) in
                    LYProgressHUD.dismiss()
                    LYAlertView.show("提示", "退出失败，是否强制退出？","取消","确定", {
                        logoutOperation()
                    })
                }
            }
            
            if (str1?.isEmpty)! || (str2?.isEmpty)! || (str3?.isEmpty)!{
                LYProgressHUD.showError("密码不可为空!")
                return
            }
            if str2 != str3 || str1 == str2 || str1 == str3{
                LYProgressHUD.showError("新密码应保持一致，且与旧密码不同")
                return
            }
            
            LYProgressHUD.showLoading()
            var params : [String:Any] = [:]
            params["original_pass"] = str1!.md5String()
            params["new_pass"] = str2!.md5String()
            NetTools.requestData(type: .post, urlString: EnterpriseVertifiPwdApi, parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.dismiss()
                //支付密码正确
                LYAlertView.show("修改成功", "登录密码修改成功，重新登录使用app", "好的", {
                    //退出
                    logout()
                },{
                    //退出
                    logout()
                })
            }) { (error) in
                LYProgressHUD.showError(error ?? "修改失败，请重试！")
            }
        }
        
    }
    
    
    
}

extension ChangePasswordViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0{
            //增加字符
            if self.type == .setPayPwd || self.type == .changePayPwd{
                if (textField.text?.count)! > 5 {
                    LYProgressHUD.showError("最多6位数字！")
                    return false
                }
            }else{
                if textField == self.tf1 && (textField.text?.count)! > 17{
                    return false
                }
                if textField == self.tf2 || textField == self.tf3{
                    if (textField.text?.count)! > 15 {
                        LYProgressHUD.showError("密码最多16位！")
                        return false
                    }
                }
            }
        }else{
            //删除字符
            
        }
        return true
    }
}
