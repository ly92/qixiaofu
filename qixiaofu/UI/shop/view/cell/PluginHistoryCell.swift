//
//  PluginHistoryCell.swift
//  qixiaofu
//
//  Created by ly on 2017/10/11.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PluginHistoryCell: UITableViewCell {
    @IBOutlet weak var orderNumBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var stateBtn: UIButton!
    @IBOutlet weak var createTimeLbl: UILabel!
    @IBOutlet weak var payTimeLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    
    var goPayBlock : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var subJson : JSON = []{
        didSet{
            self.orderNumBtn.setTitle(subJson["ordercode"].stringValue, for: .normal)
            self.nameLbl.text = subJson["plugname"].stringValue
            self.createTimeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["creattime"].stringValue)
            self.priceLbl.text = subJson["price"].stringValue
            if subJson["paystatu"].stringValue.intValue == 0{
                self.stateBtn.setTitle("去支付", for: .normal)
            }else{
                self.payTimeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["paytime"].stringValue)
                self.stateBtn.setTitle("已付款", for: .normal)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func copyAction() {
        UIPasteboard.general.string = self.subJson["ordercode"].stringValue
        LYProgressHUD.showSuccess("复制成功！")
    }
    @IBAction func goPayAction() {
        if self.subJson["paystatu"].stringValue.intValue == 0{
            if self.goPayBlock != nil{
                self.goPayBlock!()
            }
        }
    }
    
}
