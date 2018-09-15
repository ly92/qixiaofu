//
//  VideoCommentCell.swift
//  qixiaofu
//
//  Created by ly on 2018/1/31.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class VideoCommentCell: UICollectionViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLbl.layer.cornerRadius = 15
    }

}
