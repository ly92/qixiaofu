//
//  LYPhotosViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/10/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class LYPhotosViewController: UIViewController {

    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>?
    //缩略图大小
    var collectionItemSize:CGSize{
        get{
            var w : CGFloat = 0
            if kScreenW == 320{
                w = (kScreenW - 4) / 3.0
            }else if kScreenW == 375{
                w = (kScreenW - 5) / 4.0
            }else{
                w = (kScreenW - 6) / 5.0
            }
            return CGSize.init(width: w, height: w)
        }
    }
    //每次最多可选择的照片数量
    var maxNum : NSInteger = 9
    
    //选中的
    var selectedIndex = Array<NSInteger>()
    var selectedArray = Array<PHAsset>()
    
    //照片选择完毕后的回调
    var completeBlock : ((Array<PHAsset>) -> Void)?
    //取消回调
    var cancelBlock : (() -> Void)?
    
    fileprivate var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpViews()

        
    }
    
    func setUpViews() {
        //1.图片列表
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = collectionItemSize
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        self.collectionView = UICollectionView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: self.view.h - 50), collectionViewLayout:layout)
        self.collectionView.backgroundColor = BG_Color
        self.collectionView.contentInset = UIEdgeInsets.init(top: 1, left: 1, bottom: 1, right: 1)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        self.collectionView.register(UINib.init(nibName: "LYSelectePhotoCell", bundle: Bundle.main), forCellWithReuseIdentifier: "LYSelectePhotoCell")
        
        

        //2.底部按钮
        let bottomView = UIView(frame:CGRect.init(x: 0, y: self.view.h-50, width: kScreenW, height: 50))
        bottomView.backgroundColor = BG_Color
        self.view.addSubview(bottomView)
        let doneBtn = UIButton.init(type: .custom)
        doneBtn.frame = CGRect.init(x: kScreenW-100, y: 0, width: 80, height: 50)
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.setTitleColor(Text_Color, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        doneBtn.addTarget(self, action: #selector(LYPhotosViewController.doneAction), for: .touchUpInside)
        bottomView.addSubview(doneBtn)
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.frame = CGRect.init(x: 20, y: 0, width: 80, height: 50)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.lightGray, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cancelBtn.addTarget(self, action: #selector(LYPhotosViewController.cancelAction), for: .touchUpInside)
        bottomView.addSubview(cancelBtn)
    }
    
    @objc func doneAction() {
        if self.completeBlock != nil{
            self.completeBlock!(self.selectedArray)
        }
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func cancelAction() {
        if self.cancelBlock != nil{
            self.cancelBlock!()
        }
        self.navigationController?.popViewController(animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LYPhotosViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LYSelectePhotoCell", for: indexPath) as! LYSelectePhotoCell
        if self.assetsFetchResults != nil{
            if self.assetsFetchResults!.count > indexPath.row{
                let asset = self.assetsFetchResults![indexPath.row]
                PHCachingImageManager.default().requestImage(for: asset, targetSize: collectionItemSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
                    cell.imgV.image = image
                })
                cell.selecteBlock = {() in
                    if self.selectedIndex .contains(indexPath.row) {
                        self.selectedArray.remove(at: self.selectedIndex.index(of: indexPath.row)!)
                        self.selectedIndex.remove(at: self.selectedIndex.index(of: indexPath.row)!)
                    }else{
                        if self.selectedIndex.count < self.maxNum{
                            self.selectedIndex.append(indexPath.row)
                            self.selectedArray.append(asset)
                        }else{
                            LYProgressHUD.showInfo("已达到选择上限！")
                        }
                    }
                    for index in self.selectedIndex{
                        self.collectionView.reloadItems(at: [IndexPath.init(row: index, section: 0)])
                    }
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        if self.selectedIndex .contains(indexPath.row) {
            let index = self.selectedIndex.index(of: indexPath.row)! + 1
            cell.selectedBtn.setImage(nil, for: .normal)
            cell.numLbl.text = "\(index)"
            cell.numLbl.isHidden = false
        }else{
            cell.numLbl.isHidden = true
            cell.selectedBtn.setImage(#imageLiteral(resourceName: "photo_select"), for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if self.assetsFetchResults != nil{
            if self.assetsFetchResults!.count > indexPath.row{
                let asset = self.assetsFetchResults![indexPath.row]
                PHCachingImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
                    if image != nil{
                        //查看图片
                        let photoBrowseVC = LYPhotoBrowseViewController()
                        photoBrowseVC.imgArray = [image!]
                        photoBrowseVC.showDeleteBtn = false
                        self.navigationController?.pushViewController(photoBrowseVC, animated: true)
                    }
                })
            }
        }
    }

}
