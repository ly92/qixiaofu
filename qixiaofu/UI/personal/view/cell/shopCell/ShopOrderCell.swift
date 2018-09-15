//
//  ShopOrderCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/11.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopOrderCell: UITableViewCell {
    

    @IBOutlet weak var singleView: UIView!
    @IBOutlet weak var singleImgV: UIImageView!
    @IBOutlet weak var singleNameLbl: UILabel!
    @IBOutlet weak var multiView: UIView!
    @IBOutlet weak var multiScrollView: UIScrollView!
    @IBOutlet weak var goodsCountLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    
    var parentVC = UIViewController()
    fileprivate var timer = Timer()//待支付计时器
    fileprivate var codeTime : Int = 0
    
    
    var subJson : JSON = []{
        didSet{
            //首先判断显示的类型
            if subJson["order_list"].arrayValue.count > 1{
                self.singleView.isHidden = true
                self.multiView.isHidden = false
                let imgW = 50
                let merge = 5
                for view in self.multiScrollView.subviews{
                    view.removeFromSuperview()
                }
                for i in 0...subJson["order_list"].arrayValue.count - 1 {
                    let sub = subJson["order_list"].arrayValue[i]
                    let imgV = UIImageView(frame:CGRect.init(x: (imgW + merge) * i, y: 0, width: imgW, height: imgW))
                    imgV.setImageUrlStr(sub["goods_image"].stringValue)
                    self.multiScrollView.addSubview(imgV)
                }
                self.multiScrollView.contentSize = CGSize.init(width: (imgW + merge) * subJson["order_list"].arrayValue.count, height: imgW)
            }else{
                self.singleView.isHidden = false
                self.multiView.isHidden = true
                
                if subJson["order_list"].arrayValue.count > 0{
                    self.singleImgV.setImageUrlStr(subJson["order_list"].arrayValue[0]["goods_image"].stringValue)
                    self.singleNameLbl.text = subJson["order_list"].arrayValue[0]["goods_name"].stringValue
                }
            }
            self.goodsCountLbl.text = "共" + "\(subJson["order_list"].arrayValue.count)" + "件商品"
            self.moneyLbl.text = "订单金额:" + subJson["order_amount"].stringValue
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.multiScrollView.addTapActionBlock { 
            let orderDetailVC = ShopOrderDetailViewController()
            orderDetailVC.orderId = self.subJson["order_id"].stringValue
            self.parentVC.navigationController?.pushViewController(orderDetailVC, animated: true)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
 
}



/**
 {
 "pay_sn" : "110555703480631014",
 "order_id" : "65",
 "order_list" : [
 {
 "goods_id" : "415",
 "order_id" : "65",
 "goods_price" : "3000.00",
 "goods_num" : "1",
 "goods_name" : "EMC CX500控制器 005048505",
 "goods_image" : "http:\/\/10.216.2.11\/data\/upload\/shop\/store\/goods\/1\/1_05435962543364337_240.jpg"
 },
 {
 "goods_id" : "419",
 "order_id" : "65",
 "goods_price" : "4000.00",
 "goods_num" : "1",
 "goods_name" : "IBM DS4700控制器 44X2426",
 "goods_image" : "http:\/\/10.216.2.11\/data\/upload\/shop\/store\/goods\/1\/1_05435979853202994_240.jpg"
 },
 {
 "goods_id" : "424",
 "order_id" : "65",
 "goods_price" : "2200.00",
 "goods_num" : "1",
 "goods_name" : "IBM PC X3650 m4硬盘 49Y2004",
 "goods_image" : "http:\/\/10.216.2.11\/data\/upload\/shop\/store\/goods\/1\/1_05435986030663157_240.jpg"
 },
 {
 "goods_id" : "437",
 "order_id" : "65",
 "goods_price" : "800.00",
 "goods_num" : "1",
 "goods_name" : "NETAPP硬盘 X306A-R5",
 "goods_image" : "http:\/\/10.216.2.11\/data\/upload\/shop\/store\/goods\/1\/1_05530231282775886_240.jpg"
 }
 ],
 "distribution_info" : "送货上门",
 "order_amount" : "10000.00",
 "state_type" : 4,
 "total_goods_num" : 4,
 "order_sn" : "652017081018044001",
 "order_end_time" : "0",
 "fanhui_sn" : null
 },
 {
 "pay_sn" : "520555703426063014",
 "order_id" : "64",
 "order_list" : [
 {
 "goods_id" : "422",
 "order_id" : "64",
 "goods_price" : "1500.00",
 "goods_num" : "2",
 "goods_name" : "IBM PC X系列硬盘 42D0613",
 "goods_image" : "http:\/\/10.216.2.11\/data\/upload\/shop\/store\/goods\/1\/1_05435984126518527_240.jpg"
 }
 ],
 "distribution_info" : "送货上门",
 "order_amount" : "3000.00",
 "state_type" : 3,
 "total_goods_num" : 2,
 "order_sn" : "642017081018034601",
 "order_end_time" : "0",
 "fanhui_sn" : null
 },
 */
