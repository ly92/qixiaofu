//
//  ShopOrderMessageCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/15.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class ShopOrderMessageCell: UITableViewCell {
    @IBOutlet weak var numLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var payWayLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
