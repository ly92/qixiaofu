//
//  EnterpriseManagerAccountCell.swift
//  qixiaofu
//
//  Created by ly on 2018/4/18.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnterpriseManagerAccountCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameAlignDis: NSLayoutConstraint!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteBtnW: NSLayoutConstraint!
    @IBOutlet weak var noticeBtn: UIButton!
    
    var operationBlock : ((Int) -> Void)?//11:设置为主账户 22:编辑 33:禁用
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.phoneLbl.addTapActionBlock {
            let phone = self.subJson["user_tel"].stringValue
            if phone.isEmpty{
                LYProgressHUD.showError("手机号为空！")
            }else{
                UIApplication.shared.openURL(URL(string: "telprompt:" + phone)!)
            }
        }
        
    }
    
    var subJson = JSON(){
        didSet{
            self.nameLbl.text = subJson["user_name"].stringValue
            self.phoneLbl.text = subJson["user_tel"].stringValue
            if subJson["parent_id"].stringValue == "0"{
                self.typeLbl.text = "主账户"
                self.setBtn.isHidden = true
                self.deleteBtn.isHidden = true
                self.deleteBtnW.constant = 0
                self.nameAlignDis.constant = 0
                self.noticeBtn.isHidden = false
            }else{
                self.typeLbl.text = "子账户"
                self.setBtn.isHidden = false
                self.deleteBtn.isHidden = false
                self.noticeBtn.isHidden = true
                self.deleteBtnW.constant = 55
                self.nameAlignDis.constant = -8
                
                if subJson["is_real"].stringValue.intValue != 1{
                    self.setBtn.setTitle("未实名认证", for: .normal)
                    self.setBtn.isEnabled = false
                }else{
                    self.setBtn.setTitle("设置为主账户", for: .normal)
                    self.setBtn.isEnabled = true
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func noticeAction() {
        let dict1 = ["title" : "主账户", "desc" : "主账户为企业账户的管理者账户，对子账户拥有添加以及禁用权限，也可设置某子账户为主账户，在账单列表中可查看所有子账户的账单 "]
        let dict2 = ["title" : "子账户", "desc" : "主账户添加的账户，只可查看自己的账单 "]
        NoticeView.showWithText("提示",[dict1,dict2])
    }
    
    
    
    @IBAction func btnAction(_ btn: UIButton) {
        if self.operationBlock != nil{
            self.operationBlock!(btn.tag)
        }
//        if btn.tag == 11{
//            //设置为主账户
//
//        }else if btn.tag == 22{
//            //编辑
//
//        }else if btn.tag == 33{
//            //禁用
//
//        }
    }
}
