//
//  EPAfterSalerDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPAfterSalerDetailViewController: BaseViewController {
    class func spwan() -> EPAfterSalerDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPAfterSalerDetailViewController
    }
    
    
    var orderId = ""
    var refreshBlock : (() -> Void)?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    fileprivate var detailJson = JSON()
    fileprivate var imgViewH : CGFloat = 0
    fileprivate var photoBrowseView = LYPhotoBrowseView.init(frame: CGRect())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "售后详情"
        
        self.tableView.register(UINib.init(nibName: "EPAfterSalerDetailStateCell", bundle: Bundle.main), forCellReuseIdentifier: "EPAfterSalerDetailStateCell")
        self.tableView.register(UINib.init(nibName: "EPAfterSalerDetailDescCell", bundle: Bundle.main), forCellReuseIdentifier: "EPAfterSalerDetailDescCell")
        self.tableView.register(UINib.init(nibName: "EPAfterSalerMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "EPAfterSalerMessageCell")
        self.tableView.register(UINib.init(nibName: "EPAfterSalerPictureCell", bundle: Bundle.main), forCellReuseIdentifier: "EPAfterSalerPictureCell")
        self.tableView.register(UINib.init(nibName: "EPAfterSalerDetailGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "EPAfterSalerDetailGoodsCell")
        
        
        self.photoBrowseView = LYPhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: 50), superVC: self)
        self.photoBrowseView.heightBlock = { (height) in
            self.imgViewH = height
            self.tableView.reloadData()
        }
        self.photoBrowseView.showDeleteBtn = false
        self.photoBrowseView.canTakePhoto = false
        
        self.loadDetailData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //售后详情数据
    func loadDetailData() {
        LYProgressHUD.showLoading()
        var params : [String : Any] = [:]
        params["return_id"] = self.orderId
        NetTools.requestData(type: .post, urlString: EPExchangeDetailApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.detailJson = resultJson
            self.resetBtn()
            
            var arrM : Array<String> = []
            for json in resultJson["return_img"].arrayValue{
                arrM.append(json.stringValue)
            }
            if arrM.count > 0{
                self.photoBrowseView.showImgUrlArray = arrM
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取信息失败！")
        }
    }
    
    
    func resetBtn() {
        
        self.rightBtn.isHidden = true
        self.leftBtn.isHidden = true
        
        //1 审核中  2 审核通过 3 审核不通过 4 商家待收货  5 商家已收货  6 完成 7 取消 8 删除
        let state = self.detailJson["return_state"].stringValue.intValue
        switch state {
        case 1:
            //审核中
            self.setBtnTitle(self.rightBtn, "取消")
        case 2:
            //审核通过
            self.setBtnTitle(self.rightBtn, "去发货")
            self.setBtnTitle(self.leftBtn, "取消")
        case 3:
            //审核不通过
            self.setBtnTitle(self.rightBtn, "删除")
        case 4:
            //商家待收货
            self.setBtnTitle(self.rightBtn, "查看物流")
        case 5:
            //商家已收货
            print("这个是什么")
        case 6:
            //完成
            self.setBtnTitle(self.rightBtn, "删除")
        case 7:
            //取消
            self.setBtnTitle(self.rightBtn, "删除")
        default:
            print("这个是什么")
        }
        
    }
    
    func setBtnTitle(_ btn : UIButton, _ title : String) {
        btn.setTitle(title, for: .normal)
        btn.isHidden = false
    }
    
    
    
    @IBAction func leftBtnAction() {
        let state = self.detailJson["return_state"].stringValue.intValue
        switch state {
        case 2:
            //审核通过
            self.cancelAction()
        default:
            print("这个是什么")
        }
    }
    
    
    @IBAction func rightBtnAction() {
        let state = self.detailJson["return_state"].stringValue.intValue
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
            print("这个是什么")
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
            params["return_id"] = self.orderId
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
            params["return_id"] = self.orderId
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
        logisticsVC.orderId = self.orderId
        logisticsVC.isEPExchange = true
        logisticsVC.logisticsNumberSuccessBlock = {() in
            //刷新列表的通知
            if self.refreshBlock != nil{
                self.refreshBlock!()
            }
        }
        self.navigationController?.pushViewController(logisticsVC, animated: true)
    }
    
    //查看物流
    func logisticsAction() {
        var  arr : Array<String> = []
        for json in self.detailJson["logistics_num"].arrayValue{
            arr.append(json.stringValue)
        }
        if arr.count == 1{
            let logisticsVC = LogisticsInfoViewController()
            logisticsVC.number = arr[0]
            self.navigationController?.pushViewController(logisticsVC, animated: true)
        }else if arr.count > 1{
            LYPickerView.show(titles: arr) { (message, index) in
                let logisticsVC = LogisticsInfoViewController()
                logisticsVC.number = message
                self.navigationController?.pushViewController(logisticsVC, animated: true)
            }
        }
    }
    
    
    
}



extension EPAfterSalerDetailViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            //单号
            return 4
        }else if section == 1{
            //商品信息
            return 1
        }else if section == 2{
            //售后进度
            return 1
        }else if section == 3{
            //审核留言
            if self.detailJson["audit_reason"].stringValue.isEmpty{
                return 0
            }
            return 1
        }else if section == 4{
            //描述
            if self.detailJson["leave_words"].stringValue.isEmpty{
                return 0
            }
            return 1
        }else if section == 5{
            //图片
            if self.detailJson["return_img"].arrayValue.count > 0{
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            //单号
            let cell = tableView.dequeueReusableCell(withIdentifier: "EPAfterSalerDetailDescCell", for: indexPath) as! EPAfterSalerDetailDescCell
            
            cell.descLbl.textColor = UIColor.darkGray
            if indexPath.row == 0{
                //售后类型
                cell.titleLbl.text = "售后类型: "
                if self.detailJson["type"].stringValue.intValue == 1{
                    cell.descLbl.text = "退货"
                }else{
                    cell.descLbl.text = "换货"
                }
                cell.descLbl.textColor = Normal_Color
                
            }else if indexPath.row == 1{
                //申请时间
                cell.titleLbl.text = "申请时间: "
                cell.descLbl.text = Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: self.detailJson["time"].stringValue)
            }else if indexPath.row == 2{
                //售后单号
                cell.titleLbl.text = "售后单号: "
                cell.descLbl.text = self.detailJson["return_no"].stringValue
            }else if indexPath.row == 3{
                //原订单号
                cell.titleLbl.text = "原订单号: "
                cell.descLbl.text = self.detailJson["order_number"].stringValue
            }
            return cell
        }else if indexPath.section == 1{
            //商品信息
            let cell = tableView.dequeueReusableCell(withIdentifier: "EPAfterSalerDetailGoodsCell", for: indexPath) as! EPAfterSalerDetailGoodsCell
            cell.orderJson = self.detailJson
            return cell
        }else if indexPath.section == 2{
            //售后进度
            let cell = tableView.dequeueReusableCell(withIdentifier: "EPAfterSalerDetailStateCell", for: indexPath) as! EPAfterSalerDetailStateCell
            cell.orderJson = self.detailJson
            return cell
        }else if indexPath.section == 3{
            //审核留言
            let cell = tableView.dequeueReusableCell(withIdentifier: "EPAfterSalerMessageCell", for: indexPath) as! EPAfterSalerMessageCell
            cell.titleLbl.text = "审核留言: "
            cell.descLbl.text = self.detailJson["audit_reason"].stringValue
            return cell
        }else if indexPath.section == 4{
            //描述
            let cell = tableView.dequeueReusableCell(withIdentifier: "EPAfterSalerMessageCell", for: indexPath) as! EPAfterSalerMessageCell
            cell.titleLbl.text = "问题描述: "
            cell.descLbl.text = self.detailJson["leave_words"].stringValue
            return cell
        }else if indexPath.section == 5{
            //图片
            let cell = tableView.dequeueReusableCell(withIdentifier: "EPAfterSalerPictureCell", for: indexPath) as! EPAfterSalerPictureCell
            for view in cell.imgsView.subviews{
                view.removeFromSuperview()
            }
            cell.imgsView.addSubview(photoBrowseView)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            //单号
            return 20
        }else if indexPath.section == 1{
            //商品信息
            var num = 0
            for goods in self.detailJson["goods"].arrayValue{
                num += goods["snprice"].arrayValue.count
            }
            let tableH = self.detailJson["goods"].arrayValue.count * 50 + num * 30
            return CGFloat(70 + tableH)
        }else if indexPath.section == 2{
            //售后进度
            let return_state = self.detailJson["return_state"].stringValue.intValue
            //1 审核中  2 审核通过 3 审核不通过 4 商家待收货  5 商家已收货  6 完成 7 取消 8 删除
            if return_state == 2{
                return 210
            }else if return_state == 5{
                return 155
            }
            return 135
        }else if indexPath.section == 3{
            //审核留言
            let message = self.detailJson["audit_reason"].stringValue
            let size = message.sizeFit(width: kScreenW - 16, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height > 30{
                return 50 + size.height
            }
            return 80
        }else if indexPath.section == 4{
            //描述
            let message = self.detailJson["leave_words"].stringValue
            let size = message.sizeFit(width: kScreenW - 16, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height > 30{
                return 50 + size.height
            }
            return 80
        }else if indexPath.section == 5{
            //图片
            return self.imgViewH + 16
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(self.tableView, numberOfRowsInSection: section) > 0{
            return 8
        }else{
            return 0.0001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
}
