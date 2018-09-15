//
//  HomeTaskListCell.swift
//  qixiaofu
//
//  Created by ly on 2017/6/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeTaskListCell: UITableViewCell {
    @IBOutlet weak var subView: UIView!

    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var topBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var taskNameLbl: UILabel!
    @IBOutlet weak var serverRangeLbl: UILabel!
    @IBOutlet weak var serverTimeLbl: UILabel!
    @IBOutlet weak var serverAreaLbl: UILabel!
    @IBOutlet weak var serverPriceLbl: UILabel!
    @IBOutlet weak var visitLbl: UILabel!
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    
    var jsonModel : JSON = [] {
        didSet{
            self.iconImgV.setHeadImageUrlStr(jsonModel["bill_user_avatar"].stringValue)
            self.nameLbl.text = jsonModel["bill_user_name"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: jsonModel["inputtime"].stringValue)
            self.taskNameLbl.text = jsonModel["entry_name"].stringValue
            self.serverRangeLbl.text = jsonModel["title"].stringValue
            self.serverTimeLbl.text = Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: jsonModel["service_stime"].stringValue) + "-" + Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: jsonModel["service_etime"].stringValue)
            self.serverAreaLbl.text = jsonModel["service_city"].stringValue
            self.serverPriceLbl.text = "¥" + jsonModel["service_price"].stringValue
            if jsonModel["is_top"].stringValue.intValue > 0{
                self.topBtn.isHidden = false
            }else{
                self.topBtn.isHidden = true
            }
            
            self.visitLbl.text = jsonModel["visit_count"].stringValue + "浏览"
            
            if jsonModel["bill_statu"].stringValue.intValue == 1{
                self.nameLbl.textColor = UIColor.RGBS(s: 33)
                self.timeLbl.textColor = UIColor.RGBS(s: 33)
                self.taskNameLbl.textColor = UIColor.RGBS(s: 33)
                self.serverRangeLbl.textColor = UIColor.RGBS(s: 33)
                self.serverTimeLbl.textColor = UIColor.RGBS(s: 33)
                self.serverAreaLbl.textColor = UIColor.RGBS(s: 33)
                self.serverPriceLbl.textColor = UIColor.RGBS(s: 33)
                self.serverPriceLbl.textColor = Normal_Color
                
                self.lbl1.textColor = UIColor.RGBS(s: 33)
                self.lbl2.textColor = UIColor.RGBS(s: 33)
                self.lbl3.textColor = UIColor.RGBS(s: 33)
                self.lbl4.textColor = UIColor.RGBS(s: 33)
                self.lbl5.textColor = UIColor.RGBS(s: 33)
                
            }else{
                self.nameLbl.textColor = UIColor.RGBS(s: 150)
                self.timeLbl.textColor = UIColor.RGBS(s: 150)
                self.taskNameLbl.textColor = UIColor.RGBS(s: 150)
                self.serverRangeLbl.textColor = UIColor.RGBS(s: 150)
                self.serverTimeLbl.textColor = UIColor.RGBS(s: 150)
                self.serverAreaLbl.textColor = UIColor.RGBS(s: 150)
                self.serverPriceLbl.textColor = UIColor.RGBS(s: 150)
                self.serverPriceLbl.textColor = UIColor.RGBS(s: 150)
                
                self.lbl1.textColor = UIColor.RGBS(s: 150)
                self.lbl2.textColor = UIColor.RGBS(s: 150)
                self.lbl3.textColor = UIColor.RGBS(s: 150)
                self.lbl4.textColor = UIColor.RGBS(s: 150)
                self.lbl5.textColor = UIColor.RGBS(s: 150)
            }
            
            //价格为0的不显示价格
            if jsonModel["service_price"].stringValue.floatValue > 0{
                self.lbl5.isHidden = false
                self.serverPriceLbl.isHidden = false
            }else{
                self.lbl5.isHidden = true
                self.serverPriceLbl.isHidden = true
            }
            
            self.stateLbl.text = "已报名"
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.subView.layer.cornerRadius = 5
        self.iconImgV.layer.cornerRadius = 12.5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
/**
 {
 "listData" : [
 {
 "id" : "717",
 "entry_name" : "IBM 2000",
 "bill_user_id" : "986",
 "bill_user_name" : "听说这里有只哈",
 "is_top" : 0,
 "service_etime" : 1500105600,
 "inputtime" : 1499790339,
 "bill_statu" : "2",
 "service_stime" : 1499760000,
 "title" : "UNIX服务器",
 "service_city" : "东莞市",
 "bill_user_avatar" : "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-06-14\/~UPLOAD~sys~2017-06-14@1497380473.jpg240",
 "service_price" : "100.00"
 },
 {
 "id" : "700",
 "entry_name" : "咨询服务测试",
 "bill_user_id" : "990",
 "bill_user_name" : "西红柿炒蛋",
 "is_top" : 0,
 "service_etime" : 1500094800,
 "inputtime" : 1499688179,
 "bill_statu" : "2",
 "service_stime" : 1499655600,
 "title" : "UNIX服务器,X86服务器,存储设备,网络交换设备,监控设备,虚拟化",
 "service_city" : "东莞市",
 "bill_user_avatar" : "http:\/\/10.216.2.11\/data\/upload\/shop\/common\/default_user_portrait.gif",
 "service_price" : "10.00"
 },
 {
 "id" : "686",
 "entry_name" : "测试一下滴哦",
 "bill_user_id" : "986",
 "bill_user_name" : "听说这里有只哈",
 "is_top" : 0,
 "service_etime" : 1500019200,
 "inputtime" : 1499444275,
 "bill_statu" : "2",
 "service_stime" : 1499414400,
 "title" : "UNIX服务器,X86服务器,存储设备,网络交换设备,监控设备,虚拟化,桌面设备,数据库,安全设备,其他设备",
 "service_city" : "成都市",
 "bill_user_avatar" : "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-06-14\/~UPLOAD~sys~2017-06-14@1497380473.jpg240",
 "service_price" : "10.00"
 }
 ],
 "repMsg" : "",
 "repCode" : "00"
 }
 */
