//
//  MyMoneyCell.swift
//  qixiaofu
//
//  Created by ly on 2018/3/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class MyMoneyCell: UITableViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var nextImgV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
