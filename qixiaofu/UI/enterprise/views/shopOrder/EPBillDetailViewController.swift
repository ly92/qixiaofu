//
//  EPBillDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/24.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPBillDetailViewController: BaseViewController {
    class func spwan() -> EPBillDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPBillDetailViewController
    }
    
    
    @IBOutlet weak var topTimeView: UIView!
    @IBOutlet weak var topTypeView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var timeArrowImgV: UIImageView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var typeArrowImgV: UIImageView!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView2: UIView!
//    @IBOutlet weak var startTimeTF: UITextField!
//    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTypeView: UIView!
    @IBOutlet weak var filterTypeViewH: NSLayoutConstraint!
    //    @IBOutlet weak var filterTimeView: UIView!
    
    var buyerId = ""
//    fileprivate var curpage = 1
    fileprivate var startTime = "0"
    fileprivate var endTime = "0"
    fileprivate var type = "0"
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var is_settle = ""//空 代表全部 0 代表未结 1代表已结
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "账单"
        self.tableView.register(UINib.init(nibName: "EnterpriseBillDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "EnterpriseBillDetailCell")
        self.tableView.register(UINib.init(nibName: "EPBillDetailReturnCell", bundle: Bundle.main), forCellReuseIdentifier: "EPBillDetailReturnCell")
        
        self.loadData()
//        self.addRefresh()
        
        self.addFilterAction()
    }
    
    func addFilterAction() {
        
        //初始时间-当月
        let curYear = Date.currentYear()
        let curMonth = Date.currentMonth()
        self.timeLbl.text = "\(curYear)年-\(curMonth)月"
        
        self.topTimeView.addTapActionBlock {
            self.timeArrowImgV.image = #imageLiteral(resourceName: "up_arrow")
            let datePicker = LYDatePicker.init(component: 2)
            datePicker.ly_datepickerWithTwoComponent = {(date,year,month) in
                self.timeLbl.text = "\(year)年-\(month)月"
                self.timeArrowImgV.image = #imageLiteral(resourceName: "down_arrow")
                
                let days = Date.dayCountInYearAndMonth(year: year, month: month)
                
                let start = Date.dateFromDateString(format: Date.dateFormatString(), dateString: "\(year)-\(month)-01")
                let end = start.dateWithDaysAfter(days: Double(days))
                
                self.startTime = start.phpTimestamp()
                self.endTime = end.phpTimestamp()
                
//                print(days)
//                print(Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: self.startTime))
//                print(Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: self.endTime))
                
                self.loadData()
            }
            datePicker.dismissBlock = {() in
                self.timeArrowImgV.image = #imageLiteral(resourceName: "down_arrow")
            }
            datePicker.show()
            self.filterView.isHidden = true
            self.typeArrowImgV.image = #imageLiteral(resourceName: "down_arrow")
        }
        
        self.topTypeView.addTapActionBlock {
            DispatchQueue.main.async {
                if self.filterView.isHidden{
                    self.filterTypeViewH.constant = 3
                    UIView.animate(withDuration: 0.5, animations: {
                        self.filterTypeViewH.constant = 135
                    })
                    self.filterView.isHidden = false
                    self.typeArrowImgV.image = #imageLiteral(resourceName: "up_arrow")
                }else{
                    UIView.animate(withDuration: 0.5, animations: {
                        self.filterTypeViewH.constant = 3
                    }, completion: { (comp) in
                        self.filterView.isHidden = true
                        self.typeArrowImgV.image = #imageLiteral(resourceName: "down_arrow")
                    })
                }
            }
        }
    }
    
//    func addRefresh() {
//        self.tableView.es.addPullToRefresh {
//            self.curpage = 1
//            self.loadData()
//        }
//        self.tableView.es.addInfiniteScrolling {
//            self.curpage += 1
//            self.loadData()
//        }
//    }
    
    func loadData() {
        var params : [String : Any] = [:]
        params["start_time"] = self.startTime
        params["end_time"] = self.endTime
//        params["curpage"] = self.curpage
        params["buyer_id"] = self.buyerId
        params["is_settle"] = self.is_settle
        NetTools.requestData(type: .post, urlString: EnterpriseDetailBillApi, parameters: params, succeed: { (resultJson, msg) in
//            if self.curpage == 1{
//                self.tableView.es.stopPullToRefresh()
//                self.dataArray.removeAll()
//            }else{
//                self.tableView.es.stopLoadingMore()
//            }
            self.dataArray.removeAll()
//            if resultJson["list"].arrayValue.count < 10{
//                self.tableView.es.noticeNoMoreData()
//            }else{
//                self.tableView.es.resetNoMoreData()
//            }
            for json in resultJson["list"].arrayValue{
                self.dataArray.append(json)
            }
            
            if self.dataArray.count > 0{
                self.emptyView2.isHidden = true
            }else{
                self.emptyView2.isHidden = false
            }
            self.moneyLbl.text = "合计：¥" + resultJson["sum"].stringValue
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "数据请求失败！")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAction(_ btn: UIButton) {
//        self.curpage = 1
        if btn.tag == 11{
            //全部类型
            self.is_settle = ""
            self.typeLbl.text = "全部"
        }else if btn.tag == 22{
            //未结账单
            self.typeLbl.text = "未结账单"
            self.is_settle = "0"
        }else if btn.tag == 33{
            //已结账单
            self.typeLbl.text = "已结账单"
            self.is_settle = "1"
        }
        
        //黑色半透明
        if btn.tag != 66{
            self.loadData()
        }
        self.typeArrowImgV.image = #imageLiteral(resourceName: "down_arrow")
        self.filterView.isHidden = true
    }
    
    
    
}

//时间选择
extension EPBillDetailViewController : UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == self.startTimeTF{
//            let datePicker = LYDatePicker.init(component: 3)
//            datePicker.ly_datepickerWithThreeComponent = {(date,year,month,day) in
//                self.startTime = date.phpTimestamp()
//                self.startTimeTF.text = "\(year)-\(month)-\(day)"
//            }
//            datePicker.show()
//            return false
//        }else if textField == self.endTimeTF{
//            let datePicker = LYDatePicker.init(component: 3)
//            datePicker.ly_datepickerWithThreeComponent = {(date,year,month,day) in
//                self.endTime = date.phpTimestamp()
//                self.endTimeTF.text = "\(year)-\(month)-\(day)"
//            }
//            datePicker.show()
//            return false
//        }
        return true
    }
}

extension EPBillDetailViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataArray.count > section{
            let subJson = self.dataArray[section]
            if subJson["return_list"].arrayValue.count > 0{
                return subJson["goods"].arrayValue.count + 1
            }else{
                return subJson["goods"].arrayValue.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.dataArray.count > indexPath.section{
            let subJson = self.dataArray[indexPath.section]
            if subJson["goods"].arrayValue.count > indexPath.row{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EnterpriseBillDetailCell", for: indexPath) as! EnterpriseBillDetailCell
                let json = subJson["goods"].arrayValue[indexPath.row]
                cell.subJson = json
            }else if subJson["goods"].arrayValue.count == indexPath.row{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "EPBillDetailReturnCell", for: indexPath) as! EPBillDetailReturnCell
                let json = subJson["return_list"]
                cell.dataArray = json
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count > indexPath.section{
            let subJson = self.dataArray[indexPath.section]
            if subJson["goods"].arrayValue.count > indexPath.row{
                return 35
            }else if subJson["goods"].arrayValue.count == indexPath.row{
                let returnList = subJson["return_list"].arrayValue
                var num = 0
                for goods in returnList{
                    num += goods["mingxi"].arrayValue.count
                }
                let tableH = returnList.count * 30 + num * 25
                return CGFloat(66 + tableH)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 60))
        view.backgroundColor = BG_Color
        let subView = UIView(frame: CGRect.init(x: 0, y: 8, width: kScreenW, height: 51))
        subView.backgroundColor = UIColor.white
        view.addSubview(subView)
        
        let billLbl = UILabel(frame: CGRect.init(x: 10, y: 20, width: kScreenW - 180, height: 20))
        billLbl.textColor = Text_Color
        billLbl.font = UIFont.systemFont(ofSize: 13.0)
        subView.addSubview(billLbl)
        let timeLbl = UILabel(frame: CGRect.init(x: kScreenW - 160, y: 20, width: 150, height: 20))
        timeLbl.textColor = Text_Color
        timeLbl.font = UIFont.systemFont(ofSize: 12.0)
        timeLbl.textAlignment = .right
        subView.addSubview(timeLbl)
        
        if self.dataArray.count > section{
            let subJson = self.dataArray[section]
            billLbl.text = "订单号：" + subJson["order_number"].stringValue
            timeLbl.text = Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: subJson["order_time"].stringValue)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 30))
        view.backgroundColor = UIColor.white
        let lbl = UILabel(frame: CGRect.init(x: 0, y: 0, width: kScreenW-10, height: 20))
        lbl.textColor = Normal_Color
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.textAlignment = .right
        view.addSubview(lbl)
        if self.dataArray.count > section{
            let subJson = self.dataArray[section]
           lbl.text = "¥" + subJson["total_amount"].stringValue
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
}
