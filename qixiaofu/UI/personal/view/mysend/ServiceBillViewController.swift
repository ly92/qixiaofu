//
//  ServiceBillViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ServiceBillViewController: BaseTableViewController {
    class func spwan() -> ServiceBillViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! ServiceBillViewController
    }
    
    var operationBlock : (() -> Void)?
    
    
    var billId = ""
    var billStatus = ""
    var shareUrl = ""
    var service_sector = ""
    var showType = 1 //1:工程师创建。2:工程师修改。3:客户确认前工程师查看（可编辑） 4:客户查看 5:客户确认后工程师查看（不可编辑）
    fileprivate var sTime = Date()
    fileprivate var eTime = Date()
    fileprivate var editBillId = ""
    fileprivate var deletedPartIds = Array<String>()//编辑时删除的备件
    
    fileprivate var machineTypeData = Array<Dictionary<String, String>>()//设备型号数组
    fileprivate var replaceMentData = Array<Dictionary<String, String>>()//备件使用数组
    fileprivate lazy var screenshotBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kScreenW-120, y: kScreenH-150, width: 60, height: 35)
        btn.backgroundColor = UIColor.RGB(r: 252, g: 150, b: 19)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10
        btn.setTitle("截屏", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        btn.addTarget(self, action: #selector(ServiceBillViewController.screenshot), for: .touchUpInside)
        return btn
    }()//截屏按钮
    fileprivate var currentOffsetY : CGFloat = 0//当前
    
    @IBOutlet weak var TF1: UITextField!//用户联系单位
    @IBOutlet weak var TF2: UITextField!//用户地点
    @IBOutlet weak var TF3: UITextField!//城市
    @IBOutlet weak var TF4: UITextField!//发单人ID
    @IBOutlet weak var TF5: UITextField!// 接单人ID
    @IBOutlet weak var TF6: UITextField!//服务领域
    @IBOutlet weak var TF7: UITextField!//服务类型
    @IBOutlet weak var TF8: UITextField!//到达时间
    @IBOutlet weak var TF9: UITextField!//离开时间
    @IBOutlet weak var TF10: UITextField!//工作时长
    @IBOutlet weak var TF11: UITextField!//订单号
    @IBOutlet weak var TF12: UITextField!//服务单号
    @IBOutlet weak var textView1: UITextView!//故障现象
    @IBOutlet weak var textView2: UITextView!//故障处理过程
    @IBOutlet weak var textView3: UITextView!//后续建议
    @IBOutlet weak var textView4: UITextView!//软件使用情况
    @IBOutlet weak var contentView1: UIView!//设备型号／序列号
    @IBOutlet weak var contentView2: UIView!//备件使用情况
    @IBOutlet weak var sureBtn: UIButton!//确认按钮
    
    
    fileprivate var serviceReplacementView = ServiceReplacementView()
    fileprivate var machineTypeView = MachineTypeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "现场服务记录报告"
        
        //设备型号以及备件使用
        self.setUPCustomViews()
        
        //设置是否可编辑
        self.prepareUI()
        
        //加载服务单详情
        self.loadServiceBillData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpScreenshotBtn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeScreenshotBtn()
    }
    
    
    
    
    //加载服务单详情
    func loadServiceBillData() {
        var params : [String : Any] = [:]
        params["bill_id"] = self.billId
        var url = ServiceBillDetailApi
        if self.showType == 1{
            url = PrepareServiceBillDetailApi
        }
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            
            self.editBillId = result["id"].stringValue
            
            self.TF1.text = result["company_name"].stringValue
            self.TF2.text = result["service_address"].stringValue
            self.TF3.text = result["service_city"].stringValue
            self.TF4.text = result["bill_user_id"].stringValue
            self.TF5.text = result["ot_user_id"].stringValue
            self.TF6.text = result["service_sector"].stringValue
            self.TF7.text = result["service_form"].stringValue
            self.TF8.text = Date.dateStringFromDate(format: Date.datesBiasFormatString(), timeStamps: result["bill_start_time"].stringValue)
            self.TF9.text = Date.dateStringFromDate(format: Date.datesBiasFormatString(), timeStamps: result["bill_sucess_time"].stringValue)
            self.sTime = Date.init(timeIntervalSince1970: TimeInterval(result["bill_start_time"].stringValue.intValue))
            self.eTime = Date.init(timeIntervalSince1970: TimeInterval(result["bill_sucess_time"].stringValue.intValue))
//            var second = result["bill_time"].stringValue.doubleValue
//            var str = ""
//            if second < 0{
//                second = -second
//            }
//            if second > 86400{
//                str = "\(Int(second / 86400))" + "天"
//                str += "\(Int(second.truncatingRemainder(dividingBy: 86400) / 3600))" + "时"
//                str += "\(Int(second.truncatingRemainder(dividingBy: 3600) / 60))" + "分"
//            }else if second > 3600{
//                str = "\(Int(second / 3600))" + "时"
//                str += "\(Int(second.truncatingRemainder(dividingBy: 3600) / 60))" + "分"
//            }else if second > 60{
//                str = "\(Int(second / 60))" + "分"
//                str += "\(Int(second.truncatingRemainder(dividingBy: 60)))" + "秒"
//            }else{
//                str = "\(second)" + "秒"
//            }
//            self.TF10.text = str
            self.TF10.text = result["bill_time"].stringValue
            self.TF11.text = result["bill_sn"].stringValue
            if self.showType != 1{
                self.TF12.text = result["service_sn"].stringValue
                self.textView1.text = result["fail_cause"].stringValue
                self.textView2.text = result["fail_handle"].stringValue
                self.textView3.text = result["after_advice"].stringValue
                self.textView4.text = result["use_software"].stringValue
                self.replaceMentData.removeAll()
                self.machineTypeData.removeAll()
                for subJson in result["parts"].arrayValue{
                    self.replaceMentData.append(subJson.dictionaryObject as! [String : String])
                }
                self.serviceReplacementView.dataArray = self.replaceMentData
                for subJson in result["equipment"].arrayValue{
                    self.machineTypeData.append(subJson.dictionaryObject as! [String : String])
                }
                if self.machineTypeData.count == 0{
                    self.machineTypeData.append(Dictionary<String, String>())
                }
                self.machineTypeView.dataArray = self.machineTypeData
            }
            
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    func setUPCustomViews() {
        self.machineTypeView = MachineTypeView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW-20, height: 0))
        self.machineTypeView.parentVC = self
        if self.machineTypeData.count == 0{
            
            self.machineTypeData.append(Dictionary<String, String>())
        }
        self.machineTypeView.dataArray = self.machineTypeData
        //设备型号数据变化
        self.machineTypeView.dataChangedBlock = {data in
            self.machineTypeData = data
            self.tableView.reloadData()
        }
        self.contentView1.addSubview(self.machineTypeView)
        
        self.serviceReplacementView = ServiceReplacementView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 20 , height: 0))
        self.serviceReplacementView.dataArray = self.replaceMentData
        self.serviceReplacementView.selectDataBlock = {index in
            if index == 666 {
                let addVC = AddReplaceMentViewController.spwan()
                addVC.billId = self.billId
                addVC.addDataBlock = {data in
                    self.replaceMentData.append(data)
                    self.serviceReplacementView.dataArray = self.replaceMentData
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(addVC, animated: true)
            }else{
                if self.replaceMentData.count > index{
                    let subJson = self.replaceMentData[index]
                    let addVC = AddReplaceMentViewController.spwan()
                    addVC.showType = self.showType
                    addVC.billId = self.billId
                    addVC.subJson = subJson
                    addVC.addDataBlock = {data in
                        self.replaceMentData.remove(at: index)
                        self.replaceMentData.insert(data, at: index)
                        self.serviceReplacementView.dataArray = self.replaceMentData
                        self.tableView.reloadData()
                    }
                    addVC.deleteDataBlock = {() in
                        if subJson.keys.contains("id"){
                            if !self.deletedPartIds.contains(subJson["id"]!){
                                self.deletedPartIds.append(subJson["id"]!)
                            }
                        }
                        self.replaceMentData.remove(at: index)
                        self.serviceReplacementView.dataArray = self.replaceMentData
                        self.tableView.reloadData()
                    }
                    self.navigationController?.pushViewController(addVC, animated: true)
                }
            }
        }
        self.contentView2.addSubview(self.serviceReplacementView)
        
        
    }
    
    func prepareUI() {
        self.sureBtn.layer.cornerRadius = 25
        self.machineTypeView.showType = self.showType
        self.serviceReplacementView.showType = self.showType
        self.deletedPartIds.removeAll()
        
        if self.showType == 1{
            //1:工程师创建
            self.TF4.isEnabled = false
            self.TF5.isEnabled = false
            self.TF6.isEnabled = false
            self.TF7.isEnabled = false
            self.TF10.isEnabled = false
            self.TF11.isEnabled = false
            
            self.TF1.isEnabled = true
            self.TF2.isEnabled = true
            self.TF3.isEnabled = true
            self.TF8.isEnabled = true
            self.TF9.isEnabled = true
            self.textView1.isEditable = true
            self.textView2.isEditable = true
            self.textView3.isEditable = true
            self.textView4.isEditable = true
            self.TF12.isEnabled = true
        }else if self.showType == 2{
            //2:工程师修改
            self.TF4.isEnabled = false
            self.TF5.isEnabled = false
            self.TF6.isEnabled = false
            self.TF7.isEnabled = false
            self.TF10.isEnabled = false
            self.TF11.isEnabled = false
            //            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", target: self, action: #selector(ServiceBillViewController.rightItemAction))
            self.TF1.isEnabled = true
            self.TF2.isEnabled = true
            self.TF3.isEnabled = true
            self.TF8.isEnabled = true
            self.TF9.isEnabled = true
            self.textView1.isEditable = true
            self.textView2.isEditable = true
            self.textView3.isEditable = true
            self.textView4.isEditable = true
            self.TF12.isEnabled = true
        }else{
            //3/4:客户/工程师查看
            self.TF1.isEnabled = false
            self.TF2.isEnabled = false
            self.TF3.isEnabled = false
            self.TF4.isEnabled = false
            self.TF5.isEnabled = false
            self.TF6.isEnabled = false
            self.TF7.isEnabled = false
            self.TF8.isEnabled = false
            self.TF9.isEnabled = false
            self.TF10.isEnabled = false
            self.TF11.isEnabled = false
            self.TF12.isEnabled = false
            self.textView1.isEditable = false
            self.textView2.isEditable = false
            self.textView3.isEditable = false
            self.textView4.isEditable = false
            if self.showType == 3{
                let item1 = UIBarButtonItem.init(image: #imageLiteral(resourceName: "edit_icon"), target: self, action: #selector(ServiceBillViewController.rightItemAction))
                let item2 = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_share"), target: self, action: #selector(ServiceBillViewController.shareAction))
                self.navigationItem.rightBarButtonItems = [item2,item1]
            }else{
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_share"), target: self, action: #selector(ServiceBillViewController.shareAction))
            }
        }
    }
    
    @objc func rightItemAction() {
        if self.showType == 2{
            self.showType = 3
        }else if self.showType == 3{
            self.showType = 2
        }
        self.prepareUI()
        self.tableView.reloadData()
    }
    
    //分享
    @objc func shareAction() {
        if self.shareUrl.isEmpty{
            LYProgressHUD.showError("工程师未提交服务单")
        }else{
            ShareView.show(url: self.shareUrl, title: "服务单", desc: "点击链接查看七小服平台服务单详细信息", viewController: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sureAction() {
        
        
        if self.showType == 4 && self.operationBlock != nil{
            self.operationBlock!()
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let company_name = self.TF1.text
        let service_address = self.TF2.text
        let service_city = self.TF3.text
        let service_sn = self.TF12.text
        let fail_cause = self.textView1.text
        let fail_handle = self.textView2.text
        let after_advice = self.textView3.text
        let use_software = self.textView4.text
        
        if (company_name?.isEmpty)!{
            LYProgressHUD.showError("用户联系单位不可为空")
            return
        }
        if (service_address?.isEmpty)!{
            LYProgressHUD.showError("用户地点不可为空")
            return
        }
        if (service_city?.isEmpty)!{
            LYProgressHUD.showError("城市不可为空")
            return
        }
        if (fail_cause?.isEmpty)!{
            LYProgressHUD.showError("故障现象不可为空")
            return
        }
        if (fail_handle?.isEmpty)!{
            LYProgressHUD.showError("故障处理过程不可为空")
            return
        }
        
        if self.machineTypeData.count == 0{
            LYProgressHUD.showError("请填写设备品牌型号和序列号")
            return
        }
        for json in self.machineTypeData{
            if json.keys.count > 0{
                if (json["equipment_type"]?.isEmpty)! || (json["equipment_pn"]?.isEmpty)!{
                    LYProgressHUD.showError("请补全设备品牌型号和序列号")
                    return
                }
            }else{
                LYProgressHUD.showError("请补全设备品牌型号和序列号")
                return
            }
        }
        //隐藏键盘
        self.view.endEditing(true)
        
        let equipment = self.machineTypeData.jsonString()
        var params : [String : Any] = [:]
        params["bill_id"] = self.billId
        //        params["service_sector"] = self.service_sector
        params["company_name"] = company_name
        params["service_address"] = service_address
        params["service_city"] = service_city
        params["service_sn"] = service_sn
        params["fail_cause"] = fail_cause
        params["fail_handle"] = fail_handle
        params["after_advice"] = after_advice
        params["use_software"] = use_software
        params["equipment"] = equipment
        params["delete_parts"] = self.deletedPartIds.joined(separator: ",")
        params["bill_start_time"] = self.sTime.phpTimestamp()
        params["bill_sucess_time"] = self.eTime.phpTimestamp()
        params["bill_time"] = "\(self.eTime.phpTimestamp().intValue - self.sTime.phpTimestamp().intValue)"
        
        //
        if self.replaceMentData.count > 0{
            let parts = self.replaceMentData.jsonString()
            params["parts"] = parts
        }
        LYProgressHUD.showLoading()
        
        var url = ""
        if self.showType == 1{
            url = AddServiceBillApi
        }else if self.showType == 2{
            url = ModifyServiceBillApi
            params["id"] = self.editBillId
        }else{
            return
        }
        
        
//        NetTools.requestDataTest(urlString: url, parameters: params, succeed: { (result) in
//            LYProgressHUD.showSuccess("保存成功！")
//            if self.operationBlock != nil{
//                self.operationBlock!()
//            }
//            print("----------------------------------------------------")
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
//                print("----------------------------------------------------")
//                self.navigationController?.popViewController(animated: true)
//            })
//        }) { (error) in
//            LYProgressHUD.showError(error!)
//        }
        
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("保存成功！")
            if self.operationBlock != nil{
                self.operationBlock!()
            }
            print("----------------------------------------------------")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                print("----------------------------------------------------")
                self.navigationController?.popViewController(animated: true)
            })
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
        /**
         
         Bill_id               订单id
         Company_name     公司名称       参数类型string
         Service_address         工作地点   参数类型string
         Service_sn       服务单号          参数类型string
         Fail_cause     故障现象            参数类型string
         Fail_handle      故障处理过程      参数类型string
         After_advice     后续建议          参数类型string
         
         Equipment       设备信息          参数类型array
         Equipment:[{
         equipment_type         设备类型
         equipment_pn          设备号
         },
         {
         equipment_type         设备类型
         equipment_pn          设备号
         } ...];
         
         
         
         Parts :[
         {
         parts_status          备件使用情况
         parts_pn            备件号
         new_serial            新序列号
         old_serial               旧序列号
         store_room                备件出处
         
         },
         {
         parts_status          备件使用情况
         parts_pn            备件号
         new_serial            新序列号
         old_serial               旧序列号
         store_room                备件出处
         },...];
         */
        
    }
    
}

extension ServiceBillViewController{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0...11:
            //用户联系单位~服务单号
            return 60
        case 12:
            //设备型号
            return CGFloat(self.machineTypeData.count * 35 + 65)
        case 13:
            //故障现象
            let size = self.textView1.text.sizeFitTextView(width: kScreenW - 55, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height < 60{
                self.textView1.h = 60
            }else{
                self.textView1.h = size.height
            }
            return self.textView1.h + 48
        case 14:
            //故障处理过程
            let size = self.textView2.text.sizeFitTextView(width: kScreenW - 55, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height < 60{
                self.textView2.h = 60
            }else{
                self.textView2.h = size.height
            }
            return self.textView2.h + 48
        case 15:
            //后续建议
            let size = self.textView3.text.sizeFitTextView(width: kScreenW - 55, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height < 60{
                self.textView3.h = 60
            }else{
                self.textView3.h = size.height
            }
            return self.textView3.h + 48
        case 16:
            //备件使用情况
            if self.showType == 1 || self.showType == 2{
                return CGFloat(self.replaceMentData.count * 35 + 40 + 32)
            }else if self.replaceMentData.count > 0{
                return CGFloat(self.replaceMentData.count * 35 + 32)
            }else{
                return 0
            }
        case 17:
            //软件使用情况
            let size = self.textView4.text.sizeFitTextView(width: kScreenW - 55, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height < 60{
                self.textView4.h = 60
            }else{
                self.textView4.h = size.height
            }
            return self.textView4.h + 48
        case 18:
            //确定按钮
            if billStatus.intValue == 2 {
                if self.showType == 1 || self.showType == 2{
                    return 150
                }else if self.showType == 4{
                    return 150
                }
            }
            return 0
        default:
            return 0
        }
    }
    
    //    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        if indexPath.row == 18{
    //            //确定按钮
    //            if self.showType == 1 || self.showType == 2 || self.showType == 4{
    //                cell.isHidden = false
    //            }else{
    //                cell.isHidden = true
    //            }
    //        }
    //    }
}

extension ServiceBillViewController : UITextViewDelegate, UITextFieldDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        self.tableView.reloadData()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        func setTF10Text(){
            var str = ""
            let days = self.sTime.daysBeforeDate(aDate: self.eTime)
            let hours = self.sTime.hourssBeforeDate(aDate: self.eTime)
            let mins = self.sTime.minutesBeforeDate(aDate: self.eTime)
            if days > 0{
                str = "\(days)天\(hours - days * 24)时\(mins - hours * 60)分"
            }else if hours > 0{
                str = "\(hours)时\(mins - hours * 60)分"
            }else if mins > 0{
                str = "\(mins)分"
            }else{
                str = "1分"
            }
            self.TF10.text = str
        }
        
        if textField == self.TF8 {
            let datePicker = LYDatePicker.init(component: 5)
            datePicker.ly_datepickerWithFiveComponent = {(date,year,month,day,hour,min) in
                if self.eTime.isEarlierThanDate(aDate: date){
                    //开始时间晚于结束时间
                    LYProgressHUD.showError("开始时间晚于结束时间")
                    return
                }
                self.sTime = date
                self.TF8.text = "\(year)/\(month)/\(day) \(hour):\(min)"
                setTF10Text()
            }
            datePicker.show()
            return false
        }else if textField == self.TF9{
            let datePicker = LYDatePicker.init(component: 5)
            datePicker.ly_datepickerWithFiveComponent = {(date,year,month,day,hour,min) in
                if self.sTime.isLaterThanDate(aDate: date){
                    //结束时间早于开始时间
                    LYProgressHUD.showError("结束时间早于开始时间")
                    return
                }
                self.eTime = date
                self.TF9.text = "\(year)/\(month)/\(day) \(hour):\(min)"
                setTF10Text()
            }
            datePicker.show()
            return false
        }
        return true
    }
    
    //MARK:截屏
    func setUpScreenshotBtn() {
        // 监听屏幕截图
        NotificationCenter.default.addObserver(self, selector: #selector(ServiceBillViewController.screenshot), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        UIApplication.shared.keyWindow?.addSubview(self.screenshotBtn)
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(ServiceBillViewController.panDirection(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delaysTouchesBegan = true
        pan.delaysTouchesEnded = true
        pan.cancelsTouchesInView = true
        self.screenshotBtn.addGestureRecognizer(pan)
    }
    
    func removeScreenshotBtn() {
        NotificationCenter.default.removeObserver(self)
        self.screenshotBtn.removeFromSuperview()
    }
    
    @objc func screenshot() {
        guard let image = self.tableView.getScreenshotImage(nil) else {
            return
        }
        //保存图片到本地
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(ServiceBillViewController.save(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func save(image:UIImage, didFinishSavingWithError:NSError?,contextInfo:AnyObject) {
        if didFinishSavingWithError == nil{
            LYProgressHUD.showSuccess("保存成功！请前往相册查看")
        }else{
            LYAlertView.show("提示", "保存失败，请检查是否允许访问相册权限", "去设置","取消",{
                //打开设置页面
                let url = URL(string:UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            })
        }
    }
    
    @objc func panDirection(_ pan:UIPanGestureRecognizer) {
        if pan.state != .failed && pan.state != .recognized{
            guard let keyWindow = UIApplication.shared.keyWindow else{
                return
            }
            self.screenshotBtn.center = pan.location(in: keyWindow)
            if self.screenshotBtn.x < 0{
                self.screenshotBtn.frame = CGRect.init(x: 0, y: self.screenshotBtn.y, width: self.screenshotBtn.w, height: self.screenshotBtn.h)
            }
            if self.screenshotBtn.x > keyWindow.w - self.screenshotBtn.w{
                self.screenshotBtn.frame = CGRect.init(x: keyWindow.w - self.screenshotBtn.w, y: self.screenshotBtn.y, width: self.screenshotBtn.w, height: self.screenshotBtn.h)
            }
            
            if self.screenshotBtn.y < 88{
                self.screenshotBtn.frame = CGRect.init(x: self.screenshotBtn.x, y: 88, width: self.screenshotBtn.w, height: self.screenshotBtn.h)
            }
            
            if self.screenshotBtn.y > keyWindow.h - self.screenshotBtn.h - 20{
                self.screenshotBtn.frame = CGRect.init(x: self.screenshotBtn.x, y: keyWindow.h - self.screenshotBtn.h - 20, width: self.screenshotBtn.w, height: self.screenshotBtn.h)
            }
            
        }
    }
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.currentOffsetY = scrollView.contentOffset.y
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.currentOffsetY > scrollView.contentOffset.y{
            self.screenshotBtn.isHidden = false
        }else{
            self.screenshotBtn.isHidden = true
        }
    }
    
}




