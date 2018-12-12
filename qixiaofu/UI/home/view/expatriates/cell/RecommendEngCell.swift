//
//  RecommendEngCell.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class RecommendEngCell: UITableViewCell {

    @IBOutlet weak var engIconImgV: UIImageView!
    @IBOutlet weak var engNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var engJobLbl: UILabel!
    @IBOutlet weak var chatStateLbl: UILabel!
    
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
        preResumeVC.engId = self.subJson["member_id"].stringValue
        self.parentVC.navigationController?.pushViewController(preResumeVC, animated: true)
    }
    @IBAction func chatEng() {
        print("联系工程师")
        
        func chat(){
            DispatchQueue.main.async {
            esmobChat(self.parentVC, self.subJson["phone"].stringValue, 2, self.subJson["member_name"].stringValue, self.subJson["member_avatar"].stringValue)
            }
        }
        
        var params : [String : Any] = [:]
        params["jobid"] = self.subJson["id"].stringValue
        params["identity"] = "2"
        params["engineer_id"] = self.subJson["member_id"].stringValue
        NetTools.requestData(type: .post, urlString: JobChatApi, parameters: params, succeed: { (resultJson, msg) in
            chat()
        }, failure: { (error) in
        })
    }
    
    
    var subJson = JSON(){
        didSet{
            self.engIconImgV.setImageUrlStr(subJson["member_avatar"].stringValue)
            self.engNameLbl.text = subJson["member_name"].stringValue
            self.priceLbl.text = subJson["salary_low"].stringValue + "~" + subJson["salary_heigh"].stringValue
            self.engJobLbl.text = subJson["type_name"].stringValue
            self.chatStateLbl.text = subJson["status"].stringValue.intValue == 1 ? "" : ""
        }
    }
    
}
