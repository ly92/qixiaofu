
//
//  AssociationCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/9.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias AssociationCellBlock = () -> Void

class AssociationCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var iconLeftDis: NSLayoutConstraint!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var setRemarkBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var arrowBtn: UIButton!

    var rightArrowSelected : AssociationCellBlock?
    var refreshBlock : AssociationCellBlock?
    
    var subJson : JSON = []{
        didSet{
            self.iconImgV.setHeadImageUrlStr(subJson["member_avatar"].stringValue)
            self.nameLbl.text = subJson["member_name"].stringValue
            if subJson["to_user_name"].stringValue.isEmpty{
                self.setRemarkBtn.setTitle("设置备注", for: .normal)
            }else{
                self.setRemarkBtn.setTitle(subJson["to_user_name"].stringValue, for: .normal)
            }
            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["inputtime"].stringValue)
            self.levelLbl.text = "级别:" + subJson["jibie"].stringValue
            
            //判断右侧是否可点击
//            if self.rightArrowSelected == nil{
//                self.arrowBtn.isEnabled = false
//            }else{
//                self.arrowBtn.isEnabled = true
//            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImgV.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func setRemarkAction() {
        let customAlertView = UIAlertView.init(title: "设置备注", message: "请输入要设置的备注名", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "保存")
        customAlertView.alertViewStyle = .plainTextInput
        let nameField = customAlertView.textField(at: 0)
        nameField?.keyboardType = .default
        nameField?.placeholder = "输入"
        customAlertView.show()
    }
    
    @IBAction func rightArrowAction() {
        if self.rightArrowSelected != nil{
            self.rightArrowSelected!()
        }
    }
    
}


extension AssociationCell : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            let nameField = alertView.textField(at: 0)
            guard let name = nameField?.text else{
                LYProgressHUD.showError("请重试！")
                return
            }
            if name.isEmpty{
                LYProgressHUD.showError("不可为空！")
                return
            }
            var params : [String : Any] = [:]
            params["name"] = name
            params["id"] = subJson["member_id"].stringValue
            NetTools.requestData(type: .post, urlString: SetConnectMemberNameApi, parameters: params, succeed: { (result, error) in
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        }
    }
}
