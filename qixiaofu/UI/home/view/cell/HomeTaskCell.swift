//
//  HomeTaskCell.swift
//  qixiaofu
//
//  Created by ly on 2018/3/20.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class HomeTaskCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
