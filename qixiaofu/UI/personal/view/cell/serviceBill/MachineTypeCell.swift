//
//  MachineTypeCell.swift
//  qixiaofu
//
//  Created by ly on 2017/9/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class MachineTypeCell: UITableViewCell {
    
    var parentVC : UIViewController!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var reduceBtn: UIButton!
    @IBOutlet weak var leftTF: UITextField!
    @IBOutlet weak var rightTF: UITextField!
    @IBOutlet weak var rightScanBtn: UIButton!
    @IBOutlet weak var leftScanBtn: UIButton!
    //1:工程师创建。2:工程师修改。3:工程师查看 4:客户查看
    var showType = 1{
        didSet{
            if self.showType == 1 || self.showType == 2{
                self.addBtn.isHidden = false
                self.reduceBtn.isHidden = false
                self.rightScanBtn.isHidden = false
                self.leftScanBtn.isHidden = false
                self.leftTF.isEnabled = true
                self.rightTF.isEnabled = true
            }else{
                self.addBtn.isHidden = true
                self.reduceBtn.isHidden = true
                self.rightScanBtn.isHidden = true
                self.leftScanBtn.isHidden = true
                self.leftTF.isEnabled = false
                self.rightTF.isEnabled = false
            }
        }
    }
    
    var operationBlock : ((Int) -> Void)?//1:add 2:reduce
    var editDoneBlock : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addAction() {
        if self.operationBlock != nil{
            self.operationBlock!(1)
        }
    }
    
    @IBAction func reduceAction() {
        if self.operationBlock != nil{
            self.operationBlock!(2)
        }
    }
    
    @IBAction func leftScanAction() {
        let scanVC = ScanActionViewController()
        scanVC.scanResultBlock = {(result) in
            self.leftTF.text = result
            if self.editDoneBlock != nil{
                self.editDoneBlock!()
            }
        }
        self.parentVC.navigationController?.pushViewController(scanVC, animated: true)
    }
    @IBAction func rightScanAction() {
        let scanVC = ScanActionViewController()
        scanVC.scanResultBlock = {(result) in
            self.rightTF.text = result
            if self.editDoneBlock != nil{
                self.editDoneBlock!()
            }
        }
        self.parentVC.navigationController?.pushViewController(scanVC, animated: true)
    }
    
}

extension MachineTypeCell : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.editDoneBlock != nil{
            self.editDoneBlock!()
        }
    }
}
