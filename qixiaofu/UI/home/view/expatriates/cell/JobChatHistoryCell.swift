//
//  JobChatHistoryCell.swift
//  qixiaofu
//
//  Created by ly on 2018/10/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class JobChatHistoryCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var engIcon: UIImageView!
    @IBOutlet weak var engNameLbl: UILabel!
    @IBOutlet weak var engTypeLbl: UILabel!
    
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func engDetail() {
        let preResumeVC = EngResumeViewController.spwan()
        self.parentVC.navigationController?.pushViewController(preResumeVC, animated: true)
    }
    
    @IBAction func engChat() {
         print("联系工程师")
        var params : [String : Any] = [:]
        params["jobid"] = self.subJson["id"].stringValue
        params["identity"] = "2"
        params["engineer_id"] = self.subJson["member_id"].stringValue
        NetTools.requestData(type: .get, urlString: JobChatApi, parameters: params, succeed: { (resultJson, msg) in
        }, failure: { (error) in
        })
    }
    
    @IBAction func jobDetail() {
        let jobDetailVC = JobDetailViewController.spwan()
//        jobDetailVC.jobId = self.su
        jobDetailVC.idType = 2
        self.parentVC.navigationController?.pushViewController(jobDetailVC, animated: true)
    }
    
    
    var subJson = JSON(){
        didSet{
            self.nameLbl.text = subJson["type_name"].stringValue + "(" + (subJson["nature"].stringValue.intValue == 1 ? "内部招聘" : "外派驻场") + ")"
            self.addressLbl.text = subJson["area_info"].stringValue
            self.priceLbl.text = subJson["salary_low"].stringValue + "~" + subJson["salary_heigh"].stringValue
            self.engIcon.setImageUrlStr(subJson["member_avatar"].stringValue)
            self.engNameLbl.text = subJson["member_name"].stringValue
            self.engTypeLbl.text = subJson["type_name"].stringValue
        }
    }
}
