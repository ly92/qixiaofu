//
//  MySendOrderCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/2.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MySendOrderCell: UITableViewCell {
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var projectNameLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var subscribeTimeLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceTitleLbl: UILabel!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var centerBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    fileprivate var timer = Timer()//待支付计时器
    fileprivate var codeTime : Int = 0
    
    var parentVC : UIViewController!
    
    //刷新列表 1:从列表删除 2:原地刷新 3:从数据库删除（删除，撤销）
    var refreshBlock : ((Int) -> Void)?
    
    var subJson : JSON = []{
        didSet{
            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: subJson["inputtime"].stringValue)
            self.projectNameLbl.text = subJson["entry_name"].stringValue
            self.contentLbl.text = subJson["title"].stringValue
            self.subscribeTimeLbl.text = Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: subJson["service_stime"].stringValue) + "-" + Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: subJson["service_etime"].stringValue)
            self.areaLbl.text = subJson["service_city"].stringValue
            self.priceLbl.text = "¥" + subJson["service_price"].stringValue
            
            //先将按钮隐藏
            self.leftBtn.isHidden = true
            self.centerBtn.isHidden = true
            self.rightBtn.isHidden = true
            self.rightBtn.isSelected = false
            self.chatBtn.isHidden = true//仅已接单状态显示聊天按钮
            
            //判断是我的发单还是我的接单
            if subJson["isMyReceive"].stringValue.intValue == 1{
                self.myReceiveUI()
            }else{
                self.mySendUI()
            }
        }
    }
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    @IBAction func chatBtnAction() {
        //聊天
//        let chatVC = ChatViewController.init(conversationChatter: self.subJson["call_name"].stringValue, conversationName: self.subJson["call_nik_name"].stringValue, conversationIcon: self.subJson["ot_user_avatar"].stringValue)
//        self.parentVC.navigationController?.pushViewController(chatVC, animated: true)
        
        //登录环信
        esmobLogin()
        esmobChat(self.parentVC, self.subJson["call_name"].stringValue, 2, self.subJson["call_nik_name"].stringValue, self.subJson["ot_user_avatar"].stringValue)
    }
    
    //左边按钮点击事件
    @IBAction func leftBtnAction() {
        //判断是我的发单还是我的接单
        if subJson["isMyReceive"].stringValue.intValue == 1{
            self.leftReceiveAction()
        }else{
            self.leftSendAction()
        }
    }
    
    //中间按钮点击事件
    @IBAction func centerBtnAction() {
        //判断是我的发单还是我的接单
        if subJson["isMyReceive"].stringValue.intValue == 1{
            self.centerReceiveAction()
        }else{
            self.centerSendAction()
        }
    }
    
    //右边按钮点击事件
    @IBAction func rightBtnAction() {
        //判断是我的发单还是我的接单
        if subJson["isMyReceive"].stringValue.intValue == 1{
            self.rightReceiveAction()
        }else{
            self.rightSendAction()
        }
    }
    
    //取消订单
    func cancelOrderAction() {
        var message = "确定要取消此订单吗"
        var url = CancelCustomerOrderApi
        if self.subJson["bill_statu"].stringValue.intValue == 2 {
            message = "取消订单将扣除服务费用的10%,\n你确定要取消订单吗?"
        }
        //如果是我的接单则修改API和提示
        if self.subJson["isMyReceive"].stringValue.intValue == 1{
            url = CancelEngineerOrderApi
            message = "取消订单将扣除服务费用的10%,\n你确定要取消订单吗?"
        }
        LYAlertView.show("提示", message, "放弃取消", "确定取消",{
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                if self.subJson["isMyReceive"].stringValue.intValue == 1{
                    if result["state"].intValue == 1{
                        LYProgressHUD.showError(msg ?? "余额不足，请充值！")
                    }else{
                        LYProgressHUD.showSuccess("取消成功！")
                        //刷新数据
                        if self.refreshBlock != nil{
                            self.refreshBlock!(1)
                        }
                    }
                }else{
                    LYProgressHUD.showSuccess("取消成功！")
                    //刷新数据
                    if self.refreshBlock != nil{
                        self.refreshBlock!(1)
                    }
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
            params["id"] = self.subJson["id"].stringValue
            var url = DeleteCustomerOrderApi
            //如果是我的接单则修改API和提示
            if self.subJson["isMyReceive"].stringValue.intValue == 1{
                url = DeleteEngineerOrderApi
            }
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("删除成功！")
                //刷新数据
                if self.refreshBlock != nil{
                    self.refreshBlock!(3)
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
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
        params["id"] = self.subJson["id"].stringValue
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
            if self.refreshBlock != nil{
                self.refreshBlock!(2)
            }
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
        params["id"] = self.subJson["id"].stringValue
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
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: EngineerFinishOrderApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                //刷新数据
                if self.refreshBlock != nil{
                    self.refreshBlock!(1)
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        }else{
            //使用了备件
            let serviceBillVC = ServiceBillViewController.spwan()
            serviceBillVC.billId = subJson["id"].stringValue
            serviceBillVC.service_sector = subJson["title"].stringValue
            serviceBillVC.showType = 1
            serviceBillVC.billStatus = subJson["bill_statu"].stringValue
            serviceBillVC.operationBlock = {() in
                //工程师创建,调用完成接口
                NetTools.requestData(type: .post, urlString: EngineerFinishOrderApi, parameters: params, succeed: { (result, msg) in
                    //刷新数据
                    if self.refreshBlock != nil{
                        self.refreshBlock!(2)
                    }
                }, failure: { (error) in
                })
            }
            self.parentVC.navigationController?.pushViewController(serviceBillVC, animated: true)
        }
        
        //结束记录位置
         BaiDuMap.default.stopTrace()
    }
    
    
}


//MARK: - 发单处理
extension MySendOrderCell{
    
    //左边按钮点击
    func leftSendAction() {
        switch subJson["bill_statu"].stringValue.intValue {
        case 3:
            //服务单
            let serviceBillVC = ServiceBillViewController.spwan()
            serviceBillVC.billId = subJson["id"].stringValue
            serviceBillVC.service_sector = subJson["title"].stringValue
            serviceBillVC.showType = 4
            serviceBillVC.shareUrl = subJson["report_html"].stringValue
            serviceBillVC.billStatus = subJson["bill_statu"].stringValue
            self.parentVC.navigationController?.pushViewController(serviceBillVC, animated: true)
        default:
            print("未知状态")
        }
    }
    
    //中间按钮点击事件
    func centerSendAction() {
        var params : [String : Any] = [:]
        params["id"] = self.subJson["id"].stringValue
        
        switch subJson["bill_statu"].stringValue.intValue {
        case 1:
            if subJson["pay_statu"].stringValue.intValue == 0{
                //取消订单
                self.cancelOrderAction()
            }
        case 2:
            if subJson["t_state"].stringValue.intValue == 1{
                //未完成UNCompleteCustomerOrderApi
                NetTools.requestData(type: .post, urlString: UNCompleteCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("设置成功！")
                    //刷新数据
                    if self.refreshBlock != nil{
                        self.refreshBlock!(2)
                    }
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }
        case 3:
            if subJson["is_eval"].stringValue.intValue == 0{
                //去评价
                let addCommentVC = AddCommentViewController.spwan()
                addCommentVC.orderId = subJson["id"].stringValue
                addCommentVC.addCommentSuccessBlock = {() in
                    //评价后刷新数据
                    if self.refreshBlock != nil{
                        self.refreshBlock!(2)
                    }
                }
                self.parentVC.navigationController?.pushViewController(addCommentVC, animated: true)
            }else{
                //查看评价
                //评价列表
                let commentVC = CommentListViewController()
                commentVC.orderId = subJson["id"].stringValue
                self.parentVC.navigationController?.pushViewController(commentVC, animated: true)
            }
        case 4:
            //撤销
            LYAlertView.show("提示", "撤销之后订单无法被找回,你确认要撤销此订单吗", "取消", "确定",{
                NetTools.requestData(type: .post, urlString: UndoCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("撤销成功！")
                    //刷新数据
                    if self.refreshBlock != nil{
                        self.refreshBlock!(3)
                    }
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            })
        default:
            print("未知状态")
        }
    }
    //右边按钮点击事件
    func rightSendAction() {
        var params : [String : Any] = [:]
        params["id"] = self.subJson["id"].stringValue
        
        
        switch subJson["bill_statu"].stringValue.intValue {
        case 0:
            //删除订单
            self.deleteOrderAction()
        case 1:
            if subJson["pay_statu"].stringValue.intValue == 0{
                //去支付
                let payVC = PaySendTaskViewController.spwan()
                payVC.isJustPay = true
                payVC.totalMoney = subJson["service_price"].stringValue.doubleValue
                payVC.orderId = subJson["id"].stringValue
                payVC.rePayOrderSuccessBlock = {() in
                    //刷新数据
                    if self.refreshBlock != nil{
                        self.refreshBlock!(2)
                    }
                }
                self.parentVC.navigationController?.pushViewController(payVC, animated: true)
            }else{
                //取消订单
                self.cancelOrderAction()
            }
        case 2:
            if subJson["t_state"].stringValue.intValue == 0 || subJson["t_state"].stringValue.intValue == 4{
                //取消订单
                self.cancelOrderAction()
            }else if subJson["t_state"].stringValue.intValue == 1{
                //服务单
                let serviceBillVC = ServiceBillViewController.spwan()
                serviceBillVC.billId = subJson["id"].stringValue
                serviceBillVC.service_sector = subJson["title"].stringValue
                serviceBillVC.showType = 4
                serviceBillVC.shareUrl = subJson["report_html"].stringValue
                serviceBillVC.billStatus = subJson["bill_statu"].stringValue
                serviceBillVC.operationBlock = {() in
                    //客户确认完成
                    LYProgressHUD.showLoading()
                    NetTools.requestData(type: .post, urlString: CompleteCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                        LYProgressHUD.dismiss()
                        //刷新数据
                        if self.refreshBlock != nil{
                            self.refreshBlock!(1)
                        }
                        //自动跳转去评价
                        let addCommentVC = AddCommentViewController.spwan()
                        addCommentVC.orderId = self.subJson["id"].stringValue
                        addCommentVC.addCommentSuccessBlock = {[weak self] () in
                            //评价后刷新数据
                            if self?.refreshBlock != nil{
                                self?.refreshBlock!(1)
                            }
                        }
                        self.parentVC.navigationController?.pushViewController(addCommentVC, animated: true)
                    }, failure: { (error) in
                        LYProgressHUD.showError(error!)
                    })
                }
                self.parentVC.navigationController?.pushViewController(serviceBillVC, animated: true)
            }
        case 3:
            //删除订单
            self.deleteOrderAction()
        case 4:
            //重新发布
            let redoOrderVC = SendTaskViewController.spwan()
            redoOrderVC.isRedoOrder = true
            redoOrderVC.orderId = self.subJson["id"].stringValue
            self.parentVC.navigationController?.pushViewController(redoOrderVC, animated: true)
        case 5:
            //删除订单
            self.deleteOrderAction()
        case 6:
            print("等待工程师同意")
        default:
            print("未知状态")
        }
        
    }
    //布局
    func mySendUI() {
        // 发单状态【0 撤销】【1 待接单】【2 已接单】【3 已完成】【4 已过期 or 已失效】【5 已取消】【6 调价中】【7 补单】【8 开始工作】
        
        //防止复用cell时继续计时
        self.timer.invalidate()
        
        
        switch subJson["bill_statu"].stringValue.intValue {
        case 0:
            self.stateLbl.text = "已撤销"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
        case 1:
            if subJson["pay_statu"].stringValue.intValue == 0{//未支付
                //                self.stateLbl.text = "待支付"
                self.codeTime = subJson["bill_end_time"].stringValue.intValue
                self.setUpCodeTimer()
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 去支付 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 取消订单 ", for: .normal)
            }else{
                self.stateLbl.text = "已报名：" + subJson["num"].stringValue + "人"
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
            }
        case 2:
            self.stateLbl.text = "已接单"
            self.chatBtn.isHidden = false
            //  工程师完成状态【0 未完成】【1 已完成】
            if subJson["t_state"].stringValue.intValue == 0 || subJson["t_state"].stringValue.intValue == 4{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
            }else if subJson["t_state"].stringValue.intValue == 1{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 确认完成 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 未完成 ", for: .normal)
            }
        case 3:
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
            self.centerBtn.isHidden = false
            if subJson["is_eval"].stringValue.intValue == 0{
                self.stateLbl.text = "已完成"
                self.centerBtn.setTitle(" 去评价 ", for: .normal)
            }else{
                self.stateLbl.text = "已评价"
                self.centerBtn.setTitle(" 查看评价 ", for: .normal)
            }
            if subJson["is_have_report"].stringValue.intValue == 1{
                self.leftBtn.isHidden = false
                self.leftBtn.setTitle(" 服务单 ", for: .normal)
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
            self.rightBtn.isSelected = false
            
            //            case 7:
            //                return "补单"
            //            case 8:
        //                return "工作中"
        default:
            print("未知状态")
        }
        
    }
}


//MARK: - 接单处理
extension MySendOrderCell{
    //左边按钮点击
    func leftReceiveAction() {
        switch subJson["bill_statu"].stringValue.intValue {
        case 3:
            //服务单
            let serviceBillVC = ServiceBillViewController.spwan()
            serviceBillVC.billId = subJson["id"].stringValue
            serviceBillVC.service_sector = subJson["title"].stringValue
            serviceBillVC.showType = 5
            serviceBillVC.shareUrl = subJson["report_html"].stringValue
            serviceBillVC.billStatus = subJson["bill_statu"].stringValue
            self.parentVC.navigationController?.pushViewController(serviceBillVC, animated: true)
        default:
            print("未知状态")
        }
    }
    
    
    //中间按钮点击事件
    func centerReceiveAction() {
        var params : [String : Any] = [:]
        params["id"] = self.subJson["id"].stringValue
        
        switch subJson["bill_statu"].stringValue.intValue {
        case 2:
            if subJson["t_state"].stringValue.intValue == 0 || subJson["t_state"].stringValue.intValue == 4{
                if subJson["is_special"].stringValue.intValue == 1{
                    // 确认完成--> 去选择使用的备件sn码  并完成订单
                    LYAlertView.show("提示", "是否使用了备件", "未使用", "选择备件", {
                        //选择备件
                        let replacementVC = ReplacementPartListViewController()
                        replacementVC.orerId = self.subJson["id"].stringValue
                        replacementVC.finishSuccessBlock = {() in
                            //刷新数据
                            if self.refreshBlock != nil{
                                self.refreshBlock!(1)
                            }
                        }
                        self.parentVC.navigationController?.pushViewController(replacementVC, animated: true)
                    },{
                        //未使用备件
                        self.doneOrderWork(1)
                    })
                }else{
                    //服务单
                    self.doneOrderWork(2)
                }
            }else{
                //服务单
                let serviceBillVC = ServiceBillViewController.spwan()
                serviceBillVC.billId = subJson["id"].stringValue
                serviceBillVC.service_sector = subJson["title"].stringValue
                serviceBillVC.showType = 3
                serviceBillVC.shareUrl = subJson["report_html"].stringValue
                serviceBillVC.billStatus = subJson["bill_statu"].stringValue
                serviceBillVC.operationBlock = {() in
                    //工程师修改
                }
                self.parentVC.navigationController?.pushViewController(serviceBillVC, animated: true)
                
            }
        case 3:
            if subJson["is_user_eval"].stringValue.intValue == 0{
                //去评价
                let addCommentVC = AddCommentViewController.spwan()
                addCommentVC.orderId = subJson["id"].stringValue
                addCommentVC.isEngineer = true
                addCommentVC.addCommentSuccessBlock = {[weak self] () in
                    //评价后刷新数据
                    if self?.refreshBlock != nil{
                        self?.refreshBlock!(2)
                    }
                }
                self.parentVC.navigationController?.pushViewController(addCommentVC, animated: true)
            }else{
                //查看评价
                //评价列表
                let commentVC = CommentListViewController()
                commentVC.orderId = subJson["id"].stringValue
                self.parentVC.navigationController?.pushViewController(commentVC, animated: true)
                
            }
        case 6:
            //拒绝调价
            params["state"] = "0"
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: AgreeOrUnAgreeChangePriceApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("设置成功！")
                //刷新数据
                if self.refreshBlock != nil{
                    self.refreshBlock!(2)
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
            
        case 7:
            if subJson["pay_statu"].stringValue.intValue == 0{
                LYAlertView.show("提示", "确定要取消此订单吗", "放弃取消", "确定取消",{
                    var params : [String : Any] = [:]
                    params["id"] = self.subJson["id"].stringValue
                    LYProgressHUD.showLoading()
                    NetTools.requestData(type: .post, urlString: CancelCustomerOrderApi, parameters: params, succeed: { (result, msg) in
                        LYProgressHUD.showSuccess("取消成功！")
                        //刷新数据
                        if self.refreshBlock != nil{
                            self.refreshBlock!(1)
                        }
                    }, failure: { (error) in
                        LYProgressHUD.showError(error!)
                    })
                })
                
            }else{
                
            }
        case 8:
            //转移状态 1转移中 2已接受 0已拒绝
            if subJson["move_state"].stringValue.intValue == 1{
                if subJson["bill_belong"].stringValue.intValue == 1{//1别人转给我的 2我转移给别人的
                    //同意转移
                    LYAlertView.show("提示", "确定同意接受转移的订单？", "取消", "确定",{
                        var params : [String : Any] = [:]
                        params["id"] = self.subJson["id"].stringValue
                        params["move_to_eng_id"] = self.subJson["ot_user_id"].stringValue//接受者的id
                        params["move_to_eng_name"] = self.subJson["call_nik_name"].stringValue//接受者的昵称
                        params["move_state"] = self.subJson["move_state"].stringValue
                        
                        LYProgressHUD.showLoading()
                        NetTools.requestData(type: .post, urlString: EngineerAgreeTransferMove, parameters: params, succeed: { (result, msg) in
                            LYProgressHUD.showSuccess("操作成功！")
                            //刷新数据
                            if self.refreshBlock != nil{
                                self.refreshBlock!(2)
                            }
                        }, failure: { (error) in
                            LYProgressHUD.showError(error!)
                        })
                    })
                }
            }else if subJson["move_state"].stringValue.intValue == 2{
                if subJson["bill_belong"].stringValue.intValue == 2{
                    //开始工作
                    self.beginOrderWork()
                }
            }
                //            else if subJson["move_state"].stringValue.intValue == 0{
                //            }
            else{
                //开始工作
                self.beginOrderWork()
            }
            
        default:
            print("未知状态")
        }
    }
    //右边按钮点击事件
    func rightReceiveAction() {
        var params : [String : Any] = [:]
        params["id"] = self.subJson["id"].stringValue
        
        switch subJson["bill_statu"].stringValue.intValue {
        case 0:
            //取消订单
            self.cancelOrderAction()
        case 2:
            if subJson["t_state"].stringValue.intValue == 0 || subJson["t_state"].stringValue.intValue == 4{
                //取消订单
                self.cancelOrderAction()
                
            }else if subJson["t_state"].stringValue.intValue == 1{
            }
            
        case 3:
            //删除我的接单
            self.deleteOrderAction()
        case 4:
            //取消订单
            self.cancelOrderAction()
        case 5:
            //删除我的接单
            self.deleteOrderAction()
        case 6:
            //同意调价
            params["state"] = "1"
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: AgreeOrUnAgreeChangePriceApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("设置成功！")
                //刷新数据
                if self.refreshBlock != nil{
                    self.refreshBlock!(2)
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
            
        case 7:
            if subJson["pay_statu"].stringValue.intValue == 0{
                //去支付
                let payVC = PaySendTaskViewController.spwan()
                payVC.isJustPay = true
                payVC.totalMoney = subJson["service_price"].stringValue.doubleValue
                payVC.orderId = subJson["id"].stringValue
                payVC.rePayOrderSuccessBlock = {[weak self] () in
                    //刷新数据
                    if self?.refreshBlock != nil{
                        self?.refreshBlock!(2)
                    }
                }
                self.parentVC.navigationController?.pushViewController(payVC, animated: true)
                
            }else{
                // 确认完成--> 去选择使用的备件sn码  并完成订单
                LYAlertView.show("提示", "是否使用了备件", "未使用", "选择备件", {
                    // 确认完成--> 去选择使用的备件sn码  并完成订单
                    //选择备件
                    let replacementVC = ReplacementPartListViewController()
                    replacementVC.orerId = self.subJson["id"].stringValue
                    replacementVC.isReplacementOrder = true
                    replacementVC.finishSuccessBlock = {[weak self] () in
                        //刷新数据
                        if self?.refreshBlock != nil{
                            self?.refreshBlock!(2)
                        }
                    }
                    self.parentVC.navigationController?.pushViewController(replacementVC, animated: true)
                },{
                    //未使用备件
                    LYProgressHUD.showLoading()
                    NetTools.requestData(type: .post, urlString: CustomerFinishOrderApi, parameters: params, succeed: { (result, msg) in
                        LYProgressHUD.dismiss()
                        //刷新数据
                        if self.refreshBlock != nil{
                            self.refreshBlock!(2)
                        }
                    }, failure: { (error) in
                        LYProgressHUD.showError(error!)
                    })
                })
                
            }
        case 8:
            
            //转移状态 1转移中 2已接受 0已拒绝
            if subJson["move_state"].stringValue.intValue == 1{
                if subJson["bill_belong"].stringValue.intValue == 1{//1别人转给我的 2我转移给别人的
                    //拒绝转移
                    LYAlertView.show("提示", "确定拒绝接受转移的订单？", "取消", "确定",{
                        var params : [String : Any] = [:]
                        params["id"] = self.subJson["id"].stringValue
                        params["move_to_eng_id"] = self.subJson["ot_user_id"].stringValue//接受者的id
                        params["move_to_eng_name"] = self.subJson["call_nik_name"].stringValue//接受者的昵称
                        params["move_state"] = self.subJson["move_state"].stringValue
                        LYProgressHUD.showLoading()
                        NetTools.requestData(type: .post, urlString: EngineerRefuseTransferMove, parameters: params, succeed: { (result, msg) in
                            LYProgressHUD.showSuccess("拒绝成功！")
                            //刷新数据
                            if self.refreshBlock != nil{
                                self.refreshBlock!(1)
                            }
                        }, failure: { (error) in
                            LYProgressHUD.showError(error!)
                        })
                    })
                    
                }
            }else if subJson["move_state"].stringValue.intValue == 2{
                if subJson["bill_belong"].stringValue.intValue == 2{
                    //取消订单
                    self.cancelOrderAction()
                }
            }
                //            else if subJson["move_state"].stringValue.intValue == 0{
                //            }
            else{
                //取消订单
                self.cancelOrderAction()
            }
            
        default:
            print("未知状态")
        }
    }
    //布局
    func myReceiveUI() {
        // 发单状态【0 撤销】【1 待接单】【2 已接单】【3 已完成】【4 已过期 or 已失效】【5 已取消】【6 调价中】【7 补单】【8 开始工作】
        
        //防止复用cell时继续计时
        self.timer.invalidate()
        
        switch subJson["bill_statu"].stringValue.intValue {
        case 0:
            self.stateLbl.text = "已撤销"
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 取消订单 ", for: .normal)
        case 1:
            self.stateLbl.text = "已报名"
        case 2:
            self.stateLbl.text = "已接单"
            self.chatBtn.isHidden = false
            if subJson["t_state"].stringValue.intValue == 0 || subJson["t_state"].stringValue.intValue == 4{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 确认完成 ", for: .normal)
            }else if subJson["t_state"].stringValue.intValue == 1{
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 等待客户确认完成 ", for: .normal)
                self.rightBtn.isSelected = true
                if subJson["is_special"].stringValue.intValue != 1{
                    self.centerBtn.isHidden = false
                    self.centerBtn.setTitle(" 服务单 ", for: .normal)
                }
            }
            
        case 3:
            self.rightBtn.isHidden = false
            self.rightBtn.setTitle(" 删除 ", for: .normal)
            self.centerBtn.isHidden = false
            
            if subJson["is_user_eval"].stringValue.intValue == 0{
                self.stateLbl.text = "已完成"
                self.centerBtn.setTitle(" 去评价 ", for: .normal)
            }else{
                self.stateLbl.text = "已评价"
                self.centerBtn.setTitle(" 查看评价 ", for: .normal)
            }
            if subJson["is_have_report"].stringValue.intValue == 1{
                self.leftBtn.isHidden = false
                self.leftBtn.setTitle(" 服务单 ", for: .normal)
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
            if subJson["pay_statu"].stringValue.intValue == 0{
                //                self.stateLbl.text = "待支付"
                self.codeTime = subJson["bill_end_time"].stringValue.intValue
                self.setUpCodeTimer()
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
            if subJson["move_state"].stringValue.intValue == 1{
                self.stateLbl.text = "转移待确定"
                if subJson["bill_belong"].stringValue.intValue == 1{//1别人转给我的 2我转移给别人的
                    self.rightBtn.isHidden = false
                    self.rightBtn.setTitle(" 拒绝 ", for: .normal)
                    self.centerBtn.isHidden = false
                    self.centerBtn.setTitle(" 同意 ", for: .normal)
                }else{
                    self.rightBtn.isHidden = true
                    self.centerBtn.isHidden = true
                }
            }else if subJson["move_state"].stringValue.intValue == 2{
                self.stateLbl.text = "来自订单转移"
                if subJson["bill_belong"].stringValue.intValue == 2{
                    self.rightBtn.isHidden = false
                    self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                    self.centerBtn.isHidden = false
                    self.centerBtn.setTitle(" 开始工作 ", for: .normal)
                    self.chatBtn.isHidden = false
                } else if subJson["bill_belong"].stringValue.intValue == 1{
                    self.rightBtn.isHidden = true
                    self.centerBtn.isHidden = true
                }
            }
                //            else if subJson["move_state"].stringValue.intValue == 0{
                //                self.stateLbl.text = "来自订单转移"
                //                self.rightBtn.isHidden = true
                //                self.centerBtn.isHidden = true
                //            }
            else{
                self.stateLbl.text = "已接单"
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(" 取消订单 ", for: .normal)
                self.centerBtn.isHidden = false
                self.centerBtn.setTitle(" 开始工作 ", for: .normal)
                self.chatBtn.isHidden = false
            }
        default:
            print("未知状态")
        }
        
        
        if subJson["service_price"].stringValue.floatValue > 0{
            self.priceTitleLbl.isHidden = false
            self.priceLbl.isHidden = false
        }else{
            self.priceTitleLbl.isHidden = true
            self.priceLbl.isHidden = true
        }
        
    }
    
    
    
    //MARK: - 计时器
    func setUpCodeTimer() {
        if self.timer.isValid{
            self.timer.invalidate()
        }
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(MySendOrderCell.changeCodeBtnTitle), userInfo: nil, repeats: true)
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
            //刷新数据
            //            if self.refreshBlock != nil{
            //                self.refreshBlock!()
            //            }
            self.stateLbl.text = "超时取消"
            self.timer.invalidate()
        }
        
    }
    
}



/**
 {
 call_nik_name = "",
 ot_user_id = "0",
 title = "存储设备-00Y2448",
 top_last_day = "0",
 is_eval = "0",
 bill_statu = "1",
 bill_end_time = 0,
 service_price = "1200.00",
 pay_statu = "1",
 bill_user_avatar = "http://www.7xiaofu.com/UPLOAD/sys/2017-07-26/~UPLOAD~sys~2017-07-26@1501051518.jpg240",
 os = "0",
 is_change_price = <null>,
 service_etime = "1501827240",
 id = "1169",
 inputtime = "1500963386",
 service_city = "北京市",
 is_top = "0",
 call_name = <null>,
 t_state = "0",
 ot_user_avatar = "http://www.7xiaofu.com/data/upload/shop/common/default_user_portrait.gif",
 entry_name = "IBM V7000硬盘调试",
 service_stime = "1500963240",
 },
 
 
 
 {
 call_nik_name = "勇闯天涯",
 ot_user_id = "1151",
 title = "桌面设备,信息安全-124",
 top_last_day = "0",
 eng_sucess_time = <null>,
 bill_statu = "8",
 is_eval = "0",
 bill_end_time = 0,
 goods_name = <null>,
 service_price = "114.00",
 pay_statu = "1",
 is_guoqi = <null>,
 bill_user_avatar = "http://10.216.2.11/UPLOAD/sys/2017-08-04/~UPLOAD~sys~2017-08-04@1501839011.jpg240",
 os = "0",
 move_to_eng_name = <null>,
 service_etime = "1503630480",
 id = "1138",
 inputtime = "1501845224",
 service_city = "上海市",
 is_top = "0",
 move_state = <null>,
 user_sucess_time = <null>,
 move_count = <null>,
 call_name = "18612334016",
 t_state = "0",
 move_to_eng_id = <null>,
 move_reason = <null>,
 ot_user_avatar = "http://10.216.2.11/UPLOAD/sys/2017-08-04/~UPLOAD~sys~2017-08-04@1501838972.jpg240",
 bill_belong = "2",
 entry_name = "2141",
 goods_sn = <null>,
 service_stime = "1501816134",
 },
 */
