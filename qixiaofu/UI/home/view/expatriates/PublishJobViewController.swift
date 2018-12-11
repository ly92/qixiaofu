//
//PublishJobViewController.swift
//qixiaofu
//
//Created by ly on 2018/10/19.
//Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import Speech
import AudioToolbox
import SwiftyJSON


class PublishJobViewController: BaseTableViewController {
    class func spwan() -> PublishJobViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! PublishJobViewController
    }
    
    
    var editJson = JSON()
    var publishSuccessBlock : (() -> Void)?
    
    
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var companyTF: UITextField!
    @IBOutlet weak var companyBtn1: UIButton!
    @IBOutlet weak var companyBtn2: UIButton!
    @IBOutlet weak var typeBtn1: UIButton!
    @IBOutlet weak var typeBtn2: UIButton!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var responsibilityPlaceholderLbl: UILabel!
    @IBOutlet weak var responsibilityTextView: UITextView!
    @IBOutlet weak var responsibilityBottomLbl: UILabel!
    @IBOutlet weak var qualificationPlaceholderLbl: UILabel!
    @IBOutlet weak var qualificationTextView: UITextView!
    @IBOutlet weak var qualificationBottomLbl: UILabel!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minuteBtn: UIButton!
    
    
    
    fileprivate var  typeid = ""          //工程师类型id
    fileprivate var  nature = "1"          //招聘性质，1，内部招聘，2，驻场招聘
    fileprivate var  province_id = ""          //省级id
    fileprivate var  city_id = ""          //市级id
    fileprivate var  county_id = ""          //县级id
    fileprivate var  address_detail = ""          //详细地址
//    fileprivate var  company_name = ""          //公司名称
    fileprivate var  duty = ""          //工作职责
    fileprivate var  condition = ""          //任职资格
    fileprivate var  nums = ""          //招聘人数
    fileprivate var  min_salary = ""          //薪资范围
    fileprivate var  max_salary = ""          //薪资范围
    fileprivate var  isCompanyShow = "1"          //是否展示公司名称  1显示 2隐藏

    fileprivate var typeArray = JSON()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "发布招聘"
        
        self.plusBtn.layer.cornerRadius = 2
        self.minuteBtn.layer.cornerRadius = 2
        self.publishBtn.layer.cornerRadius = 15
        
        
        self.loadTypeData()
        
        if !editJson["typeid"].stringValue.isEmpty{
            self.prepareOriginalData()
            self.publishBtn.setTitle("更新招聘", for: .normal)
        }
        
    }
    
    //设置编辑的原数据
    func prepareOriginalData() {
        self.typeid = self.editJson["typeid"].stringValue
        self.nature = self.editJson["nature"].stringValue
        self.province_id = self.editJson["province_id"].stringValue
        self.city_id = self.editJson["city_id"].stringValue
        self.county_id = self.editJson["county_id"].stringValue
        self.address_detail = self.editJson["address_detail"].stringValue
        self.duty = self.editJson["duty"].stringValue
        self.condition = self.editJson["condition"].stringValue
        self.nums = self.editJson["nums"].stringValue
        self.min_salary = self.editJson["salary_low"].stringValue
        self.max_salary = self.editJson["salary_heigh"].stringValue
        self.isCompanyShow = self.editJson["company_is_show"].stringValue
        
        self.jobNameLbl.text = self.editJson["type_name"].stringValue
        self.companyTF.text = self.editJson["company_name"].stringValue
        if self.isCompanyShow.intValue == 1{
            self.companyBtn1.isSelected = true
        }else{
            self.companyBtn2.isSelected = true
        }
        if self.typeid.intValue == 1{
            self.typeBtn1.isSelected = true
        }else{
            self.typeBtn2.isSelected = true
        }
        self.numberTF.text = self.nums
        self.addressLbl.text = self.editJson["area_info"].stringValue
        self.moneyLbl.text = self.min_salary + "~" + self.max_salary + "K"
        self.responsibilityTextView.text = self.duty
        self.qualificationTextView.text = self.condition
        self.responsibilityPlaceholderLbl.isHidden = true
        self.qualificationPlaceholderLbl.isHidden = true
        
        
    }
    

    @IBAction func btnAction(_ btn: UIButton) {
        self.view.endEditing(true)
        
        if btn.tag == 11{
            //显示公司名称
            self.companyBtn1.isSelected = true
            self.companyBtn2.isSelected = false
            self.isCompanyShow = "1"
        }else if btn.tag == 22{
            //隐藏公司名称
            self.companyBtn1.isSelected = false
            self.companyBtn2.isSelected = true
            self.isCompanyShow = "2"
        }else if btn.tag == 33{
            //内部招聘
            self.typeBtn1.isSelected = true
            self.typeBtn2.isSelected = false
            self.nature = "1"
        }else if btn.tag == 44{
            //外派
            self.typeBtn1.isSelected = false
            self.typeBtn2.isSelected = true
            self.nature = "2"
        }else if btn.tag == 55{
            //减人数
            let num = self.numberTF.text?.intValue
            if num != nil{
                if num! > 1{
                    self.numberTF.text = "\(num! - 1)"
                }else{
                    LYProgressHUD.showInfo("至少一位！")
                    self.numberTF.text = "1"
                }
            }
        }else if btn.tag == 66{
            //加人数
            let num = self.numberTF.text?.intValue ?? 0
            self.numberTF.text = "\(num + 1)"
        }else if btn.tag == 77{
            //工作职责输入
            
        }else if btn.tag == 88{
            //任职资格输入
            
        }else if btn.tag == 99{
            //发布
            self.publishAction()
        }
    }
    
    //分类数据
    func loadTypeData() {
        NetTools.requestData(type: .get, urlString: JobTypeListApi, succeed: { (resultJson, msg) in
            self.typeArray = resultJson
        }) { (error) in
        }
    }
    

    func publishAction() {
        if self.typeid.isEmpty{
            LYProgressHUD.showError("请选择招聘职位")
            return
        }
        let company = self.companyTF.text
        if company == nil{
            LYProgressHUD.showError("请填写公司名称")
            return
        }
        if company!.isEmpty{
            LYProgressHUD.showError("请填写公司名称")
            return
        }
        let num = self.numberTF.text
        if num == nil{
            LYProgressHUD.showError("请设置招聘人数")
            return
        }
        if self.province_id.isEmpty || self.city_id.isEmpty || self.county_id.isEmpty{
            LYProgressHUD.showError("请选择工作地址")
            return
        }
        if self.min_salary.isEmpty || self.max_salary.isEmpty{
            LYProgressHUD.showError("请选择薪资范围")
            return
        }
        let responsibility = self.responsibilityTextView.text
        if responsibility!.isEmpty{
            LYProgressHUD.showError("请输入工作职责")
            return
        }
        let qualification = self.qualificationTextView.text
        if qualification!.isEmpty{
            LYProgressHUD.showError("请输入任职资格")
            return
        }
        
        
        var params : [String : Any] = [:]
        params["typeid"] = self.typeid
        params["nature"] = self.nature
        params["province_id"] = self.province_id
        params["city_id"] = self.city_id
        params["county_id"] = self.county_id
        params["address_detail"] = self.address_detail
        params["company_name"] = company!
        params["duty"] = responsibility!
        params["condition"] = qualification!
        params["nums"] = num!
        params["salary_low"] = self.min_salary
        params["salary_heigh"] = self.max_salary
        params["is_show"] = self.isCompanyShow
        
        
        if !self.editJson["typeid"].stringValue.isEmpty{
            params["jobid"] = self.editJson["id"].stringValue
        }
        
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: PublishJobApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            if self.publishSuccessBlock != nil{
                self.publishSuccessBlock!()
            }
            if !self.editJson["typeid"].stringValue.isEmpty{
                LYAlertView.show("提示", "发布成功！","知道了",{
                    self.navigationController?.popViewController(animated: true)
                })
            }else{
                LYAlertView.show("提示", "更新成功！","知道了",{
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络请求错误！")
        }
    }
    
    
}


extension PublishJobViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.section == 0{
            if indexPath.row == 0{
                //职位
                var arr : Array<String> = Array<String>()
                for json in self.typeArray.arrayValue{
                    arr.append(json["type_name"].stringValue)
                }
                LYPickerView.show(titles: arr, selectBlock: {(title,index) in
                    if self.typeArray.count > index{
                        let json = self.typeArray[index]
                        self.jobNameLbl.text = json["type_name"].stringValue
                        self.typeid = json["id"].stringValue
                    }
                })
            }else if indexPath.row == 4{
                //工作地址
                let editVC = AddAddressViewController.spwan()
                editVC.isFromSendTask = true
                editVC.selectAddressBlock2 = { (provinceId, cityId, areaId, areaInfo, address) in
                    self.province_id = provinceId
                    self.city_id = cityId
                    self.county_id = areaId
                    self.address_detail = address
                    
                    self.addressLbl.text = areaInfo + address
                }
                self.navigationController?.pushViewController(editVC, animated: true)
            }else if indexPath.row == 5{
                //薪资要求
                let picker = LYPricePickerView()
                picker.show()
                picker.pickerViewBlock = {(first,second) in
                    self.moneyLbl.text = "\(first)~\(second)K"
                    self.min_salary = "\(first)"
                    self.max_salary = "\(second)"
                }
            }
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



extension PublishJobViewController : UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == self.responsibilityTextView{
            self.responsibilityPlaceholderLbl.isHidden = true
            
        }else if textView == self.qualificationTextView{
            self.qualificationPlaceholderLbl.isHidden = true
            
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {

        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == self.responsibilityTextView{
            if textView.text.isEmpty{
                self.responsibilityPlaceholderLbl.isHidden = false
            }
        }else if textView == self.qualificationTextView{
            if textView.text.isEmpty{
                self.qualificationPlaceholderLbl.isHidden = false
            }
        }
    }
    
    
}

