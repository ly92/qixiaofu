//
//  SetSpaceTimeViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/12.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias SetSpaceTimeSuccessBlock = () -> Void

class SetSpaceTimeViewController: BaseTableViewController {
    class func spwan() -> SetSpaceTimeViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! SetSpaceTimeViewController
    }
    
    var setSpaceTimeBlock : SetSpaceTimeSuccessBlock?
    
    
    @IBOutlet weak var areaLbl1: UILabel!
    @IBOutlet weak var areaLbl2: UILabel!
    @IBOutlet weak var areaLbl3: UILabel!
    @IBOutlet weak var sTimeLbl: UILabel!
    @IBOutlet weak var eTimeLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!

    fileprivate var sTime : Date?
    fileprivate var eTime : Date?
    
    fileprivate lazy var areaArray : Array<[String : Any]> = {
        var array = Array<[String : Any]>()
        array = [[String : Any](),[String : Any](),[String : Any]()]
        return array
    }()
    
    fileprivate var showAreaOne = false
    fileprivate var showAreaTwo = false
    
    var subJson : JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "设置空闲时间"
        self.sendBtn.layer.cornerRadius = 20
        
        if subJson != nil{
            self.prepareData(json: self.subJson!)
        }
    }
    
    func prepareData(json : JSON) {
        self.sTime = Date.init(timeIntervalSince1970: json["service_stime"].stringValue.doubleValue)
        self.sTimeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: json["service_stime"].stringValue)
        self.eTime = Date.init(timeIntervalSince1970: json["service_etime"].stringValue.doubleValue)
        self.eTimeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: json["service_etime"].stringValue)
        
        for i in 0...json["tack_arrays"].arrayValue.count - 1{
            let sub = json["tack_arrays"].arrayValue[i]
            var dict : [String : Any] = [:]
            dict["address"] = sub["address"].stringValue
            dict["lng"] = sub["lng"].stringValue.floatValue
            dict["lat"] = sub["lat"].stringValue.floatValue
            self.areaArray[i] = dict
        }
        
        if json["tack_arrays"].arrayValue.count == 1{
            self.areaLbl1.text = json["tack_arrays"].arrayValue[0]["address"].stringValue
        }else if json["tack_arrays"].arrayValue.count == 2{
            self.areaLbl1.text = json["tack_arrays"].arrayValue[0]["address"].stringValue
            self.areaLbl2.text = json["tack_arrays"].arrayValue[1]["address"].stringValue
            self.showAreaOne = true
        }else{
            self.areaLbl1.text = json["tack_arrays"].arrayValue[0]["address"].stringValue
            self.areaLbl2.text = json["tack_arrays"].arrayValue[1]["address"].stringValue
            self.areaLbl3.text = json["tack_arrays"].arrayValue[2]["address"].stringValue
            self.showAreaTwo = true
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addAreaAction() {
        if self.showAreaOne{
            self.showAreaTwo = true
        }else{
            self.showAreaOne = true
        }
        self.tableView.reloadData()
    }
    
    @IBAction func sendAction() {
        var array = Array<[String : Any]>()
        for dict in self.areaArray {
            if dict.keys.count > 0 {
                array.append(dict)
            }
        }
        if array.count == 0{
            LYProgressHUD.showError("请选择服务区域！")
            return
        }
        if sTime == nil {
            LYProgressHUD.showError("请选择开始时间")
            return
        }
        if eTime == nil {
            LYProgressHUD.showError("请选择结束时间")
            return
        }
        if (sTime?.isLaterThanDate(aDate: eTime!))!{
            LYProgressHUD.showError("开始时间不可晚于结束时间！")
            return
        }
        
        var params : [String : Any] = [:]
        params["service_stime"] = self.sTime!.phpTimestamp()
        params["service_etime"] = self.eTime!.phpTimestamp()
        params["citys"] = array.jsonString()
        
        NetTools.requestData(type: .post, urlString: SetSpaceTimeApi,parameters: params, succeed: { (resultJson, error) in
            LYProgressHUD.showSuccess("设置成功！")
            if (self.setSpaceTimeBlock != nil){
                self.setSpaceTimeBlock!()
            }
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
}


extension SetSpaceTimeViewController{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            if indexPath.row == 0{
                return 44
            }else if indexPath.row == 1 && self.showAreaOne{
                return 44
            }else if indexPath.row == 2 && self.showAreaTwo{
                return 44
            }else if indexPath.row == 3 && !(self.showAreaOne && self.showAreaTwo){
                return 44
            }else{
                return 0.001
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            return 100
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 && indexPath.row != 3{
//            let mapSearchVC = MapSearchViewController()
//            if indexPath.row == 0{
//                mapSearchVC.selectedLocation = {(poi) in
//                    self.areaLbl1.text = poi.name
//                    var dict : [String : Any] = [:]
//                    dict["address"] = poi.name
//                    dict["lng"] = poi.location.longitude
//                    dict["lat"] = poi.location.latitude
//                    self.areaArray[indexPath.row] = dict
//                }
//            }else if indexPath.row == 1{
//                mapSearchVC.selectedLocation = {(poi) in
//                    self.areaLbl2.text = poi.name
//                    var dict : [String : Any] = [:]
//                    dict["address"] = poi.name
//                    dict["lng"] = poi.location.longitude
//                    dict["lat"] = poi.location.latitude
//                    self.areaArray[indexPath.row] = dict
//                }
//            }else if indexPath.row == 2{
//                mapSearchVC.selectedLocation = {(poi) in
//                    self.areaLbl3.text = poi.name
//                    var dict : [String : Any] = [:]
//                    dict["address"] = poi.name
//                    dict["lng"] = poi.location.longitude
//                    dict["lat"] = poi.location.latitude
//                    self.areaArray[indexPath.row] = dict
//                }
//            }
//            self.navigationController?.pushViewController(mapSearchVC, animated: true)
        }else if indexPath.section == 1{
            //开始时间
            let datePicker = LYDatePicker.init(component: 5)
            datePicker.ly_datepickerWithFiveComponent = {(date,year,month,day,hour,minute) in
                self.sTimeLbl.text = "\(year).\(month).\(day) \(hour):\(minute)"
                self.sTime = date
            }
            datePicker.show()
        }else if indexPath.section == 2{
            //结束时间
            let datePicker = LYDatePicker.init(component: 5)
            datePicker.ly_datepickerWithFiveComponent = {(date,year,month,day,hour,minute) in
                self.eTimeLbl.text = "\(year).\(month).\(day) \(hour):\(minute)"
                self.eTime = date
            }
            datePicker.show()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0{
            if indexPath.row == 1 || indexPath.row == 2{
                return UITableViewCellEditingStyle.delete
            }
        }
        return UITableViewCellEditingStyle.none
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            if indexPath.section == 0{
                if indexPath.row == 1{
                    self.showAreaOne = false
                }else if indexPath.row == 2{
                    self.showAreaTwo = false
                }
                self.areaArray[indexPath.row] = [String : Any]()
            }
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.isHidden = false
        if indexPath.section == 0{
            if indexPath.row == 1 && !self.showAreaOne{
                cell.isHidden = true
            }else if indexPath.row == 2 && !self.showAreaTwo{
                cell.isHidden = true
            }else if indexPath.row == 3 && self.showAreaOne && self.showAreaTwo{
                cell.isHidden = true
            }
        }
    }
}







