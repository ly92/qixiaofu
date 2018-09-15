//
//  GoodsFromCell.swift
//  qixiaofu
//
//  Created by ly on 2018/4/4.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class GoodsFromCell: UITableViewCell {

    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var leftLbl: UILabel!
    @IBOutlet weak var rightLbl: UILabel!
    @IBOutlet weak var standLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.rightLbl.layer.cornerRadius = 7.5
        
        self.leftLbl.addTapActionBlock {
            let dict1 = ["title" : "自营", "desc" : "七小服平台自营备件，保修期为1年由平台提供服务"]
            let dict2 = ["title" : "代卖", "desc" : "第三方代卖备件，保修期为1月由第三方提供服务"]
            NoticeView.showWithText("自营/代卖须知",[dict1,dict2])
        }
        self.rightLbl.addTapActionBlock {
            let dict1 = ["title" : "自营", "desc" : "七小服平台自营备件，保修期为1年由平台提供服务"]
            let dict2 = ["title" : "代卖", "desc" : "第三方代卖备件，保修期为1月由第三方提供服务"]
            NoticeView.showWithText("自营/代卖须知",[dict1,dict2])
        }
        
        self.standLbl.addTapActionBlock {
            var arr : Array<Dictionary<String,String>> = []
            for subJson in self.resultJson["standard_list"].arrayValue{
                var dict : Dictionary<String,String> = [:]
                dict["title"] = subJson["name"].stringValue
                dict["desc"] = subJson["content"].stringValue
                arr.append(dict)
            }
            NoticeView.showWithText("成色标准",arr)
        }
    }
    
    var resultJson = JSON(){
        didSet{
            
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                if resultJson["sale_type"].stringValue.intValue == 2{
                    self.leftLbl.text = "代卖"
                }else{
                    self.leftLbl.text = "自营"
                }
            }else{
                if resultJson["goods_info"]["sale_type"].stringValue.intValue == 2{
                    self.leftLbl.text = "代卖"
                }else{
                    self.leftLbl.text = "自营"
                }
            }
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                if resultJson["is_discount"].stringValue.intValue == 1{
                    self.priceLbl.text = ""
                }else{
                    self.priceLbl.text = "¥ " + resultJson["goods_price"].stringValue
                }
            }else{
                if resultJson["goods_info"]["is_discount"].stringValue.intValue == 1{
                    self.priceLbl.text = ""
                }else{
                    self.priceLbl.text = "¥ " + resultJson["goods_info"]["goods_price"].stringValue
                }
            }
            
            self.standLbl.text = resultJson["goods_info"]["chengse"].stringValue
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
