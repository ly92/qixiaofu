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
    
    var personalInfo : JSON = []
    
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
    
    
    fileprivate var workYear : Date?//从业年限
    fileprivate var nickName : String = ""//昵称
    fileprivate var techRangeArray : Array<String> = Array<String>()//技术领域
    fileprivate var adaptBrand : String = ""//擅长品牌
    fileprivate var cerImgs : String = ""//职业证书
    fileprivate var serverRangeJson : JSON = []
    fileprivate var photoView = LYPhotoBrowseView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "工程师简历"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "预览", target: self, action: #selector(EngResumeTableViewController.rightItemAction))
        
        
        self.prepareData()
        
        self.setUpUIData()
    }
    
    @objc func rightItemAction(){
        let preResumeVC = EngResumeViewController.spwan()
        preResumeVC.personalInfo = self.personalInfo
        self.navigationController?.pushViewController(preResumeVC, animated: true)
    }
    
    
    //准备数据
    func prepareData() {
        NetTools.requestData(type: .post, urlString: ServerRangeListApi, succeed: { (result, msg) in
            self.serverRangeJson = result
        }) { (error) in
        }
    }
    
    //设置页面数据
    func setUpUIData() {
        
        self.saveBtn.layer.cornerRadius = 20
        
        if !self.personalInfo["working_time"].stringValue.isEmpty{
            self.workYearLbl.text = Date.dateStringFromDate(format: Date.yearFormatString(), timeStamps: self.personalInfo["working_time"].stringValue)
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
                self.navigationController?.pushViewController(addCertVC, animated: true)
            }
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
        
        //        NetTools.requestData(type: .post, urlString: ChangePersonalInfoApi, parameters: params, succeed: { (result, msg) in
        //            LYProgressHUD.showSuccess("保存成功！")
        //        }) { (error) in
        //            LYProgressHUD.showError(error!)
        //        }
    }
    
    @IBAction func saveAction() {

    }
    
    
}

extension EngResumeTableViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            //当前状态
            LYPickerView.show(titles: ["在职","已离职","在职-考虑机会","在职-月内到岗"], selectBlock: {(title,index) in
                self.curStateLbl.text = title
            })
        }else if indexPath.row == 1{
            //职位
            LYPickerView.show(titles: ["驻场工程师","职位1","职位2","职位3"], selectBlock: {(title,index) in
                self.jobNameLbl.text = title
            })
        }else if indexPath.row == 2{
            //工作地址
            let chooseVc = ChooseAreaViewController()
            chooseVc.chooseAeraBlock = {(provinceId,cityId,areaId,addressArray) in
//                self.areaDict["city"] = addressArray[1]
                self.addressLbl.text = addressArray.joined()
//                self.provinceId = provinceId
//                self.cityId = cityId
//                self.areaId = areaId
            }
            self.navigationController?.pushViewController(chooseVc, animated: true)
        }else if indexPath.row == 3{
            //薪资要求
            let picker = LYPricePickerView()
            picker.show()
            picker.pickerViewBlock = {(first,second) in
                self.jobPriceLbl.text = "\(first)~\(second)K"
            }
            
        }else if indexPath.row == 4{
            //从业时间
            let datePicker = LYDatePicker.init(component: 1)
            datePicker.ly_datepickerWithOneComponent = {(date,year) in
                self.workYear = date
                self.workYearLbl.text = "\(year)年"
                self.changePersonalInfo()
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
    
    
    
    
}
