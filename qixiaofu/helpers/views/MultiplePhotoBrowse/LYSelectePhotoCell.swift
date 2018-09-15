//
//  LYSelectePhotoCell.swift
//  qixiaofu
//
//  Created by ly on 2017/10/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class LYSelectePhotoCell: UICollectionViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var numLbl: UILabel!
    
    var selecteBlock : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.numLbl.layer.cornerRadius = 10.5
    }

    @IBAction func selecteAction() {
        if self.selecteBlock != nil{
            self.selecteBlock!()
        }
    }
}
