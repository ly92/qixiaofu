//
//  EngineerInvetoryCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/19.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngineerInvetoryCell: UITableViewCell {

    var subJson : JSON = [] {
        didSet{
            self.imgV.setImageUrlStr(subJson["member_avatar"].stringValue)
            self.nameLbl.text = subJson["call_nik_name"].stringValue
            self.inventoryLbl.text = "库存数量：" + subJson["count"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: subJson["time"].stringValue)
        }
    }
    
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var inventoryLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgV.layer.cornerRadius = 22.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
