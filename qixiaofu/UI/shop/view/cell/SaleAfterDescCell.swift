//
//  SaleAfterDescCell.swift
//  qixiaofu
//
//  Created by ly on 2018/4/4.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class SaleAfterDescCell: UITableViewCell {
    @IBOutlet weak var playBtn: UIButton!
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.playBtn.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func playAction() {
        //包装视频
        let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
        videoPlayVC.videoId = "31"
        self.parentVC.navigationController?.pushViewController(videoPlayVC, animated: true)
    }
    
}
