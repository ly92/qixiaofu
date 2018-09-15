//
//  LoginViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/5.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: BaseViewController {
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var personLoginBtn: UIButton!
    @IBOutlet weak var conView: UIView!
    
    @IBOutlet weak var pwdView: UIView!
    @IBOutlet weak var pwdSubView: UIView!
    @IBOutlet weak var pwdTF1: UITextField!
    @IBOutlet weak var pwdTF2: UITextField!
    
    @IBOutlet weak var personSelecteBtn: UIButton!
    @IBOutlet weak var epSelecteBtn: UIButton!
    @IBOutlet weak var btnLineLeftDis: NSLayoutConstraint!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var registerBottomDis: NSLayoutConstraint!
    @IBOutlet weak var epOrPersonView: UIView!
    @IBOutlet weak var epOrPersonLbl: UILabel!
    
    
    var isBeginEditPwdTF = Bool()
    
    class func spwan() -> LoginViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! LoginViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conView.addTapAction(action: #selector(LoginViewController.contentViewAction), target: self)
        self.personLoginBtn.layer.cornerRadius = 20
        self.navigationItem.title = "登录"
        self.pwdSubView.layer.cornerRadius = 10
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if LocalData.getUserPhone().isEmpty{
            self.accountTF.text = ""
        }else{
            self.accountTF.text = LocalData.getUserPhone()
        }
        self.pwdTF.text = ""
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        self.prepareAction()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.operationWechatLogin(_:)), name: NSNotification.Name(rawValue: KWechatLoginNotiName), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KWechatLoginNotiName), object: nil)
    }
    
    @objc func backClick() {
        if AppDelegate.sharedInstance.window?.rootViewController?.childViewControllers.last is LoginViewController{
            LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
            //是否需要登录
            if LocalData.getYesOrNotValue(key: IsLogin){
                AppDelegate.sharedInstance.resetRootViewController(1)
            }else{
                self.prepareAction()
            }
        }else{
            AppDelegate.sharedInstance.resetRootViewController(1)
        }
    }
    
    
    func prepareAction() {
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            self.epOrPersonLbl.text = "登录企业账户"
            self.epOrPersonView.isHidden = true
            self.epSelecteBtn.isSelected = true
            self.personSelecteBtn.isSelected = false
            self.accountTF.isEnabled = false
            //返回按钮
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(LoginViewController.backClick))
        }else{
            self.epOrPersonLbl.text = ""
            self.epOrPersonView.isHidden = false
            self.epSelecteBtn.isSelected = false
            self.personSelecteBtn.isSelected = true
            self.accountTF.isEnabled = true
            self.navigationItem.leftBarButtonItem = nil
        }
        
        if self.personSelecteBtn.isSelected{
            self.btnLineLeftDis.constant = self.personSelecteBtn.centerX - 7.5
        }else{
            self.btnLineLeftDis.constant = self.epSelecteBtn.centerX - 7.5
        }
    }
    
    func dissAction() {
        if self.presentingViewController != nil{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //点击事件
    @IBAction func btnAction(_ btn: UIButton, forEvent event: UIEvent) {
        if btn.tag == 11 {
            //忘记密码
            self.forgetPwd()
        }else if btn.tag == 22 {
            
//            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
//                //企业登录
//                self.loginAction(2)
//            }else{
//                //个人登录
//                self.loginAction(1)
//            }
            if self.epSelecteBtn.isSelected{
                //企业登录
                self.loginAction(2)
            }else if self.personSelecteBtn.isSelected{
                //个人登录
                self.loginAction(1)
//
//                if WXApi.isWXAppInstalled(){
//                    let req = SendAuthReq()
//                    req.scope = "snsapi_userinfo"
//                    req.state = "qixiaofu_wechat_login"
//                    WXApi.sendAuthReq(req, viewController: self, delegate: self)
//                }else{
//                    LYProgressHUD.showError("请安装微信！")
//                }
            }
        }else if btn.tag == 33 {
            //隐藏／显示密码
            self.pwdTF.isSecureTextEntry = !self.pwdTF.isSecureTextEntry
            self.eyeBtn.isSelected = !self.eyeBtn.isSelected
        }else if btn.tag == 44 {
            //注册
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                //注册企业账户
                let registerEPVC = RegisterEnterpriseViewController.spwan()
                self.navigationController?.pushViewController(registerEPVC, animated: true)
            }else{
                if self.epSelecteBtn.isSelected{
                    //注册企业账户
                    let registerEPVC = RegisterEnterpriseViewController.spwan()
                    self.navigationController?.pushViewController(registerEPVC, animated: true)
                }else{
                    //注册个人账号
                    self.registerAction()
                }
            }
//            self.registerView.isHidden = false
//            self.registerBottomDis.constant = -230
//            UIView.animate(withDuration: 0.5) {
//                self.registerBottomDis.constant = 0
//            }
        }else if btn.tag == 55 {
            //确定设置密码
            self.resetEnterprisePwd()
        }else if btn.tag == 66 {
            //切换个人登录
            self.personSelecteBtn.isSelected = true
            self.epSelecteBtn.isSelected = false
            self.btnLineLeftDis.constant = self.personSelecteBtn.centerX - 7.5
            //如果个人账户登录了则直接进个人版
            if LocalData.getYesOrNotValue(key: IsLogin){
                self.dissAction()
                AppDelegate.sharedInstance.resetRootViewController(1)
            }
        }else if btn.tag == 77 {
            //切换企业登录
            self.personSelecteBtn.isSelected = false
            self.epSelecteBtn.isSelected = true
            self.btnLineLeftDis.constant = self.epSelecteBtn.centerX - 7.5
            //如果企业版登录了则直接进企业版
            if LocalData.getYesOrNotValue(key: IsEPLogin){
                self.dissAction()
                AppDelegate.sharedInstance.resetRootViewController(2)
            }
        }else if btn.tag == 88 {
            //注册个人账号
            self.registerAction()
            self.registerView.isHidden = true
        }else if btn.tag == 99 {
            //注册企业账户
            let registerEPVC = RegisterEnterpriseViewController.spwan()
            self.navigationController?.pushViewController(registerEPVC, animated: true)
            self.registerView.isHidden = true
        }else if btn.tag == 89 {
            //取消注册
            self.registerBottomDis.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.registerBottomDis.constant = -230
            }) { (comple) in
                self.registerView.isHidden = true
            }
        }
    }
}

extension LoginViewController : WXApiDelegate{
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
            self.getWechatUserInfo(result)
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取数据失败！")
        }
    }
    
    func refreshWechatToken(_ token : String) {
        var params : [String : Any] = [:]
        params["appid"] = KWechatKey
        params["refresh_token"] = token
        params["grant_type"] = "refresh_token"
        NetTools.requestCustomerApi(type: .get, urlString: "https://api.weixin.qq.com/sns/oauth2/refresh_token", parameters: params, succeed: { (result) in
//            print(result)
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取数据失败！")
        }
    }
    
    func getWechatUserInfo(_ result : JSON) {
        var params : [String : Any] = [:]
        params["access_token"] = result["access_token"].stringValue
        params["openid"] = result["openid"].stringValue
        NetTools.requestCustomerApi(type: .get, urlString: "https://api.weixin.qq.com/sns/userinfo", parameters: params, succeed: { (result) in
            print(result)
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取数据失败！")
        }
    }
    
}





// MARK: - 点击事件处理
extension LoginViewController{
    @objc func contentViewAction(){
        self.view.endEditing(true)
    }
    
    func forgetPwd() {
        let forgetVC = ForgetPasswordViewController.spwan()
//        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
//            forgetVC.isForgetEpLoginPwd = true
//        }
        forgetVC.isForgetEpLoginPwd = self.epSelecteBtn.isSelected
        self.navigationController?.pushViewController(forgetVC, animated: true)
    }
    
    //type 1:personal  2:enterprise
    func loginAction(_ type : Int) {
        
        let account = self.accountTF.text
        let pwd = self.pwdTF.text
        if !(account?.isMobelPhone())!{
            LYProgressHUD.showError("请输入正确手机号码")
            return;
        }
        if type == 1{
            if (pwd?.count)! < 6{
                LYProgressHUD.showError( "请输入至少6位密码")
                return;
            }
        }else if type == 2{
            if (pwd?.count)! < 8{
                LYProgressHUD.showError( "请输入至少8位密码")
                return;
            }
            if !checkEpPwd(pwd!){
                return
            }
        }
        
        //参数
        var params : [String:Any] = ["password" : (pwd?.md5String())!, "client" : "ios"]
        LYProgressHUD.showLoading()
        var url = ""
        if type == 1{
            url = LoginApi
            params["username"] = account!
        }else if type == 2{
            url = EnterpriseLoginApi
            params["mobile"] = account!
        }else{
            return
        }
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultDict, error) in
            LYProgressHUD.dismiss()
            //登录环信
            self.loginEasemob()
            if type == 1{
                //先记录环境
                LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
                //保存userid
                LocalData.saveUserId(userId: resultDict["userid"].stringValue)
                //保存user phone
                LocalData.saveUserPhone(phone: account!)
                //记录已登录
                LocalData.saveYesOrNotValue(value: "1", key: IsLogin)
                //个人版
                AppDelegate.sharedInstance.resetRootViewController(1)
                    self.dissAction()
            }else if type == 2{
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
                    AppDelegate.sharedInstance.resetRootViewController(2)
                    self.dissAction()
                }
            }
            
        }) { (error) in
            LYProgressHUD.showError( error ?? "登录失败，请重试！")
        }
    }
    
    func registerAction() {
        let registerVC = RegisterViewController.spwan()
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    //环信//登录环信
    func loginEasemob() {
        DispatchQueue.global().async {
            HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
        }
    }
    
    // MARK: - 获取用户信息
    func loadMineInfoData() {
        NetTools.requestData(type: .post, urlString: PersonalInfoApi, succeed: { (resultJson, msg) in
            
            //保存是否实名
            if resultJson["is_real"].stringValue == "1"{
                //已实名
                LocalData.saveYesOrNotValue(value: "1", key: IsTrueName)
            }else{
                //未实名
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
            }
            //保存姓名
            LocalData.saveUserName(userName: resultJson["member_nik_name"].stringValue)
            LocalData.saveTrueUserName(userName: resultJson["member_truename"].stringValue)
            
            //保存邀请码
            LocalData.saveUserInviteCode(phone: resultJson["iv_code"].stringValue)
            
            //是否为A用户
            if  resultJson["member_level"].stringValue == "A" || resultJson["member_level"].stringValue == "DA"{
                LocalData.saveYesOrNotValue(value: "1", key: IsALevelUser)
            }else{
                LocalData.saveYesOrNotValue(value: "0", key: IsALevelUser)
            }
            
            //保存自己的聊天页面数据
            LocalData.saveChatUserInfo(name: resultJson["member_nik_name"].stringValue, icon: resultJson["member_avatar"].stringValue, key: LocalData.getUserPhone())
        }) { (error) in
        }
    }
    
    //初次登录设置密码
    func resetEnterprisePwd() {
        guard let pwd = self.pwdTF1.text?.trim else {
            LYProgressHUD.showError("请输入密码")
            return
        }
        guard let pwd2 = self.pwdTF2.text?.trim else {
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
            self.dissAction()
            self.pwdView.isHidden = true
        }) { (error) in
            LYProgressHUD.showError(error ?? "修改失败，请重试！")
        }
    }
    
}

//// MARK: - 获取用户信息
//extension LoginViewController{
//    func loadUserInfo() {
//        
//        UserViewModel.loadUserInfo { (userModel) in }
//    
//    }
//}


// MARK: - UIScrollViewDelegate
extension LoginViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard var account = self.accountTF.text else {
            return false
        }
        guard var pwd = self.pwdTF.text else {
            return false
        }
        
        if range.length == 0{
            //增加字符
            if textField == self.accountTF{
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
            if textField == self.accountTF{
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
            self.personLoginBtn.isEnabled = true
        }else{
            self.personLoginBtn.isEnabled = false
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //清除输入框时不可登录
        self.personLoginBtn.isEnabled = false
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






