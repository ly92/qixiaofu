//
//  AddTestCell3.swift
//  qixiaofu
//
//  Created by ly on 2018/2/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class AddTestCell3: UITableViewCell {
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var moneyLbl: UILabel!
    
    var selectBtnBlock : ((Int) -> Void)?
    var deleteBtnBlock : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //选择
    @IBAction func btnAction(_ btn: UIButton) {
        if btn == self.btn1{
            btn2.setImage(#imageLiteral(resourceName: "btn_checkbox_n"), for: .normal)
            btn1.setImage(#imageLiteral(resourceName: "btn_checkbox_s"), for: .normal)
            if self.selectBtnBlock != nil{
                self.selectBtnBlock!(1)
            }
        }else{
            btn1.setImage(#imageLiteral(resourceName: "btn_checkbox_n"), for: .normal)
            btn2.setImage(#imageLiteral(resourceName: "btn_checkbox_s"), for: .normal)
            if self.selectBtnBlock != nil{
                self.selectBtnBlock!(2)
            }
        }
    }
    //删除
    @IBAction func deleteAction() {
        LYAlertView.show("提示", "确定删除此条？", "取消", "确定", {
            if self.deleteBtnBlock != nil{
                self.deleteBtnBlock!()
            }
        })
    }
    
    //仅测试
    @IBAction func onlyTestAction() {
        if self.selectBtnBlock != nil{
            self.selectBtnBlock!(3)
        }
    }
    
    //测试后包装
    @IBAction func testAndPackAction() {
        if self.selectBtnBlock != nil{
            self.selectBtnBlock!(4)
        }
    }
    
}
