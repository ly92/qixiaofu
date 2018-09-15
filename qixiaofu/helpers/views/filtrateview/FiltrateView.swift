//
//  FiltrateView.swift
//  qixiaofu
//
//  Created by ly on 2017/6/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class FiltrateView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias FiltrateViewBlock = (Array<String>) -> Void
    var filtrateBlock : FiltrateViewBlock?
    
    var area_list : JSON = []
    var selectedIds : Array<String> = Array<String>()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.register(UINib.init(nibName: "FiltrateCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FiltrateCell")
    }
    
    //弹出
    func show(with data:JSON) {
        self.area_list = data
        self.collectionView.reloadData()
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubview(toFront: self)
        self.x = kScreenW
        UIView.animate(withDuration: 0.25, animations: {
            self.x = 0
        })
    }
    

    @IBAction func bottomAction(_ btn: UIButton) {
        if btn.tag == 11{
            self.selectedIds.removeAll()
            self.collectionView.reloadData()
        }else{
            if (self.filtrateBlock != nil){
                self.filtrateBlock!(self.selectedIds)
            }
            self.hideAction()
        }
    }
    
    @IBAction func hideAction() {
        self.x = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.x = kScreenW
        }) { (complention) in
            self.removeFromSuperview()
        }
    }
    
}



extension FiltrateView : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.area_list.arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltrateCell", for: indexPath) as! FiltrateCell
        
        cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_gray")
        if area_list.arrayValue.count > indexPath.row{
            let subJson = self.area_list.arrayValue[indexPath.row]
            cell.titleLbl.text = subJson["area_name"].stringValue
            if self.selectedIds.contains(subJson["area_id"].stringValue){
                cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_red")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if area_list.arrayValue.count > indexPath.row{
            let subJson = self.area_list.arrayValue[indexPath.row]
            if self.selectedIds.contains(subJson["area_id"].stringValue){
                self.selectedIds.remove(at: self.selectedIds.index(of: subJson["area_id"].stringValue)!)
            }else{
                self.selectedIds.append(subJson["area_id"].stringValue)
            }
            
            self.collectionView.reloadData()
        }
    }
    

}

extension FiltrateView : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(kScreenW - 60 - 30) / 2.0, height:30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,left: 10,bottom: 5,right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    
    
}
