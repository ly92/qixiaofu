//
//  EPShopOrderDetailChatCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/3.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPShopOrderDetailChatCell: UITableViewCell {
    @IBOutlet weak var totalMoneyLbl: UILabel!
    @IBOutlet weak var couponMoneyLbl: UILabel!
    @IBOutlet weak var actualMoneyLbl: UILabel!
    @IBOutlet weak var payTypeLbl: UILabel!
    
    
    
    var parentVC = UIViewController()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //订单状态  0全部  1待支付   2待发货   3待收货  4已完成 5已取消
    var subJson = JSON(){
        didSet{
            self.totalMoneyLbl.text = "¥" + subJson["order_price"].stringValue
            self.couponMoneyLbl.text = "-¥" + subJson["coupon_price"].stringValue
            self.actualMoneyLbl.text = "¥" + subJson["total_amount"].stringValue
            if subJson["pay_type"].stringValue.isEmpty{
                self.payTypeLbl.text = "未知"
            }else{
                self.payTypeLbl.text = subJson["pay_type"].stringValue
            }
            
        }
    }

    
    @IBAction func chatAction() {
        //登录环信
        esmobLogin()
        let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
        self.parentVC.navigationController?.pushViewController(chatVC!, animated: true)
    }
    
}
