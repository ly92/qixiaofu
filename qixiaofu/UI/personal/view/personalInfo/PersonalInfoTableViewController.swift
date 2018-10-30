//
//  PersonalInfoTableViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/26.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Photos


class PersonalInfoTableViewController: BaseTableViewController {
    class func spwan() -> PersonalInfoTableViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! PersonalInfoTableViewController
    }
    
    var personalInfo : JSON = []
    
    
    
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var realNameLbl: UILabel!
    @IBOutlet weak var realNameArrowImgV: UIImageView!
//    @IBOutlet weak var workYearLbl: UILabel!
//    @IBOutlet weak var certView: UIView!
//    @IBOutlet weak var techRangeLbl: UILabel!
//    @IBOutlet weak var adaptBrandTF: UITextField!
    @IBOutlet weak var invoteCodeLbl: UILabel!
    @IBOutlet weak var levelCodeLbl: UILabel!
    @IBOutlet weak var levelImgV1: UIImageView!
    @IBOutlet weak var levelImgV2: UIImageView!
    @IBOutlet weak var levelImgV3: UIImageView!
    fileprivate var photoView = LYPhotoBrowseView()
    fileprivate var serverRangeJson : JSON = []
    
    
    fileprivate var workYear : Date?//从业年限
    fileprivate var nickName : String = ""//昵称
    fileprivate var techRangeArray : Array<String> = Array<String>()//技术领域
    fileprivate var adaptBrand : String = ""//擅长品牌
    fileprivate var cerImgs : String = ""//职业证书
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "个人信息"
        self.iconImgV.layer.cornerRadius = 20
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "reminder_icon"), target: self, action: #selector(PersonalInfoTableViewController.rightItemAction))
        
        self.setUpUIData()
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.loadMineInfoData()
    }
    
    //用户信息
    func loadMineInfoData() {
        NetTools.requestData(type: .post, urlString: PersonalInfoApi, succeed: { (resultJson, msg) in
            self.personalInfo = resultJson
            self.setUpUIData()
            self.tableView.reloadRows(at: [IndexPath.init(row: 4, section: 0)], with: .none)
        }) { (error) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //温馨提示
    @objc func rightItemAction() {
        let remindView = PersonalRemindView.init(frame: CGRect.zero)
        remindView.show()
    }
    
    

    
    //设置页面数据
    func setUpUIData() {
        self.iconImgV.setHeadImageUrlStr(self.personalInfo["member_avatar"].stringValue)
        if !self.personalInfo["member_nik_name"].stringValue.isEmpty{
            self.nickNameTF.text = self.personalInfo["member_nik_name"].stringValue
        }
        if self.personalInfo["is_real"].stringValue.intValue == 1{
            self.realNameLbl.text = "已认证"
            self.realNameArrowImgV.isHidden = true
        }else if self.personalInfo["is_real"].stringValue.intValue == 2{
            self.realNameLbl.text = "审核中"
            self.realNameArrowImgV.isHidden = false
        }
//        if !self.personalInfo["working_time"].stringValue.isEmpty{
//            self.workYearLbl.text = Date.dateStringFromDate(format: Date.yearFormatString(), timeStamps: self.personalInfo["working_time"].stringValue)
//        }
        
        
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
//        self.certView.addSubview(self.photoView)
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
//            self.techRangeLbl.text = sectorArray.joined(separator: ",")
        }
        if !self.personalInfo["service_brand"].stringValue.isEmpty{
//            self.adaptBrandTF.text = self.personalInfo["service_brand"].stringValue
        }
        if !self.personalInfo["iv_code"].stringValue.isEmpty{
            self.invoteCodeLbl.text = self.personalInfo["iv_code"].stringValue
        }
        
        self.levelCodeLbl.text = self.personalInfo["levelscore"].stringValue + "分"
        UIImageView.setLevelImageView(imgV1: self.levelImgV3, imgV2: self.levelImgV2, imgV3: self.levelImgV1, level: self.personalInfo["level"].stringValue)
        
    }
    
    //更改个人信息
    func changePersonalInfo() {
        self.view.endEditing(true)
        var params : [String : Any] = [:]
        if self.workYear != nil{
            params["working_time"] = self.workYear?.phpTimestamp()
        }
        if !self.nickName.isEmpty{
            params["nik_name"] = self.nickName
        }
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
            LYProgressHUD.showSuccess("保存成功！")
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
}

extension PersonalInfoTableViewController : UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //编辑完成
        if textField == self.nickNameTF{
            self.nickName = textField.text!
            if !self.nickName.isEmpty{
                self.changePersonalInfo()
            }
        }
        return true
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == self.adaptBrandTF{
//            let editVC = PersonalEditInfoViewController()
//            editVC.textView.text = self.adaptBrandTF.text
//            editVC.editDoneBlock = {(str) in
//                self.adaptBrand = str
//                self.adaptBrandTF.text = str
//                self.changePersonalInfo()
//            }
//            self.navigationController?.pushViewController(editVC, animated: true)
//            return false
//        }
//        return true
//    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.view.endEditing(true)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.row {
        case 0:
            //更换头像
            self.addPhotoAction()
        case 2:
            //等级
            let levelInfoVC = LevelInfoViewController.spwan()
            self.navigationController?.pushViewController(levelInfoVC, animated: true)
        case 3:
            //实名认证
            if !self.realNameArrowImgV.isHidden{
                let idVC = IdentityViewController.spwan()
                self.navigationController?.pushViewController(idVC, animated: true)
            }
//        case 4:
            //从业年限
//            let datePicker = LYDatePicker.init(component: 1)
//            datePicker.ly_datepickerWithOneComponent = {(date,year) in
//                self.workYear = date
////                self.workYearLbl.text = "\(year)年"
//                self.changePersonalInfo()
//            }
//            datePicker.show()
//        case 6:
//            //技术领域
//            let serverRangeVC = ServerRangeViewController.spwan()
//            serverRangeVC.selectedIds = self.techRangeArray
//            serverRangeVC.serverRangeBlock = {(selectedDictArray,titles,ids) in
////                self.techRangeLbl.text = titles.joined(separator: ";")
//                self.techRangeArray = ids
//                self.changePersonalInfo()
//            }
//            serverRangeVC.dataArray = self.serverRangeJson.arrayValue
//            self.navigationController?.pushViewController(serverRangeVC, animated: true)
            
        case 5:
            //评价列表
            let commentVC = CommentListViewController()
            commentVC.member_id = self.personalInfo["member_id"].stringValue
            commentVC.isFromPersonalInfo = true
            self.navigationController?.pushViewController(commentVC, animated: true)
        case 6:
            //工程师简历
            let resumeVC = EngResumeTableViewController.spwan()
            resumeVC.personalInfo = self.personalInfo
//            commentVC.member_id = self.personalInfo["member_id"].stringValue
//            commentVC.isFromPersonalInfo = true
            self.navigationController?.pushViewController(resumeVC, animated: true)
        default:
            //
            print(indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 71
        }else if indexPath.row == 4{
            if self.personalInfo["member_level"].stringValue == "DA"{
                return 0
            }else{
                return 44
            }
        }
        return 44;
    }
}

extension PersonalInfoTableViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate {
    
    func addPhotoAction() {
        let sheet = UIActionSheet.init(title: "添加图片", delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: nil, otherButtonTitles: "相册", "拍照")
        sheet.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1{
            //相册
            self.photoAlbum()
        }else if buttonIndex == 2{
            //相机
            self.camera()
        }
    }
    //相机
    func camera() {
        //是否允许使用相机
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .restricted,.denied:
            LYAlertView.show("提示", "请允许App使用相机权限", "取消", "去设置", {
                //打开设置页面
                let url = URL(string:UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            })
            return
        case .authorized,.notDetermined:
            break
        }
        
        //是否有相机设备
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            LYProgressHUD.showError("此设备无拍照功能!!!")
            return
        }
        //后置与前置摄影头均不可用
        if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) && !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front){
            LYProgressHUD.showError("相机不可用!!!")
            return
        }
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    //相册
    func photoAlbum() {
        
        //是否允许使用相册
        switch PHPhotoLibrary.authorizationStatus() {
        case .restricted,.denied:
            LYAlertView.show("提示", "请允许App访问相册", "取消", "去设置", {
                //打开设置页面
                let url = URL(string:UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            })
            return
        case .authorized,.notDetermined:
            break
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.navigationBar.tintColor = UIColor.RGBS(s: 33)
            self.present(picker, animated: true, completion: nil)
        }else{
            LYProgressHUD.showError("不允许访问相册")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        var params : [String : String] = [:]
        params["store_id"] = "1"
        
        LYProgressHUD.showLoading()
        NetTools.upLoadCustomImage(urlString: ChangePersonalIconApi, imgArray: [img], parameters: params, success: { (result) in
            self.iconImgV.image = img
            
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError("请重新选择！")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

