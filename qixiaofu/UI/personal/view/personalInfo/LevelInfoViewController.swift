//
//  LevelInfoViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/30.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class LevelInfoViewController: BaseTableViewController {
    class func spwan() -> LevelInfoViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! LevelInfoViewController
    }
    
    
    @IBOutlet weak var infoLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "等级说明"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 10{
            return self.infoLbl.resizeHeight() + 45
        }
        return 44
    }
}
