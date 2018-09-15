//
//  HomeCollectionViewCell.swift
//  qixiaofu
//
//  Created by ly on 2017/6/19.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var redPointView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.redPointView.layer.cornerRadius = 4
    }

}
