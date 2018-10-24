//
//  PublishJobViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import Speech
import AudioToolbox


class PublishJobViewController: BaseTableViewController {
    class func spwan() -> PublishJobViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! PublishJobViewController
    }
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "发布招聘"
        
        self.plusBtn.layer.cornerRadius = 2
        self.minuteBtn.layer.cornerRadius = 2
        self.publishBtn.layer.cornerRadius = 15
        
        
        
    }
    

    @IBAction func btnAction(_ btn: UIButton) {
        self.view.endEditing(true)
        
        if btn.tag == 11{
            //显示公司名称
            self.companyBtn1.isSelected = true
            self.companyBtn2.isSelected = false
        }else if btn.tag == 22{
            //隐藏公司名称
            self.companyBtn1.isSelected = false
            self.companyBtn2.isSelected = true
        }else if btn.tag == 33{
            //内部招聘
            self.typeBtn1.isSelected = true
            self.typeBtn2.isSelected = false
        }else if btn.tag == 44{
            //外派
            self.typeBtn1.isSelected = false
            self.typeBtn2.isSelected = true
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
            
        }
    }
    

}


extension PublishJobViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                //职位
                LYPickerView.show(titles: ["驻场工程师","职位1","职位2","职位3"], selectBlock: {(title,index) in
                    self.jobNameLbl.text = title
                })
            }else if indexPath.row == 4{
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
            }else if indexPath.row == 5{
                //薪资要求
                let picker = LYPricePickerView()
                picker.show()
                picker.pickerViewBlock = {(first,second) in
                    self.moneyLbl.text = "\(first)~\(second)K"
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

