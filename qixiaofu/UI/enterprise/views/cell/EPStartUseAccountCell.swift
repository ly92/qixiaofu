//
//  EPStartUseAccountCell.swift
//  qixiaofu
//
//  Created by ly on 2018/4/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPStartUseAccountCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    
    var operationBlock : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var subJson = JSON(){
        didSet{
            self.nameLbl.text = subJson["user_name"].stringValue
            self.phoneLbl.text = subJson["user_tel"].stringValue
        }
    }
    
    @IBAction func startUseAction() {
        if self.operationBlock != nil{
            self.operationBlock!()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
