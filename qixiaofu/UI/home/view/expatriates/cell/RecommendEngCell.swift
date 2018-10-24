//
//  RecommendEngCell.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class RecommendEngCell: UITableViewCell {

    @IBOutlet weak var engIconImgV: UIImageView!
    @IBOutlet weak var engNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var engJobLbl: UILabel!
    @IBOutlet weak var chatStateLbl: UILabel!
    
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func engDetail() {
        let preResumeVC = EngResumeViewController.spwan()
        self.parentVC.navigationController?.pushViewController(preResumeVC, animated: true)
    }
    @IBAction func chatEng() {
        print("联系工程师")
    }
    
}
