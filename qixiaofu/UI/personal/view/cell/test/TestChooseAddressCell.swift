//
//  TestChooseAddressCell.swift
//  qixiaofu
//
//  Created by ly on 2018/2/7.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestChooseAddressCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var subJson : JSON = [] {
        didSet{
            self.nameLbl.text = subJson["people"].string
            self.phoneLbl.text = subJson["phone"].string
            self.addressLbl.text = subJson["address"].string
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
