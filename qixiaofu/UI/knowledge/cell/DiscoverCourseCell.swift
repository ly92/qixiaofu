//
//  DiscoverCourseCell.swift
//  qixiaofu
//
//  Created by ly on 2017/12/11.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class DiscoverCourseCell: UITableViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    fileprivate var gradientLayer : CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgV.layer.cornerRadius = 8
        self.addCoverImage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //lession_enroll_state 0: 什么都不显示   1： 已报名  2：已结束
    var subJson : JSON = []{
        didSet{
            self.imgV.setImageUrlStrAndPlaceholderImg(subJson["lession_img"].stringValue, #imageLiteral(resourceName: "course_cover"))
            self.titleLbl.text = subJson["lession_name"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: subJson["lession_start_time"].stringValue)
            let status = subJson["lession_enroll_state"].stringValue.intValue
            if status == 1{
                self.statusLbl.text = "已报名 " + subJson["lession_num"].stringValue + "个"
            }else if status == 2{
                self.statusLbl.text = "已结束"
            }else{
                self.statusLbl.text = ""
            }
        }
    }
    
    var courseJson : JSON = []{
        didSet{
            self.imgV.setImageUrlStrAndPlaceholderImg(courseJson["img"].stringValue, #imageLiteral(resourceName: "course_cover"))
            self.titleLbl.text = courseJson["name"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: courseJson["start_time"].stringValue)
            
            let isEnd = courseJson["is_end"].stringValue.intValue
            let isSign = courseJson["is_sign"].stringValue.intValue
            if isEnd == 1{
                self.statusLbl.text = "已结束"
            }else{
                if isSign == 1{
                    self.statusLbl.text = "已报名 " + courseJson["count"].stringValue + "个"
                }else{
                    self.statusLbl.text = ""
                }
            }
            
        }
    }
    
    func addCoverImage() {
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.colors = [UIColor.clear.cgColor,UIColor.black.withAlphaComponent(0.3).cgColor,UIColor.black.withAlphaComponent(0.5).cgColor]
        self.gradientLayer!.frame = CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: (kScreenW - 16) / 2.0)
        self.gradientLayer!.startPoint = CGPoint.zero
        self.gradientLayer!.endPoint = CGPoint.init(x: 0, y: 1)
        self.imgV.layer.addSublayer(self.gradientLayer!)
    }
}
