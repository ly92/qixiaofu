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
        jobDetailVC.isEng = true
        jobDetailVC.jobId = self.subJson["id"].stringValue
        self.parentVC.navigationController?.pushViewController(jobDetailVC, animated: true)
    }
    
    @IBAction func chatAction() {
        //联系招聘官
        
        func chat(){
            //TODO
            DispatchQueue.main.async {
            esmobChat(self.parentVC, self.subJson["job_phone"].stringValue, 2, self.subJson["job_member_name"].stringValue, self.subJson["job_avatar"].stringValue)
            }
        }
        
        var params : [String : Any] = [:]
        params["jobid"] = self.subJson["id"].stringValue
        params["identity"] = "1"
        NetTools.requestData(type: .post, urlString: JobChatApi, parameters: params, succeed: { (resultJson, msg) in
            chat()
        }, failure: { (error) in
        })
        
    }
    
    
    var subJson = JSON(){
        didSet{
            self.jobNameLbl.text = subJson["job_name"].stringValue + "(" + (subJson["nature"].stringValue.intValue == 1 ? "内部招聘" : "外派驻场") + ")"
            self.stateLbl.text = subJson["status"].stringValue.intValue == 1 ? "招聘中" : "已暂停"
            self.priceLbl.text = subJson["salary_low"].stringValue + "~" + subJson["salary_heigh"].stringValue + "K"
            self.addressLbl.text = subJson["area_info"].stringValue
            self.iconImgV.setImageUrlStr(subJson["job_avatar"].stringValue)
            self.recruiterLbl.text = subJson["job_member_name"].stringValue
        }
    }
}
