//
//  JobListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class JobListViewController: BaseViewController {
    class func spwan() -> JobListViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! JobListViewController
    }
    
    var isEng = false
    
    @IBOutlet weak var leftLbl: UILabel!
    @IBOutlet weak var leftImgV: UIImageView!
    @IBOutlet weak var middleImgV: UIImageView!
    @IBOutlet weak var middleLbl: UILabel!
    @IBOutlet weak var rightImgV: UIImageView!
    @IBOutlet weak var rightLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomViewBottomDis: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isEng{
            self.bottomViewBottomDis.constant = -50
            self.bottomView.isHidden = true
        }else{
            self.bottomViewBottomDis.constant = 0
            self.bottomView.isHidden = false
        }
        
        self.tableView.register(UINib.init(nibName: "JobCell", bundle: Bundle.main), forCellReuseIdentifier: "JobCell")
    }
    
    @IBAction func bottomBtnAction(_ btn: UIButton) {
        if btn.tag == 11{
            
        }else if btn.tag == 22{
            let publishVC = PublishJobViewController.spwan()
            self.navigationController?.pushViewController(publishVC, animated: true)
        }else if btn.tag == 33{
            
        }
    }
    

}


extension JobListViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let jobDetailVC = JobDetailViewController.spwan()
        jobDetailVC.isEng = self.isEng
        self.navigationController?.pushViewController(jobDetailVC, animated: true)
    }
    
    
    
    
}
