//
//  BuyChatViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class BuyChatViewController: BaseTableViewController {
    class func spwan() -> BuyChatViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! BuyChatViewController
    }
    
    
    @IBOutlet weak var currentLbl: UILabel!

    @IBOutlet weak var bgBtn1: UIButton!
    @IBOutlet weak var bgBtn2: UIButton!
    @IBOutlet weak var bgBtn3: UIButton!
    @IBOutlet weak var bgBtn4: UIButton!
    @IBOutlet weak var bgBtn5: UIButton!
    @IBOutlet weak var bgBtn6: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var buyBtn: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "套餐购买"
        
        self.buyBtn.layer.cornerRadius = 20
    }
    
    
    @IBAction func btnAction(_ btn: UIButton) {
        
        func setBtn(){
            self.bgBtn1.isHidden = false
            self.bgBtn2.isHidden = false
            self.bgBtn3.isHidden = false
            self.bgBtn4.isHidden = false
            self.bgBtn5.isHidden = false
            self.bgBtn6.isHidden = false
        }
        
        if btn.tag == 77{
            btn.isSelected = !btn.isSelected
        }else if btn.tag == 88{
            //购买
            
        }else{
            setBtn()
            btn.isHidden = true
        }
        
        
    }
    
    
}
