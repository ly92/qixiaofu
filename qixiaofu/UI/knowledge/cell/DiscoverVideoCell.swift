//
//  DiscoverVideoCell.swift
//  qixiaofu
//
//  Created by ly on 2017/12/11.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class DiscoverVideoCell: UITableViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    fileprivate var gradientLayer : CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgV.layer.cornerRadius = 8
        self.addCoverImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var subJson : JSON = []{
        didSet{
            self.imgV.setImageUrlStrAndPlaceholderImg(subJson["mv_img"].stringValue, #imageLiteral(resourceName: "course_cover"))
            self.nameLbl.text = subJson["mv_name"].stringValue
            self.descLbl.text = subJson["mv_info"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.dateBiasFormatString(), timeStamps: subJson["mv_time"].stringValue)
        }
    }
    
    
    func addCoverImage() {
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.colors = [UIColor.black.withAlphaComponent(0.3).cgColor,UIColor.black.withAlphaComponent(0.2).cgColor,UIColor.black.withAlphaComponent(0.2).cgColor,UIColor.black.withAlphaComponent(0.4).cgColor]
        self.gradientLayer!.frame = CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: (kScreenW - 16) / 2.0)
        self.gradientLayer!.startPoint = CGPoint.zero
        self.gradientLayer!.endPoint = CGPoint.init(x: 0, y: 1)
        self.imgV.layer.addSublayer(self.gradientLayer!)
    }
    
}

/**
 {
 "mv_img" : "http:\/\/www.7xiaofu.com\/download\/app\/img00E0658.jpg",
 "mv_info" : "刘老师小课堂",
 "mv_sender" : "7小服",
 "mv_headimg" : "http:\/\/www.7xiaofu.com\/UPLOAD\/sys\/2017-08-31\/~UPLOAD~sys~2017-08-31@1503575033.jpg",
 "type_id" : "0",
 "mv_id" : "9",
 "mv_time" : "1512719683",
 "mv_name" : "刘老师小课堂",
 "mv_link" : "http:\/\/www.7xiaofu.com\/download\/app\/mvcf102cf3953c5c88a4791b0a2acd4af8-895.mp4"
 }
 */
