//
//  TestServiceOrderCell.swift
//  qixiaofu
//
//  Created by ly on 2018/2/5.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestServiceOrderCell: UITableViewCell {
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var singleView: UIView!
    @IBOutlet weak var singleImgV: UIImageView!
    @IBOutlet weak var singleNameLbl: UILabel!
    @IBOutlet weak var multiView: UIView!
    @IBOutlet weak var multiScrollView: UIScrollView!
    @IBOutlet weak var goodsCountLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var pnLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    
    var parentVC = UIViewController()
    fileprivate var timer = Timer()//待支付计时器
    fileprivate var codeTime : Int = 0
    
    //order_state 订单状态  0：待审核  1：待支付 2：订单取消 3：测试中 4:测试完成 5:审核失败 6：商家待收货 7:待发货 8:客户待收货 9:订单完成
    var subJson : JSON = []{
        didSet{
            for view in self.multiScrollView.subviews{
                view.removeFromSuperview()
            }
            //首先判断显示的类型
            if subJson["order_photo"].arrayValue.count > 1{
                self.singleView.isHidden = true
                self.multiView.isHidden = false
                let imgW = 50
                let merge = 5
                for i in 0...subJson["order_photo"].arrayValue.count - 1 {
                    let subStr = subJson["order_photo"].arrayValue[i].stringValue
                    let imgV = UIImageView(frame:CGRect.init(x: (imgW + merge) * i, y: 0, width: imgW, height: imgW))
                    imgV.setImageUrlStr(subStr)
                    self.multiScrollView.addSubview(imgV)
                }
                self.multiScrollView.contentSize = CGSize.init(width: (imgW + merge) * subJson["order_photo"].arrayValue.count, height: imgW)
            }else{
                self.singleView.isHidden = false
                self.multiView.isHidden = true
                
                if subJson["order_photo"].arrayValue.count > 0{
                    self.singleImgV.setImageUrlStr(subJson["order_photo"].arrayValue[0].stringValue)
                }
                self.singleNameLbl.text = subJson["name"].stringValue
                self.snLbl.text = "SN:" + subJson["determinand_sn"].stringValue
                self.pnLbl.text = "PN:" + subJson["determinand_pn"].stringValue
            }
            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: subJson["order_time"].stringValue)
            self.goodsCountLbl.text = "共" + subJson["goods_num"].stringValue + "件商品"
            self.moneyLbl.text = "订单金额:" + subJson["order_price"].stringValue
            
            //            self.stateLbl.text = ""
            let state = subJson["order_state"].stringValue
            switch state.intValue {
            case 0:
                //待审核
                self.stateLbl.text = "待审核"
            case 1:
                //待支付
                self.stateLbl.text = "待支付"
            case 2:
                //订单取消
                self.stateLbl.text = "已取消"
            case 3:
                //测试中
                self.stateLbl.text = "测试中"
            case 4:
                //测试完成
                self.stateLbl.text = "测试完成"
            case 5:
                //审核失败
                self.stateLbl.text = "审核失败"
            case 6:
                //商家待收货
                self.stateLbl.text = "商家待收货"
            case 7:
                //待发货
                self.stateLbl.text = "待发货"
            case 8:
                //待收货
                self.stateLbl.text = "待收货"
            case 9:
                //订单完成
                self.stateLbl.text = "完成"
            default:
                //
                self.stateLbl.text = ""
            }
        }
    }
    
    //代卖状态 (1已代卖完成   2代卖取消  3代卖中 0不代卖 4代卖删除 5 代卖待审核 6代卖审核不通过)  传空值为全部
    var sealJson : JSON = []{
        didSet{
            for view in self.multiScrollView.subviews{
                view.removeFromSuperview()
            }
            //首先判断显示的类型
            //            if subJson["order_photo"].arrayValue.count > 1{
            //                self.singleView.isHidden = true
            //                self.multiView.isHidden = false
            //                let imgW = 50
            //                let merge = 5
            //                for i in 0...subJson["order_photo"].arrayValue.count - 1 {
            //                    let subStr = subJson["order_photo"].arrayValue[i].stringValue
            //                    let imgV = UIImageView(frame:CGRect.init(x: (imgW + merge) * i, y: 0, width: imgW, height: imgW))
            //                    imgV.setImageUrlStr(subStr)
            //                    self.multiScrollView.addSubview(imgV)
            //                }
            //                self.multiScrollView.contentSize = CGSize.init(width: (imgW + merge) * subJson["order_photo"].arrayValue.count, height: imgW)
            //            }else{
            self.singleView.isHidden = false
            self.multiView.isHidden = true
            
            //                if subJson["order_photo"].arrayValue.count > 0{
            self.singleImgV.setImageUrlStr(sealJson["determinand_photo"].stringValue)
            //                }
            self.singleNameLbl.text = sealJson["goods_name"].stringValue
            self.pnLbl.text = "PN:" + sealJson["determinand_pn"].stringValue
            self.snLbl.text = "SN:" + sealJson["determinand_sn"].stringValue
            //            }
            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: sealJson["order_time"].stringValue)
            self.moneyLbl.text = "¥" + sealJson["consignment_price"].stringValue
            
            //代卖状态 (1已代卖完成   2代卖取消  3代卖中 0不代卖 4代卖删除 5 代卖待审核 6代卖审核不通过) 8:代卖已退货  传空值为全部
            let state = sealJson["stuff_state"].stringValue
            switch state.intValue {
                //            case 0:
                //                //待审核
            //                self.stateLbl.text = "待审核"
            case 1:
                //完成
                if sealJson["is_aftersale"].intValue == 1{
                    self.stateLbl.text = "售后待解决"
                }else{
                    self.stateLbl.text = "完成"
                }
            case 2:
                //已取消
                self.stateLbl.text = "已取消"
            case 3:
                //代卖中
                self.stateLbl.text = "代卖中"
                //            case 4:
                //                //测试完成
            //                self.stateLbl.text = "测试完成"
            case 5:
                //待审核
                self.stateLbl.text = "待审核"
            case 6:
                //代卖审核不通过
                self.stateLbl.text = "审核不通过"
            case 8:
                //代卖已退货
                self.stateLbl.text = "代卖已退货"
            default:
                //
                print("我去，这是什么")
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.multiScrollView.addTapActionBlock {
            let orderDetailVC = TestOrderDetailViewController.spwan()
            orderDetailVC.orderId = self.subJson["id"].stringValue
            orderDetailVC.state = self.subJson["order_state"].stringValue
            self.parentVC.navigationController?.pushViewController(orderDetailVC, animated: true)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
