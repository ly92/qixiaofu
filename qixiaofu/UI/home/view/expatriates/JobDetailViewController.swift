//
//  JobDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class JobDetailViewController: BaseViewController {
    class func spwan() -> JobDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! JobDetailViewController
    }
    
    var isEng = false
    
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var responsibilityLbl: UILabel!
    @IBOutlet weak var qualificationLbl: UILabel!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var employmentBottomView: UIView!
    @IBOutlet weak var engineerBottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "招聘详情"
        
        if self.isEng{
            self.employmentBottomView.isHidden = true
            self.engineerBottomView.isHidden = false
        }else{
            self.employmentBottomView.isHidden = false
            self.engineerBottomView.isHidden = true
        }
        
        
    }
    

    @IBAction func btnAction(_ btn: UIButton) {
        if btn.tag == 11{
            let historyVC = ChatOrRecommendListViewController.spwan()
            self.navigationController?.pushViewController(historyVC, animated: true)
        }else if btn.tag == 22{
            let historyVC = ChatOrRecommendListViewController.spwan()
            historyVC.isChatHistory = true
            self.navigationController?.pushViewController(historyVC, animated: true)
        }else if btn.tag == 33{
            
        }
    }
    
    

}
