//
//  EngineerReplyCell.swift
//  qixiaofu
//
//  Created by ly on 2017/6/27.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngineerReplyCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!

    var jsonModel : JSON = [] {
        didSet{
            let json = jsonModel["reply_list"].arrayValue[0] as JSON
            
            self.iconImgV.setHeadImageUrlStr(json["member_avatar"].stringValue)
            self.nameLbl.text = json["member_truename"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: json["time"].stringValue)
            self.contentLbl.text = json["content"].stringValue
            let _ = self.contentLbl.resizeHeight()
            
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.iconImgV.layer.cornerRadius = 12.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

/**
 {
 content = "完成",
 time = "1496915412",
 eval_id = "113",
 member_truename = "12",
 member_id = "1009",
 member_avatar = "http://10.216.2.11/UPLOAD/sys/2017-06-12/~UPLOAD~sys~2017-06-12@1497274993.jpg240",
 stars = "5",
 reply_list = 	(
 {
 member_truename = "16",
 member_avatar = "http://10.216.2.11/UPLOAD/sys/2017-06-06/~UPLOAD~sys~2017-06-06@1496757625.jpg240",
 member_id = "1005",
 content = "测试你的时候才来后悔没买的是什么鬼？测试你的时候我们就要多注意休息？测试你的心是一个测试看看你自己不知道怎么着吧嗒掉落物品保险柜？测试你的心都碎了一个月就有多美瘦身的功效？测试你的心在一起就会！测试结果的事情？测试你的心是最棒的确是不是么么哒。测试结果是好是在我心里是最大限度减少到目前的情况下",
 time = "1498553710",
 },
 ),
 },
 */
