//
//  EnterpriseAddAccountViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnterpriseAddAccountViewController: BaseViewController {
    class func spwan() -> EnterpriseAddAccountViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EnterpriseAddAccountViewController
    }
    
    var editJson : JSON?
    var addSuccessBlock : (() -> Void)?
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveBtn.layer.cornerRadius = 20
        self.navigationItem.title = "添加账户"
        if self.editJson != nil{
            self.nameTF.text = self.editJson!["user_name"].stringValue
            self.phoneTF.text = self.editJson!["user_tel"].stringValue
            self.navigationItem.title = "编辑账户"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction() {
        
        self.view.endEditing(true)
        
        guard let name = self.nameTF.text else {
            return
        }
        guard let phone = self.phoneTF.text else {
            return
        }
        if name.isEmpty{
            LYProgressHUD.showError("姓名不可为空")
            return
        }
        if phone.isEmpty{
            LYProgressHUD.showError("手机号不可为空")
            return
        }
        LYProgressHUD.showLoading()
        var params : [String:Any] = [:]
        params["user_name"] = name
        params["user_tel"] = phone
        var url = EnterpriseAddAccountApi
        if self.editJson != nil{
            params["newuser_id"] = self.editJson!["user_id"].stringValue
            url = EnterpriseEditAccountApi
        }
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            if self.editJson != nil{
                LYProgressHUD.showSuccess("修改成功！")
                if self.addSuccessBlock != nil{
                    self.addSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }else{
                DispatchQueue.global().async {
                    //注册环信
                    esmobRegister(phone)
                }
                LYAlertView.show("提示", "添加成功，初始密码8个0", "知道了","继续添加",{
                    self.nameTF.text = ""
                    self.phoneTF.text = ""
                },{
                    if self.addSuccessBlock != nil{
                        self.addSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }) { (error) in
            LYProgressHUD.showError(error ?? "操作失败，请重试！")
        }
    }
    
    
}
