//
//  AddTestCell1.swift
//  qixiaofu
//
//  Created by ly on 2018/2/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class AddTestCell1: UITableViewCell {
    @IBOutlet weak var pnTF: UITextField!
    
    
    var doneEditPNBlock : ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension AddTestCell1 : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let pnStr = textField.text else {
            return false
        }
        
        if self.doneEditPNBlock != nil{
            self.doneEditPNBlock!(pnStr)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let pnStr = textField.text else {
            return
        }
        
        if self.doneEditPNBlock != nil{
            self.doneEditPNBlock!(pnStr)
        }
    }
    
    
}
