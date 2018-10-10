//
//  SendTaskViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SendTaskViewController: BaseTableViewController {
    class func spwan() -> SendTaskViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! SendTaskViewController
    }
    
    var isRepairOrder = false//是否为补单
    var isRedoOrder = false//是否为重新发布
    var orderId = ""

    
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var serverControlLbl: UILabel!
    @IBOutlet weak var serverTypeLbl: UILabel!
    @IBOutlet weak var serverAreaLbl: UILabel!
    @IBOutlet weak var serverStartTimeLbl: UILabel!
    @IBOutlet weak var serverEndTimeLbl: UILabel!
    @IBOutlet weak var serverRangeLbl: UILabel!
    @IBOutlet weak var goodsBrandLbl: UILabel!
    @IBOutlet weak var countTF: UITextField!
    @IBOutlet weak var unitTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var goodsBrandTF: UITextField!
    @IBOutlet weak var priceInfoLbl: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    fileprivate var sTime : Date?
    fileprivate var eTime : Date?
    fileprivate var lat : String = ""
    fileprivate var lon : String = ""
    fileprivate var city : String = ""
    fileprivate var address : String = ""
    
    fileprivate var params : [String : Any] = [:]//参数
    
    fileprivate var controlJson : JSON = []
    fileprivate var rangeJson : JSON = []
    fileprivate var paymentJson : JSON = []
    fileprivate var serverTypeJson : JSON = []
    fileprivate var facilityData : JSON = []
    fileprivate var top_price : String = "100"
    
    fileprivate var redoOrderDataJson : JSON = []//重新发单时的订单信息
    
    fileprivate var service_form : String = ""//服务形式
    fileprivate var service_type : String = ""//服务类型
    fileprivate var service_sector : String = ""//服务领域
    
    
    
    fileprivate var selectedServerRangeIndex : Array<String>?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载必要条件数据
        self.loadEssentialData()
        self.loadFacilityData()
        
        if self.isRedoOrder{
            self.loadRedoOrderData()
            self.navigationItem.title = "发单"
        }else if self.isRepairOrder{
            self.navigationItem.title = "补单"
        }else{
            self.navigationItem.title = "发单"
            
        }
        self.nextBtn.layer.cornerRadius = 20.0
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "notice_icon") ,target:self,action:#selector(SendTaskViewController.rightItemAction))
        
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(SendTaskViewController.backClick))
    
        
        //是否已提示解决故障的步骤
        if !LocalData.getYesOrNotValue(key: "haveShowSendStep"){
            self.rightItemAction()
            LocalData.saveYesOrNotValue(value: "1", key: "haveShowSendStep")
        }
    }
    
    //重新发布订单时先加载订单详情
    func loadRedoOrderData() {
        let redoParams : [String : Any] = ["id" : self.orderId]
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: RedoOrderDataApi, parameters: redoParams, succeed: { (result, msg) in
            
            self.taskNameTF.text = result["entry_name"].stringValue
            self.taskNameTF.isEnabled = false
            self.serverControlLbl.text = result["service_form"].stringValue
            self.serverTypeLbl.text = result["service_type"].stringValue
            self.serverAreaLbl.text = result["service_address"].stringValue
            self.serverRangeLbl.text = result["service_sector"].stringValue
            self.goodsBrandTF.text = result["service_brand"].stringValue
            self.goodsBrandTF.isEnabled = false
            self.countTF.text = result["number"].stringValue
            self.unitTF.text = result["number_unit"].stringValue
            self.unitTF.isEnabled = false
            self.priceTF.text = result["service_price"].stringValue
            self.priceTF.isEnabled = false
            
            self.redoOrderDataJson = result
            
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //分类和型号数据
    func loadFacilityData(){
        NetTools.requestData(type: .post, urlString: SendTaskFacilityTypeApi, succeed: { (resultJson, msg) in
            self.facilityData = resultJson
        }) { (error) in
            LYProgressHUD.showError(error ?? "分类型号数据加载失败，可手动输入")
        }
    }
    
    //下一步
    @IBAction func nextAction() {
        if self.isRedoOrder{
            var redoParams : [String : Any] = [:]
            redoParams["id"] = self.orderId
            let count = self.countTF.text!
            
            if (self.sTime?.phpTimestamp().isEmpty)! {
                LYProgressHUD.showError("请选择开始时间")
                return
            }
            redoParams["service_stime"] = self.sTime?.phpTimestamp()
            
            if (self.eTime?.phpTimestamp().isEmpty)! {
                LYProgressHUD.showError("请选择结束时间")
                return
            }
            redoParams["service_etime"] = self.eTime?.phpTimestamp()
            if (sTime?.isLaterThanDate(aDate: eTime!))!{
                LYProgressHUD.showError("开始时间不可晚于结束时间！")
                return
            }
            if count.isEmpty && count.intValue > 0 {
                LYProgressHUD.showError("请输入数量")
                return
            }
            redoParams["number"] = count
            
            let sendVC = SendTaskSureViewController.spwan()
            sendVC.params = redoParams
            sendVC.redoOrderDataJson = self.redoOrderDataJson
            sendVC.isRedoOrder = self.isRedoOrder
            sendVC.top_price = self.top_price
            self.navigationController?.pushViewController(sendVC, animated: true)
            
        }else{
            if self.setUpParams(true){
                if self.isRepairOrder{
                    params["is_compe"] = "1"//表示补单
                    let payVC = PaySendTaskViewController.spwan()
                    payVC.paymentJson = paymentJson
                    payVC.isRepairOrder = true
                    payVC.params = params
                    self.navigationController?.pushViewController(payVC, animated: true)
                }else{
                    let sendVC = SendTaskSureViewController.spwan()
                    sendVC.params = params
                    sendVC.paymentJson = paymentJson
                    sendVC.top_price = self.top_price
                    self.navigationController?.pushViewController(sendVC, animated: true)
                }
                
            }
        }
    }
    
    //MARK: 返回时提示保存
    @objc func backClick() {
        //关闭编辑状态
        self.view.endEditing(true)
        let _ = self.setUpParams(false)
        if self.params.keys.count > 0 && !self.isRedoOrder{
            LYAlertView.show("提示", "是否保存草稿，保存后下次打开将自动填充", "放弃", "保存", {
                if self.params.keys.count > 0{
                    LocalData.saveSendTaskData(dict: self.params)
                }
                self.navigationController?.popViewController(animated: true)
            },{
                LocalData.saveSendTaskData(dict: [:])
                self.navigationController?.popViewController(animated: true)
            })
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //MARK: 添加退入后台的通知
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //进入后台的通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ""), object: self, queue: OperationQueue.main) { (noti) in
            let _ = self.setUpParams(false)
            if self.params.keys.count > 0{
                LocalData.saveSendTaskData(dict: self.params)
            }
        }
    }
    //MARK: 去除退入后台的通知
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //移除进入后台的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ""), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //加载必要条件数据
    func loadEssentialData() {
        NetTools.requestData(type: .post, urlString: SendTaskEssentialDataApi, succeed: { (resultJson, error) in
            self.controlJson = resultJson["service_form"]
            self.rangeJson = resultJson["service_sector"]
            self.paymentJson = resultJson["payment_list"]
            self.serverTypeJson = resultJson["service_type"]
            self.top_price = resultJson["top_price"].stringValue
            
            self.priceInfoLbl.text = resultJson["price_info"].stringValue
            
            if !self.isRedoOrder{
                //根据草稿填充信息
                self.params = LocalData.getSendTaskData()
                self.prepareLocalData()
            }
            
        }) { (error) in
            
        }
    }
    //根据草稿填充信息
    func prepareLocalData() {
        if params.keys.count == 0{
            return
        }
        if params.keys.contains("project_name"){
            self.taskNameTF.text = (params["project_name"] as! String)
        }
        if params.keys.contains("service_form"){
            service_form = params["service_form"] as! String
            for subJson in self.controlJson.arrayValue {
                if subJson["field_value"].stringValue.intValue == (params["service_form"] as! String).intValue{
                    self.serverControlLbl.text = subJson["field_name"].stringValue
                }
            }
        }
        if params.keys.contains("service_type"){
            service_type = params["service_type"] as! String
            for subJson in self.serverTypeJson.arrayValue {
                if subJson["field_value"].stringValue.intValue == (params["service_type"] as! String).intValue{
                    self.serverTypeLbl.text = subJson["field_name"].stringValue
                }
            }
        }
        if params.keys.contains("service_address") && params.keys.contains("lng") && params.keys.contains("lat"){
            self.serverAreaLbl.text = (params["service_address"] as! String) + (params["service_city"] as! String)
            self.address = params["service_address"] as! String
            self.lat = params["lat"] as! String
            self.lon = params["lng"] as! String
        }
        if params.keys.contains("service_stime"){
            sTime = Date.init(timeIntervalSince1970: TimeInterval(params["service_stime"] as! String)!)
            self.serverStartTimeLbl.text = Date.dateStringFromDate(format: Date.datesChineseFormatString(), timeStamps: (params["service_stime"] as! String))
        }
        if params.keys.contains("service_etime"){
            eTime = Date.init(timeIntervalSince1970: TimeInterval(params["service_etime"] as! String)!)
            self.serverEndTimeLbl.text = Date.dateStringFromDate(format: Date.datesChineseFormatString(), timeStamps: (params["service_etime"] as! String))
        }
        if params.keys.contains("service_sector") && params.keys.contains("title"){
            service_sector = params["service_sector"] as! String
            self.serverRangeLbl.text = params["title"] as? String
        }
        if params.keys.contains("service_brand"){
            self.goodsBrandTF.text = (params["service_brand"] as! String)
        }
        if params.keys.contains("number"){
            self.countTF.text = (params["number"] as! String)
        }
        if params.keys.contains("number_unit"){
            self.unitTF.text = (params["number_unit"] as! String)
        }
        if params.keys.contains("service_price"){
            self.priceTF.text = (params["service_price"] as! String)
        }
    }
    //添加参数
    func setUpParams(_ showError:Bool) -> Bool{
        let taskName = self.taskNameTF.text!
        let serverRangeStr = self.serverRangeLbl.text!
        let brand = self.goodsBrandTF.text!
        let count = self.countTF.text!
        let unit = self.unitTF.text!
        let price = self.priceTF.text!
        
        if taskName.isEmpty{
            if showError {
                LYProgressHUD.showError("请输入项目名称")
            }
            return false
        }
        params["project_name"] = taskName
        
        if service_form.isEmpty{
            if showError {
                LYProgressHUD.showError("请选择服务形式")
            }
            return false
        }
        params["service_form"] = service_form
        
        
        if service_type.isEmpty{
            if showError {
                LYProgressHUD.showError("请选择服务类型")
            }
            return false
        }
        params["service_type"] = service_type
        
        if self.address.isEmpty{
            if showError {
                LYProgressHUD.showError("请选择服务区域")
            }
            return false
        }
        params["service_address"] = self.address
        params["service_city"] = self.city
        params["lng"] = self.lon
        params["lat"] = self.lat
        
        if self.sTime == nil || self.eTime == nil{
            if showError {
                LYProgressHUD.showError("请选择时间")
            }
            return false
        }
        if (self.sTime?.phpTimestamp().isEmpty)! {
            if showError {
                LYProgressHUD.showError("请选择开始时间")
            }
            return false
        }
        params["service_stime"] = self.sTime?.phpTimestamp()
        
        if (self.eTime?.phpTimestamp().isEmpty)! {
            if showError {
                LYProgressHUD.showError("请选择结束时间")
            }
            return false
        }
        params["service_etime"] = self.eTime?.phpTimestamp()
        if showError{
            if (sTime?.isLaterThanDate(aDate: eTime!))!{
                LYProgressHUD.showError("开始时间不可晚于结束时间！")
                return false
            }
        }
        
        if service_sector.isEmpty{
            if showError {
                LYProgressHUD.showError("请选择服务领域")
            }
            return false
        }
        params["service_sector"] = service_sector
        params["title"] = serverRangeStr
        
        if brand.isEmpty{
            if showError {
                LYProgressHUD.showError("请输入品牌型号")
            }
            return false
        }
        params["service_brand"] = brand
        
        if count.isEmpty && count.intValue > 0{
            if showError {
                LYProgressHUD.showError("请输入数量")
            }
            return false
        }
        params["number"] = count
        
        if unit.isEmpty{
            if showError {
                LYProgressHUD.showError("请输入单位")
            }
            return false
        }
        params["number_unit"] = unit
        
        if price.isEmpty{
            if showError {
                LYProgressHUD.showError("请输入价格")
            }
            return false
        }
        if price.doubleValue <= 0{
            if showError {
                LYProgressHUD.showError("请输入标准价格")
            }
            return false
        }
        params["service_price"] = price
        
        return true
    }
    
    //弹出
    @objc func rightItemAction() {
        let image = #imageLiteral(resourceName: "send_task_step")
        let h = kScreenW / image.size.width * image.size.height
        let scroll = UIScrollView.init(frame: CGRect.init(x: kScreenW-40, y: 50, width: 0, height: 0))
//        scroll.backgroundColor = UIColor.colorHexWithAlpha(hex: "000000", alpha: 0.5)
        let imgV = UIImageView.init(image: image)
        imgV.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: h)
        scroll.addSubview(imgV)
        scroll.contentSize = CGSize.init(width: kScreenW, height: h)
        UIApplication.shared.keyWindow?.addSubview(scroll)
        
        UIView.animate(withDuration: 0.5) {
            scroll.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        }
        
        scroll.addTapActionBlock {
            UIView.animate(withDuration: 0.5, animations: {
                scroll.frame = CGRect.init(x: kScreenW-40, y: 50, width: 0, height: 0)
            }, completion: { (comple) in
                scroll.removeFromSuperview()
            })
        }
    }
    
    
}

//MARK: - UITableViewDelegate
extension SendTaskViewController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.view.endEditing(true)
        
        
        if self.isRedoOrder{
            if indexPath.row != 4 && indexPath.row != 5{
                return
            }
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                //服务形式
                var arrM = Array<String>()
                if self.controlJson.arrayValue.count > 0{
                    for subJson in self.controlJson.arrayValue {
                        arrM.append(subJson["field_name"].stringValue)
                    }
                }else{
                    arrM = ["现场服务","培训服务","远程服务"]
                }
                LYPickerView.show(titles: arrM, selectBlock: {[weak self] (title,index) in
                    self?.serverControlLbl.text = title
                    self?.service_form = "\(index + 1)"
                })
                
            case 2:
                //服务类型
                var arrM = Array<String>()
                if self.serverTypeJson.arrayValue.count > 0{
                    for subJson in self.serverTypeJson.arrayValue {
                        arrM.append(subJson["field_name"].stringValue)
                    }
                }else{
                    arrM = ["安装","巡检","调试","故障","方案","售前","培训","驻场","搬迁","咨询"]
                }
                LYPickerView.show(titles: arrM, selectBlock: {[weak self] (title,index) in
                    self?.serverTypeLbl.text = title
                    self?.service_type = "\(index + 1)"
                })
            case 3:
                //服务区域
                let editVC = AddAddressViewController.spwan()
                editVC.isFromSendTask = true
                editVC.selectAddressBlock = { (dict) in
                    //重新加载
                    self.lat = dict["lat"]!
                    self.lon = dict["lon"]!
                    self.address = dict["province"]!
                    self.city = dict["address"]!
                    self.serverAreaLbl.text = dict["province"]! + self.city
                }
                self.navigationController?.pushViewController(editVC, animated: true)
            case 4:
                //预约开始时间
                let datePicker = LYDatePicker.init(component: 4)
                datePicker.ly_datepickerWithFourComponent = {(date,year,month,day,hour) in
                    self.sTime = date
                    self.serverStartTimeLbl.text = "\(year)年\(month)月\(day)日 \(hour)时"
                }
                datePicker.show()
                
            case 5:
                //预约结束时间
                let datePicker = LYDatePicker.init(component: 4)
                datePicker.ly_datepickerWithFourComponent = {(date,year,month,day,hour) in
                    self.eTime = date
                    self.serverEndTimeLbl.text = "\(year)年\(month)月\(day)日 \(hour)时"
                }
                datePicker.show()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                //服务领域
                let serverRangeVC = ServerRangeViewController.spwan()
                if (self.selectedServerRangeIndex != nil){
                    serverRangeVC.selectedIds = self.selectedServerRangeIndex!
                }
                serverRangeVC.serverRangeBlock = {[weak self] (selectedDictArray,titles,ids) in
                    self?.serverRangeLbl.text = titles.joined(separator: ";")
                    self?.selectedServerRangeIndex = ids
                    self?.service_sector = ids.joined(separator: ",")
                }
                serverRangeVC.dataArray = self.rangeJson.arrayValue
                self.navigationController?.pushViewController(serverRangeVC, animated: true)
            case 1:
                //品牌型号
                let picker = LYBrandPickerView()
                picker.show(facilityData)
                picker.pickerViewBlock = {(brand,type,model) in
                    self.goodsBrandTF.text = brand + " " + type + " " + model
                }
                
            default:
                break
            }
        default:
            break
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.taskNameTF.isFirstResponder{
            self.view.endEditing(true)
        }
    }
    
    
    
}
//MARK: - UITextFieldDelegate
extension SendTaskViewController : UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.textAlignment = .left
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textAlignment = .right
    }
}
