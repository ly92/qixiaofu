//
//  AddStandardViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/3.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddStandardViewController: BaseViewController {
    class func spwan() -> AddStandardViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! AddStandardViewController
    }
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descTFV: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var placeholderLbl: UILabel!
    
    var refreshBlock : (() -> Void)?
    
    var isAdd = false
    var isPackageStandard = false
    var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitBtn.layer.cornerRadius = 20
        
        if self.isAdd{
            if self.isPackageStandard{
                self.navigationItem.title = "添加包装标准"
            }else{
                self.navigationItem.title = "添加测试标准"
            }
        }else{
            self.navigationItem.title = "标准详情"
            let audit_state = self.resultJson["audit_state"].stringValue.intValue //审核状态 0为待审核 1为审核通过 2为审核不通过
            if audit_state == 0{
                self.submitBtn.setTitle("取消审核", for: .normal)
            }else if audit_state == 1{
                self.submitBtn.setTitle("使用此标准", for: .normal)
            }else if audit_state == 2{
                self.submitBtn.setTitle("删除", for: .normal)
            }
            
            self.nameTF.isEnabled = false
            self.descTFV.isEditable = false
            if self.isPackageStandard{
                self.nameTF.text = self.resultJson["package_name"].stringValue
                self.descTFV.text = self.resultJson["package_standard"].stringValue
            }else{
                self.nameTF.text = self.resultJson["test_name"].stringValue
                self.descTFV.text = self.resultJson["test_standard"].stringValue
            }
            self.placeholderLbl.isHidden = true
        }
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
    }


    
    @IBAction func submitAction() {
        if self.isAdd{
            guard let name = self.nameTF.text else{
                return
            }
            guard let desc = self.descTFV.text else{
                return
            }
            if name.isEmpty{
                LYProgressHUD.showError("请输入一个名字")
                return
            }
            if desc.isEmpty{
                LYProgressHUD.showError("请填写定制描述")
                return
            }
            var params : [String:String] = [:]
            var url = ""
            if self.isPackageStandard{
                params["package_name"] = name
                params["package_standard"] = desc
                url = AddPackageStandardApi
            }else{
                params["test_name"] = name
                params["test_standard"] = desc
                url = AddTestStandardApi
            }
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("添加成功！")
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error ?? "添加失败，请重试！")
            }
        }else{
            let audit_state = self.resultJson["audit_state"].stringValue.intValue //审核状态 0为待审核 1为审核通过 2为审核不通过
            if audit_state == 0{
                //取消审核
                var params : [String:String] = [:]
                var url = ""
                params["id"] = self.resultJson["id"].stringValue
                if self.isPackageStandard{
                    url = DeletePackageStandardApi
                }else{
                    url = DeleteTestStandardApi
                }
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("操作成功！")
                    if self.refreshBlock != nil{
                        self.refreshBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }) { (error) in
                    LYProgressHUD.showError(error ?? "操作失败，请重试！")
                }
            }else if audit_state == 1{
                //使用此标准
                var params : [String:String] = [:]
                var url = ""
                params["id"] = self.resultJson["id"].stringValue
                if self.isPackageStandard{
                    url = ChoosePackageStandardApi
                }else{
                    url = ChooseTestStandardApi
                }
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("操作成功！")
                    self.navigationController?.popToRootViewController(animated: true)
                }) { (error) in
                    LYProgressHUD.showError(error ?? "操作失败，请重试！")
                }
                
            }else if audit_state == 2{
                //删除
                var params : [String:String] = [:]
                var url = ""
                params["id"] = self.resultJson["id"].stringValue
                if self.isPackageStandard{
                    url = DeletePackageStandardApi
                }else{
                    url = DeleteTestStandardApi
                }
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("操作成功！")
                    if self.refreshBlock != nil{
                        self.refreshBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }) { (error) in
                    LYProgressHUD.showError(error ?? "操作失败，请重试！")
                }
            }
        }
        
        
    }
    
   
}

extension AddStandardViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeholderLbl.isHidden = false
        }else{
            self.placeholderLbl.isHidden = true
        }
    }
}



