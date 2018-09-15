//
//  EPAfterSalerCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPAfterSalerCell: UITableViewCell {
    
    var parentVC = UIViewController()
    var refreshBlock : (() -> Void)?
    
    @IBOutlet weak var numLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var singleImgV: UIImageView!
    @IBOutlet weak var singleLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var typeLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    //1 审核中  2 审核通过 3 审核不通过 4 商家待收货  5 商家已收货  6 完成 7 取消 8 删除
    var subJson = JSON(){
        didSet{
            self.numLbl.text = "售后单号：" + subJson["return_no"].stringValue
            if subJson["type"].stringValue.intValue == 1{
                self.typeLbl.text = "退货"
                self.priceLbl.text = "共" + subJson["goods_num"].stringValue + "件商品 退款金额：¥" + subJson["return_price"].stringValue
            }else{
                self.typeLbl.text = "换货"
                self.priceLbl.text = "共" + subJson["goods_num"].stringValue + "件商品"
            }
            
            let imgs = subJson["goods_img"].arrayValue
            if imgs.count == 1{
                self.scrollView.isHidden = true
                self.singleLbl.text = subJson["goods_name"].stringValue
                self.singleImgV.setImageUrlStr(imgs[0].stringValue)
            }else if imgs.count > 1{
                self.scrollView.isHidden = false
                for view in self.scrollView.subviews{
                    view.removeFromSuperview()
                }
                for i in 0...imgs.count - 1{
                    let imgV = UIImageView(frame: CGRect.init(x: i * 52, y: 0, width: 50, height: 50))
                    imgV.setImageUrlStr(imgs[i].stringValue)
                    self.scrollView.addSubview(imgV)
                }
                self.scrollView.contentSize = CGSize.init(width: 50 * imgs.count, height: 50)
            }
            
            self.rightBtn.isHidden = true
            self.leftBtn.isHidden = true
            //1 审核中  2 审核通过 3 审核不通过 4 商家待收货  5 商家已收货  6 完成 7 取消 8 删除
            let state = subJson["return_state"].stringValue.intValue
            switch state {
            case 1:
                //审核中
                self.stateLbl.text = "审核中"
                self.setBtnTitle(self.rightBtn, "取消")
            case 2:
                //审核通过
                self.stateLbl.text = "待发货"
                self.setBtnTitle(self.rightBtn, "去发货")
                self.setBtnTitle(self.leftBtn, "取消")
            case 3:
                //审核不通过
                self.stateLbl.text = "审核失败"
                self.setBtnTitle(self.rightBtn, "删除")
            case 4:
                //商家待收货
                self.stateLbl.text = "商家待收货"
                self.setBtnTitle(self.rightBtn, "查看物流")
            case 5:
                //商家已收货
                self.stateLbl.text = "结算中"
                self.setBtnTitle(self.rightBtn, "查看详情")
            case 6:
                //完成
                self.stateLbl.text = "完成"
                self.setBtnTitle(self.rightBtn, "删除")
            case 7:
                //取消
                self.stateLbl.text = "已取消"
                self.setBtnTitle(self.rightBtn, "删除")
            default:
                print("这个是什么")
            }
            
        }
    }
    
    
    
    func setBtnTitle(_ btn : UIButton, _ title : String) {
        btn.setTitle(title, for: .normal)
        btn.isHidden = false
    }
    
    
    @IBAction func leftBtnAction() {
        let state = subJson["return_state"].stringValue.intValue
        switch state {
        case 2:
            //审核通过
            self.cancelAction()
        default:
            print("这个是什么")
        }
    }
    
    @IBAction func rightBtnAction() {
        let state = subJson["return_state"].stringValue.intValue
        switch state {
        case 1:
            //审核中
            self.cancelAction()
        case 2:
            //审核通过
            self.goLogisticsAction()
        case 3:
            //审核不通过
            self.deleteAction()
        case 4:
            //商家待收货
            self.logisticsAction()
        case 5:
            //商家已收货
            self.detailAction()
        case 6:
            //完成
            self.deleteAction()
        case 7:
            //取消
            self.deleteAction()
        default:
            print("这个是什么")
        }
    }
    
    
    
    //取消操作
    func cancelAction() {
        LYAlertView.show("提示", "确定取消吗？","放弃取消","确定取消",{
            var params : [String : Any] = [:]
            params["return_id"] = self.subJson["return_id"].stringValue
            NetTools.requestData(type: .post, urlString: EPExchangeCancelApi, parameters: params, succeed: { (result, msg) in
                //刷新列表
                LYProgressHUD.showSuccess("操作成功！")
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        })
    }
    
    //删除操作
    func deleteAction() {
        LYAlertView.show("提示", "确定删除吗？删除后不可找回","取消","删除",{
            var params : [String : Any] = [:]
            params["return_id"] = self.subJson["return_id"].stringValue
            NetTools.requestData(type: .post, urlString: EPExchangeDeleteApi, parameters: params, succeed: { (result, msg) in
                //刷新列表
                LYProgressHUD.showSuccess("操作成功！")
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        })
    }
    
    //去发货
    func goLogisticsAction() {
        let logisticsVC = LogisticsNumberViewController.spwan()
        logisticsVC.orderId = self.subJson["return_id"].stringValue
        logisticsVC.isEPExchange = true
        logisticsVC.logisticsNumberSuccessBlock = {() in
            //刷新列表的通知
            if self.refreshBlock != nil{
                self.refreshBlock!()
            }
        }
        self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
    }
    
    //查看物流
    func logisticsAction() {
        var  arr : Array<String> = []
        for json in self.subJson["logistics_num"].arrayValue{
            arr.append(json.stringValue)
        }
        if arr.count == 1{
            let logisticsVC = LogisticsInfoViewController()
            logisticsVC.number = arr[0]
            self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
        }else if arr.count > 1{
            LYPickerView.show(titles: arr) { (message, index) in
                let logisticsVC = LogisticsInfoViewController()
                logisticsVC.number = message
                self.parentVC.navigationController?.pushViewController(logisticsVC, animated: true)
            }
        }
    }
    
    //查看详情
    func detailAction() {
        let detailVC = EPAfterSalerDetailViewController.spwan()
        detailVC.orderId = self.subJson["return_id"].stringValue
        self.parentVC.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
