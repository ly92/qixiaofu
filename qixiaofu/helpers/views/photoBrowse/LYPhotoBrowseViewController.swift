//
//  LYPhotoBrowseViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/4.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import Photos

typealias LYPhotoBrowseViewControllerBlock = (Array<UIImage>) -> Void

class LYPhotoBrowseViewController: UIViewController {
    
    var backImgArrayBlock : LYPhotoBrowseViewControllerBlock?
    var showDeleteBtn : Bool = true//是否显示图片的删除按钮
    var imgSingleTapBlock : (() -> Void)?
    
    var collectionView : UICollectionView!
    var imgArray : Array<UIImage> = Array<UIImage>()
    var imgDescArray : Array<String> = Array<String>()
    var selectIndex : NSInteger = 0
    
    //2018/10/11  -- 通过链接展示图片
    var imgUrlArray : Array<String> = Array<String>()
    var isByUrl = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpCollectionView()
        if self.isByUrl{
            self.navigationItem.title = "\(self.selectIndex + 1)/\(self.imgUrlArray.count)"
        }else{
            self.navigationItem.title = "\(self.selectIndex + 1)/\(self.imgArray.count)"
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(LYPhotoBrowseViewController.backClick))
        if (self.showDeleteBtn){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "删除", target: self, action: #selector(LYPhotoBrowseViewController.deleteImage))
        }
    }
    
    @objc func deleteImage() {
        if self.isByUrl{
            
        }else{
            if self.imgDescArray.count == self.imgArray.count{
                self.imgDescArray.remove(at: self.selectIndex)
            }
            self.imgArray.remove(at: self.selectIndex)
            if self.imgArray.count == 0{
                if (self.backImgArrayBlock != nil && self.showDeleteBtn){
                    self.backImgArrayBlock!(self.imgArray)
                }
                self.navigationController?.popViewController(animated: true)
            }
            if self.selectIndex == self.imgArray.count{
                self.selectIndex -= 1
            }
            self.navigationItem.title = "\(self.selectIndex + 1)/\(self.imgArray.count)"
            self.collectionView.reloadData()
        }
    }
    
    @objc func backClick() {
        if self.isByUrl{
            
        }else{
            if (self.backImgArrayBlock != nil && self.showDeleteBtn){
                self.backImgArrayBlock!(self.imgArray)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //collection
    func setUpCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.view.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView.register(LYPhotoPreviewCell.self, forCellWithReuseIdentifier: "LYPhotoPreviewCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.backgroundColor = UIColor.black
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.contentOffset = CGPoint.init(x: kScreenW * CGFloat(self.selectIndex), y: 0)
        
        self.view.addSubview(self.collectionView)
    }
    
}


extension LYPhotoBrowseViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isByUrl{
            return self.imgUrlArray.count
        }else{
            return self.imgArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell : LYPhotoPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LYPhotoPreviewCell", for: indexPath) as! LYPhotoPreviewCell
        cell.delegate = self
        if self.isByUrl{
            if self.imgUrlArray.count > indexPath.row{
                cell.setImageUrl(self.imgUrlArray[indexPath.row])
            }
        }else{
            if self.imgArray.count > indexPath.row{
                if self.imgDescArray.count == self.imgArray.count{
                    cell.renderModel(image: self.imgArray[indexPath.row], desc: self.imgDescArray[indexPath.row])
                }else{
                    cell.renderModel(image: self.imgArray[indexPath.row])
                }
                
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var showIndex : NSInteger
        showIndex = NSInteger(scrollView.contentOffset.x / kScreenW)
        if self.isByUrl{
            self.navigationItem.title = "\(showIndex + 1)/\(self.imgUrlArray.count)"
        }else{
            self.navigationItem.title = "\(showIndex + 1)/\(self.imgArray.count)"
        }
        self.selectIndex = showIndex
    }
    
    
}

extension LYPhotoBrowseViewController : LYPhotoPreviewCellDelegate{
    func onImageSingleTap(_ image: UIImage?) {
        
        if image != nil && self.imgSingleTapBlock == nil{
            let alert = UIAlertController.init(title: "图片操作", message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction.init(title: "保存到相册", style: .default) { (action) in
                PHPhotoLibrary.shared().performChanges({
                    let _ = PHAssetChangeRequest.creationRequestForAsset(from: image!)
                }, completionHandler: { (success, error) in
                    DispatchQueue.main.async {
                        if success{
                            LYProgressHUD.showSuccess("保存成功！")
                        }else if error != nil{
                            LYProgressHUD.showError("保存失败！")
                        }
                    }
                })
            }
            let action2 = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            }
            
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion:nil)
        }
        
        if (self.imgSingleTapBlock != nil){
            self.imgSingleTapBlock!()
        }
    }
    
}
