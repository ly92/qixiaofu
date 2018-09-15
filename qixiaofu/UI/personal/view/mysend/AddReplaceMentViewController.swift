//
//  AddReplaceMentViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class AddReplaceMentViewController: BaseViewController {
    class func spwan() -> AddReplaceMentViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! AddReplaceMentViewController
    }
    
    var billId = ""
    
    var showType = 1 //1:工程师创建。2:工程师修改。3:客户确认前工程师查看（可编辑） 4:客户查看 5:客户确认后工程师查看（不可编辑）
    
    var subJson : Dictionary<String, String>?
    var addDataBlock : ((Dictionary<String, String>) -> Void)?
    var deleteDataBlock : (() -> Void)?
    
    
    fileprivate var store_parts_id = "0"
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var replaceNumTF: UITextField!
    @IBOutlet weak var newNumTF: UITextField!
    @IBOutlet weak var oldNumTF: UITextField!
    
    @IBOutlet weak var replaceFromTF: UITextField!
    
    @IBOutlet weak var selectDOA: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var chooseSnBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subView.layer.cornerRadius = 10
        self.saveBtn.layer.cornerRadius = 20
        self.deleteBtn.layer.cornerRadius = 20
        self.navigationItem.title = "选择备件"
        
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }

        if self.subJson != nil{
            self.replaceNumTF.text = self.subJson!["parts_pn"]
            self.newNumTF.text = self.subJson!["new_serial"]
            self.oldNumTF.text = self.subJson!["old_serial"]
            self.replaceFromTF.text = self.subJson!["store_room"]
            if self.subJson!["parts_status"] == "DOA"{
                self.selectDOA.isSelected = true
            }
            if !(self.subJson!["store_parts_id"]?.trim.isEmpty)! && self.subJson!["store_parts_id"]?.intValue != 0{
                //平台备件
                self.newNumTF.isEnabled = false
                self.replaceFromTF.isEnabled = false
                self.store_parts_id = (self.subJson!["store_parts_id"]?.trim)!
            }
            if self.showType == 3 || self.showType == 4 || self.showType == 5{
                self.replaceNumTF.isEnabled = false
                self.newNumTF.isEnabled = false
                self.oldNumTF.isEnabled = false
                self.replaceFromTF.isEnabled = false
                self.selectDOA.isEnabled = false
                self.saveBtn.isHidden = true
                self.deleteBtn.isHidden = true
                self.chooseSnBtn.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doaAction() {
        self.selectDOA.isSelected = !self.selectDOA.isSelected
    }
    
    @IBAction func saveAction() {
        let replaceNum = self.replaceNumTF.text
        let newNum = self.newNumTF.text
        let oldNum = self.oldNumTF.text
        let from = self.replaceFromTF.text
        let doa = self.selectDOA.isSelected ? "DOA" : ""
        
        if (replaceNum?.isEmpty)!{
            LYProgressHUD.showError("请输入备件号")
            return
        }
        if (newNum?.isEmpty)!{
            LYProgressHUD.showError("请输入新件序列号")
            return
        }
        if !self.selectDOA.isSelected {
            if (oldNum?.isEmpty)!{
                LYProgressHUD.showError("请输入旧件序列号")
                return
            }
        }
        if (from?.isEmpty)!{
            LYProgressHUD.showError("请输入备件出处")
            return
        }
        
        if self.subJson != nil{
            self.subJson!["parts_pn"] = replaceNum!
            self.subJson!["new_serial"] = newNum!
            self.subJson!["old_serial"] = oldNum!
            self.subJson!["store_room"] = from!
            self.subJson!["parts_status"] = doa
            self.subJson!["store_parts_id"] = self.store_parts_id
        }else{
            self.subJson = ["parts_pn" : replaceNum!,"new_serial" : newNum!,"old_serial" : oldNum!,"store_room" : from!,"parts_status" : doa, "store_parts_id" : self.store_parts_id]
        }
        
        
        if self.addDataBlock != nil && self.subJson != nil{
            self.addDataBlock!(self.subJson!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chooseSnAction() {
        //选择sn
        let replacementVC = ReplacementPartListViewController()
        replacementVC.orerId = self.billId
        replacementVC.isServiceBill = true
        replacementVC.finishChooseSnBlock = {(id, sn) in
            if id.isEmpty || sn.isEmpty{
                LYProgressHUD.showError("选择出错，请重新选择")
                return
            }
            self.store_parts_id = id
            self.newNumTF.text = sn
            self.newNumTF.isEnabled = false
            self.replaceFromTF.text = "七小服平台"
            self.replaceFromTF.isEnabled = false
        }
        self.navigationController?.pushViewController(replacementVC, animated: true)
    }
    
    
    @IBAction func deleteAction() {
        if self.deleteDataBlock != nil && self.subJson != nil{
            self.deleteDataBlock!()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func newSnAction() {
        if self.newNumTF.isEnabled{
            let scanVC = ScanActionViewController()
            scanVC.scanResultBlock = {[weak self] (result) in
                self?.newNumTF.text = result
            }
            self.navigationController?.pushViewController(scanVC, animated: true)
        }
    }
    
    @IBAction func oldSnAction() {
        let scanVC = ScanActionViewController()
        scanVC.scanResultBlock = {[weak self] (result) in
            self?.oldNumTF.text = result
        }
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
}
