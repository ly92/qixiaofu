//
//  ShopInventoryCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class ShopInventoryCell: UITableViewCell {
    @IBOutlet weak var shopInventoryLbl: UILabel!
    @IBOutlet weak var engineerInventoryLbl: UILabel!
    @IBOutlet weak var engineerLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
