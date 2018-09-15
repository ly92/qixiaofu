//
//  AddAddressViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias AddAddressViewControllerBlock = (JSON) -> Void
typealias SelectAddressViewControllerBlock = (Dictionary<String,String>) -> Void


class AddAddressViewController: BaseViewController {
    class func spwan() -> AddAddressViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! AddAddressViewController
    }
    
    
    var isEditAddress = false
    var isFromSendTask = false
    //搜索API
    fileprivate var searcher = BMKGeoCodeSearch()
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var chooseAreaView: UIView!
    @IBOutlet weak var chooseAreaViewTopDis: NSLayoutConstraint!
    
    @IBOutlet weak var detailTextV: UITextView!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    

    fileprivate var provinceId = ""
    fileprivate var cityId = ""
    fileprivate var areaId = ""

    
    var jsonModel : JSON = []
    
    var editAddressBlock : AddAddressViewControllerBlock?
    var selectAddressBlock : SelectAddressViewControllerBlock?
    
    fileprivate var areaDict = ["province" : "","city" : "","address" : "","lat" : "","lon" : ""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveBtn.layer.cornerRadius = 20
        if self.isFromSendTask{
            self.chooseAreaViewTopDis.constant = 8
            self.saveBtn.setTitle("确定", for: .normal)
            self.navigationItem.title = "服务区域"
            self.addressTF.placeholder = "请选择服务区域"
        }else{
            self.chooseAreaViewTopDis.constant = 105
            self.saveBtn.setTitle("保存", for: .normal)
            if self.isEditAddress{
                self.navigationItem.title = "编辑地址"
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "删除", target: self, action: #selector(AddAddressViewController.deleteAction))
                
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    self.nameTF.text = jsonModel["company_true_name"].stringValue
                }else{
                    self.nameTF.text = jsonModel["true_name"].stringValue
                }
                self.phoneTf.text = jsonModel["mob_phone"].stringValue
                self.addressTF.text = jsonModel["area_info"].stringValue
                if !jsonModel["address"].stringValue.isEmpty{
                    self.detailTextV.text = jsonModel["address"].stringValue
                    self.placeholderLbl.isHidden = true
                }
                self.provinceId = jsonModel["prov_id"].stringValue
                self.areaId = jsonModel["area_id"].stringValue
                self.cityId = jsonModel["city_id"].stringValue
                
            }else{
                self.navigationItem.title = "添加地址"
            }
        }
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
        
        self.chooseAreaView.addTapActionBlock { 
            self.chooseArea()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isFromSendTask{
            self.searcher.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isFromSendTask{
            self.searcher.delegate = nil
        }
    }
    
    @objc func deleteAction() {
        LYAlertView.show("提示", "您确定要删除此地址", "取消","删除", {
            var params : [String : Any] = [:]
            var url = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                url = EPDeleteAddressApi
                params["company_address_id"] = self.jsonModel["company_address_id"].stringValue
            }else{
                url = DeleteAddressApi
                params["store_id"] = "1"
                params["address_id"] = self.jsonModel["address_id"].stringValue
            }
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("删除成功！")
                if self.editAddressBlock != nil{
                    self.editAddressBlock!([])
                    self.navigationController?.popViewController(animated: true)
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
    }
    
    func chooseArea() {
        let chooseVc = ChooseAreaViewController()
        chooseVc.chooseAeraBlock = {(provinceId,cityId,areaId,addressArray) in
            self.areaDict["city"] = addressArray[1]
            self.addressTF.text = addressArray.joined()
            self.provinceId = provinceId
            self.cityId = cityId
            self.areaId = areaId
        }
        self.navigationController?.pushViewController(chooseVc, animated: true)
    }

    @IBAction func saveAction() {
        let areaInfo = self.addressTF.text
        let address = self.detailTextV.text
        if (areaInfo?.isEmpty)! || provinceId.isEmpty || cityId.isEmpty || areaId.isEmpty{
            LYProgressHUD.showError("请选择地区")
            return
        }
        if !self.isFromSendTask{
            if (address?.isEmpty)!{
                LYProgressHUD.showError("请填写详细地址")
                return
            }
        }
        if self.isFromSendTask{
            self.areaDict["province"] = areaInfo!
            self.areaDict["address"] = address!
            self.getLocation(areaInfo!, address!)
        }else{
            let name = self.nameTF.text
            let phone = self.phoneTf.text
            if (name?.isEmpty)!{
                LYProgressHUD.showError("请输入收货人姓名")
                return
            }
            if (phone?.isEmpty)! || !(phone?.isMobelPhone())!{
                LYProgressHUD.showError("请输入正确手机号")
                return
            }
            var params : [String : Any] = [:]
            var editUrl = ""
            var addUrl = ""
            params["true_name"] = name!
            params["mob_phone"] = phone!
            params["address"] = address!
            params["prov_id"] = self.provinceId
            params["city_id"] = self.cityId
            params["area_id"] = self.areaId
            params["area_info"] = areaInfo!
            
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                addUrl = EPAddAddressApi
                editUrl = EPVertifiAddressApi
            }else{
                addUrl = AddAddressApi
                editUrl = EditAddressApi
                params["store_id"] = "1"
            }
            
            LYProgressHUD.showLoading()
            if self.isEditAddress{
                //修改地址
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    params["company_address_id"] = jsonModel["company_address_id"].stringValue
                }else{
                    params["address_id"] = jsonModel["address_id"].stringValue
                }
                NetTools.requestData(type: .post, urlString: editUrl, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.dismiss()
                    if self.editAddressBlock != nil{
                        self.editAddressBlock!([])
                        self.navigationController?.popViewController(animated: true)
                    }
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }else{
                //新增地址]
                NetTools.requestData(type: .post, urlString: addUrl, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.dismiss()
                    if self.editAddressBlock != nil{
                        self.editAddressBlock!([])
                        self.navigationController?.popViewController(animated: true)
                    }
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AddAddressViewController : UITextViewDelegate,UIScrollViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeholderLbl.isHidden = false
        }else{
            self.placeholderLbl.isHidden = true
        }
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}


extension AddAddressViewController : BMKGeoCodeSearchDelegate{
    
    //根据地址查经纬度
    func getLocation(_ city : String, _ address : String) {
        let geoCodeSearchOption = BMKGeoCodeSearchOption()
        geoCodeSearchOption.address = city + address
        geoCodeSearchOption.city = city
        let flag = self.searcher.geoCode(geoCodeSearchOption)
        if flag{
            print("geo 检索发送成功！")
        }else{
            print("geo 检索发送失败！")
        }
    }
    
    func onGetGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR{
            self.areaDict["lat"] = String.init(format: "%.6f", result.location.latitude)
            self.areaDict["lon"] = String.init(format: "%.6f", result.location.longitude)
        }else{
            //未定位到所选位置, 默认北京海淀区
            //39.959912, 116.298056
            self.areaDict["lat"] = "39.959912"
            self.areaDict["lon"] = "116.298056"
        }
        if self.selectAddressBlock != nil{
            self.selectAddressBlock!(self.areaDict)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
