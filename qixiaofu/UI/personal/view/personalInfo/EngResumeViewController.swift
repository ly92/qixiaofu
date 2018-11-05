//
//  EngResumeViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngResumeViewController: BaseTableViewController {
    class func spwan() -> EngResumeViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! EngResumeViewController
    }
    
    var personalInfo : JSON = []
    
    @IBOutlet weak var engImgV: UIImageView!
    @IBOutlet weak var baoImgV: UIImageView!
    @IBOutlet weak var engNameLbl: UILabel!
    @IBOutlet weak var curStateLbl: UILabel!
    @IBOutlet weak var realNameLbl: UILabel!
    @IBOutlet weak var workYearLbl: UILabel!
    @IBOutlet weak var advantageLbl: UILabel!
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var jobAddressLbl: UILabel!
    @IBOutlet weak var jobPriceLbl: UILabel!
    @IBOutlet weak var techRangeLbl: UILabel!
    @IBOutlet weak var brandLbl: UILabel!
    @IBOutlet weak var certView: UIView!
    
    fileprivate var photoView = LYPhotoBrowseView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title =  self.personalInfo["member_truename"].stringValue + "的简历"
        
        self.engImgV.layer.cornerRadius = 20
        
        self.setUpUI()
    }
    
    
    func setUpUI() {
        self.engImgV.setImageUrlStr(self.personalInfo["member_avatar"].stringValue)
        //保证金
        if self.personalInfo["is_bail"].stringValue.intValue == 1{
            self.baoImgV.image = UIImage.init(named: "eng_xin_icon2")
        }else{
            self.baoImgV.image = UIImage.init(named: "eng_xin_icon1")
        }
        self.engNameLbl.text = self.personalInfo["member_truename"].stringValue
        
//        self.curStateLbl.text = self.personalInfo[""].stringValue
        self.curStateLbl.text = "在职-考虑机会"
        
        if self.personalInfo["is_real"].stringValue.intValue == 1{
            self.realNameLbl.text = "已认证"
        }else if self.personalInfo["is_real"].stringValue.intValue == 2{
            self.realNameLbl.text = "审核中"
        }else{
            self.realNameLbl.text = "未实名"
        }
        if !self.personalInfo["working_time"].stringValue.isEmpty{
            self.workYearLbl.text = "工作经验" + Date.dateStringFromDate(format: Date.yearFormatString(), timeStamps: self.personalInfo["working_time"].stringValue)
        }
        
        //技术领域
        if self.personalInfo["service_sector"].arrayValue.count > 0{
            var sectorArray : Array<String> = Array<String>()
            for subJson in self.personalInfo["service_sector"].arrayValue {
                sectorArray.append(subJson["gc_name"].stringValue)
            }
            self.techRangeLbl.text = sectorArray.joined(separator: ",")
        }
        //擅长品牌
        if !self.personalInfo["service_brand"].stringValue.isEmpty{
            self.brandLbl.text = self.personalInfo["service_brand"].stringValue
        }
        
//        self.jobNameLbl.text = self.personalInfo[""].stringValue
//        self.jobAddressLbl.text = self.personalInfo[""].stringValue
//        self.jobPriceLbl.text = self.personalInfo[""].stringValue
        self.jobNameLbl.text = "服务器工程师"
        self.jobAddressLbl.text = "北京市昌平区"
        self.jobPriceLbl.text = "9～10K"
        
        
//        self.advantageLbl.text = self.personalInfo[""].stringValue
        self.advantageLbl.text = "567899876543234567898765123俄特工身份的奉公守法的财富公司承担噶双方都尴尬的嘎的感觉啊是个大皇宫树大根深梵蒂冈哈佛的高发换个地方哈高速发达噶是否德国法国的"
        
        self.photoView = LYPhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: 50),superVC:self)
        self.photoView.backgroundColor = UIColor.white
        self.photoView.showLogoImgV = true
        self.photoView.maxPhotoNum = 5
        self.photoView.canTakePhoto = false
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
        
        
        
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 70
        }else if indexPath.row == 1{
            return self.advantageLbl.resizeHeight() + 45
        }else if indexPath.row == 2{
            return 80
        }else if indexPath.row == 3{
            return self.techRangeLbl.resizeHeight() + 45
        }else if indexPath.row == 4{
            return self.brandLbl.resizeHeight() + 45
        }else if indexPath.row == 5{
            return 106
        }
        return 0
    }
    
    
}
