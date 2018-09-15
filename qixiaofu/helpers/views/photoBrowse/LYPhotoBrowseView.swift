//
//  LYPhotoBrowseView.swift
//  qixiaofu
//
//  Created by ly on 2017/7/3.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

typealias LYPhotoBrowseViewHeightBlock = (CGFloat) -> Void
typealias LYPhotoBrowseViewImageBlock = (UIImage) -> Void
typealias LYPhotoBrowseViewCustomBlock = () -> Void
typealias LYPhotoBrowseViewLongPressBlock = (NSInteger) -> Void

@objc
protocol LYPhotoBrowseViewDelegate : NSObjectProtocol{
    @objc func lyPhotoBrowseViewChangeHeight(lyPhoto:LYPhotoBrowseView, height:CGFloat)
}


class LYPhotoBrowseView: UIView {
    
    var showLogoImgV : Bool = false//是否显示图片的标签
    var showDeleteBtn : Bool = true//是否显示图片的删除按钮
    var canTakePhoto : Bool  = true//是否需要显示选择图片
    var maxPhotoNum : NSInteger { //最多选择多少图片,默认三张
        didSet{
            //显示图片控制
            if self.imgArray.count > maxPhotoNum{
                self.imgArray.removeSubrange(maxPhotoNum...self.imgArray.count - 1)
                self.collectionView.reloadData()
            }
        }
    }
    var imgArray : Array<UIImage> = Array<UIImage>()
    var imgDescArray : Array<String> = Array<String>()
    var imgLogoArray : Array<String> = Array<String>()
    var superVC : UIViewController!
    var heightValue : CGFloat = 0
    var imgUrlArray : Array<String> = Array<String>()//上传图片后得到的url
    
//    var isShowImg = false
    var isUrlImgArray = false
    var showImgUrlArray : Array<String>{
        didSet{
            isUrlImgArray = true
            self.imgArray.removeAll()
            self.collectionView.reloadData()
        }
    }
    
    
    var delegate : LYPhotoBrowseViewDelegate?

    var collectionView : UICollectionView!
    var heightBlock : LYPhotoBrowseViewHeightBlock?
    var imageBlock : LYPhotoBrowseViewImageBlock?
    var customBlock : LYPhotoBrowseViewCustomBlock?
    var longPressBlock : LYPhotoBrowseViewLongPressBlock?
    
    override init(frame: CGRect) {
        self.superVC = nil
        self.maxPhotoNum = 3
        self.showImgUrlArray = Array<String>()
        
        super.init(frame:frame)
        self.isUserInteractionEnabled = true
        self.frame = frame
        self.setUpCollectionView()
    }
    
    init(frame: CGRect,superVC:UIViewController) {
        self.superVC = superVC
        self.maxPhotoNum = 3
        self.showImgUrlArray = Array<String>()
        
        super.init(frame:frame)
        self.isUserInteractionEnabled = true
        self.frame = frame
        self.setUpCollectionView()
    }
    
    init(frame: CGRect, imgArray:Array<UIImage>,superVC:UIViewController) {
        self.imgArray = imgArray
        self.superVC = superVC
        self.maxPhotoNum = 3
        self.showImgUrlArray = Array<String>()
        
        super.init(frame:frame)
        self.isUserInteractionEnabled = true
        self.frame = frame
        self.setUpCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //collection
    func setUpCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:50, height:50)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 1
        //        layout.sectionInset = UIEdgeInsets(top: 5,left: 10,bottom: 5,right: 10)
        
        self.collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.dataSource = self
        self.collectionView.register(UINib.init(nibName: "LYPhotoBrowseCell", bundle: Bundle.main), forCellWithReuseIdentifier: "LYPhotoBrowseCell")
        
        self.addSubview(self.collectionView)
    }
    
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension LYPhotoBrowseView : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isUrlImgArray{
            if self.showImgUrlArray.count < maxPhotoNum && self.canTakePhoto{
                return self.showImgUrlArray.count + 1
            }
            return self.showImgUrlArray.count
        }else{
            if self.imgArray.count < maxPhotoNum && self.canTakePhoto{
                return self.imgArray.count + 1
            }
            return self.imgArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : LYPhotoBrowseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LYPhotoBrowseCell", for: indexPath) as! LYPhotoBrowseCell
        if self.isUrlImgArray{
            if self.showImgUrlArray.count > indexPath.row{
                cell.imgV.kf.setImage(with: URL(string:self.showImgUrlArray[indexPath.row]), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, memory, url) in
                    if image != nil{
                        self.imgArray.append(image!)
                    }
                })
                cell.deleteBtn.isHidden = !self.showDeleteBtn
                
                if self.showLogoImgV && self.imgLogoArray.count == self.showImgUrlArray.count{
                cell.logoImgV.isHidden = false
                    let type = self.imgLogoArray[indexPath.row]
                    if type == "20"{
                    cell.logoImgV.image = #imageLiteral(resourceName: "cert_nopass")
                    }else if type == "30"{
                    cell.logoImgV.image = #imageLiteral(resourceName: "cert_auditing")
                    }else{
                    cell.logoImgV.isHidden = true
                    }
                    
                }else{
                cell.logoImgV.isHidden = true
                }
            }else{
                cell.imgV.image = #imageLiteral(resourceName: "camera_icon")
                cell.deleteBtn.isHidden = true
                cell.logoImgV.isHidden = true
            }
            
            cell.deleteBlock = {[weak self] () in
                self?.showImgUrlArray.remove(at: indexPath.row)
                self?.collectionView.reloadData()
                self?.imgArray.remove(at: indexPath.row)
//                self.imgUrlArray.remove(at: indexPath.row)
            }
            cell.longPressBlock = {() in
                if (self.longPressBlock != nil){
                    self.longPressBlock!(indexPath.row)
                }
            }
            
        }else{
            if self.imgArray.count > indexPath.row{
                cell.imgV.image = self.imgArray[indexPath.row]
                cell.deleteBtn.isHidden = !self.showDeleteBtn
                if self.showLogoImgV && self.imgLogoArray.count == self.imgArray.count{
                    cell.logoImgV.isHidden = false
                    let type = self.imgLogoArray[indexPath.row]
                    if type == "20"{
                        cell.logoImgV.image = #imageLiteral(resourceName: "cert_nopass")
                    }else if type == "30"{
                        cell.logoImgV.image = #imageLiteral(resourceName: "cert_auditing")
                    }else{
                        cell.logoImgV.isHidden = true
                    }
                }else{
                    cell.logoImgV.isHidden = true
                }
            }else{
                cell.imgV.image = #imageLiteral(resourceName: "camera_icon")
                cell.deleteBtn.isHidden = true
                cell.logoImgV.isHidden = true
            }
            
            cell.deleteBlock = {[weak self] () in
                self?.imgArray.remove(at: indexPath.row)
                self?.collectionView.reloadData()
                self?.imgUrlArray.remove(at: indexPath.row)
            }
            cell.longPressBlock = {[weak self] () in
                if (self?.longPressBlock != nil){
                    self?.longPressBlock!(indexPath.row)
                }
            }
        }
        
        cell.deleteBtn.isHidden = true
//        cell.rightDis.constant = 0
//        cell.leftDis.constant = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.imgArray.count > indexPath.row{
            //查看图片
            let photoBrowseVC = LYPhotoBrowseViewController()
            
            photoBrowseVC.imgArray = self.imgArray
            photoBrowseVC.imgDescArray = self.imgDescArray
            photoBrowseVC.selectIndex = indexPath.row
            photoBrowseVC.showDeleteBtn = self.showDeleteBtn
            photoBrowseVC.backImgArrayBlock = {[weak self] (imgArray) in
                self?.imgArray = imgArray
                self?.collectionView.reloadData()
            }
            self.superVC.navigationController?.pushViewController(photoBrowseVC, animated: true)
        }else{
            if (self.customBlock != nil){
                self.customBlock!()
            }else{
                //选取照片
                self.addPhotoAction()
            }
        }
    }
    //将高度返回
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (self.heightBlock != nil && self.heightValue != collectionView.contentSize.height + 5){
            self.heightBlock!(collectionView.contentSize.height + 5)
            self.h = collectionView.contentSize.height + 5
            collectionView.h = collectionView.contentSize.height + 5
        }
        
        if (self.heightValue != collectionView.contentSize.height + 5){
            self.h = collectionView.contentSize.height + 5
            collectionView.h = collectionView.contentSize.height + 5
            self.heightValue = collectionView.contentSize.height + 5
            
            self.delegate?.lyPhotoBrowseViewChangeHeight(lyPhoto: self, height: collectionView.contentSize.height)
        }
    }
    
    
}

extension LYPhotoBrowseView : UIActionSheetDelegate{
    func addPhotoAction() {
        let sheet = UIActionSheet.init(title: "添加图片", delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: nil, otherButtonTitles: "相册", "拍照")
        sheet.show(in: self)
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
    

}

extension LYPhotoBrowseView : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
        self.superVC.present(picker, animated: true, completion: nil)
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
            self.superVC.present(picker, animated: true, completion: nil)
        }else{
            LYProgressHUD.showError("不允许访问相册")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if (self.imageBlock != nil){
            self.imageBlock!(img)
        }
        
        LYProgressHUD.showLoading()
        NetTools.upLoadImage(urlString : UploadImageApi,imgArray: [img], success: { (result) in
            self.imgUrlArray.append(result)
            if self.isUrlImgArray{
                self.showImgUrlArray.append(result)
            }
            self.imgArray.append(img)
            self.collectionView.reloadData()
            LYProgressHUD.dismiss()
        }, failture: { (error) in
            LYProgressHUD.showError("请重新选择！")
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}
