//
//  SysMessageCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/16.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class SysMessageCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var unReadNumLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.iconImgV.layer.cornerRadius = 22.5
        self.unReadNumLbl.layer.cornerRadius = 7.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
