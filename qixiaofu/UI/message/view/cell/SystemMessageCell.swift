//
//  SystemMessageCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/16.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SystemMessageCell: UITableViewCell {
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var selecteBtn: UIButton!
    @IBOutlet weak var detailImgV: UIImageView!
    
    var isEP = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.subView.layer.cornerRadius = 6
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    var subJson : JSON = []{
        didSet{
            func splitLength(preStr : String) -> String{
                var str = preStr
                if str.count > 10{
                    str.removeLast()
                    return splitLength(preStr: str)
                }
                return str
            }
            self.descLbl.text = subJson["message_body"].stringValue
            
            var time = ""
            if subJson["message_time"].stringValue.isEmpty{
                time = subJson["input_time"].stringValue
            }else{
                time = subJson["message_time"].stringValue
            }
            
            if Double(splitLength(preStr: time)) != nil{
                let date  = Date(timeIntervalSince1970: Double(splitLength(preStr: time))!)
                if (date.isYesterday()){
                    self.timeLbl.text = "昨天" + Date.dateStringFromDate(format: Date.timeFormatString(), timeStamps: time)
                }else if date.isToday(){
                    self.timeLbl.text = Date.dateStringFromDate(format: Date.timeFormatString(), timeStamps: time)
                }else{
                    self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: time)
                }
            }
            
            var readType = 0
            if subJson["message_open"].stringValue.isEmpty{
                readType = subJson["is_read"].stringValue.intValue
            }else{
                readType = subJson["message_open"].stringValue.intValue
            }
            //判断是否已读
            if readType == 1{
                self.titleLbl.textColor = UIColor.RGBS(s: 120)
                self.descLbl.textColor = UIColor.RGBS(s: 120)
            }else{
                self.titleLbl.textColor = UIColor.RGBS(s: 33)
                self.descLbl.textColor = UIColor.RGBS(s: 33)
            }
            
            //是否可跳转详情
            if subJson["jump_type"].stringValue.intValue > 0{
                self.detailImgV.isHidden = false
            }else{
                self.detailImgV.isHidden = true
                if subJson["is_read"].stringValue.intValue == 0{
                    //标示已读
                    if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                        if subJson["is_read"].stringValue.intValue == 0{
                            var params : [String : Any] = [:]
                            params["id"] = subJson["id"].stringValue
                            NetTools.requestData(type: .post, urlString: EPMessageReadApi, parameters: params, succeed: { (result, msg) in
                                self.titleLbl.textColor = UIColor.RGBS(s: 120)
                                self.descLbl.textColor = UIColor.RGBS(s: 120)
                            }, failure: { (error) in
                            })
                        }
                    }else{
                        if subJson["message_open"].stringValue.intValue == 0{
                            var params : [String : Any] = [:]
                            params["store_id"] = "1";
                            params["message_id"] = subJson["message_id"].stringValue
                            NetTools.requestData(type: .post, urlString: MessageDetaileApi, parameters: params, succeed: { (result, msg) in
                                self.titleLbl.textColor = UIColor.RGBS(s: 120)
                                self.descLbl.textColor = UIColor.RGBS(s: 120)
                            }, failure: { (error) in
                            })
                        }
                    }
                    
                }
            }
        }
    }
    
}
