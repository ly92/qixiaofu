//
//  ReplacementPartCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/7.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class ReplacementPartCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self
    }
}
