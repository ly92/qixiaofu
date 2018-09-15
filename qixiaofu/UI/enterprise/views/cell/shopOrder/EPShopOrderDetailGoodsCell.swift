//
//  EPShopOrderDetailGoodsCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/3.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
class EPShopOrderDetailGoodsCell: UITableViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //订单状态  0全部  1待支付   2待发货   3待收货  4已完成 5已取消
    var subJson = JSON(){
        didSet{
            self.imgV.setImageUrlStr(subJson["goods_img"].stringValue)
            self.nameLbl.text = subJson["goods_name"].stringValue
            self.priceLbl.text = "¥" + subJson["goods_price"].stringValue
            self.countLbl.text = "x" + subJson["goods_num"].stringValue
        }
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
