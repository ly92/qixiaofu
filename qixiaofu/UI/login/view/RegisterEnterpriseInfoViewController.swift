//
//  RegisterEnterpriseInfoViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/18.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class RegisterEnterpriseInfoViewController: BaseViewController {
    class func spwan() -> RegisterEnterpriseInfoViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! RegisterEnterpriseInfoViewController
    }
    
    @IBOutlet weak var logoImgV: UIImageView!
    @IBOutlet weak var epNameTF: UITextField!
    @IBOutlet weak var epCodeTF: UITextField!
    @IBOutlet weak var epImgV: UIImageView!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var nextStepBtn: UIButton!
    
    var params : [String:Any] = [:]
    fileprivate var isLogo = true//是否在上传logo
    fileprivate var logoImgUrl = ""//logo
    fileprivate var epImgUrl = ""//营业执照
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logoImgV.layer.cornerRadius = 10
        self.nextStepBtn.layer.cornerRadius = 20
        
        self.logoImgV.addTapActionBlock {
            self.isLogo = true
            self.addPhotoAction()
        }
        self.epImgV.addTapActionBlock {
            self.isLogo = false
            self.addPhotoAction()
        }
        
        self.navigationItem.title = "上传企业信息"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAction(_ btn: UIButton) {
        if btn.tag == 11{
            //退出编辑
            self.view.endEditing(true)
        }else if btn.tag == 22{
            //同意协议
            self.selectedBtn.isSelected = !self.selectedBtn.isSelected
        }else if btn.tag == 33{
            //服务条款
            let webVC = BaseWebViewController.spwan()
            webVC.urlStr = RegisterRulesApi
            webVC.titleStr = "注册协议"
            self.navigationController?.pushViewController(webVC, animated: true)
        }else if btn.tag == 44{
            //下一步
            self.nextStepAction()
        }
    }
    
    
    func nextStepAction() {
        let epName = self.epNameTF.text
        let epCode = self.epCodeTF.text
        
        if self.logoImgUrl.isEmpty{
            LYProgressHUD.showError("请上传公司logo")
            return
        }
        
        if (epName?.isEmpty)!{
            LYProgressHUD.showError("请输入企业名称")
            return
        }
        
        if (epCode?.isEmpty)!{
            LYProgressHUD.showError("请输入企业编码")
            return
        }
        
        if !self.selectedBtn.isSelected{
            LYProgressHUD.showError( "请同意用户注册协议")
            return;
        }
        params["company_name"] = epName!
        params["company_number"] = epCode!
        params["company_license"] = self.epImgUrl
        params["company_logo"] = self.logoImgUrl
        let idVC = IdentityViewController.spwan()
        idVC.enterpriseParams = params
        self.navigationController?.pushViewController(idVC, animated: true)
    }
    
}



extension RegisterEnterpriseInfoViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate {
    
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
        LYProgressHUD.showLoading()
        NetTools.upLoadImage(urlString : UploadImageApi,imgArray: [img], success: { (result) in
            if self.isLogo{
                self.logoImgV.image = img
                self.logoImgUrl = result
            }else{
                self.epImgV.image = img
                self.epImgUrl = result
            }
            LYProgressHUD.dismiss()
        }, failture: { (error) in
            LYProgressHUD.showError("请重新选择！")
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

extension RegisterEnterpriseInfoViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
