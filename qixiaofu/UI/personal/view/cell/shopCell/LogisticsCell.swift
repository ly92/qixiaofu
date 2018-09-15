//
//  LogisticsCell.swift
//  qixiaofu
//
//  Created by ly on 2018/3/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class LogisticsCell: UITableViewCell {

    @IBOutlet weak var logisticsTF: UITextField!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    var minusActionBlock : (() -> Void)?
    var plusActionBlock : (() -> Void)?
    var doneEditBlock : ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func minusAction() {
        if self.minusActionBlock != nil{
            self.minusActionBlock!()
        }
    }
    
    
    @IBAction func plusAction() {
        if self.plusActionBlock != nil{
            self.plusActionBlock!()
        }
    }
}

extension LogisticsCell : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.logisticsTF.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.doneEditBlock != nil{
            guard let logostics = self.logisticsTF.text else{
                return
            }
            self.doneEditBlock!(logostics)
        }
    }
}
