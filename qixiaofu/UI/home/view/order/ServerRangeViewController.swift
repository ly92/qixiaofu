//
//  ServerRangeViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/3.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ServerRangeVCBlock = (Array<[String : Any]>,Array<String>,Array<String>) -> Void


class ServerRangeViewController: BaseViewController {
    class func spwan() -> ServerRangeViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! ServerRangeViewController
    }
    
    var serverRangeBlock : ServerRangeVCBlock?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataArray : Array<JSON> = Array<JSON>()
    
    
    var selectedIds : Array<String> = Array<String>()
    fileprivate var selectedDictArray : Array<[String : Any]> = Array<[String : Any]>()//所选领域字典的数组
    fileprivate var sectionTwoArray : Array<JSON> = Array<JSON>()//当前选中的父领域对应的子领域
    fileprivate var sectionOneIndex : NSInteger = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "请选择服务领域"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定" , target: self, action: #selector(ServerRangeViewController.rightItemAction))
        
        self.collectionView.register(UINib.init(nibName: "ServerRangeCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ServerRangeCollectionCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func rightItemAction() {
        var titles = Array<String>()
        var ids = Array<String>()
        for dict in self.selectedDictArray {
            let sub = dict["obj"] as! JSON
            var title = sub["gc_name"].stringValue
            ids.append(sub["gc_id"].stringValue)
            if dict.keys.contains("list"){
                var titiles1 = Array<String>()
                for subJson in dict["list"] as! Array<JSON> {
                    titiles1.append(subJson["gc_name"].stringValue)
                    ids.append(subJson["gc_id"].stringValue)
                }
                title = title + "(" + titiles1.joined(separator: ",") + ")"
            }
            titles.append(title)
        }
        
        if self.serverRangeBlock != nil{
            self.serverRangeBlock!(self.selectedDictArray,titles,ids)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension ServerRangeViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return self.dataArray.count
        }else{
            return self.sectionTwoArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ServerRangeCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServerRangeCollectionCell", for: indexPath) as! ServerRangeCollectionCell
        
        if indexPath.section == 0{
            if self.dataArray.count > indexPath.row{
                let subJson = self.dataArray[indexPath.row]
                cell.lbl.text = subJson["gc_name"].stringValue
                if selectedIds.contains(subJson["gc_id"].stringValue){
                    cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_red")
                }else{
                    cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_gray")
                }
            }
        }else{
            if self.sectionTwoArray.count > indexPath.row{
                let subJson = self.sectionTwoArray[indexPath.row]
                cell.lbl.text = subJson["gc_name"].stringValue
                if selectedIds.contains(subJson["gc_id"].stringValue){
                    cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_red")
                }else{
                    cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_gray")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if self.dataArray.count > indexPath.row{
                self.sectionOneIndex = indexPath.row
                let subJson = self.dataArray[indexPath.row]
                if selectedIds.contains(subJson["gc_id"].stringValue){
                    self.selectedIds.remove(at: self.selectedIds.index(of: subJson["gc_id"].stringValue)!)
                    let array = self.selectedDictArray
                    for (index,dict) in array.enumerated() {
                        let json = dict["obj"] as! JSON
                        if json["gc_id"].stringValue == subJson["gc_id"].stringValue{
                            self.selectedDictArray.remove(at: index)
                            if dict.keys.contains("list"){
                                for listJson in dict["list"] as! Array<JSON> {
                                    if self.selectedIds.contains(listJson["gc_id"].stringValue){
                                        self.selectedIds.remove(at: self.selectedIds.index(of: listJson["gc_id"].stringValue)!)
                                    }
                                }
                            }
                        }
                    }
                    self.sectionTwoArray.removeAll()
                }else{
                    self.selectedIds.append(subJson["gc_id"].stringValue)
                    var dict : [String : Any] = [:]
                    dict["obj"] = subJson
                    self.selectedDictArray.append(dict)
                    self.sectionTwoArray = subJson["list"].arrayValue
                    
                }
                
            }
        }else{
            if self.sectionTwoArray.count > indexPath.row{
                let subJson = self.sectionTwoArray[indexPath.row]
                
                if self.sectionOneIndex >= 0{
                    let subObj = self.dataArray[self.sectionOneIndex]
                    let array = self.selectedDictArray
                    for (index,dict) in array.enumerated() {
                        let json = dict["obj"] as! JSON
                        if json["gc_id"].stringValue == subObj["gc_id"].stringValue{
                            //选中的列表中包含当前选择项的父项
                            self.selectedDictArray.remove(at: index)
                            if dict.keys.contains("list"){
                                var list = dict["list"] as! Array<JSON>
                                
                                if selectedIds.contains(subJson["gc_id"].stringValue){
                                    self.selectedIds.remove(at: self.selectedIds.index(of: subJson["gc_id"].stringValue)!)
                                    for (index1,listJson) in (dict["list"] as! Array<JSON>).enumerated() {
                                        if listJson["gc_id"].stringValue == subJson["gc_id"].stringValue{
                                            list.remove(at: index1)
                                        }
                                    }
                                }else{
                                    list.append(subJson)
                                    self.selectedIds.append(subJson["gc_id"].stringValue)
                                }

                                var dict2 : [String : Any] = [:]
                                dict2["obj"] = dict["obj"]
                                dict2["list"] = list
                                self.selectedDictArray.append(dict2)
                            }else{
                                if selectedIds.contains(subJson["gc_id"].stringValue){
                                    self.selectedIds.remove(at: self.selectedIds.index(of: subJson["gc_id"].stringValue)!)
                                }else{
                                    self.selectedIds.append(subJson["gc_id"].stringValue)
                                    var dict2 : [String : Any] = [:]
                                    dict2["obj"] = dict["obj"]
                                    var list : Array<JSON> = Array<JSON>()
                                    list.append(subJson)
                                    dict2["list"] = list
                                    self.selectedDictArray.append(dict2)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
}

extension ServerRangeViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:kScreenW/3.0 - 10, height:30)
        
        
//        var width : CGFloat = 0
//        if indexPath.section == 0{
//            if self.dataArray.count > indexPath.row{
//                let subJson = self.dataArray[indexPath.row]
//                let text = subJson["gc_name"].stringValue
//                width = text.sizeFit(width: CGFloat(MAXFLOAT), height: 17, fontSize: 14.0).width + 10
//            }
//        }else{
//            if self.sectionTwoArray.count > indexPath.row{
//                let subJson = self.sectionTwoArray[indexPath.row]
//                let text = subJson["gc_name"].stringValue
//                width = text.sizeFit(width: CGFloat(MAXFLOAT), height: 17, fontSize: 14.0).width + 10
//            }
//        }
//        if width < 50 {
//            width = 50
//        }
//        return CGSize(width:width, height:30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize.zero
        }else{
            return CGSize.init(width: kScreenW, height: 20)
        }
    }
    
    
}

