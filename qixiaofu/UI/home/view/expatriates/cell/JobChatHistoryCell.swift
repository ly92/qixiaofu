//
//  JobChatHistoryCell.swift
//  qixiaofu
//
//  Created by ly on 2018/10/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class JobChatHistoryCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var engIcon: UIImageView!
    @IBOutlet weak var engNameLbl: UILabel!
    @IBOutlet weak var engTypeLbl: UILabel!
    
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
    
    @IBAction func engChat() {
         print("联系工程师")
    }
    
    @IBAction func jobDetail() {
        let jobDetailVC = JobDetailViewController.spwan()
        jobDetailVC.idType = 2
        self.parentVC.navigationController?.pushViewController(jobDetailVC, animated: true)
    }
    
}
