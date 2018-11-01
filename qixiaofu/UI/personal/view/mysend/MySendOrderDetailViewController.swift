//
//  MySendOrderDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/2.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


class MySendOrderDetailViewController: UITableViewController {
    class func spwan() -> MySendOrderDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! MySendOrderDetailViewController
    }
    
    //刷新列表 1:从列表删除 2:原地刷新 3:从数据库删除（删除，撤销）
    var refreshBlock : ((Int) -> Void)?
    
    var orderId = ""
    var isMyReceive = false
    var moveState = ""
    var enrollNum = "0"
    
    
    @IBOutlet weak var orderNumBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl2: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var enrollNumLbl: UILabel!
    @IBOutlet weak var taskNameLbl: UILabel!
    @IBOutlet weak var serverRangeLbl: UILabel!
    @IBOutlet weak var brandTypeLbl: UILabel!
    @IBOutlet weak var amountUnitLbl: UILabel!
    @IBOutlet weak var serverControlLbl: UILabel!
    @IBOutlet weak var serverTypeLbl: UILabel!
    @IBOutlet weak var serverTimeLbl: UILabel!
    @IBOutlet weak var serverAreaLbl: UILabel!
    @IBOutlet weak var memoLbl: UILabel!
    @IBOutlet weak var serverPriceLbl: UILabel!
    @IBOutlet weak var serverPriceTitleLbl: UILabel!
    @IBOutlet weak var imgsView: UIView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var centerBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var changePriceTF: UITextField!
    @IBOutlet weak var changePriceImgsView: UIView!
    @IBOutlet weak var sureChangePriceBtn: UIButton!
    
    //0915
    @IBOutlet weak var engIcon: UIImageView!
    @IBOutlet weak var engNameLbl: UILabel!
    @IBOutlet weak var levelImgV1: UIImageView!
    @IBOutlet weak var levelImgV2: UIImageView!
    @IBOutlet weak var levelImgV3: UIImageView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var taskNoteImg1: UIImageView!
    @IBOutlet weak var taskNoteImg2: UIImageView!
    @IBOutlet weak var taskNoteImg3: UIImageView!
    @IBOutlet weak var taskNoteImg4: UIImageView!
    @IBOutlet weak var taskNoteImg5: UIImageView!
    @IBOutlet weak var taskNoteView1: UIView!
    @IBOutlet weak var taskNoteView2: UIView!
    @IBOutlet weak var taskNoteView3: UIView!
    @IBOutlet weak var taskNoteView4: UIView!
    @IBOutlet weak var noteView: UIView!
    
    
    fileprivate var projectImgsVH : CGFloat = 0//项目详情中图片高度
    fileprivate var changePriceImgsVH : CGFloat = 0//调价时图片高度
    fileprivate var projectPhotoView = LYPhotoBrowseView.init(frame: CGRect())
    fileprivate var changePricePhotoView = LYMultiplePhotoBrowseView.init(frame: CGRect())
    fileprivate var isChangePrice = false
    
    //修改报价的view
    fileprivate var rechangePriceView = UIView()
    fileprivate var rechargePriceLbl = UILabel()
    fileprivate var rechargeDescLbl = UILabel()
    
    fileprivate var modelJson : JSON = []//详情数据
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sureChangePriceBtn.layer.cornerRadius = 20
        self.iconImgV.layer.cornerRadius = 20
        self.engIcon.layer.cornerRadius = 22.5
        
        self.changePricePhotoView = LYMultiplePhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 10, height: self.changePriceImgsView.h), superVC: self)
        self.changePricePhotoView.maxPhotoNum = 9
        self.changePricePhotoView.delegate = self
        self.changePriceImgsView.addSubview(self.changePricePhotoView)
        self.navigationItem.title = "订单详情"
        //初次加载数据
        if self.isMyReceive{
            self.loadReceiveDetailData()
        }else{
            self.loadSendDetailData()
        }
    }
    
    //修改报价的view
    func prepareRechangePriceView(){
        if self.rechangePriceView.subviews.count > 0{
            return
        }
        self.rechangePriceView = UIView(frame: CGRect.init(x: 0, y: kScreenH-60, width: kScreenW, height: 60))
        self.rechangePriceView.alpha = 1.0
        self.rechangePriceView.backgroundColor = BG_Color
        
        //我的报价
        let imgV1 = UIImageView()
        imgV1.image = #imageLiteral(resourceName: "recharge_offer")
        self.rechargePriceLbl.font = UIFont.systemFont(ofSize: 12.0)
        self.rechargePriceLbl.textColor = Text_Color
        self.rechangePriceView.addSubview(imgV1)
        self.rechangePriceView.addSubview(self.rechargePriceLbl)
        
        //修改报价
        let imgV2 = UIImageView()
        imgV2.image = #imageLiteral(resourceName: "recharge_modify")
        let lbl2 = UILabel()
        lbl2.text = "修改报价"
        lbl2.font = UIFont.systemFont(ofSize: 12)
        lbl2.textColor = Normal_Color
        self.rechangePriceView.addSubview(imgV2)
        self.rechangePriceView.addSubview(lbl2)
        
        //报价机会
        self.rechargeDescLbl.font = UIFont.systemFont(ofSize: 10.0)
        self.rechargeDescLbl.textColor = UIColor.lightGray
        self.rechangePriceView.addSubview(self.rechargeDescLbl)

        
        
        imgV1.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(15)
            make.width.height.equalTo(20)
        }
        self.rechargePriceLbl.snp.makeConstraints { (make) in
            make.left.equalTo(imgV1.snp.right).offset(2)
            make.top.equalTo(15)
            make.height.equalTo(20)
        }
        
        imgV2.snp.makeConstraints { (make) in
            make.left.equalTo(self.rechangePriceView.snp.centerX)
            make.top.equalTo(15)
            make.width.height.equalTo(20)
        }
        lbl2.snp.makeConstraints { (make) in
            make.left.equalTo(imgV2.snp.right).offset(2)
            make.top.equalTo(15)
            make.height.equalTo(20)
        }
        self.rechargeDescLbl.snp.makeConstraints { (make) in
            make.left.equalTo(lbl2.snp.right)
            make.top.equalTo(20)
            make.height.equalTo(20)
        }
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self.rechangePriceView)
        
        lbl2.addTapActionBlock {
            if self.modelJson["offer_num"].stringValue.intValue == 0{
                LYProgressHUD.showError("议价机会已用完！")
                return
            }
            let customAlertView = UIAlertView.init(title: "我的报价", message: "请输入期望的报价，可高于或低于原价", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            customAlertView.alertViewStyle = .plainTextInput
            let nameField = customAlertView.textField(at: 0)
            nameField?.keyboardType = .default
            nameField?.placeholder = "输入期望价格"
            customAlertView.show()
        }
        imgV2.addTapActionBlock {
            if self.modelJson["offer_num"].stringValue.intValue == 0{
                LYProgressHUD.showError("议价机会已用完！")
                return
            }
            let customAlertView = UIAlertView.init(title: "我的报价", message: "请输入期望的报价，可高于或低于原价", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            customAlertView.alertViewStyle = .plainTextInput
            let nameField = customAlertView.textField(at: 0)
            nameField?.keyboardType = .default
            nameField?.placeholder = "输入期望价格"
            customAlertView.show()
        }
    }
    
    //联系工程师
    @IBAction func chatEngAction() {
        //聊天
        esmobChat(self, self.modelJson["call_name"].stringValue, 2, self.modelJson["call_nik_name"].stringValue, self.modelJson["ot_user_avatar"].stringValue)
    }
    
    //工程师详情
    @IBAction func engDetailAction() {
        let engineerDetailVC = EngineerDetailViewController()
        engineerDetailVC.member_id = self.modelJson["ot_user_id"].stringValue
        self.navigationController?.pushViewController(engineerDetailVC, animated: true)
    }
    
    
    //刷新列表和详情的通知
    func refreshData(type : Int) {
        //刷新数据
        if self.refreshBlock != nil{
            self.refreshBlock!(type)
        }
        if type == 1 || type == 3{
            //返回列表
            self.navigationController?.popViewController(animated: true)
        }else{
            //刷新详情数据
            if self.isMyReceive{
                self.loadReceiveDetailData()
            }else{
                self.loadSendDetailData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        
        self.rechangePriceView.alpha = 0.3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.rechangePriceView.alpha = 1.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.rechangePriceView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //复制订单号
    @IBAction func copyOrderNumAction() {
        UIPasteboard.general.string = self.modelJson["bill_sn"].stringValue
        LYProgressHUD.showSuccess("订单号复制成功！")
    }
    
    //加载数据
    func loadSendDetailData() {
        var params : [String : Any] = [:]
        params["id"] = self.orderId
        
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: MySendOrderDetailApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            self.modelJson = result
            self.prepareViews(resultDict: result)
        }) { (error) in
            LYProgressHUD.showError(error!)
            if error!.hasPrefix("无记录"){
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //加载数据
    func loadReceiveDetailData() {
        var params : [String : Any] = [:]
        params["id"] = self.orderId
        params["move_state"] = self.moveState
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: ReceiveDetailDataApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            self.modelJson = result
            self.prepareViews(resultDict: result)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //填充数据
    func prepareViews(resultDict:JSON) {
        self.orderNumBtn.setTitle("订单序号" + resultDict["bill_sn"].stringValue, for: .normal)
        self.iconImgV.setHeadImageUrlStr(resultDict["bill_user_avatar"].stringValue)
        self.nameLbl.text = resultDict["bill_user_name"].stringValue
        self.timeLbl.text = "创建时间" + Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: resultDict["inputtime"].stringValue)
        self.timeLbl2.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: resultDict["inputtime"].stringValue)
        self.taskNameLbl.text = resultDict["entry_name"].stringValue
        self.serverRangeLbl.text = resultDict["service_sector"].stringValue
        self.brandTypeLbl.text = resultDict["service_brand"].stringValue
        self.amountUnitLbl.text = resultDict["number"].stringValue
        self.serverControlLbl.text = resultDict["service_form"].stringValue
        self.serverTypeLbl.text = resultDict["service_type"].stringValue
        self.serverTimeLbl.text = Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: resultDict["service_stime"].stringValue) + "-" + Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: resultDict["service_etime"].stringValue)
        self.serverAreaLbl.text = resultDict["service_address"].stringValue
        self.memoLbl.text = resultDict["bill_desc"].stringValue
        self.serverPriceLbl.text = "¥" + resultDict["service_price"].stringValue
        
        //报名人数
        self.enrollNum = self.modelJson["willnum"].stringValue
        self.rechargePriceLbl.text = "我的报价:¥" + self.modelJson["offer_price"].stringValue
        self.rechargeDescLbl.text = "剩余" + self.modelJson["offer_num"].stringValue + "次报价机会"
        
        var arrM = Array<String>()
        for subJson in resultDict["image"].arrayValue{
            arrM.append(subJson.stringValue)
        }
        self.projectPhotoView = LYPhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 10, height: 50), superVC: self)
        self.projectPhotoView.tag = 22
        self.projectPhotoView.delegate = self
        self.projectPhotoView.showImgUrlArray = arrM
        self.projectPhotoView.showDeleteBtn = false
        self.projectPhotoView.canTakePhoto = false
        self.imgsView.addSubview(self.projectPhotoView)
        
        
        //先将按钮隐藏
        self.leftBtn.isHidden = true
        self.centerBtn.isHidden = true
        self.rightBtn.isHidden = true
        
        //判断是接单还是发单
        if self.isMyReceive{
            self.receiveOrderUI(resultDict: resultDict)
        }else{
            self.sendOrderUI(resultDict: resultDict)
        }
        
        
        //接单工程师
        if !self.modelJson["ot_user_id"].stringValue.isEmpty{
            self.engIcon.setImageUrlStr(self.modelJson["ot_user_avatar"].stringValue)
            self.engNameLbl.text = self.modelJson["call_nik_name"].stringValue
        }
        
        self.tableView.reloadData()
    }
    
    //导航栏按钮-聊天
    @objc func chatItemAction() {
        //聊天
        esmobChat(self, self.modelJson["call_name"].stringValue, 2, self.modelJson["call_nik_name"].stringValue, self.modelJson["ot_user_avatar"].stringValue)
        
    }
    //导航栏按钮-工作轨迹
    @objc func trackItemAction() {
        let startTime = UInt(self.modelJson["bill_start_time"].stringValue.intValue)
        var endTime = UInt(self.modelJson["bill_sucess_time"].stringValue.intValue)
        if endTime == 0{
            endTime = startTime + 86400
        }
        //工作轨迹
        let workTrackVC = WorkTrackViewController()
        workTrackVC.startTime = startTime
        workTrackVC.endTime = endTime
        workTrackVC.engPhone = self.modelJson["call_name"].stringValue
        self.navigationController?.pushViewController(workTrackVC, animated: true)
    }
    
    
    //MARK:-订单操作
    @IBAction func leftBtnAction() {
        if self.isMyReceive{
            self.leftReceiveAction()
        }else{
            self.leftSendAction()
        }
    }
    
    @IBAction func centerBtnAction() {
        if self.isMyReceive{
            self.centerReceiveAction()
        }else{
            self.centerSendAction()
        }
    }
    
    @IBAction func rightBtnAction() {
        if self.isMyReceive{
            self.rightReceiveAction()
        }else{
            self.rightSendAction()
        }
    }
    
    //取消订单
    func cancelOrderAction() {
        var message = "确定要取消此订单吗"
        var url = CancelCustomerOrderApi
        if self.modelJson["bill_statu"].stringValue.intValue == 2 {
            message = "取消订单将扣除服务费用的10%,\n你确定要取消订单吗?"
        }
        //如果是我的接单则修改API和提示
        if self.isMyReceive{
            url = CancelEngineerOrderApi
            message = "取消订单将扣除服务费用的10%,\n你确定要取消订单吗?"
        }
        LYAlertView.show("提示", message, "放弃取消", "确定取消",{
            var params : [String : Any] = [:]
            params["id"] = self.modelJson["id"].stringValue
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                if self.isMyReceive{
                    if result["state"].intValue == 1{
                        LYProgressHUD.showError(msg ?? "余额不足，请充值！")
                    }else{
                        LYProgressHUD.showSuccess("取消成功！")
                        //刷新数据
                        self.refreshData(type: 1)
                    }
                }else{
                    LYProgressHUD.showSuccess("取消成功！")
                    //刷新数据
                    self.refreshData(type: 1)
                }
                
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
    }
    
    //删除订单
    func deleteOrderAction() {
        LYAlertView.show("提示", "删除之后订单无法被找回,你确认要删除此订单吗", "取消", "确定",{
            var params : [String : Any] = [:]
            params["id"] = self.modelJson["id"].stringValue
            var url = DeleteCustomerOrderApi
            //如果是我的接单则修改API和提示
            if self.isMyReceive{
                url = DeleteEngineerOrderApi
            }
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("删除成功！")
                //刷新数据
                self.refreshData(type: 3)
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
    }
    
    
    //调价
    @IBAction func changePriceAction() {
        if (self.changePriceTF.text?.isEmpty)!{
            LYProgressHUD.showError("请输入调价后的价格")
            return
        }
        let newPrice = self.changePriceTF.text!.doubleValue
        if newPrice == 0{
            LYProgressHUD.showError("新的价格不能为0")
            return
        }
        if self.modelJson["service_price"].stringValue.doubleValue == newPrice{
            LYProgressHUD.showError("新的价格不能跟原价一样")
            return
        }
        
        if newPrice > self.modelJson["original_price"].stringValue.doubleValue{
            //去支付
            let payVC = PaySendTaskViewController.spwan()
            payVC.isJustPay = true
            payVC.totalMoney = newPrice - self.modelJson["original_price"].stringValue.doubleValue
            payVC.orderId = modelJson["id"].stringValue
            payVC.newPrice = "\(newPrice)"
            if self.changePricePhotoView.imgArray.count > 0{
                payVC.imgArray = self.changePricePhotoView.imgArray
            }
            payVC.rePayOrderSuccessBlock = {[weak self] () in
                self?.isChangePrice = false
                self?.tableView.reloadData()
                //刷新数据
                self?.refreshData(type: 2)
                self?.changePricePhotoView.imgArray = []
                self?.changePriceTF.text = ""
            }
            self.navigationController?.pushViewController(payVC, animated: true)
            
            
        }else{
            
            func requestNet(_ images : String){
                var params : [String : Any] = [:]
                params["id"] = self.modelJson["id"].stringValue
                params["service_up_price"] = newPrice
                if self.changePricePhotoView.imgArray.count > 0{
                    params["up_images"] = images
                }
                NetTools.requestData(type: .post, urlString: ChangeDownPriceApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("调价成功")
                    self.isChangePrice = false
                    self.tableView.reloadData()
                    //刷新数据
                    self.refreshData(type: 2)
                    
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }
            
            if self.changePricePhotoView.imgArray.count > 0{
                LYProgressHUD.showLoading()
                NetTools.upLoadImage(urlString : UploadAllImageApi,imgArray: self.changePricePhotoView.imgArray, success: { (result) in
                    requestNet(result)
                }, failture: { (error) in
                    LYProgressHUD.showError("图片上传失败！")
                })
            }else{
                requestNet("")
            }
        }
    }
    
    
    
    //开始工作
    func beginOrderWork() {
        if CLLocationManager.authorizationStatus() == .denied{
            LYAlertView.show("提示", "请允许App访问位置服务，否则无法开始工作", "去设置", {
                //打开设置页面
                let url = URL(string:UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            })
            return
        }
        
        var params : [String : Any] = [:]
        params["id"] = self.modelJson["id"].stringValue
        if BaiDuMap.default.getUserLocal() != nil{
            params["lat_start_work"] = BaiDuMap.default.getUserLocal()!.latitude
            params["lng_start_work"] = BaiDuMap.default.getUserLocal()!.longitude
        }else{
            //默认北京地址
            params["lat_start_work"] = "39.959912"
            params["lng_start_work"] = "116.298056"
        }
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: EngineerStartWorkApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("操作成功！")
            //刷新数据
            self.refreshData(type: 2)
        }, failure: { (error) in
            LYProgressHUD.showError(error!)
        })
        
        
        //开始记录位置
        BaiDuMap.default.startTrace()
    }
    
    //完成工作
    func doneOrderWork(_ type : Int) {
        if CLLocationManager.authorizationStatus() == .denied{
            LYAlertView.show("提示", "请允许App访问位置服务，否则无法完成工作", "去设置", {
                //打开设置页面
                let url = URL(string:UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            })
            return
        }
        
        
        var params : [String : Any] = [:]
        params["id"] = self.modelJson["id"].stringValue
        if BaiDuMap.default.getUserLocal() != nil{
            params["lat_end_work"] = BaiDuMap.default.getUserLocal()!.latitude
            params["lng_end_work"] = BaiDuMap.default.getUserLocal()!.longitude
        }else{
            //默认北京地址
            params["lat_end_work"] = "39.959912"
            params["lng_end_work"] = "116.298056"
        }
        
        if type == 1{
            //未使用备件
            var params : [String : Any] = [:]
            params["id"] = self.modelJson["id"].stringValue
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: EngineerFinishOrderApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                //刷新数据
                self.refreshData(type: 2)
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        }else{
            //使用了备件
            let serviceBillVC = ServiceBillViewController.spwan()
            serviceBillVC.billId = self.orderId
            serviceBillVC.service_sector = self.serverRangeLbl.text!
            serviceBillVC.showType = 1
            serviceBillVC.billStatus = modelJson["bill_statu"].stringValue
            serviceBillVC.operationBlock = { () in
                //工程师创建，调用完成接口
                var params : [String : Any] = [:]
                params["id"] = self.modelJson["id"].stringValue
                NetTools.requestData(type: .post, urlString: EngineerFinishOrderApi, parameters: params, succeed: { (result, msg) in
                    //刷新列表和详情的通知
                    if self.refreshBlock != nil{
                        self.refreshBlock!(2)
                    }
                    //刷新数据
                    self.loadReceiveDetailData()
                }, failure: { (error) in
                })
            }
            self.navigationController?.pushViewController(serviceBillVC, animated: true)
        }
        
        //结束记录位置
        BaiDuMap.default.stopTrace()
    }
    
}

extension MySendOrderDetailViewController : LYMultiplePhotoBrowseViewDelegate, LYPhotoBrowseViewDelegate{
    func LYMultiplePhotoBrowseViewChangeHeight(lyPhoto: LYMultiplePhotoBrowseView, height: CGFloat) {
        self.tableView.reloadData()
    }
    
    func lyPhotoBrowseViewChangeHeight(lyPhoto: LYPhotoBrowseView, height: CGFloat) {
        self.tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return 44
            }else if indexPath.row == 1{
                return 70
            }else if indexPath.row == 12{
                return self.projectPhotoView.heightValue
            }else if indexPath.row == 13{
                return 44
            }else if indexPath.row == 14{
                if self.isChangePrice{
                    return self.changePricePhotoView.heightValue + 134
                }else{
                    return 0
                }
            }
            if indexPath.row == 2{
                let desc = modelJson["entry_name"].stringValue
                let height = desc.sizeFit(width: kScreenW - 80, height: CGFloat.greatestFiniteMagnitude, fontSize: 14.0).height + 4
                if height > 25 {
                    return height
                }
            }
            if indexPath.row == 3{
                let desc = modelJson["service_sector"].stringValue
                let height = desc.sizeFit(width: kScreenW - 80, height: CGFloat.greatestFiniteMagnitude, fontSize: 14.0).height + 4
                if height > 25 {
                    return height
                }
            }
            if indexPath.row == 9{
                let desc = modelJson["service_address"].stringValue
                let height = desc.sizeFit(width: kScreenW - 80, height: CGFloat.greatestFiniteMagnitude, fontSize: 14.0).height + 4
                if height > 25 {
                    return height
                }
            }
            if indexPath.row == 10{
                let desc = modelJson["bill_desc"].stringValue
                let height = desc.sizeFit(width: kScreenW - 80, height: CGFloat.greatestFiniteMagnitude, fontSize: 14.0).height + 4
                if height > 25 {
                    return height
                }
            }
        }else if indexPath.section == 1{
            //发单状态【0 撤销】【1 待接单】【2 已接单】【3 已完成】【4 已过期 or 已失效】【5 已取消】【6 调价中】【7 补单】
            if self.isMyReceive{
                return 0
            }else{
                if indexPath.row == 0{
                    if self.modelJson["ot_user_id"].stringValue.isEmpty{
                        return 0
                    }
                    return 95
                }else if indexPath.row == 1{
                    if self.modelJson["bill_statu"].stringValue.intValue == 1 || self.modelJson["bill_statu"].stringValue.intValue == 2 || self.modelJson["bill_statu"].stringValue.intValue == 3 || self.modelJson["bill_statu"].stringValue.intValue == 6{
                        return 130
                    }
                    return 0
                }else if indexPath.row == 2{
                    return 0
                }
            }
        }
        return 21
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 14 && !self.isChangePrice{
            cell.isHidden = true
        }else{
            cell.isHidden = false
        }
    }
    
    //    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        self.view.endEditing(true)
    //    }
}


//MARK: - 接单详情处理
extension MySendOrderDetailViewController{
    //左按钮点击
    func leftReceiveAction() {
        switch modelJson["bill_statu"].stringValue.intValue {
        case 3:
            if modelJson["is_have_report"].stringValue.intValue == 1{
                //服务单
                let serviceBillVC = ServiceBillViewController.spwan()
                serviceBillVC.billId = self.orderId
                serviceBillVC.service_sector = self.serverRangeLbl.text!
                serviceBillVC.showType = 5
                serviceBillVC.shareUrl = modelJson["report_html"].stringValue
                serviceBillVC.billStatus = modelJson["bill_statu"].stringValue
                self.navigationController?.pushViewController(serviceBillVC, animated: true)
            }else{
                //所用备件
                let replacementVC = ReplacementPartListViewController()
                replacementVC.orerId = self.modelJson["id"].stringValue
                replacementVC.isUsedSns = true
                for subJson in self.modelJson["goods"].arrayValue {
                    replacementVC.dataArray.append(subJson)
                }
                self.navigationController?.pushViewController(replacementVC, animated: true)
            }
        case 8:
            //转移订单
            let transferVC = TransferOrderViewController.spwan()
            transferVC.orderId = self.modelJson["id"].stringValue
            transferVC.transferSuccessBlock = {[weak self] () in
                self?.refreshData(type: 2)
            }
            self.navigationController?.pushViewController(transferVC, animated: true)
            
        default:
            print("未知状态")
        }
        
    }
    //中间按钮点击
    func centerReceiveAction() {
        switch modelJson["bill_statu"].stringValue.intValue {
        case 2:
            self.setRightItem()
            if modelJson["t_state"].stringValue.intValue == 0 || modelJson["t_state"].stringValue.intValue == 4{
                
                if modelJson["is_special"].stringValue.intValue == 1{
                    // 确认完成--> 去选择使用的备件sn码  并完成订单
                    LYAlertView.show("提示", "是否使用了备件", "未使用", "选择备件", {
                        //选择备件
                        let replacementVC = ReplacementPartListViewController()
                        replacementVC.orerId = self.modelJson["id"].stringValue
                        replacementVC.finishSuccessBlock = {[weak self] () in
                            //刷新列表和详情
                            self?.refreshData(type: 2)
                        }
                        self.navigationController?.pushViewController(replacementVC, animated: true)
                    },{
                        //未使用备件
                        self.doneOrderWork(1)
                    })
                }else{
                    //服务单
                    self.doneOrderWork(2)
                }
                
            }else if modelJson["t_state"].stringValue.intValue == 1{
                //服务单
                let serviceBillVC = ServiceBillViewController.spwan()
                serviceBillVC.billId = self.orderId
                serviceBillVC.service_sector = self.serverRangeLbl.text!
                serviceBillVC.showType = 3
                serviceBillVC.shareUrl = modelJson["report_html"].stringValue
                serviceBillVC.billStatus = modelJson["bill_statu"].stringValue
                serviceBillVC.operationBlock = {() in
                    //工程师修改
                }
                self.navigationController?.pushViewController(serviceBillVC, animated: true)
            }
            
        case 3:
            if modelJson["is_user_eval"].stringValue.intValue == 0{
                //去评价
                let addCommentVC = AddCommentViewController.spwan()
                addCommentVC.orderId = modelJson["id"].stringValue
                addCommentVC.isEngineer = true
                addCommentVC.addCommentSuccessBlock = {() in
                    //评价后刷新数据
                    self.refreshData(type: 2)
                }
                self.navigationController?.pushViewController(addCommentVC, animated: true)
            }else{
                //查看评价
                //评价列表
                let commentVC = CommentListViewController()
                commentVC.orderId = modelJson["id"].stringValue
                self.navigationController?.pushViewController(commentVC, animated: true)
            }
        case 6:
            var params : [String : Any] = [:]
            params["id"] = self.modelJson["id"].stringValue
            params["state"] = "0"
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: AgreeOrUnAgreeChangePriceApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("设置成功！")
                //刷新数据
                self.refreshData(type: 1)
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
            
        case 7:
            if modelJson["pay_statu"].stringValue.intValue == 0{
                LYAlertView.show("提示", "确定要取消此订单吗", "放弃取消", "确定取消",{
                    var params : [String : Any] = [:]
                    params["id"] = self.modelJson["id"].stringValue
                    LYProgressHUD.showLoading()
                    NetTools.requestData(type: .post, urlString: CancelCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                        LYProgressHUD.showSuccess("取消成功！")
                        //刷新数据
                        self.refreshData(type: 1)
                    }, failure: { (error) in
                        LYProgressHUD.showError(error!)
                    })
                })
            }else{
            }
        case 8:
            //转移状态 1转移中 2已接受 0已拒绝
            if modelJson["move_state"].stringValue.intValue == 1{
                if modelJson["bill_belong"].stringValue.intValue == 1{//1别人转给我的 2我转移给别人的
                    //同意转移
                    LYAlertView.show("提示", "确定同意接受转移的订单？", "取消", "确定",{
                        var params : [String : Any] = [:]
                        params["id"] = self.modelJson["id"].stringValue
                        params["move_to_eng_id"] = self.modelJson["ot_user_id"].stringValue//接受者的id
                        params["move_to_eng_name"] = self.modelJson["call_nik_name"].stringValue//接受者的昵称
                        params["move_state"] = self.modelJson["move_state"].stringValue
                        
                        LYProgressHUD.showLoading()
                        NetTools.requestData(type: .post, urlString: EngineerAgreeTransferMove, parameters: params, succeed: { (result, msg) in
                            LYProgressHUD.showSuccess("操作成功！")
                            //刷新数据
                            self.refreshData(type: 2)
                        }, failure: { (error) in
                            LYProgressHUD.showError(error!)
                        })
                    })
                }
            }else if modelJson["move_state"].stringValue.intValue == 2{
                self.stateLbl.text = "来自订单转移"
                if modelJson["bill_belong"].stringValue.intValue == 2{
                    //开始工作
                    self.beginOrderWork()
                }
            }
                //            else if modelJson["move_state"].stringValue.intValue == 0{
                //            }
            else{
                //开始工作
                self.beginOrderWork()
            }
            
        default:
            print("未知状态")
        }
        
    }
    //右边按钮点击
    func rightReceiveAction() {
        switch modelJson["bill_statu"].stringValue.intValue {
        case 0:
            //取消订单
            self.cancelOrderAction()
        case 2:
            if modelJson["t_state"].stringValue.intValue == 0 || modelJson["t_state"].stringValue.intValue == 4{
                //取消订单
                self.cancelOrderAction()
                
            }else if modelJson["t_state"].stringValue.intValue == 1{
            }
            
        case 3:
            //删除
            self.deleteOrderAction()
            
        case 4:
            //取消订单
            self.cancelOrderAction()
            
        case 5:
            //删除
            self.deleteOrderAction()
        case 6:
            var params : [String : Any] = [:]
            params["id"] = self.modelJson["id"].stringValue
            params["state"] = "1"
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: AgreeOrUnAgreeChangePriceApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("设置成功！")
                //刷新数据
                self.refreshData(type: 2)
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        case 7:
            if modelJson["pay_statu"].stringValue.intValue == 0{
                //去支付
                let payVC = PaySendTaskViewController.spwan()
                payVC.isJustPay = true
                payVC.totalMoney = modelJson["service_price"].stringValue.doubleValue
                payVC.orderId = modelJson["id"].stringValue
                payVC.rePayOrderSuccessBlock = {[weak self] () in
                    //刷新数据
                    self?.refreshData(type: 2)
                }
                self.navigationController?.pushViewController(payVC, animated: true)
                
            }else{
                
                // 确认完成--> 去选择使用的备件sn码  并完成订单
                LYAlertView.show("提示", "是否使用了备件", "未使用", "选择备件", {
                    // 确认完成--> 去选择使用的备件sn码  并完成订单
                    //选择备件
                    let replacementVC = ReplacementPartListViewController()
                    replacementVC.orerId = self.modelJson["id"].stringValue
                    replacementVC.isReplacementOrder = true
                    replacementVC.finishSuccessBlock = {[weak self] () in
                        //刷新数据
                        self?.refreshData(type: 2)
                    }
                    self.navigationController?.pushViewController(replacementVC, animated: true)
                },{
                    //未使用备件
                    self.doneOrderWork(1)
                })
            }
        case 8:
            //转移状态 1转移中 2已接受 0已拒绝
            if modelJson["move_state"].stringValue.intValue == 1{
                if modelJson["bill_belong"].stringValue.intValue == 1{//1别人转给我的 2我转移给别人的
                    LYAlertView.show("提示", "确定拒绝接受转移的订单？", "取消", "确定",{
                        var params : [String : Any] = [:]
                        params["id"] = self.modelJson["id"].stringValue
                        params["move_to_eng_id"] = self.modelJson["ot_user_id"].stringValue//接受者的id
                        params["move_to_eng_name"] = self.modelJson["call_nik_name"].stringValue//接受者的昵称
                        params["move_state"] = self.modelJson["move_state"].stringValue
                        
                        LYProgressHUD.showLoading()
                        NetTools.requestData(type: .post, urlString: EngineerRefuseTransferMove, parameters: params, succeed: { (result, msg) in
                            LYProgressHUD.showSuccess("拒绝成功！")
                            //刷新数据
                            self.refreshData(type: 1)
                        }, failure: { (error) in
                            LYProgressHUD.showError(error!)
                        })
                    })
                }
            }else if modelJson["move_state"].stringValue.intValue == 2{
                if modelJson["bill_belong"].stringValue.intValue == 2{
                    //取消订单
                    self.cancelOrderAction()                                    }
            }
                //            else if modelJson["move_state"].stringValue.intValue == 0{
                //            }
            else{
                //取消订单
                self.cancelOrderAction()
            }
            
        default:
            print("未知状态")
        }
        
    }
    
    func receiveOrderUI(resultDict:JSON) {
        // 发单状态【0 撤销】【1 待接单】【2 已接单】【3 已完成】【4 已过期 or 已失效】【5 已取消】【6 调价中】【7 补单】【8 开始工作】
        switch resultDict["bill_statu"].stringValue.intValue {
        case 0:
            self.stateLbl.text = "已撤销"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 取消订单 ", for: .normal)
        case 1:
            self.stateLbl.text = "已报名"
            //展示报价
            self.setRightItem()
            self.prepareRechangePriceView()
            self.enrollNumLbl.text = "已报名" + self.enrollNum + "人"
        case 2:
            self.setRightItem()
            self.stateLbl.text = "已接单"
            if resultDict["t_state"].stringValue.intValue == 0 || resultDict["t_state"].stringValue.intValue == 4{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 确认完成 ", for: .normal)
            }else if resultDict["t_state"].stringValue.intValue == 1{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 等待客户确认完成 ", for: .normal)
                self.rightBtn.isSelected = true
                if resultDict["is_special"].stringValue.intValue != 1{
                    self.centerBtn.isHidden = false
                    self.centerBtn.setTitle(" 服务单 ", for: .normal)
                }
            }
            
        case 3:
            
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
            self.centerBtn.isHidden = false
            
            if resultDict["is_user_eval"].stringValue.intValue == 0{
                self.stateLbl.text = "已完成"
                self.centerBtn.setTitle(" 去评价 ", for: .normal)
            }else{
                self.stateLbl.text = "已评价"
                self.centerBtn.setTitle(" 查看评价 ", for: .normal)
            }
            if resultDict["is_have_report"].stringValue.intValue == 1{
                self.leftBtn.isHidden = false
                self.leftBtn.setTitle(" 服务单 ", for: .normal)
            }else{
                if resultDict["goods"].arrayValue.count > 0{
                    self.leftBtn.isHidden = false
                    self.leftBtn.setTitle(" 所用备件 ", for: .normal)
                }
            }
        case 4:
            self.stateLbl.text = "已失效"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 取消订单 ", for: .normal)
            
        case 5:
            self.stateLbl.text = "已取消"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
        case 6:
            self.stateLbl.text = "调价中"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 同意 ", for: .normal)
            self.centerBtn.isHidden = false
            self.centerBtn.setTitle(" 不同意 ", for: .normal)
            
        case 7:
            if resultDict["pay_statu"].stringValue.intValue == 0{
                self.stateLbl.text = "待支付"
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 去支付 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 取消 ", for: .normal)
            }else{
                self.stateLbl.text = "补单"
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 确认完成 ", for: .normal)
            }
        case 8:
            //转移状态 1转移中 2已接受 0已拒绝
            if resultDict["move_state"].stringValue.intValue == 1{
                self.stateLbl.text = "转移待确定"
                if resultDict["bill_belong"].stringValue.intValue == 1{//1别人转给我的 2我转移给别人的
                    self.stateLbl.text = "转移待确定"
                    self.rightBtn.isHidden = false
                    self.rightBtn.setTitle(" 拒绝 ", for: .normal)
                    self.centerBtn.isHidden = false
                    self.centerBtn.setTitle(" 同意 ", for: .normal)
                }else{
                    self.leftBtn.isHidden = true
                    self.rightBtn.isHidden = true
                    self.centerBtn.isHidden = true
                }
            }else if resultDict["move_state"].stringValue.intValue == 2{
                self.stateLbl.text = "来自订单转移"
                if resultDict["bill_belong"].stringValue.intValue == 2{
                    self.setRightItem()
                    self.rightBtn.isHidden = false
                    self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                    self.centerBtn.isHidden = false
                    self.centerBtn.setTitle(" 开始工作 ", for: .normal)
                    self.leftBtn.isHidden = false
                    self.leftBtn.setTitle(" 转移订单 ", for: .normal)
                } else if resultDict["bill_belong"].stringValue.intValue == 1{
                    self.leftBtn.isHidden = true
                    self.rightBtn.isHidden = true
                    self.centerBtn.isHidden = true
                }
            }else{
                self.stateLbl.text = "已接单"
                self.setRightItem()
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 开始工作 ", for: .normal)
                self.leftBtn.isHidden = false
                self.leftBtn.setTitle(" 转移订单 ", for: .normal)
            }
            if resultDict["move_state"].stringValue.intValue >= 2{
                self.leftBtn.isHidden = true
            }
            
        default:
            print("未知状态")
        }
        
        //价格为0的不显示价格
        if resultDict["service_price"].stringValue.floatValue > 0{
            self.serverPriceLbl.isHidden = false
            self.serverPriceTitleLbl.isHidden = false
        }else{
            self.serverPriceLbl.isHidden = true
            self.serverPriceTitleLbl.isHidden = true
        }
        
    }
}


//MARK: - 发单详情处理
extension MySendOrderDetailViewController{
    
    //左按钮点击
    func leftSendAction() {
        switch modelJson["bill_statu"].stringValue.intValue {
        case 1:
            //指定接单人
            let authorizedVC = AuthorizedEnrollerController()
            authorizedVC.billId = self.orderId
            authorizedVC.successBlock = {[weak self] () in
                //刷新数据
                if self?.refreshBlock != nil{
                    self?.refreshBlock!(1)
                }
                self?.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(authorizedVC, animated: true)
        case 3:
            if modelJson["is_have_report"].stringValue.intValue == 1{
                //服务单
                let serviceBillVC = ServiceBillViewController.spwan()
                serviceBillVC.billId = self.orderId
                serviceBillVC.service_sector = self.serverRangeLbl.text!
                serviceBillVC.showType = 4
                serviceBillVC.shareUrl = modelJson["report_html"].stringValue
                serviceBillVC.billStatus = modelJson["bill_statu"].stringValue
                self.navigationController?.pushViewController(serviceBillVC, animated: true)
            }else{
                if modelJson["bill_statu"].stringValue.intValue == 3 && modelJson["goods"].arrayValue.count > 0{
                    //所用备件
                    let replacementVC = ReplacementPartListViewController()
                    replacementVC.orerId = self.modelJson["id"].stringValue
                    replacementVC.isUsedSns = true
                    for subJson in self.modelJson["goods"].arrayValue {
                        replacementVC.dataArray.append(subJson)
                    }
                    self.navigationController?.pushViewController(replacementVC, animated: true)
                }
            }
            
        default:
            print("未知状态")
        }
    }
    //中间按钮点击
    func centerSendAction() {
        var params : [String : Any] = [:]
        params["id"] = self.modelJson["id"].stringValue
        
        switch modelJson["bill_statu"].stringValue.intValue {
        case 1:
            if modelJson["pay_statu"].stringValue.intValue == 0{
                //取消订单
                self.cancelOrderAction()
            }else{
                //调价
                self.isChangePrice = !self.isChangePrice
                self.tableView.reloadData()
            }
        case 2:
            if modelJson["t_state"].stringValue.intValue == 0 || modelJson["t_state"].stringValue.intValue == 4{
                //调价
                self.isChangePrice = !self.isChangePrice
                self.tableView.reloadData()
            }else if modelJson["t_state"].stringValue.intValue == 1{
                //未完成
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: UNCompleteCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("设置成功！")
                    //刷新数据
                    self.refreshData(type: 2)
                    
                    self.loadSendDetailData()
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }
            
        case 3:
            if modelJson["is_eval"].stringValue.intValue == 0{
                //去评价
                let addCommentVC = AddCommentViewController.spwan()
                addCommentVC.orderId = modelJson["id"].stringValue
                addCommentVC.addCommentSuccessBlock = {[weak self] () in
                    //评价后刷新数据
                    self?.refreshData(type: 2)
                }
                self.navigationController?.pushViewController(addCommentVC, animated: true)
            }else{
                //查看评价
                //评价列表
                let commentVC = CommentListViewController()
                commentVC.orderId = modelJson["id"].stringValue
                self.navigationController?.pushViewController(commentVC, animated: true)
            }
        case 4:
            //撤销
            LYAlertView.show("提示", "撤销之后订单无法被找回,你确认要删除此订单吗", "取消", "确定",{
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: UndoCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("撤销成功！")
                    //刷新数据
                    self.refreshData(type: 3)
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            })
        default:
            print("未知状态")
        }
    }
    //右边按钮点击
    func rightSendAction() {
        switch modelJson["bill_statu"].stringValue.intValue {
        case 0:
            //删除订单
            self.deleteOrderAction()
        case 1:
            if modelJson["pay_statu"].stringValue.intValue == 0{
                //去支付
                let payVC = PaySendTaskViewController.spwan()
                payVC.isJustPay = true
                payVC.totalMoney = modelJson["service_price"].stringValue.doubleValue
                payVC.orderId = modelJson["id"].stringValue
                payVC.rePayOrderSuccessBlock = {() in
                    //刷新数据
                    self.refreshData(type: 2)
                }
                self.navigationController?.pushViewController(payVC, animated: true)
            }else{
                //取消订单
                self.cancelOrderAction()
            }
            
        case 2:
            if modelJson["t_state"].stringValue.intValue == 0 || modelJson["t_state"].stringValue.intValue == 4{
                //取消订单
                self.cancelOrderAction()
            }else if modelJson["t_state"].stringValue.intValue == 1{
                //服务单
                let serviceBillVC = ServiceBillViewController.spwan()
                serviceBillVC.billId = self.orderId
                serviceBillVC.service_sector = self.serverRangeLbl.text!
                serviceBillVC.showType = 4
                serviceBillVC.shareUrl = modelJson["report_html"].stringValue
                serviceBillVC.billStatus = modelJson["bill_statu"].stringValue
                serviceBillVC.operationBlock = {() in
                    //客户确认完成
                    var params : [String : Any] = [:]
                    params["id"] = self.modelJson["id"].stringValue
                    LYProgressHUD.showLoading()
                    NetTools.requestData(type: .post, urlString: CompleteCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                        //刷新数据
                        //自动跳转去评价
                        let addCommentVC = AddCommentViewController.spwan()
                        addCommentVC.orderId = self.modelJson["id"].stringValue
                        addCommentVC.addCommentSuccessBlock = {() in
                            //评价后刷新数据
                            if self.refreshBlock != nil{
                                self.refreshBlock!(1)
                            }
                            //刷新数据
                            self.loadSendDetailData()
                        }
                        self.navigationController?.pushViewController(addCommentVC, animated: true)
                        LYProgressHUD.dismiss()
                    }, failure: { (error) in
                        LYProgressHUD.showError(error!)
                    })
                }
                self.navigationController?.pushViewController(serviceBillVC, animated: true)
            }
        case 3:
            //删除订单
            self.deleteOrderAction()
        case 4:
            //重新发布
            let redoOrderVC = SendTaskViewController.spwan()
            redoOrderVC.isRedoOrder = true
            redoOrderVC.orderId = self.modelJson["id"].stringValue
            self.navigationController?.pushViewController(redoOrderVC, animated: true)
        case 5:
            //删除订单
            self.deleteOrderAction()
        case 6:
            //            self.rightBtn.setTitle(" 等待工程师同意 ", for: .normal)
            print("等待工程师同意")
        default:
            print("未知状态")
        }
    }
    //布局
    func sendOrderUI(resultDict:JSON) {
        //发单状态【0 撤销】【1 待接单】【2 已接单】【3 已完成】【4 已过期 or 已失效】【5 已取消】【6 调价中】【7 补单】
        switch resultDict["bill_statu"].stringValue.intValue {
        case 0:
            self.stateLbl.text = "已撤销"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
        case 1:
            if resultDict["pay_statu"].stringValue.intValue == 0{
                self.stateLbl.text = "待支付"
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 去支付 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 取消订单 ", for: .normal)
                self.setUpTaskStep(0)
            }else{
                self.stateLbl.text = "报名中"
                self.enrollNumLbl.text = "已报名" + self.enrollNum + "人"
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 调价 ", for: .normal)
                self.leftBtn.isHidden = false
                self.leftBtn.setTitle(" 指定接单人 ", for: .normal)
                self.setUpTaskStep(1)
            }
            
        case 2:
            self.stateLbl.text = "已接单"
            self.setRightItem()
            if resultDict["t_state"].stringValue.intValue == 0 || resultDict["t_state"].stringValue.intValue == 4{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 调价 ", for: .normal)
                if resultDict["t_state"].stringValue.intValue == 4{
                    self.setUpTaskStep(3)
                }else{
                    self.setUpTaskStep(2)
                }
            }else if resultDict["t_state"].stringValue.intValue == 1{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 确认完成 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 未完成 ", for: .normal)
                self.setUpTaskStep(4)
            }else{
                self.setUpTaskStep(2)
            }
            
            
        case 3:
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
            self.centerBtn.isHidden = false
            
            //工程师工作轨迹
            //            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "map_track"), target: self, action: #selector(MySendOrderDetailViewController.trackItemAction))
            
            if resultDict["is_eval"].stringValue.intValue == 0{
                self.stateLbl.text = "已完成"
                self.centerBtn.setTitle(" 去评价 ", for: .normal)
            }else{
                self.stateLbl.text = "已评价"
                self.centerBtn.setTitle(" 查看评价 ", for: .normal)
            }
            if resultDict["is_have_report"].stringValue.intValue == 1{
                self.leftBtn.isHidden = false
                self.leftBtn.setTitle(" 服务单 ", for: .normal)
            }else{
                if resultDict["goods"].arrayValue.count > 0{
                    self.leftBtn.isHidden = false
                    self.leftBtn.setTitle(" 所用备件 ", for: .normal)
                }
            }
        case 4:
            self.stateLbl.text = "已失效"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 重新发布 ", for: .normal)
            self.centerBtn.isHidden = false
            self.centerBtn.setTitle(" 撤销 ", for: .normal)
        case 5:
            self.stateLbl.text = "已取消"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
        case 6:
            self.stateLbl.text = "调价中"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 等待工程师同意 ", for: .normal)
            self.rightBtn.isSelected = true
            
        case 7:
            self.stateLbl.text = "补单"
        default:
            self.stateLbl.text = "未知状态"
        }
    }
    
    //订单流程步骤
    func setUpTaskStep(_ index : Int) {
        switch index {
        case 0:
            //发单未成功
            self.taskNoteImg1.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView1.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg2.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView2.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg3.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView3.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg4.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView4.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg5.image = #imageLiteral(resourceName: "task_icon2")
        case 1:
            //发单
            self.taskNoteImg2.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView2.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg3.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView3.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg4.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView4.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg5.image = #imageLiteral(resourceName: "task_icon2")
        case 2:
            //工程师开始工作
            self.taskNoteImg3.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView3.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg4.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView4.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg5.image = #imageLiteral(resourceName: "task_icon2")
        case 3:
            //工程师完成工作
            self.taskNoteImg4.image = #imageLiteral(resourceName: "task_icon2")
            self.taskNoteView4.backgroundColor = UIColor.colorHex(hex: "c1c1c1")
            self.taskNoteImg5.image = #imageLiteral(resourceName: "task_icon2")
        case 4:
            //完成
            self.taskNoteImg5.image = #imageLiteral(resourceName: "task_icon2")
        default:
            print("123")
        }
    }
    
    
    //订单跟踪记录
    func createNoteView(_ time : String, _ title : String, _ index : Int) -> UIView{
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 60))
        let timeLbl = UILabel.init(frame: CGRect.init(x: 30, y: 0, width: kScreenW-60, height: 20))
        timeLbl.textColor = UIColor.RGBS(s: 70)
        timeLbl.font = UIFont.systemFont(ofSize: 12.0)
        timeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: time)
        let size = title.sizeFit(width: kScreenW-60, height: CGFloat(MAXFLOAT), fontSize: 14.0)
        let titleLbl = UILabel.init(frame: CGRect.init(x: 30, y: 25, width: kScreenW-60, height: size.height))
        titleLbl.numberOfLines = 0
        titleLbl.textColor = UIColor.RGBS(s: 70)
        titleLbl.font = UIFont.systemFont(ofSize: 12.0)
        titleLbl.text = title
        
        view.addSubview(timeLbl)
        view.addSubview(titleLbl)
        
        return view
    }
    
    
    //聊天以及看轨迹
    func setRightItem() {
        //如果有工程师开始工作时间则可以展示工作轨迹
        if self.modelJson["bill_start_time"].stringValue.isEmpty{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_chat_red"), target: self, action: #selector(MySendOrderDetailViewController.chatItemAction))
        }else{
//            var chatItem = UIBarButtonItem()
//            chatItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_chat_red"), target: self, action: #selector(MySendOrderDetailViewController.chatItemAction))
//            let trackItem = UIBarButtonItem(image: #imageLiteral(resourceName: "map_track"), target: self, action: #selector(MySendOrderDetailViewController.trackItemAction))
            //            self.navigationItem.rightBarButtonItems = [chatItem,trackItem]
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_chat_red"), target: self, action: #selector(MySendOrderDetailViewController.chatItemAction))
        }
        
    }
    
    
}


extension MySendOrderDetailViewController : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            let nameField = alertView.textField(at: 0)
            guard let price = nameField?.text else{
                LYProgressHUD.showError("请重试！")
                return
            }
            if price.isEmpty{
                LYProgressHUD.showError("不可为空！")
                return
            }
            print(price)
            var params : [String : Any] = [:]
            params["bill_id"] = self.modelJson["id"].stringValue
            params["offer_price"] = price
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: EngineerRechangePriceApi, parameters: params, succeed: { (result, msg) in
                //刷新数据
                self.loadReceiveDetailData()
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
            
        }
    }
}




/*
 {
 repCode = "00",
 repMsg = "",
 listData = 	{
 is_change_price = <null>,
 inputtime = "1500963386",
 entry_name = "IBM V7000硬盘调试",
 bill_sn = "800020170725141626",
 is_top = "0",
 id = "1169",
 service_brand = "00Y2448",
 t_state = "0",
 service_address = "北京市海淀区清河小营桥",
 other_service_sector = <null>,
 bill_user_id = "936",
 available_predeposit = "22525.00",
 service_up_price = "0.00",
 service_type = "调试",
 bill_user_avatar = "http://www.7xiaofu.com/UPLOAD/sys/2017-07-26/~UPLOAD~sys~2017-07-26@1501051518.jpg240",
 number = "10块",
 payment_list = 	(
 {
 payment_name = "支付宝",
 payment_img = "http://www.cpweb.gov.cn/uploads/allimg/141203/538-141203135F5E4.png",
 payment_id = "2",
 },
 {
 payment_name = "微信支付",
 payment_img = "http://img1.2345.com/duoteimg/softImg/soft/11/1412053391_28.jpg",
 payment_id = "6",
 },
 {
 payment_name = "钱包",
 payment_img = "",
 payment_id = "7",
 },
 ),
 image = 	(
 ),
 bill_user_name = "一块烤肉",
 ot_user_avatar = "http://www.7xiaofu.com/data/upload/shop/common/default_user_portrait.gif",
 service_etime = "1501827240",
 top_price = "0",
 bill_desc = "CK17070813",
 service_stime = "1500963240",
 service_price = "1200.00",
 is_eval = "0",
 os = "0",
 ot_user_id = "",
 ot_user_name = "",
 other_service_brand = "",
 call_nik_name = <null>,
 service_city = "北京市海淀区清河小营桥",
 service_sector = "存储设备-00Y2448",
 bill_statu = "1",
 service_form = "现场服务",
 call_name = <null>,
 title = "存储设备-00Y2448",
 },
 */
