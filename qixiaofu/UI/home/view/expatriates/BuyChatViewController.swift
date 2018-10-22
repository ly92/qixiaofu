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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    @IBAction func btnAction(_ btn: UIButton) {
    }
    
    
}
