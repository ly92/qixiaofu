//
//  LYPricePickerView.swift
//  qixiaofu
//
//  Created by ly on 2018/10/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class LYPricePickerView: UIView {
    
    
    var first = 1
    var second = 1
    
    var scale = 3
    
    typealias LYPricePickerViewBlock = (Int, Int) -> Void
    var pickerViewBlock : LYPricePickerViewBlock?
    
    fileprivate lazy var pickerView : UIPickerView = {
        let pickerView = UIPickerView.init(frame: CGRect.init(x: 10, y: 50, width: kScreenW-20, height: 185))
        pickerView.backgroundColor = UIColor.white
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    fileprivate var bgBtn : UIButton = {
        let bg_btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW-0, height: kScreenH))
        bg_btn.backgroundColor = UIColor.black
        bg_btn.alpha = 0.4
        bg_btn.addTarget(self, action: #selector(LYPickerView.hide), for: .touchUpInside)
        return bg_btn
    }()
    fileprivate var subView : UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: kScreenH - 235, width: kScreenW, height: 235))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    fileprivate lazy var btnView : UIView = {
        let btnView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 44))
        btnView.backgroundColor = UIColor.white
        
        //底部线
        let line = UIView.init(frame: CGRect.init(x: 0, y: 43, width: kScreenW, height: 1))
        line.backgroundColor = UIColor.RGBS(s: 240)
        btnView.addSubview(line)
        //取消按钮
        let cancelBtn = UIButton.init(frame: CGRect.init(x: 15, y: 0, width: 60, height: 43))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.lightGray, for: .normal)
        cancelBtn.addTarget(self, action: #selector(LYPricePickerView.hide), for: .touchUpInside)
        btnView.addSubview(cancelBtn)
        //确定按钮
        let sureBtn = UIButton.init(frame: CGRect.init(x: kScreenW - 75, y: 0, width: 60, height: 43))
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
        sureBtn.addTarget(self, action: #selector(LYPricePickerView.sureAction), for: .touchUpInside)
        btnView.addSubview(sureBtn)
        return btnView
    }()
    
    
    func show() {
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        self.setUpMainUI()
        UIApplication.shared.keyWindow?.addSubview(self)
        self.subView.y = kScreenH
        UIView.animate(withDuration: 0.25) {
            self.subView.y = kScreenH - 235
        }
    }
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
    
    @objc func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.subView.y = kScreenH
        }) { (completion) in
            self.removeFromSuperview()
        }
    }
    
    @objc func sureAction() {
        if self.second >= self.first{
            if self.pickerViewBlock != nil{
                if self.first == 1{
                    self.first = 0
                }
                self.pickerViewBlock!(first,second)
            }
            self.hide()
        }else{
            LYProgressHUD.showError("选择出错！")
        }
    }

}



extension LYPricePickerView : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return "\(row * self.scale)"
        }else if component == 1{
            return "\(row * self.scale + self.first)"
        }
        return "无效选项"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            self.first = row * self.scale
            self.second = self.first
            pickerView.selectRow(0, inComponent: 1, animated: false)
        }else if component == 1{
            self.second = row * self.scale + self.first
        }
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLbl = view as? UILabel
        if pickerLbl == nil{
            pickerLbl = UILabel()
        }
        pickerLbl?.adjustsFontSizeToFitWidth = true
        pickerLbl?.textAlignment = .center
        pickerLbl?.backgroundColor = UIColor.clear
        pickerLbl?.font = UIFont.systemFont(ofSize: 14.0)
        pickerLbl?.minimumScaleFactor = 0.8
        pickerLbl?.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        
        return pickerLbl!
    }
}

