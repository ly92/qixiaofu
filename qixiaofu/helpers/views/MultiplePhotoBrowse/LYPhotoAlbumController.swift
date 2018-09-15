//
//  LYPhotoAlbumController.swift
//  qixiaofu
//
//  Created by ly on 2017/10/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import Photos

//相簿列表项
struct LYPgotoAlbumItem {
    //相簿名称
    var title : String?
    //相簿内的资源
    var fetchResult : PHFetchResult<PHAsset>
}

class LYPhotoAlbumController: UITableViewController {
    
    //数据
    fileprivate var items = Array<LYPgotoAlbumItem>()
    //每次可选的最大数,默认为9
    var maxNum : NSInteger = 9
    //回调
    var completeBlock : ((Array<PHAsset>) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "相册"
        
        self.checkPhotoAlbum()
        
        //添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self,
                                           action:#selector(LYPhotoAlbumController.cancel) )
        self.navigationItem.rightBarButtonItem = rightBarItem
        
    }
    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //相册
    func checkPhotoAlbum() {
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
            // 列出所有系统的智能相册
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOptions)
            self.convertCollection(collection: smartAlbums)
            //列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.convertCollection(collection: userCollections as! PHFetchResult<PHAssetCollection>)
            //相册按包含的照片数量排序（降序）
            self.items.sort(by: { (item1, item2) -> Bool in
                return item1.fetchResult.count > item2.fetchResult.count
            })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                //首次进来后直接进入第一个相册图片展示页面（相机胶卷）
                let photosVC = LYPhotosViewController()
                photosVC.title = self.items.first?.title
                photosVC.assetsFetchResults = self.items.first?.fetchResult
                photosVC.maxNum = self.maxNum
                photosVC.completeBlock = {[weak self] (assets) in
                    if self?.completeBlock != nil{
                        self?.completeBlock!(assets)
                    }
                    self?.cancel()
                }
                photosVC.cancelBlock = {[weak self] () in
                    self?.cancel()
                }
                self.navigationController?.pushViewController(photosVC, animated: false)
            }
        }
        
        
    }
    
    func convertCollection(collection:PHFetchResult<PHAssetCollection>) {
        for i in 0..<collection.count {
            //获取出但前相簿内的图片
            let reultsOptions = PHFetchOptions()
            reultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            reultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let col = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: col, options: reultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0{
                let title = titleOfAlbumForChinse(title: col.localizedTitle)
                items.append(LYPgotoAlbumItem.init(title: title, fetchResult: assetsFetchResult))
            }
        }
    }
    
    func titleOfAlbumForChinse(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
    

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LYPhotoAlbumControllerCell")
        if cell == nil{
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "LYPhotoAlbumControllerCell")
        }
        cell?.textLabel?.textColor = Text_Color
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell?.accessoryType = .disclosureIndicator
        if self.items.count > indexPath.row{
            let sub = self.items[indexPath.row]
            cell?.textLabel?.text = sub.title
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.items.count > indexPath.row{
            let sub = self.items[indexPath.row]
            
            let photosVC = LYPhotosViewController()
            photosVC.title = sub.title
            photosVC.assetsFetchResults = sub.fetchResult
            photosVC.maxNum = self.maxNum
            photosVC.completeBlock = {[weak self] (assets) in
                if self?.completeBlock != nil{
                    self?.completeBlock!(assets)
                }
                self?.cancel()
            }
            photosVC.cancelBlock = {[weak self] () in
                self?.cancel()
            }
            self.navigationController?.pushViewController(photosVC, animated: false)
        }
    }
    
    
}
