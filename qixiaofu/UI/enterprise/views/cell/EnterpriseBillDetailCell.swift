//
//  EnterpriseBillDetailCell.swift
//  qixiaofu
//
//  Created by ly on 2018/4/18.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnterpriseBillDetailCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var numLbl: UILabel!
    @IBOutlet weak var titleLblLeftDis: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var subJson = JSON(){
        didSet{
            self.titleLblLeftDis.constant = 15
            self.titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            self.titleLbl.text = subJson["goods_name"].stringValue
            self.priceLbl.text = "¥" + subJson["goods_price"].stringValue
            self.numLbl.text = "X" + subJson["goods_num"].stringValue
        }
    }
    
    var returnJson = JSON(){
        didSet{
            self.titleLblLeftDis.constant = 20
            self.titleLbl.font = UIFont.systemFont(ofSize: 12.0)
            self.titleLbl.text = returnJson["goods_name"].stringValue
            self.priceLbl.text = "¥" + returnJson["goods_price"].stringValue
            self.numLbl.text = "X" + returnJson["goods_num"].stringValue
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
