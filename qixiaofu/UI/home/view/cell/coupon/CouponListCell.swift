//
//  CouponListCell.swift
//  qixiaofu
//
//  Created by ly on 2018/3/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CouponListCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var moreActionBlock : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImgV.layer.cornerRadius = 17.5
        self.collectionView.register(UINib.init(nibName: "CouponListSubCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CouponListSubCell")
    }
    
    var subJson = JSON(){
        didSet{
            self.iconImgV.setHeadImageUrlStr(subJson["member_avatar"].stringValue)
            self.nameLbl.text = subJson["member_name"].stringValue
            self.collectionView.reloadData()
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moreAction() {
        if self.moreActionBlock != nil{
            self.moreActionBlock!()
        }
    }
}

extension CouponListCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subJson["coupon_list"].arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item  = collectionView.dequeueReusableCell(withReuseIdentifier: "CouponListSubCell", for: indexPath) as! CouponListSubCell
        if self.subJson["coupon_list"].arrayValue.count > indexPath.row{
            item.subJson = self.subJson["coupon_list"].arrayValue[indexPath.row]
        }
        
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if self.subJson["coupon_list"].arrayValue.count > indexPath.row{
            var json = self.subJson["coupon_list"].arrayValue[indexPath.row]
            if json["is_have"].intValue == 1{
                LYProgressHUD.showInfo("只可以领一张，不要贪心哦！")
                return
            }
            var params : [String : Any] = [:]
            params["coupon_id"] = json["id"].stringValue
            params["use_type"] = json["use_type"].stringValue
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: CouponTakeApi, parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.showSuccess("领券成功！")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: KPickCouponSuccessNotification), object: nil)
                })
            }) { (error) in
                LYProgressHUD.showError(error ?? "领取失败，请重试！")
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 150, height: 76)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
