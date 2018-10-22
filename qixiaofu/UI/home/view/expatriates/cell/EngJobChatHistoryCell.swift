//
//  EngJobChatHistoryCell.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class EngJobChatHistoryCell: UITableViewCell {
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var recruiterLbl: UILabel!
    
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func jobDetail() {
        let jobDetailVC = JobDetailViewController.spwan()
        jobDetailVC.idType = 1
        self.parentVC.navigationController?.pushViewController(jobDetailVC, animated: true)
    }
    
    @IBAction func chatAction() {
    }
    
}
