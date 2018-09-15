//
//  FiltrateView2.swift
//  qixiaofu
//
//  Created by ly on 2017/6/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
class FiltrateView2: UIView {
    
    typealias FiltrateView2Block = ([String : Any]) -> Void
    var filtRateBlock : FiltrateView2Block?
    var startTime : Date?
    var endTime : Date?
    

    @IBOutlet weak var subscribeBtn1: UIButton!
    @IBOutlet weak var subscribeBtn2: UIButton!
    @IBOutlet weak var subscribeBtn3: UIButton!
    @IBOutlet weak var subscribeBtn4: UIButton!
    @IBOutlet weak var startTimeTF: UITextField!
    @IBOutlet weak var endTimeTF: UITextField!
    
    @IBOutlet weak var priceBtn1: UIButton!
    @IBOutlet weak var priceBtn2: UIButton!
    @IBOutlet weak var priceBtn3: UIButton!
    @IBOutlet weak var priceBtn4: UIButton!
    @IBOutlet weak var startPriceTF: UITextField!
    @IBOutlet weak var endPriceTF: UITextField!
    @IBOutlet weak var scrollViewH: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var subscribeBtnArray : Array<UIButton> = []
    var priceBtnArray : Array<UIButton> = []
    
    fileprivate var areaList : Array<Dictionary> = Array<Dictionary<String, String>>()
    fileprivate var selectedNames : Array<String> = Array<String>()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = CGRect(x:0,y:0,width:kScreenW,height:kScreenH)
//        self.addTapAction(action: #selector(FiltrateView2.endEdit), target: self)
        self.subscribeBtnArray = [self.subscribeBtn1,self.subscribeBtn2,self.subscribeBtn3,self.subscribeBtn4]
        self.priceBtnArray = [self.priceBtn1,self.priceBtn2,self.priceBtn3,self.priceBtn4]
        
        self.collectionView.register(UINib.init(nibName: "FiltrateCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FiltrateCell")
        
        self.scrollViewH.constant = 700
        
        //地址数组
        let path = Bundle.main.path(forResource: "area", ofType: "plist")
        self.areaList = NSArray.init(contentsOfFile: path!) as! Array<Dictionary<String, String>>
        self.collectionView.reloadData()
    }
    
    func endEdit() {
        self.endEditing(true)
    }
    
    //隐藏
    @IBAction func hideFiltRate() {
        if self.startPriceTF.isEditing || self.endPriceTF.isEditing{
            self.endEditing(true)
        }
        self.x = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.x = kScreenW
        }) { (complention) in
            self.removeFromSuperview()
        }
    }
    
    //弹出
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubview(toFront: self)
        self.x = kScreenW
        UIView.animate(withDuration: 0.25, animations: {
            self.x = 0
        })
    }
    
    //重置
    @IBAction func resetCondition() {
        for subBtn in self.subscribeBtnArray {
            subBtn.isSelected = false
        }
        for priceBtn in self.priceBtnArray {
            priceBtn.isSelected = false
        }
        self.startTimeTF.text = ""
        self.endTimeTF.text = ""
        self.startPriceTF.text = ""
        self.endPriceTF.text = ""
        
        self.selectedNames.removeAll()
        self.collectionView.reloadData()
    }
    //确定
    @IBAction func sureAction() {
        var params : [String : Any] = [:]
        params["service_stime"] = ""
        params["service_etime"] = ""
        params["service_sprice"] = ""
        params["service_eprice"] = ""
        
        if !(self.startTimeTF.text?.isEmpty)! && !(self.endTimeTF.text?.isEmpty)!{
            params["service_stime"] = self.startTime?.phpTimestamp()
            params["service_etime"] = self.endTime?.phpTimestamp()
        }else{
            for subBtn in self.subscribeBtnArray {
                if subBtn.isSelected{
                    switch subBtn.tag {
                    case 22:
                        params["service_stime"] = Date.phpTimestamp()
                        params["service_etime"] = Date.dateWithDaysAfterNow(days: 7).phpTimestamp()
                    case 33:
                        params["service_stime"] = Date.phpTimestamp()
                        params["service_etime"] = Date.dateWithDaysAfterNow(days: 15).phpTimestamp()
                    case 44:
                        params["service_stime"] = Date.dateWithDaysAfterNow(days: 15).phpTimestamp()
                        params["service_etime"] = ""
                    default:
                        break
                    }
                }
            }
        }
        
        if !(self.startPriceTF.text?.isEmpty)! && !(self.endPriceTF.text?.isEmpty)!{
            
            if self.startPriceTF.text!.floatValue > self.endPriceTF.text!.floatValue{
                LYProgressHUD.showError("最高价不得低于最低价！")
                return
            }
            
            params["service_sprice"] = self.startPriceTF.text
            params["service_eprice"] = self.endPriceTF.text
        }else{
            for priceBtn in self.priceBtnArray {
                if priceBtn.isSelected{
                    switch priceBtn.tag {
                    case 22:
                        params["service_sprice"] = "0"
                        params["service_eprice"] = "2000"
                    case 33:
                        params["service_sprice"] = "2000"
                        params["service_eprice"] = "5000"
                    case 44:
                        params["service_sprice"] = "5000"
                        params["service_eprice"] = ""
                    default:
                        break
                    }
                }
            }
        }
        
        //地址
        if self.selectedNames.count > 0{
            params["address"] = self.selectedNames.joined(separator: ",")
        }else{
            params["address"] = ""
        }
        
        if (self.filtRateBlock != nil){
            self.filtRateBlock!(params)
        }
        self.hideFiltRate()
    }
    
    //选择预约时间范围
    @IBAction func subscribeAction(_ btn: UIButton) {
        self.endEdit()
        for subBtn in self.subscribeBtnArray {
            if subBtn == btn{
                subBtn.isSelected = true
            }else{
                subBtn.isSelected = false
            }
        }
    }
    //选择价格范围
    @IBAction func spriceAction(_ btn: UIButton) {
        self.endEdit()
        for priceBtn in self.priceBtnArray {
            if priceBtn == btn{
                priceBtn.isSelected = true
            }else{
                priceBtn.isSelected = false
            }
        }
    }
    
}

extension FiltrateView2 : UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.startTimeTF || textField == self.endTimeTF{
            self.endEdit()
            let lyDatePicker = LYDatePicker.init(component: 3)
            //选择预约时间
            lyDatePicker.ly_datepickerWithThreeComponent = {(date,year,month,day) -> Void in
                
                if textField == self.startTimeTF{
                    if (self.endTime != nil){
                        if (date.isLaterThanDate(aDate: self.endTime!)){
                            LYProgressHUD.showError("开始时间不得晚于结束时间！")
                            return
                        }
                    }
                    self.startTime = date
                }else{
                    if (self.startTime != nil){
                        if (date.isEarlierThanDate(aDate: self.startTime!)){
                            LYProgressHUD.showError("开始时间不得晚于结束时间！")
                            return
                        }
                    }
                    self.endTime = date
                }
                textField.text = "\(year):\(month):\(day)"
            }
            lyDatePicker.show()
            
            return false
        }
        return true
    }
}

extension FiltrateView2 : UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.endEditing(true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.areaList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltrateCell", for: indexPath) as! FiltrateCell
        
        cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_gray")
        if areaList.count > indexPath.row{
            let dict = self.areaList[indexPath.row]
            cell.titleLbl.text = dict["areaName"]
            if self.selectedNames.contains(dict["areaName"]!){
                cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_red")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if areaList.count > indexPath.row{
            let dict = self.areaList[indexPath.row]
            if self.selectedNames.contains(dict["areaName"]!){
                self.selectedNames.remove(at: self.selectedNames.index(of: dict["areaName"]!)!)
            }else{
                self.selectedNames.append(dict["areaName"]!)
            }
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(kScreenW - 100 - 30) / 2.0, height:30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,left: 0,bottom: 5,right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    
}



