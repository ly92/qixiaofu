//
//  InventoryCell.swift
//  qixiaofu
//
//  Created by ly on 2017/8/10.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class InventoryCell: UITableViewCell {
    
    var refreshBlock : (() -> Void)?
    

    var parentVC = UIViewController()
    
    var subJson : JSON = []{
        didSet{
            self.iconImgV.setImageUrlStr(subJson["goods_image"].stringValue)
            self.nameLbl.text = subJson["goods_name"].stringValue
            self.snLbl.text = subJson["goods_sn"].stringValue
            self.countLbl.text = "数量 " + subJson["goods_num"].stringValue
            self.areaLbl.text = subJson["area_name"].stringValue
        }
    }
    
    
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func changeAreaAction() {
        let chooseVc = ChooseAreaViewController()
        chooseVc.chooseAeraBlock = {(provinceId,cityId,areaId,addressArray) in
            LYProgressHUD.showLoading()
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            params["prov_id"] = provinceId
            params["city_id"] = cityId
            params["area_id"] = areaId
            params["address_name"] = addressArray.joined()
            
            NetTools.requestData(type: .post, urlString: ChangeInventoryAddressApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("更改成功！")
                //刷新数据
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })

        }
        self.parentVC.navigationController?.pushViewController(chooseVc, animated: true)
    }
    
    @IBAction func spendAction() {
        LYAlertView.show("提示", "你确定要销毁这个小库存吗", "取消", "确定", {
            LYProgressHUD.showLoading()
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: SpendInventoryApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("操作成功！")
                //刷新数据
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
            }, failure: { (error) in
                LYProgressHUD.showError(error!)
            })
        })
    }
    
}
