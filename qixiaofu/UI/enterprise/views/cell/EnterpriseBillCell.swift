//
//  EnterpriseBillCell.swift
//  qixiaofu
//
//  Created by ly on 2018/4/18.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnterpriseBillCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var unpaidBillLbl: UILabel!
    @IBOutlet weak var prepaidBillLbl: UILabel!
    @IBOutlet weak var unCircleView: UIView!
    @IBOutlet weak var preCircleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.unCircleView.layer.cornerRadius = 3.5
        self.preCircleView.layer.cornerRadius = 3.5
    }
    
    
    var subJson = JSON(){
        didSet{
            self.nameLbl.text = subJson["user_name"].stringValue
            self.unpaidBillLbl.text = "¥" + subJson["non_checkout_total"].stringValue
            self.prepaidBillLbl.text = "¥" + subJson["account_checkout_total"].stringValue
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
