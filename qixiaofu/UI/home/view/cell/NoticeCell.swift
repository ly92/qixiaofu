//
//  NoticeCell.swift
//  qixiaofu
//
//  Created by ly on 2018/1/12.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class NoticeCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
