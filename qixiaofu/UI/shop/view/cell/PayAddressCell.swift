//
//  PayAddressCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/24.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias PayAddressCellBlock = () -> Void

class PayAddressCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewH: NSLayoutConstraint!
    @IBOutlet weak var defaultBtn: UIButton!
    @IBOutlet weak var arrowImgV: UIImageView!

    var editBlock : PayAddressCellBlock?
    var deleteBlock : PayAddressCellBlock?
    var setDefaultBlock : PayAddressCellBlock?

    var jsonModel : JSON = []{
        didSet{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self.nameLbl.text = jsonModel["company_true_name"].stringValue
            }else{
                self.nameLbl.text = jsonModel["true_name"].stringValue
            }
            
            self.addressLbl.text = jsonModel["area_info"].stringValue + jsonModel["address"].stringValue
            self.phoneLbl.text = jsonModel["mob_phone"].stringValue
            if jsonModel["is_default"].stringValue.intValue == 1{
                self.defaultBtn.isSelected = true
                self.defaultBtn.setTitle("  默认", for: .normal)
            }else{
                self.defaultBtn.isSelected = false
                self.defaultBtn.setTitle("  设为默认", for: .normal)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    @IBAction func setDefaultAction() {
        if self.setDefaultBlock != nil{
            self.setDefaultBlock!()
        }
    }
    
    @IBAction func deleteAction() {
        if self.deleteBlock != nil{
            self.deleteBlock!()
        }
    }
    
    @IBAction func editAddAction() {
        if self.editBlock != nil{
            self.editBlock!()
        }
    }
    
    
}
