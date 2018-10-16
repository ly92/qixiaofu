//
//  IdentityViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/26.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import Photos

class IdentityViewController: BaseViewController {
    class func spwan() -> IdentityViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! IdentityViewController
    }
    
    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var numLbl: UITextField!
    @IBOutlet weak var imgV1: UIImageView!
    @IBOutlet weak var imgV2: UIImageView!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    fileprivate var isImgV1 = true
    fileprivate var imgUrl1 = ""
    fileprivate var imgUrl2 = ""
    
    
    //来自企业注册认证时enterpriseParams不为空
    var enterpriseParams : [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "实名认证"
        
        self.submitBtn.layer.cornerRadius = 20
        self.imgV1.layer.cornerRadius = 10
        self.imgV2.layer.cornerRadius = 10

        self.imgV1.addTapAction(action: #selector(IdentityViewController.takeImg1), target: self)
        self.imgV2.addTapAction(action: #selector(IdentityViewController.takeImg2), target: self)
        if self.enterpriseParams == nil{
            self.loadIdentityInfo()
        }
        
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func takeImg1() {
        self.isImgV1 = true
        self.addPhotoAction()
    }
    @objc func takeImg2() {
        self.isImgV1 = false
        self.addPhotoAction()
    }
    
    //加载审核信息
    func loadIdentityInfo() {
        var url = ""
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPIDInfoApi
        }else{
            url = IdentityInfoApi
        }
        NetTools.requestData(type: .post, urlString: url, succeed: { (result, msg) in
            //0 未认证可提交 1 已认证不可提交 2 待审核不可提交
            self.nameLbl.text = result["member_truename"].stringValue
            self.numLbl.text = result["id_card"].stringValue
            self.imgUrl1 = result["real_img1"].stringValue
            self.imgUrl2 = result["real_img2"].stringValue
            
            self.imgV1.setImageUrlStrAndPlaceholderImg(result["real_img1"].stringValue, #imageLiteral(resourceName: "btn_uploadcamera"))
            
            self.imgV2.setImageUrlStrAndPlaceholderImg(result["real_img2"].stringValue, #imageLiteral(resourceName: "btn_uploadcamera"))
            
            self.lbl1.isHidden = false
            self.lbl2.isHidden = false
            
            if result["is_real"].stringValue.intValue == 1{
                self.submitBtn.isHidden = true
            }else{
                self.submitBtn.isHidden = false
            }
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //提交
    @IBAction func submitAction() {
        if (self.nameLbl.text?.isEmpty)!{
            LYProgressHUD.showError("请输入姓名")
            return
        }
        if !(self.numLbl.text?.isIdCard())!{
            LYProgressHUD.showError("请填写正确身份证号")
            return
        }
        if self.imgUrl1.isEmpty{
            LYProgressHUD.showError("请上传身份证正面")
            return
        }
        if self.imgUrl2.isEmpty {
            LYProgressHUD.showError("请上传身份证反面")
            return
        }
        if self.enterpriseParams != nil{
            self.registerEnterprise(2)
        }else{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self.registerEnterprise(2)
            }else{
                var params : [String : Any] = [:]
                params["member_truename"] = self.nameLbl.text
                params["id_card"] = self.numLbl.text
                params["real_img1"] = imgUrl1
                params["real_img2"] = imgUrl2
                NetTools.requestData(type: .post, urlString: IdentitySubmitApi, parameters: params, succeed: { (result, msg) in
                    LYAlertView.show("提交成功", "实名信息提交成功，等待后台审核！", "知道了", {
                        self.navigationController?.popViewController(animated: true)
                    })
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
            }
        }
    }
    
    //来自企业采购的实名认证  type:1 提交实名 2注册企业购
    func registerEnterprise(_ type : Int) {
        if type == 1{
            //实名认证
            var params : [String : Any] = [:]
            params["user_truename"] = self.nameLbl.text
            params["id_card"] = self.numLbl.text
            params["real_img1"] = imgUrl1
            params["real_img2"] = imgUrl2
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: EnterpriseIdVertifiApi, parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.dismiss()
                LYAlertView.show("提交成功", "审核结果将会短信通知您！可以先登录浏览App", "知道了", {
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }) { (error) in
                LYProgressHUD.showError(error ?? "提交失败，请重试！")
            }
        }else if type == 2{
            //注册时的认证
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: EnterpriseRegisterApi, parameters: self.enterpriseParams!, succeed: { (resultJson, msg) in
                LocalData.saveEPUserId(userId: resultJson["userid"].stringValue)
                let phone = self.enterpriseParams!["phone"]! as! String
                LocalData.saveYesOrNotValue(value: "1", key: KEnterpriseVersion)
                self.registerEnterprise(1)
                DispatchQueue.global().async {
                    //注册环信
                    esmobRegister(phone)
                    LocalData.saveUserPhone(phone: phone)
                }
            }) { (error) in
                LYProgressHUD.showError(error ?? "提交失败，请重试！")
            }
        }
    }
    
}


extension IdentityViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate {
    
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
        NetTools.upLoadImage(urlString : UploadImageApi,imgArray: [img], success: { (result) in
            if self.isImgV1{
                self.imgV1.image = img
                self.imgUrl1 = result
            }else{
                self.imgV2.image = img
                self.imgUrl2 = result
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
