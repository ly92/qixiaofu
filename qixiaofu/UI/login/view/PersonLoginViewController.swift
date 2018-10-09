//
//  PersonLoginViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PersonLoginViewController: BaseViewController {
    class func spwan() -> PersonLoginViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! PersonLoginViewController
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var contentViewH: NSLayoutConstraint!
    @IBOutlet weak var bottomViewTopDis: NSLayoutConstraint!
    @IBOutlet weak var otherLoginView: UIView!
    
    fileprivate var isBeginEditPwdTF = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "登录"
        self.loginBtn.layer.cornerRadius = 20
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
        
        if kScreenH - 64 > 557{
            self.contentViewH.constant = kScreenH
            self.bottomViewTopDis.constant = kScreenH - 100 - 457
        }else{
            self.contentViewH.constant = 557 + 80
            self.bottomViewTopDis.constant = 100
        }
        
        if WXApi.isWXAppInstalled(){
            self.otherLoginView.isHidden = false
        }else{
            self.otherLoginView.isHidden = true
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loginBtn.isEnabled = false
        self.pwdTF.text = ""
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.operationWechatLogin(_:)), name: NSNotification.Name(rawValue: KWechatLoginNotiName), object: nil)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KWechatLoginNotiName), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func eyeBtnAction() {
        self.eyeBtn.isSelected = !self.eyeBtn.isSelected
        self.pwdTF.isSecureTextEntry = !self.eyeBtn.isSelected
    }
    
    @IBAction func loginBtnAction() {
        let account = self.phoneTF.text
        let pwd = self.pwdTF.text
        if !(account?.isMobelPhone())!{
            LYProgressHUD.showError("请输入正确手机号码")
            return;
        }
        if (pwd?.count)! < 6{
            LYProgressHUD.showError( "请输入至少6位密码")
            return;
        }
        
        //参数
        var params : [String:Any] = ["password" : (pwd?.md5String())!, "client" : "ios"]
        params["username"] = account!
        LYProgressHUD.showLoading()
        
        NetTools.requestData(type: .post, urlString: LoginApi, parameters: params, succeed: { (resultDict, error) in
            LYProgressHUD.dismiss()
            //登录环信
            esmobLogin()
            //先记录环境
            LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
            //保存userid
            LocalData.saveUserId(userId: resultDict["userid"].stringValue)
            //保存user phone
            LocalData.saveUserPhone(phone: account!)
            //记录已登录
            LocalData.saveYesOrNotValue(value: "1", key: IsLogin)
            //回到根页
            self.navigationController?.popToRootViewController(animated: true)
            //个人版
            AppDelegate.sharedInstance.resetRootViewController(1)
        }) { (error) in
            LYProgressHUD.showError( error ?? "登录失败，请重试！")
        }
    }
    
    
    @IBAction func forgetPwdAction() {
        //忘记密码
        let forgetVC = ForgetPasswordViewController.spwan()
        forgetVC.isForgetEpLoginPwd = false
        forgetVC.phone = self.phoneTF.text
        self.navigationController?.pushViewController(forgetVC, animated: true)
    }
    
    @IBAction func registerAction() {
        //注册个人账号
        let registerVC = RegisterViewController.spwan()
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func wechatLoginAction() {
        LYProgressHUD.showLoading()
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "qixiaofu_wechat_login"
        WXApi.sendAuthReq(req, viewController: self, delegate: self)
    }
    
    
    
    
}



extension PersonLoginViewController : WXApiDelegate{
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: SendAuthResp.self){
            let authResp = resp as! SendAuthResp
            //            var dict = [String:String]()
            //            dict["errCode"] = "\(authResp.errCode)"
            //            dict["code"] = authResp.code
            //            dict["state"] = authResp.state
            //            dict["lang"] = authResp.lang
            //            dict["country"] = authResp.country
            //处理登录结果
            self.getWechatToken(authResp.code)
        }
    }
    
    
    
    @objc func operationWechatLogin(_ noti : Notification) {
        let userInfo = noti.userInfo
        self.getWechatToken(userInfo!["code"] as! String)
    }
    
    
    func getWechatToken(_ code : String) {
        var params : [String : Any] = [:]
        params["code"] = code
        params["appid"] = KWechatKey
        params["secret"] = KWechatSecretKey
        params["grant_type"] = "authorization_code"
        NetTools.requestCustomerApi(type: .get, urlString: "https://api.weixin.qq.com/sns/oauth2/access_token", parameters: params, succeed: { (result) in
            //            print(result)
            //            self.refreshWechatToken(result["refresh_token"].stringValue)
            self.wechatLoginAction(result)
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取数据失败！")
        }
    }
    
    //微信登录
    func wechatLoginAction(_ result : JSON) {
        var params : [String : Any] = [:]
        params["open_id"] = result["openid"].stringValue
        NetTools.requestData(type: .post, urlString: ThirdLoginApi, parameters: params, succeed: { (resultJson, msg) in
            if resultJson["type"].stringValue.intValue == 0{
                let bindingVC = BindingAccountViewController.spwan()
                bindingVC.wechatInfo = result
                self.navigationController?.pushViewController(bindingVC, animated: true)
            }else{
                LYProgressHUD.dismiss()
                //登录环信
                esmobLogin()
                //先记录环境
                LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
                //保存userid
                LocalData.saveUserId(userId: resultJson["userid"].stringValue)
                //保存user phone
                LocalData.saveUserPhone(phone: resultJson["phone"].stringValue)
                //记录已登录
                LocalData.saveYesOrNotValue(value: "1", key: IsLogin)
                //回到根页
                self.navigationController?.popToRootViewController(animated: true)
                //个人版
                AppDelegate.sharedInstance.resetRootViewController(1)
            }
        }) { (error) in
            LYProgressHUD.showError(error ?? "微信信息获取失败！")
        }
    }
    
//    func refreshWechatToken(_ token : String) {
//        var params : [String : Any] = [:]
//        params["appid"] = KWechatKey
//        params["refresh_token"] = token
//        params["grant_type"] = "refresh_token"
//        NetTools.requestCustomerApi(type: .get, urlString: "https://api.weixin.qq.com/sns/oauth2/refresh_token", parameters: params, succeed: { (result) in
//            //            print(result)
//        }) { (error) in
//            LYProgressHUD.showError(error ?? "获取数据失败！")
//        }
//    }
    
    
    
    
    
}



extension PersonLoginViewController : UITextFieldDelegate{
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
