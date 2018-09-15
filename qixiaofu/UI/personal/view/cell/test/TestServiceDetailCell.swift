//
//  TestServiceDetailCell.swift
//  qixiaofu
//
//  Created by ly on 2018/2/6.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestServiceDetailCell: UITableViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var imgVW: NSLayoutConstraint!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var checkTitleLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var pnLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var btnViewH: NSLayoutConstraint!
    @IBOutlet weak var bottomDis: NSLayoutConstraint!
    @IBOutlet weak var multiScrollView: UIScrollView!
    @IBOutlet weak var multiScrollViewH: NSLayoutConstraint!
    
    var parentVC = UIViewController()
    var state = "0"//audit_status 订单状态  0：待审核  1：待支付 2：订单取消 3：测试中 4:测试完成 5:审核失败 6：商家待收货 7:待发货 8:客户待收货 9:订单完成 10：订单删除 11：代卖中  12：寄回
//    is_audio   值为1 代表可代卖   2代表不可用  不可代卖   为空不用管
    var deleteSingleBlock : (() -> Void)?
    var refreBlock : (() -> Void)?
    var backOwnerBlock : (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var subJson : JSON = []{
        didSet{
            if subJson["order_photo"].arrayValue.count > 0{
                if subJson["order_photo"].arrayValue.count == 1{
                    self.imgV.setImageUrlStr(subJson["order_photo"].arrayValue[0].stringValue)
                    self.multiScrollView.isHidden = true
                    self.multiScrollViewH.constant = 0
                    self.imgVW.constant = 50
                }else{
                    self.multiScrollView.isHidden = false
                    self.multiScrollViewH.constant = 50
                    self.imgVW.constant = 0
                    let imgW = 50
                    let merge = 5
                    for i in 0...subJson["order_photo"].arrayValue.count - 1 {
                        let subStr = subJson["order_photo"].arrayValue[i].stringValue
                        let imgV = UIImageView(frame:CGRect.init(x: (imgW + merge) * i, y: 0, width: imgW, height: imgW))
                        imgV.setImageUrlStr(subStr)
                        self.multiScrollView.addSubview(imgV)
                    }
                    self.multiScrollView.contentSize = CGSize.init(width: (imgW + merge) * subJson["order_photo"].arrayValue.count, height: imgW)
                }
            }
            
            self.nameLbl.text = subJson["name"].stringValue
            self.snLbl.text = "SN:" + subJson["determinand_sn"].stringValue
            self.pnLbl.text = "PN:" + subJson["determinand_pn"].stringValue
            var money : CGFloat = 0
            if subJson["choice_type"].stringValue.intValue == 1{
                money += CGFloat(subJson["test_price"].stringValue.floatValue)
            }else{
//                money += CGFloat(subJson["test_price"].stringValue.floatValue)
                money += CGFloat(subJson["package_price"].stringValue.floatValue)
            }
            self.priceLbl.text = "¥" + String.init(format: "%.2f", money)
            if subJson["audit_reason"].stringValue.isEmpty{
                self.checkTitleLbl.text = ""
                self.typeLbl.text = ""
            }else{
                self.checkTitleLbl.text = "审核说明:"
                self.typeLbl.text = subJson["audit_reason"].stringValue
            }
            
            
            self.btn1.isHidden = true
            self.btn2.isHidden = true
            self.btn3.isHidden = true
            self.btn1.setTitle("", for: .normal)
            self.btn2.setTitle("", for: .normal)
            self.btn3.setTitle("", for: .normal)
            self.btnViewH.constant = 36
            self.state = subJson["audit_status"].stringValue
            switch self.state.intValue {
            case 0:
                //待审核
                self.stateLbl.text = "待审核"
                self.setTitle(title: "删除", btn: self.btn3)
            case 1:
                //待支付
                self.stateLbl.text = "待支付"
                self.setTitle(title: "删除", btn: self.btn3)
            case 2:
                //订单取消
                self.stateLbl.text = "已取消"
                self.setTitle(title: "删除", btn: self.btn3)
            case 3:
                //测试中
                self.stateLbl.text = "测试中"
                self.setTitle(title: "我们将有2-5日的测试时间", btn: self.btn3)
            case 4:
                //测试完成
                if self.subJson["is_audio"].intValue == 2{
                    self.stateLbl.text = "备件损坏"
                    self.setTitle(title: "寄回", btn: self.btn1)
                }else{
                    self.stateLbl.text = "测试完成"
                    self.setTitle(title: "代卖", btn: self.btn3)
                    self.setTitle(title: "寄回", btn: self.btn1)
                }
                self.setTitle(title: "查看测报", btn: self.btn2)
            case 5:
                //审核失败
                self.stateLbl.text = "审核失败"
                self.setTitle(title: "删除", btn: self.btn3)
            case 6:
                //商家待收货
                self.stateLbl.text = "商家待收货"
//                self.setTitle(title: "查看物流", btn: self.btn3)
                self.btnViewH.constant = 0
            case 7:
                //待收货
                self.stateLbl.text = "待发货"
//                self.setTitle(title: "去发货", btn: self.btn3)
                self.btnViewH.constant = 0
            case 8:
                //待收货
                self.stateLbl.text = ""
                self.setTitle(title: "查看测报", btn: self.btn2)
            case 9:
            //订单完成
                self.stateLbl.text = "完成"
                self.setTitle(title: "删除", btn: self.btn1)
                self.setTitle(title: "查看测报", btn: self.btn2)
            case 10:
                //订单删除
                self.stateLbl.text = "已删除"
            case 11:
                //代卖中
                self.stateLbl.text = "代卖中"
                self.setTitle(title: "查看测报", btn: self.btn2)
            case 12:
                //寄回
                self.stateLbl.text = "商家待发货"
                self.setTitle(title: "查看测报", btn: self.btn2)
            default:
                //
                print("我去，这是什么")
            }
        }
    }
    
    func setTitle(title : String, btn : UIButton) {
        btn.isHidden = false
        btn.setTitle(title, for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn1Action() {
        switch self.state.intValue {
        case 0:
            //待审核
            print("我去，竟然点击出效果了")
        case 1:
            //待支付
            print("我去，竟然点击出效果了")
        case 2:
            //订单取消
            print("我去，竟然点击出效果了")
        case 3:
            //测试中
            print("我去，竟然点击出效果了")
        case 4:
            //测试完成
            self.backToOwner()
        case 5:
            //审核失败
            print("我去，竟然点击出效果了")
        case 6:
            //商家待收货
            print("我去，竟然点击出效果了")
        case 7:
            //待发货
            print("我去，竟然点击出效果了")
        case 8:
            //待收货
            print("我去，竟然点击出效果了")
        case 9:
            //订单完成
            self.deleteOrderSingle()
        default:
            //
            print("我去，这是什么")
        }
    }
    
    @IBAction func btn2Action() {
        switch self.state.intValue {
        case 0:
            //待审核
            print("我去，竟然点击出效果了")
        case 1:
            //待支付
            print("我去，竟然点击出效果了")
        case 2:
            //订单取消
            print("我去，竟然点击出效果了")
        case 3:
            //测试中
            print("我去，竟然点击出效果了")
        case 4:
            //测试完成
            self.goSeetestResult()
        case 5:
            //审核失败
            print("我去，竟然点击出效果了")
        case 6:
            //商家待收货
            print("我去，竟然点击出效果了")
        case 7:
            //待发货
            print("我去，竟然点击出效果了")
        case 8:
            //待收货
            self.goSeetestResult()
        case 9:
            //订单完成
            self.goSeetestResult()
        case 11:
            //代卖中
            self.goSeetestResult()
        case 12:
            //寄回
            self.goSeetestResult()
        default:
            //
            print("我去，这是什么")
        }
    }
    
    @IBAction func btn3Action() {
        switch self.state.intValue {
        case 0:
            //待审核
            self.deleteOrderSingle()
        case 1:
            //待支付
            self.deleteOrderSingle()
        case 2:
            //订单取消
            self.deleteOrderSingle()
        case 3:
            //测试中
            print("我们将有2-5日的测试时间")
        case 4:
            //测试完成
            //代卖
            let sealPriceVC = TestSealPriceViewController.spwan()
            sealPriceVC.subJson = self.subJson
            sealPriceVC.refreshBlock = {() in
                if self.refreBlock != nil{
                    self.refreBlock!()
                }
            }
            sealPriceVC.goodsId = self.subJson["id"].stringValue
            self.parentVC.navigationController?.pushViewController(sealPriceVC, animated: true)
        case 5:
            //审核失败
            self.deleteOrderSingle()
        case 6:
            //商家待收货
            print("我去，竟然点击出效果了")
        case 7:
            //待发货
            print("我去，竟然点击出效果了")
        case 8:
            //待收货
            print("我去，竟然点击出效果了")

        case 9:
            //订单完成
            print("我去，竟然点击出效果了")
        case 11:
            //代卖中
            print("我去，这是什么")
        case 12:
            //寄回
            print("我去，这是什么")
        default:
            //
            print("我去，这是什么")
        }
    }
    
    
    //删除订单中的一个
    func deleteOrderSingle() {
        LYAlertView.show("提示", "是否删除此单，删除后不可找回", "取消", "删除",{
            if self.deleteSingleBlock != nil{
                self.deleteSingleBlock!()
            }
        })
    }
    
    //查看测报
    func goSeetestResult() {
        let testResultVC = TestResultViewController.spwan()
        testResultVC.subJson = self.subJson
        testResultVC.refreBlock = {() in
            if self.refreBlock != nil{
                self.refreBlock!()
            }
        }
        self.parentVC.navigationController?.pushViewController(testResultVC, animated: true)
    }
    
    //寄回
    func backToOwner() {
        LYAlertView.show("提示", "是否将此备件寄回，寄回后不负责代卖", "取消", "寄回",{
            if self.backOwnerBlock != nil{
                self.backOwnerBlock!()
            }
        })
    }
}
