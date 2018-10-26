//
//  EngResumeViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class EngResumeViewController: BaseTableViewController {
    class func spwan() -> EngResumeViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! EngResumeViewController
    }
    
    @IBOutlet weak var engImgV: UIImageView!
    @IBOutlet weak var baoImgV: UIImageView!
    @IBOutlet weak var engNameLbl: UILabel!
    @IBOutlet weak var curStateLbl: UILabel!
    @IBOutlet weak var realNameLbl: UILabel!
    @IBOutlet weak var workYearLbl: UILabel!
    @IBOutlet weak var advantageLbl: UILabel!
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var jobAddressLbl: UILabel!
    @IBOutlet weak var jobPriceLbl: UILabel!
    @IBOutlet weak var techRangeLbl: UILabel!
    @IBOutlet weak var brandLbl: UILabel!
    @IBOutlet weak var certView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "简历预览"
    }

    // MARK: - Table view data source



}
