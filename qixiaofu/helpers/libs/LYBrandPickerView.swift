//
//  LYBrandPickerView.swift
//  qixiaofu
//
//  Created by ly on 2018/9/12.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


typealias LYBrandPickerViewBlock = (String,String,String) -> Void

class LYBrandPickerView: UIView {
    
    fileprivate var brand_index = 0
    fileprivate var type_index = 0
    fileprivate var model_index = 0
    
    fileprivate var brandStr = ""
    fileprivate var typeStr = ""
    fileprivate var modelStr = ""
    
    
    fileprivate var brandTF = UITextField()
    fileprivate var typeTF = UITextField()
    fileprivate var modelTF = UITextField()
    
    var pickerViewBlock : LYBrandPickerViewBlock?
    
    fileprivate lazy var pickerView : UIPickerView = {
        let pickerView = UIPickerView.init(frame: CGRect.init(x: 10, y: 165, width: kScreenW-20, height: 185))
        pickerView.backgroundColor = UIColor.white
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    fileprivate lazy var btnView : UIView = {
        let btnView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 165))
        btnView.backgroundColor = UIColor.white
        
        //底部线
        let line = UIView.init(frame: CGRect.init(x: 0, y: 43, width: kScreenW, height: 1))
        line.backgroundColor = UIColor.RGBS(s: 240)
        btnView.addSubview(line)
        //取消按钮
        let cancelBtn = UIButton.init(frame: CGRect.init(x: 15, y: 0, width: 60, height: 43))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.lightGray, for: .normal)
        cancelBtn.addTarget(self, action: #selector(LYPickerView.hide), for: .touchUpInside)
        btnView.addSubview(cancelBtn)
        //确定按钮
        let sureBtn = UIButton.init(frame: CGRect.init(x: kScreenW - 75, y: 0, width: 60, height: 43))
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
        sureBtn.addTarget(self, action: #selector(LYPickerView.sureAction), for: .touchUpInside)
        btnView.addSubview(sureBtn)
        
        //品牌
        let brandLbl = UILabel.init(frame: CGRect.init(x: 20, y: 55, width: 50, height: 30))
        brandLbl.font = UIFont.systemFont(ofSize: 14.0)
        brandLbl.textColor = Text_Color
        brandLbl.text = "品牌:"
        btnView.addSubview(brandLbl)
        self.brandTF = UITextField.init(frame: CGRect.init(x: 70, y: 55, width: kScreenW-140, height: 30))
        self.brandTF.borderStyle = .roundedRect
        self.brandTF.font = UIFont.systemFont(ofSize: 14.0)
        self.brandTF.textColor = Text_Color
        btnView.addSubview(self.brandTF)
        
        //类型
        let typeLbl = UILabel.init(frame: CGRect.init(x: 20, y: 90, width: 50, height: 30))
        typeLbl.font = UIFont.systemFont(ofSize: 14.0)
        typeLbl.textColor = Text_Color
        typeLbl.text = "类型:"
        btnView.addSubview(typeLbl)
        self.typeTF = UITextField.init(frame: CGRect.init(x: 70, y: 90, width: kScreenW-140, height: 30))
        self.typeTF.borderStyle = .roundedRect
        self.typeTF.font = UIFont.systemFont(ofSize: 14.0)
        self.typeTF.textColor = Text_Color
        btnView.addSubview(self.typeTF)
        
        //型号
        let modelLbl = UILabel.init(frame: CGRect.init(x: 20, y: 125, width: 50, height: 30))
        modelLbl.font = UIFont.systemFont(ofSize: 14.0)
        modelLbl.textColor = Text_Color
        modelLbl.text = "型号:"
        btnView.addSubview(modelLbl)
        self.modelTF = UITextField.init(frame: CGRect.init(x: 70, y: 125, width: kScreenW-140, height: 30))
        self.modelTF.borderStyle = .roundedRect
        self.modelTF.font = UIFont.systemFont(ofSize: 14.0)
        self.modelTF.textColor = Text_Color
        btnView.addSubview(self.modelTF)
        
        //底部线
        let line2 = UIView.init(frame: CGRect.init(x: 0, y: 164, width: kScreenW, height: 1))
        line2.backgroundColor = UIColor.RGBS(s: 240)
        btnView.addSubview(line2)
        
        return btnView
    }()
    
    fileprivate var subView : UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: kScreenH - 350, width: kScreenW, height: 350))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    
    fileprivate var bgBtn : UIButton = {
        let bg_btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW-0, height: kScreenH))
        bg_btn.backgroundColor = UIColor.black
        bg_btn.alpha = 0.4
        bg_btn.addTarget(self, action: #selector(LYPickerView.hide), for: .touchUpInside)
        return bg_btn
    }()
    
    
    fileprivate lazy var dataArray : Array<JSON> = {
        let arr = Array<JSON>()
        return arr
    }()
    
    func show(_ data : JSON) {
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        self.dataArray = data.arrayValue
        self.setUpMainUI()
        UIApplication.shared.keyWindow?.addSubview(self)
        self.subView.y = kScreenH
        UIView.animate(withDuration: 0.25) {
            self.subView.y = kScreenH - 350
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
        let brandStr = self.brandTF.text
        let typeStr = self.typeTF.text
        let modelStr = self.modelTF.text
        if (brandStr?.isEmpty)! && (typeStr?.isEmpty)! && (modelStr?.isEmpty)!{
            LYProgressHUD.showError("请至少有一项不为空")
            return
        }
        if self.pickerViewBlock != nil{
            self.pickerViewBlock!(brandStr ?? "",typeStr ?? "",modelStr ?? "")
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
            return dataJson["child"].arrayValue.count
        }else if component == 2{
            let dataJson = self.dataArray[self.brand_index]
            let typeJson = dataJson["child"].arrayValue[self.type_index]
            return typeJson["child"].arrayValue.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            let dataJson = self.dataArray[row]
            self.brandTF.text = dataJson["name"].stringValue
            return dataJson["name"].stringValue
        }else if component == 1{
            let dataJson = self.dataArray[self.brand_index]
            self.typeTF.text = dataJson["child"].arrayValue[row]["name"].stringValue
            return dataJson["child"].arrayValue[row]["name"].stringValue
        }else if component == 2{
            let dataJson = self.dataArray[self.brand_index]
            let typeJson = dataJson["child"].arrayValue[self.type_index]
            self.modelTF.text = typeJson["child"].arrayValue[row]["name"].stringValue
            return typeJson["child"].arrayValue[row]["name"].stringValue
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLbl = view as? UILabel
        if pickerLbl == nil{
            pickerLbl = UILabel()
        }
        pickerLbl?.adjustsFontSizeToFitWidth = true
        pickerLbl?.textAlignment = .left
        pickerLbl?.backgroundColor = UIColor.clear
        pickerLbl?.font = UIFont.systemFont(ofSize: 14.0)
        pickerLbl?.minimumScaleFactor = 0.8
        pickerLbl?.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        
        return pickerLbl!
    }
}
