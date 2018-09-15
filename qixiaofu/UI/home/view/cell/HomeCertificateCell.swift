//
//  HomeCertificateCell.swift
//  qixiaofu
//
//  Created by ly on 2017/6/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class HomeCertificateCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    
//    var jsonModel : JSON = [] {
//        didSet{
//            self.iconImgV.kf.setImage(with: URL(string:jsonModel["member_avatar"].stringValue))
//            self.nameLbl.text = jsonModel["member_truename"].stringValue
//            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: jsonModel["time"].stringValue)
//            let level = jsonModel["stars"].stringValue.floatValue
//            let star = StarLevelView.init(frame: CGRect(x:0, y:0, width:120, height:20), level: level)
//            self.starView.addSubview(star)
//            self.contentLbl.text = jsonModel["content"].stringValue
//            
//            _ = self.contentLbl.resizeHeight()
//            
//        }
//    }
//
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
