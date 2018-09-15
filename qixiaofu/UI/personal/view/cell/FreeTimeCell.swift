//
//  FreeTimeCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/9.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class FreeTimeCell: UITableViewCell {
    @IBOutlet weak var sTimeLbl: UILabel!
    @IBOutlet weak var eTimeLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    
    var subJson : JSON = []{
        didSet{
            self.sTimeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["service_stime"].stringValue)
            self.eTimeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["service_etime"].stringValue)
            
            var arrM : Array<String> = Array<String>()
            for sub in subJson["tack_arrays"].arrayValue {
                arrM.append(sub["address"].stringValue)
            }
            self.areaLbl.text = arrM.joined(separator: ",")
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self
    }
}
