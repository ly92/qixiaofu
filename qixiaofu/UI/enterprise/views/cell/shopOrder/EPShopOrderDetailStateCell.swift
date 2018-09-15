//
//  EPShopOrderDetailStateCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/3.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPShopOrderDetailStateCell: UITableViewCell {

    @IBOutlet weak var bgImgV: UIImageView!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var stateImgV: UIImageView!
    @IBOutlet weak var stateLblCenter: NSLayoutConstraint!
    @IBOutlet weak var descLbl: UILabel!
    
    fileprivate var timer = Timer()//待支付/待收货计时器
    fileprivate var codeTime : Int = 0
    
    
    //订单状态  0全部  1待支付   2待发货  4已完成 5已取消
    var subJson = JSON(){
        didSet{
            let state = subJson["order_state"].stringValue.intValue
            if state == 1{
                //待支付
                self.stateLbl.text = "等待买家付款"
                self.stateLblCenter.constant = -10
                self.descLbl.isHidden = false
                self.bgImgV.image = #imageLiteral(resourceName: "ep_shoporder_bg_2")
                self.stateImgV.isHidden = true
                
                self.codeTime = subJson["countdown_time"].stringValue.intValue
                self.setUpCodeTimer()
                
            }else if state == 2{
                let shipping_state = subJson["shipping_state"].stringValue.intValue
                if shipping_state == 1{
                    //待发货
                    self.stateLbl.text = "等待卖家发货"
                    self.stateLblCenter.constant = 0
                    self.descLbl.isHidden = true
                    self.bgImgV.image = #imageLiteral(resourceName: "ep_shoporder_bg_1")
                    self.stateImgV.isHidden = false
                    self.stateImgV.image = #imageLiteral(resourceName: "ep_shoporder_icon_2")
                }else if shipping_state == 2{
                    //待收货
                    self.stateLbl.text = "等待买家收货"
                    self.stateLblCenter.constant = -10
                    self.descLbl.isHidden = false
                    self.bgImgV.image = #imageLiteral(resourceName: "ep_shoporder_bg_1")
                    self.stateImgV.isHidden = false
                    self.stateImgV.image = #imageLiteral(resourceName: "ep_shoporder_icon_1")
                    
                    self.codeTime = subJson["countdown_time"].stringValue.intValue
                    self.setUpCodeTimer()
                }else if shipping_state == 3{
                    //部分发货
                    self.stateLbl.text = "卖家已分批发货"
                    self.stateLblCenter.constant = 0
                    self.descLbl.isHidden = true
                    self.bgImgV.image = #imageLiteral(resourceName: "ep_shoporder_bg_1")
                    self.stateImgV.isHidden = false
                    self.stateImgV.image = #imageLiteral(resourceName: "ep_shoporder_icon_2")
                }
            }else if state == 4{
                //已完成
                self.stateLbl.text = "交易已完成"
                self.stateLblCenter.constant = 0
                self.descLbl.isHidden = true
                self.bgImgV.image = #imageLiteral(resourceName: "ep_shoporder_bg_1")
                self.stateImgV.isHidden = false
                self.stateImgV.image = #imageLiteral(resourceName: "ep_shoporder_icon_4")
                
            }else if state == 5{
                //已取消
                self.stateLbl.text = "交易已取消"
                self.stateLblCenter.constant = 0
                self.descLbl.isHidden = true
                self.bgImgV.image = #imageLiteral(resourceName: "ep_shoporder_bg_1")
                self.stateImgV.isHidden = false
                self.stateImgV.image = #imageLiteral(resourceName: "ep_shoporder_icon_3")
                
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    //MARK: - 计时器
    func setUpCodeTimer() {
        if self.timer.isValid{
            self.timer.invalidate()
        }
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(ShopOrderStateCell.changeCodeBtnTitle), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .defaultRunLoopMode)
        timer.fire()
    }
    
    @objc func changeCodeBtnTitle() {
        if self.codeTime > 0{
            let day = self.codeTime / 86400
            let hour = self.codeTime / 3600
            let minute = self.codeTime / 60
            let second = self.codeTime % 60
            let state = subJson["order_state"].stringValue.intValue
            if state == 1{
                self.descLbl.text = "剩\(minute)分\(second)秒" + "自动关闭"
            }else if state == 3{
                self.descLbl.text = "剩\(day)天\(hour)小时\(minute)分" + "自动确认"
            }
            self.codeTime -= 1
        }else{
            self.timer.invalidate()
        }
        
    }
    
}
