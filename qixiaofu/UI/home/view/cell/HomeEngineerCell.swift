//
//  HomeEngineerCell.swift
//  qixiaofu
//
//  Created by ly on 2017/6/26.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias HomeEngineerCellBlock = () -> Void

class HomeEngineerCell: UITableViewCell {

    var selectedCellBlock : HomeEngineerCellBlock?
    
    
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var serverRangeLbl: UILabel!
    @IBOutlet weak var serverTimeLbl: UILabel!
    @IBOutlet weak var serverAreaLbl: UILabel!
    @IBOutlet weak var serverExperienceLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var levelImgV1: UIImageView!
    @IBOutlet weak var levelImgV2: UIImageView!
    @IBOutlet weak var levelImageV3: UIImageView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var levelLblLeftDis: NSLayoutConstraint!
    
    var jsonModel : JSON = [] {
        didSet{
            self.iconImgV.setHeadImageUrlStr(jsonModel["member_avatar"].stringValue)
            self.nameLbl.text = jsonModel["member_nik_name"].stringValue
            
            let timeStr = Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: jsonModel["service_stime"].stringValue) + "-" + Date.dateStringFromDate(format: Date.dateChineseFormatString(), timeStamps: jsonModel["service_etime"].stringValue)
            if timeStr == "-"{
            self.serverTimeLbl.text = "未设置"
            }else{
                self.serverTimeLbl.text = timeStr
            }
            
           
            if jsonModel["service_sector"] != JSON.null{
                var serverRangeArr : Array<String> = Array<String>()
                for sub in jsonModel["service_sector"].arrayValue {
                    serverRangeArr.append(sub.stringValue)
                }
                self.serverRangeLbl.text = serverRangeArr.joined(separator: ",")
            }else{
                self.serverRangeLbl.text = "未设置"
            }
            
            
            var serverAreaArr : Array<String> = Array<String>()
            for sub in jsonModel["tack_citys"].arrayValue {
                serverAreaArr.append(sub.stringValue)
            }
            self.serverAreaLbl.text = serverAreaArr.joined(separator: ",")
            
            self.serverExperienceLbl.text = jsonModel["working_year"].stringValue + "年"
            
            let level = jsonModel["dengji"].stringValue
            UIImageView.setLevelImageView(imgV1: self.levelImgV1, imgV2: self.levelImgV2, imgV3: self.levelImageV3, level: level)
            self.levelLbl.text = level + "级"
            if level.intValue % 3 == 0{
                self.levelLblLeftDis.constant = CGFloat( 5 + 3 * 18)
            }else{
                self.levelLblLeftDis.constant = CGFloat( 5 + (level.intValue % 3) * 18)
            }
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.subView.layer.cornerRadius = 5
        self.iconImgV.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectAction() {
        if (self.selectedCellBlock != nil){
            selectedCellBlock!()
        }
    }
    
}

/**
 {
 "listData" : [
 {
 "member_nik_name" : "964",
 "service_sector" : [
 "UNIX服务器",
 "X86服务器",
 "存储设备",
 "网络交换设备"
 ],
 "member_name" : "15613026165",
 "working_year" : 3,
 "member_truename" : "964",
 "tack_citys" : [
 ""
 ],
 "member_id" : "964",
 "member_avatar" : "http:\/\/www.7xiaofu.com\/data\/upload\/shop\/common\/default_user_portrait.gif",
 "service_stime" : "0",
 "service_etime" : "0"
 },
 {
 "member_nik_name" : "绿豆汤",
 "service_sector" : [
 "UNIX服务器",
 "X86服务器",
 "存储设备",
 "网络交换设备",
 "UNIX服务器",
 "X86服务器",
 "存储设备",
 "桌面设备"
 ],
 "member_name" : "18210209011",
 "working_year" : 2,
 "member_truename" : "绿豆汤",
 "tack_citys" : [
 ""
 ],
 "member_id" : "965",
 "member_avatar" : "http:\/\/www.7xiaofu.com\/UPLOAD\/sys\/2017-03-07\/~UPLOAD~sys~2017-03-07@1488864242.jpg240",
 "service_stime" : "0",
 "service_etime" : "0"
 }
 ],
 "repMsg" : "",
 "repCode" : "00"
 }
 */
