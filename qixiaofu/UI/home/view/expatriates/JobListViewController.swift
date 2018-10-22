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

        self.navigationItem.title = "招聘大厅"
        
        if self.isEng{
            self.bottomViewBottomDis.constant = -50
            self.bottomView.isHidden = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "沟通历史", target: self, action: #selector(JobListViewController.rightItemAction))
        }else{
            self.bottomViewBottomDis.constant = 0
            self.bottomView.isHidden = false
        }
        
        self.tableView.register(UINib.init(nibName: "JobCell", bundle: Bundle.main), forCellReuseIdentifier: "JobCell")
    }
    
    @objc func rightItemAction(){
        let engChatVC = EngChatHistoryViewController()
        self.navigationController?.pushViewController(engChatVC, animated: true)
    }
    
    @IBAction func bottomBtnAction(_ btn: UIButton) {
        if btn.tag == 11{
            let myJobs = MyJobListViewController()
            self.navigationController?.pushViewController(myJobs, animated: true)
        }else if btn.tag == 22{
            let publishVC = PublishJobViewController.spwan()
            self.navigationController?.pushViewController(publishVC, animated: true)
        }else if btn.tag == 33{
            let historyVC = ChatOrRecommendListViewController.spwan()
            historyVC.isChatHistory = true
            self.navigationController?.pushViewController(historyVC, animated: true)
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
        if self.isEng{
            jobDetailVC.idType = 1
        }else{
            //jobDetailVC.idType = 2
            jobDetailVC.idType = 3
        }
        self.navigationController?.pushViewController(jobDetailVC, animated: true)
    }
    
    
    
    
}
