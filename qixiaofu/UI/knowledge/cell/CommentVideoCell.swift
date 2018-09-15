//
//  CommentVideoCell.swift
//  qixiaofu
//
//  Created by ly on 2018/1/31.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentVideoCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    var subJson : JSON = []{
        didSet{
            self.nameLbl.text = subJson["member_name"].stringValue
            self.iconImgV.setHeadImageUrlStr(subJson["head_photo"].stringValue)
            self.contentLbl.text = subJson["comment_contents"].stringValue
            
            func splitLength(preStr : String) -> String{
                var str = preStr
                if str.count > 10{
                    str.removeLast()
                    return splitLength(preStr: str)
                }
                return str
            }
            let date = Date(timeIntervalSince1970: Double(splitLength(preStr: subJson["comment_time"].stringValue))!)
            if (date.isYesterday()){
                self.timeLbl.text = "昨天" + Date.dateStringFromDate(format: Date.timeFormatString(), timeStamps: subJson["comment_time"].stringValue)
            }else if date.isToday(){
                if date.hourssBeforeDate(aDate: Date()) > 0{
                    self.timeLbl.text = "\(date.hourssBeforeDate(aDate: Date()))" + "小时前"
                }else if date.minutesBeforeDate(aDate: Date()) > 0{
                    self.timeLbl.text = "\(date.minutesBeforeDate(aDate: Date()))" + "分钟前"
                }else{
                    self.timeLbl.text = "刚刚"
                }
            }else{
                self.timeLbl.text = Date.dateStringFromDate(format: Date.datePointFormatString(), timeStamps: subJson["comment_time"].stringValue)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImgV.layer.cornerRadius = 22.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
