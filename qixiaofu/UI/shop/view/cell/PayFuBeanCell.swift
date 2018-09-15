//
//  PayFuBeanCell.swift
//  qixiaofu
//
//  Created by ly on 2018/1/5.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class PayFuBeanCell: UITableViewCell {
    @IBOutlet weak var beanLbl: UILabel!
    @IBOutlet weak var beanTF: UITextField!
    
    
    var beanNum = 0
    
    var numChangedBlock : ((Int) ->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}

extension PayFuBeanCell : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var num = textField.text else {
            return false
        }
        if range.length == 0{
            //增加字符
                num.append(string)
        }else{
            //删除字符
                num = String(num.prefix(upTo: num.index(before: num.endIndex)))
        }
        if num.intValue > self.beanNum{
            LYProgressHUD.showError("不可超过可用量！")
            return false
        }
        
        if self.numChangedBlock != nil{
            self.numChangedBlock!(num.intValue)
        }
        
        return true
    }
    
}
