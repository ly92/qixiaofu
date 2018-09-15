//
//  PayWalletCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/24.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class PayWalletCell: UITableViewCell {

    @IBOutlet weak var moneyLbl: UILabel!
    
    @IBOutlet weak var walletSwitch: UISwitch!
    
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
