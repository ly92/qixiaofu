//
//  ShopOrderStateCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/14.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopOrderStateCell: UITableViewCell {
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var bottomDis: NSLayoutConstraint!


    fileprivate var timer = Timer()//待支付计时器
    fileprivate var codeTime : Int = 0
    
    var subJson : JSON = []{
        didSet{
            
            self.stateLbl.textAlignment = .right
            self.stateLbl.textColor = Normal_Color
            self.rightArrow.isHidden = true
            self.bottomDis.constant = 0
            
            self.timer.invalidate()
            
            switch subJson["state_type"].stringValue.intValue {
            case 0:
                self.stateLbl.text = "已取消"
            case 1:
                self.stateLbl.text = "待支付"
                self.codeTime = subJson["order_end_time"].stringValue.intValue
                self.setUpCodeTimer()
            case 2:
                self.stateLbl.text = "待发货"
            case 3:
                self.stateLbl.text = "待收货"
            case 4:
                self.stateLbl.text = "已收货"
            case 5:
                self.stateLbl.text = "已完成"
            case 6:
                self.stateLbl.text = "退换货中"
                switch subJson["return_step_state"].stringValue.intValue {
                case 1:
                    if subJson["refund_type"].stringValue.intValue == 1{
                        self.stateLbl.text = "退货审核中"
                    }else{
                        self.stateLbl.text = "换货审核中"
                    }
                case 2:
                    if subJson["refund_type"].stringValue.intValue == 1{
                        self.stateLbl.text = "退货审核通过"
                    }else{
                        self.stateLbl.text = "换货审核通过"
                    }
                case 3:
                    if subJson["refund_type"].stringValue.intValue == 1{
                        self.stateLbl.text = "商家拒绝退货"
                    }else{
                        self.stateLbl.text = "商家拒绝换货"
                    }
                case 4:
                    self.stateLbl.text = "等待商家收货"
                case 5:
                    if subJson["refund_type"].stringValue.intValue == 1{
                        self.stateLbl.text = "退货完成"
                    }else{
                        self.stateLbl.text = "换货待收货"
                    }
                case 6:
                    if subJson["refund_type"].stringValue.intValue == 1{
                        self.stateLbl.text = "退货完成"
                    }else{
                        self.stateLbl.text = "换货已收货"
                    }
                default:
                    print("这又是个啥-state")
                }
            case 21:
                self.stateLbl.text = "取消订单退款中"
            default:
                print("这是个啥-state")
            }
        }
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
            let minute = self.codeTime / 60
            let second = self.codeTime % 60
            self.stateLbl.text = "待支付 " + "\(minute)" + ":" + "\(second)"
            self.codeTime -= 1
        }else{
            //            //刷新数据
            //            if self.refreshBlock != nil{
            //                self.refreshBlock!()
            //            }
            self.stateLbl.text = "超时取消"
            self.timer.invalidate()
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
    
}
