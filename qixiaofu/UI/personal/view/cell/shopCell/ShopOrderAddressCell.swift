//
//  ShopOrderAddressCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/15.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class ShopOrderAddressCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
