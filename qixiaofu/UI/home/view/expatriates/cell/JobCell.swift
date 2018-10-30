//
//  JobCell.swift
//  qixiaofu
//
//  Created by ly on 2018/10/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class JobCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var disTimeLbl: UILabel!
    @IBOutlet weak var actTimeLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var subJson = JSON(){
        didSet{
            self.nameLbl.text = subJson["type_name"].stringValue
            self.addressLbl.text = subJson["area_info"].stringValue
            self.disTimeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: subJson["add_time"].stringValue)
            self.actTimeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: subJson["activity_time"].stringValue)
            self.stateLbl.text = subJson["nature"].stringValue.intValue == 1 ? "招聘中" : "已暂停"
            self.priceLbl.text = subJson["salary_low"].stringValue + "~" + subJson["salary_heigh"].stringValue + "K"
        }
    }
    
}
