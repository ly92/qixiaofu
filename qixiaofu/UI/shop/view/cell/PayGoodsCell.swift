//
//  PayGoodsCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/24.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class PayGoodsCell: UITableViewCell {

    @IBOutlet weak var goodsNameLbl: UILabel!
    @IBOutlet weak var goodsIcon: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
