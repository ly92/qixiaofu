//
//  BeanCell.swift
//  qixiaofu
//
//  Created by ly on 2017/12/18.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class BeanCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var numLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var subJson : JSON = []{
        didSet{
            self.nameLbl.text = subJson["fu_type"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["fu_time"].stringValue)
            
            var fu_num = subJson["fu_num"].stringValue.trim
            if fu_num.hasPrefix("+"){
                self.numLbl.textColor = UIColor.colorHex(hex: "f65d2f")
            }else{
                self.numLbl.textColor = UIColor.colorHex(hex: "1cc262")
            }
            let fir = String(fu_num.removeFirst())
            self.numLbl.text = fir + String.init(format: "%d", fu_num.intValue)
        }
    }
    /**
     {
     "is_sz" : "0",
     "fu_id" : "48",
     "fu_num" : "+1.00",
     "fu_userid" : "1014",
     "fu_type" : "培训",
     "fu_time" : "1513240525"
     },
     */
    
}
