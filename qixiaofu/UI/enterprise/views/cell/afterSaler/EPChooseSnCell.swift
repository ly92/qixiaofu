//
//  EPChooseSnCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class EPChooseSnCell: UITableViewCell {

    @IBOutlet weak var selectImgV: UIImageView!
    @IBOutlet weak var imgVW: NSLayoutConstraint!
    @IBOutlet weak var snLbl: UILabel!
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
