//
//  EngResumeTableViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngResumeTableViewController: BaseTableViewController {
    class func spwan() -> EngResumeTableViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! EngResumeTableViewController
    }
    
    var engId = ""
    
    
    @IBOutlet weak var curStateLbl: UILabel!
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var jobPriceLbl: UILabel!
    @IBOutlet weak var workYearLbl: UILabel!
    @IBOutlet weak var certView: UIView!
    @IBOutlet weak var techRangeLbl: UILabel!
    @IBOutlet weak var adaptBrandTF: UITextField!
    @IBOutlet weak var advantageTextView: UITextView!
    @IBOutlet weak var advantageNumLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    fileprivate var personalInfo : JSON = []
    
    fileprivate var techRangeArray : Array<String> = Array<String>()//技术领域
    fileprivate var adaptBrand : String = ""//擅长品牌
    fileprivate var cerImgs : String = ""//职业证书
    fileprivate var serverRangeJson : JSON = []
    fileprivate var jobTitleJson : JSON = []
    fileprivate var jobTitleArray : Array<String> = Array<String>()//职位
    fileprivate var photoView = LYPhotoBrowseView()
    fileprivate var jobStatus = ""//当前状态
    fileprivate var jobType = ""//职位
    fileprivate var workYear = ""//从业年限
    fileprivate var province_id = ""
    fileprivate var city_id = ""
    fileprivate var county_id = ""
    fileprivate var salary_low = ""//工资
    fileprivate var salary_heigh = ""//工资
    fileprivate var advantage = ""//我的优势
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "工程师简历"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "预览", target: self, action: #selector(EngResumeTableViewController.rightItemAction))
        
        self.loadEngResume()
        self.prepareData()
    }
    
    @objc func rightItemAction(){
        let preResumeVC = EngResumeViewController.spwan()
        preResumeVC.engId = self.personalInfo["member_id"].stringValue
//        preResumeVC.personalInfo = self.personalInfo
        self.navigationController?.pushViewController(preResumeVC, animated: true)
    }
    
    func loadEngResume() {
        let params : [String : Any] = ["engineer_id" : self.engId]
        NetTools.requestData(type: .post, urlString: PersonalInfoApi, parameters: params, succeed: { (resultJson, msg) in
            self.personalInfo = resultJson
            self.setUpUIData()
        }) { (error) in
        }
    }
    
    
    //准备数据
    func prepareData() {
        NetTools.requestData(type: .post, urlString: ServerRangeListApi, succeed: { (result, msg) in
            self.serverRangeJson = result
        }) { (error) in
        }
        
        //职位数据
        NetTools.requestData(type: .get, urlString: JobTypeListApi, succeed: { (resultJson, msg) in
            self.jobTitleArray.removeAll()
            self.jobTitleJson = resultJson
            for json in resultJson.arrayValue{
                self.jobTitleArray.append(json["type_name"].stringValue)
            }
        }) { (error) in
        }
    }
    
    //设置页面数据
    func setUpUIData() {
        self.saveBtn.layer.cornerRadius = 20
        self.jobStatus = self.personalInfo["job_status"].stringValue
        switch self.jobStatus.intValue {
        case 1:
            self.curStateLbl.text = "在职"
        case 2:
            self.curStateLbl.text = "已离职"
        case 3:
            self.curStateLbl.text = "在职-考虑机会"
        default:
            self.curStateLbl.text = "在职-月内到岗"
        }
        
        self.jobType = self.personalInfo["typeid"].stringValue
        self.jobNameLbl.text = self.personalInfo["type_name"].stringValue
        
        self.province_id = self.personalInfo["province_id"].stringValue
        self.county_id = self.personalInfo["county_id"].stringValue
        self.city_id = self.personalInfo["city_id"].stringValue
        self.addressLbl.text = self.personalInfo["area_info"].stringValue

        self.salary_low = self.personalInfo["salary_low"].stringValue
        self.salary_heigh = self.personalInfo["salary_heigh"].stringValue
        self.jobPriceLbl.text = self.salary_low + "~" + self.salary_heigh + "K"
        
        if !self.personalInfo["job_start_time"].stringValue.isEmpty{
            self.workYear = self.personalInfo["job_start_time"].stringValue
            self.workYearLbl.text = self.personalInfo["job_start_time"].stringValue + "年"
        }
        
        self.photoView = LYPhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: 50),superVC:self)
        self.photoView.backgroundColor = UIColor.white
        self.photoView.showLogoImgV = true
        self.photoView.maxPhotoNum = 5
        self.photoView.canTakePhoto = true
        self.photoView.showDeleteBtn = false
        self.photoView.customBlock = {() in
            //添加职业证书
            let addCertVC = AddCertificateViewController.spwan()
            addCertVC.depth = "\(self.personalInfo["cer_images"].arrayValue.count + 1)"
            addCertVC.operationBlock = {() in
                self.loadEngResume()
            }
            self.navigationController?.pushViewController(addCertVC, animated: true)
        }
        self.certView.addSubview(self.photoView)
        if self.personalInfo["cer_images"].arrayValue.count > 0{
            var imgUrlArray : Array<String> = Array<String>()
            var imgDescArray : Array<String> = Array<String>()
            var imgLogoArray : Array<String> = Array<String>()
            for subJson in self.personalInfo["cer_images"].arrayValue {
                imgUrlArray.append(subJson["cer_image"].stringValue)
                imgDescArray.append(subJson["cer_image_name"].stringValue)
                //证书状态 【10 通过】【20 未通过】【30 待审核】cer_image_type
                imgLogoArray.append(subJson["cer_image_type"].stringValue)
            }
            self.photoView.showImgUrlArray = imgUrlArray
            self.photoView.imgDescArray = imgDescArray
            self.photoView.imgLogoArray = imgLogoArray
            self.photoView.longPressBlock = {(index) in
                //长按操作
                print(index)
                let addCertVC = AddCertificateViewController.spwan()
                addCertVC.certImg = self.photoView.imgArray[index]
                addCertVC.certName = imgDescArray[index]
                addCertVC.imgUrl = imgUrlArray[index]
                addCertVC.depth = "\(index + 1)"
                addCertVC.certId = self.personalInfo["cer_images"].arrayValue[index]["cer_id"].stringValue
                addCertVC.operationBlock = {() in
                    self.loadEngResume()
                }
                self.navigationController?.pushViewController(addCertVC, animated: true)
            }
            
            self.advantage = self.personalInfo["advantage"].stringValue
            self.advantageTextView.text = self.advantage
            self.advantageNumLbl.text = "\(self.advantage.count)/300"
        }
        
        self.techRangeArray.removeAll()
        if self.personalInfo["service_sector"].arrayValue.count > 0{
            var sectorArray : Array<String> = Array<String>()
            for subJson in self.personalInfo["service_sector"].arrayValue {
                sectorArray.append(subJson["gc_name"].stringValue)
                self.techRangeArray.append(subJson["gc_id"].stringValue)
            }
            self.techRangeLbl.text = sectorArray.joined(separator: ",")
        }
        if !self.personalInfo["service_brand"].stringValue.isEmpty{
            self.adaptBrandTF.text = self.personalInfo["service_brand"].stringValue
        }
    }
    
    //更改个人信息
    func changePersonalInfo() {
        self.view.endEditing(true)
        var params : [String : Any] = [:]
        if !self.techRangeArray.isEmpty{
            params["service_sector"] = self.techRangeArray.joined(separator: ",")
        }
        if !self.adaptBrand.isEmpty{
            params["service_brand"] = self.adaptBrand
        }
        if !self.cerImgs.isEmpty{
            params["cer_images"] = self.cerImgs
        }
        NetTools.requestData(type: .post, urlString: ChangePersonalInfoApi, parameters: params, succeed: { (result, msg) in
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    @IBAction func saveAction() {
        self.view.endEditing(true)
        var params : [String : Any] = [:]
        if !self.workYear.isEmpty{
            params["job_start_time"] = self.workYear
        }
        if !self.jobStatus.isEmpty{
            params["job_status"] = self.jobStatus
        }
        if !self.jobType.isEmpty{
            params["typeid"] = self.jobType
        }
        if !self.province_id.isEmpty{
            params["province_id"] = self.province_id
        }
        if !self.city_id.isEmpty{
            params["city_id"] = self.city_id
        }
        if !self.county_id.isEmpty{
            params["county_id"] = self.county_id
        }
        if !self.salary_low.isEmpty{
            params["salary_low"] = self.salary_low
        }
        if !self.salary_heigh.isEmpty{
            params["salary_heigh"] = self.salary_heigh
        }
        if !self.advantage.isEmpty{
            params["advantage"] = self.advantage
        }
        NetTools.requestData(type: .post, urlString: ChangeResumeApi, parameters: params, succeed: { (result, msg) in
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    
}

extension EngResumeTableViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            //当前状态
            LYPickerView.show(titles: ["在职","已离职","在职-考虑机会","在职-月内到岗"], selectBlock: {(title,index) in
                self.curStateLbl.text = title
                self.jobStatus = "\(index+1)"
                self.saveAction()
            })
        }else if indexPath.row == 1{
            //职位
            LYPickerView.show(titles: self.jobTitleArray, selectBlock: {(title,index) in
                self.jobNameLbl.text = title
                if self.jobTitleJson.arrayValue.count > index{
                    self.jobType = self.jobTitleJson.arrayValue[index]["id"].stringValue
                    self.saveAction()
                }
            })
        }else if indexPath.row == 2{
            //工作地址
            let chooseVc = ChooseAreaViewController()
            chooseVc.chooseAeraBlock = {(provinceId,cityId,areaId,addressArray) in
//                self.areaDict["city"] = addressArray[1]
                self.addressLbl.text = addressArray.joined()
                self.province_id = provinceId
                self.city_id = cityId
                self.county_id = areaId
                self.saveAction()
            }
            self.navigationController?.pushViewController(chooseVc, animated: true)
        }else if indexPath.row == 3{
            //薪资要求
            let picker = LYPricePickerView()
            picker.show()
            picker.pickerViewBlock = {(first,second) in
                self.jobPriceLbl.text = "\(first)~\(second)K"
                self.salary_low = "\(first)"
                self.salary_heigh = "\(second)"
                self.saveAction()
            }
            
        }else if indexPath.row == 4{
            //从业时间
            let datePicker = LYDatePicker.init(component: 1)
            datePicker.ly_datepickerWithOneComponent = {(date,year) in
                self.workYear = "\(year)"
                self.workYearLbl.text = "\(year)年"
                self.saveAction()
            }
            datePicker.show()
        }else if indexPath.row == 6{
            //技术领域
            let serverRangeVC = ServerRangeViewController.spwan()
            serverRangeVC.selectedIds = self.techRangeArray
            serverRangeVC.serverRangeBlock = {(selectedDictArray,titles,ids) in
                self.techRangeLbl.text = titles.joined(separator: ";")
                self.techRangeArray = ids
                self.changePersonalInfo()
            }
            serverRangeVC.dataArray = self.serverRangeJson.arrayValue
            self.navigationController?.pushViewController(serverRangeVC, animated: true)
        }
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.panGestureRecognizer.translation(in: self.tableView.superview)
        //键盘的隐藏与否
        if point.y > 0{
            self.view.endEditing(true)
        }
    }
    
}


extension EngResumeTableViewController : UITextFieldDelegate, UITextViewDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //编辑完成
        self.saveAction()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.adaptBrandTF{
            let editVC = PersonalEditInfoViewController()
            editVC.textView.text = self.adaptBrandTF.text
            editVC.editDoneBlock = {(str) in
                self.adaptBrand = str
                self.adaptBrandTF.text = str
                self.changePersonalInfo()
            }
            self.navigationController?.pushViewController(editVC, animated: true)
            return false
        }
        return true
    }
    

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count <= 300{
            self.advantageNumLbl.text = "\(textView.text.count)/300"
        }else{
            LYProgressHUD.showError("已超过最大字数")
            var text = textView.text
            text?.removeLast()
            textView.text = text
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.advantage = textView.text
        self.saveAction()
        return true
    }
    
    
    
    
}
