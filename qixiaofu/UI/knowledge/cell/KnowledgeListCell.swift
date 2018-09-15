//
//  KnowledgeListCell.swift
//  qixiaofu
//
//  Created by ly on 2017/9/5.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class KnowledgeListCell: UITableViewCell {

    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var titileLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var preiseLbl: UILabel!
    
    var subJson : JSON = []{
        didSet{
            self.iconImgV.setHeadImageUrlStr(subJson["user_avatar"].stringValue)
            self.nameLbl.text = subJson["nik_name"].stringValue
            
            self.titileLbl.text = subJson["post_title"].stringValue
            self.contentLbl.text = subJson["post_content"].stringValue
            self.preiseLbl.text = subJson["upvote_num"].stringValue + "赞" + "   " + subJson["viewnum"].stringValue + "浏览"
            
            
            func splitLength(preStr : String) -> String{
                var str = preStr
                if str.count > 10{
                    str.removeLast()
                    return splitLength(preStr: str)
                }
                return str
            }
            if Double(splitLength(preStr: subJson["input_time"].stringValue)) != nil{
                let date = Date(timeIntervalSince1970: Double(splitLength(preStr: subJson["input_time"].stringValue))!)
                if (date.isYesterday()){
                    self.timeLbl.text = "昨天" + Date.dateStringFromDate(format: Date.timeFormatString(), timeStamps: subJson["input_time"].stringValue)
                }else if date.isToday(){
                    if date.hourssBeforeDate(aDate: Date()) > 0{
                        self.timeLbl.text = "\(date.hourssBeforeDate(aDate: Date()))" + "小时前"
                    }else if date.minutesBeforeDate(aDate: Date()) > 0{
                        self.timeLbl.text = "\(date.minutesBeforeDate(aDate: Date()))" + "分钟前"
                    }else{
                        self.timeLbl.text = "刚刚"
                    }
                }else{
                    self.timeLbl.text = Date.dateStringFromDate(format: Date.datePointFormatString(), timeStamps: subJson["input_time"].stringValue)
                }
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImgV.layer.cornerRadius = 15
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

/**
 {
 "input_time" : "1504111791",
 "user_avatar" : "http:\/\/www.7xiaofu.com\/UPLOAD\/sys\/2017-08-31\/~UPLOAD~sys~2017-08-31@1503575033.jpg",
 "post_id" : "39",
 "type_id" : "94",
 "post_title" : "02E7",
 "nik_name" : "七小服",
 "brand" : null,
 "post_content" : "Explanation: Configuration method unable to determine if the SCSI adapter type is SE or DE type.",
 "upvote_num" : "0"
 },
 */
