//
//  EngJobChatHistoryCell.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngJobChatHistoryCell: UITableViewCell {
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var recruiterLbl: UILabel!
    
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func jobDetail() {
        let jobDetailVC = JobDetailViewController.spwan()
        jobDetailVC.idType = 1
        jobDetailVC.jobId = self.subJson["id"].stringValue
        self.parentVC.navigationController?.pushViewController(jobDetailVC, animated: true)
    }
    
    @IBAction func chatAction() {
        //联系招聘官
        esmobChat(self.parentVC, self.subJson["mobile"].stringValue, 2, self.subJson["member_name"].stringValue, self.subJson["member_avatar"].stringValue)
        
        var params : [String : Any] = [:]
        params["jobid"] = self.subJson["id"].stringValue
        params["identity"] = "1"
        NetTools.requestData(type: .get, urlString: JobChatApi, parameters: params, succeed: { (resultJson, msg) in
        }, failure: { (error) in
        })
        
    }
    
    
    var subJson = JSON(){
        didSet{
            self.jobNameLbl.text = subJson["type_name"].stringValue + "(" + (subJson["nature"].stringValue.intValue == 1 ? "内部招聘" : "外派驻场") + ")"
            self.stateLbl.text = subJson["status"].stringValue.intValue == 1 ? "招聘中" : "已暂停"
            self.priceLbl.text = subJson["salary_low"].stringValue + "~" + subJson["salary_heigh"].stringValue
            self.addressLbl.text = subJson["area_info"].stringValue
            self.iconImgV.setImageUrlStr(subJson["member_avatar"].stringValue)
            self.recruiterLbl.text = subJson["member_name"].stringValue
        }
    }
}
