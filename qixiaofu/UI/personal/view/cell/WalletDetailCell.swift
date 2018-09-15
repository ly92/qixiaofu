//
//  WalletDetailCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/31.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class WalletDetailCell: UITableViewCell {
    @IBOutlet weak var typeNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!

    var subJson : JSON = []{
        didSet{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self.typeNameLbl.text = subJson["message_type"].stringValue
                self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["lg_add_time"].stringValue)
                self.descLbl.text = subJson["lg_desc"].stringValue
                self.moneyLbl.text = subJson["wallet_av_amount"].stringValue
            }else{
                self.typeNameLbl.text = subJson["title"].stringValue
                self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["time"].stringValue)
                self.descLbl.text = subJson["desc"].stringValue
                self.moneyLbl.text = subJson["price"].stringValue
            }
            
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
    
}
