//
//  LYBrandPickerView.swift
//  qixiaofu
//
//  Created by ly on 2018/9/12.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class LYBrandPickerView: UIView {
    
    fileprivate var brand_index = 0
    fileprivate var type_index = 0
    fileprivate var model_index = 0
    
    fileprivate var brandTF = UITextField()
    fileprivate var modelTF = UITextField()
    
    
    
    fileprivate lazy var pickerView : UIPickerView = {
        let pickerView = UIPickerView.init(frame: CGRect.init(x: 0, y: 150, width: kScreenW, height: 200))
        pickerView.backgroundColor = UIColor.white
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    fileprivate lazy var btnView : UIView = {
        let btnView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 150))
        btnView.backgroundColor = UIColor.white
        
        //底部线
        let line = UIView.init(frame: CGRect.init(x: 0, y: 49, width: kScreenW, height: 1))
        line.backgroundColor = UIColor.RGBS(s: 240)
        btnView.addSubview(line)
        //取消按钮
        let cancelBtn = UIButton.init(frame: CGRect.init(x: 15, y: 0, width: 60, height: 49))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.lightGray, for: .normal)
        cancelBtn.addTarget(self, action: #selector(LYPickerView.hide), for: .touchUpInside)
        btnView.addSubview(cancelBtn)
        //确定按钮
        let sureBtn = UIButton.init(frame: CGRect.init(x: kScreenW - 75, y: 0, width: 60, height: 49))
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
        sureBtn.addTarget(self, action: #selector(LYPickerView.sureAction), for: .touchUpInside)
        btnView.addSubview(sureBtn)
        
        //品牌
        let brandLbl = UILabel.init(frame: CGRect.init(x: 20, y: 65, width: 50, height: 30))
        brandLbl.font = UIFont.systemFont(ofSize: 14.0)
        brandLbl.textColor = Text_Color
        brandLbl.text = "品牌:"
        btnView.addSubview(brandLbl)
        self.brandTF = UITextField.init(frame: CGRect.init(x: 70, y: 65, width: kScreenW-140, height: 30))
        self.brandTF.borderStyle = .roundedRect
        self.brandTF.font = UIFont.systemFont(ofSize: 14.0)
        self.brandTF.textColor = Text_Color
        btnView.addSubview(self.brandTF)
        
        //型号
        let modelLbl = UILabel.init(frame: CGRect.init(x: 20, y: 105, width: 50, height: 30))
        modelLbl.font = UIFont.systemFont(ofSize: 14.0)
        modelLbl.textColor = Text_Color
        modelLbl.text = "型号:"
        btnView.addSubview(modelLbl)
        self.modelTF = UITextField.init(frame: CGRect.init(x: 70, y: 105, width: kScreenW-140, height: 30))
        self.modelTF.borderStyle = .roundedRect
        self.modelTF.font = UIFont.systemFont(ofSize: 14.0)
        self.modelTF.textColor = Text_Color
        btnView.addSubview(self.modelTF)
        
        //底部线
        let line2 = UIView.init(frame: CGRect.init(x: 0, y: 149, width: kScreenW, height: 1))
        line2.backgroundColor = UIColor.RGBS(s: 240)
        btnView.addSubview(line2)
        
        return btnView
    }()
    
    fileprivate var subView : UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: kScreenH - 350, width: kScreenW, height: 350))
        
        return view
    }()
    
    
    fileprivate var bgBtn : UIButton = {
        let bg_btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH))
        bg_btn.backgroundColor = UIColor.black
        bg_btn.alpha = 0.4
        bg_btn.addTarget(self, action: #selector(LYPickerView.hide), for: .touchUpInside)
        return bg_btn
    }()
    
    
    fileprivate lazy var dataArray : Array<JSON> = {
        
        let mode_list1 = JSON(["111111","22222","333333","44444","55555","66666","77777","8888888","9999999"])
        let type_dict1 = JSON(["type_name" : JSON("存储设备"),"mode_list":mode_list1])
        let type_list1 = JSON([type_dict1])
        let data_dict1 = JSON(["brand":JSON("HP"),"type_list":type_list1])
        
        let mode_list2 = JSON(["111111","22222","333333","44444","55555","66666"])
        let type_dict2 = JSON(["type_name" : JSON("存设备"),"mode_list":mode_list2])
        let mode_list3 = JSON(["111111","22222","333333","44444","55555","66666","123123"])
        let type_dict3 = JSON(["type_name" : JSON("存设11备"),"mode_list":mode_list3])
        let type_list2 = JSON([type_dict2,type_dict3])
        let data_dict2 = JSON(["brand":JSON("HP"),"type_list":type_list2])
        
        let data_arr = [data_dict1,data_dict2]

        return data_arr
    }()
    
    class func show() {
        let picker = LYBrandPickerView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH))
        ;
        picker.setUpMainUI()
        
        
        UIApplication.shared.keyWindow?.addSubview(picker)
        picker.subView.y = kScreenH
        UIView.animate(withDuration: 0.25) {
            picker.subView.y = kScreenH - 350
        }
    }
    
    @objc func hide() {
        if self.brandTF.isFirstResponder || self.modelTF.isFirstResponder{
            self.endEditing(true)
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.subView.y = kScreenH
        }) { (completion) in
            self.removeFromSuperview()
        }
    }
    
    @objc func sureAction() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        if self.dataArray.count > row{
            
        }
        self.hide()
    }

}




extension LYBrandPickerView{
    func setUpMainUI() {
        //1.基础设置
        self.backgroundColor = UIColor.clear
        //2.背景按钮
        self.addSubview(self.bgBtn)
        //3.选择控件,按钮
        self.subView.addSubview(self.btnView)
        self.subView.addSubview(self.pickerView)
        
        self.addSubview(self.subView)
    }
}



extension LYBrandPickerView : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return self.dataArray.count
        }else if component == 1{
            let dataJson = self.dataArray[self.brand_index]
            return dataJson["type_list"].arrayValue.count
        }else if component == 2{
            let dataJson = self.dataArray[self.brand_index]
            let typeJson = dataJson["type_list"].arrayValue[self.type_index]
            return typeJson["mode_list"].arrayValue.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            let dataJson = self.dataArray[row]
            self.brandTF.text = dataJson["brand"].stringValue
            return dataJson["brand"].stringValue
        }else if component == 1{
            let dataJson = self.dataArray[self.brand_index]
            return dataJson["type_list"].arrayValue[row]["type_name"].stringValue
        }else if component == 2{
            let dataJson = self.dataArray[self.brand_index]
            let typeJson = dataJson["type_list"].arrayValue[self.type_index]
            self.modelTF.text = typeJson["mode_list"].arrayValue[row].stringValue
            return typeJson["mode_list"].arrayValue[row].stringValue
        }
        return "无效选项"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            self.brand_index = row
            self.type_index = 0
            self.model_index = 0
            pickerView.selectRow(0, inComponent: 1, animated: false)
            pickerView.selectRow(0, inComponent: 2, animated: false)
        }else if component == 1{
            self.type_index = row
            self.model_index = 0
            pickerView.selectRow(0, inComponent: 2, animated: false)
        }else if component == 2{
            self.model_index = row
        }
        pickerView.reloadAllComponents()
    }
}
