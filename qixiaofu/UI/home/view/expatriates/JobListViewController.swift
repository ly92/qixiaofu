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
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var topView1: UIView!
    @IBOutlet weak var topView2: UIView!
    @IBOutlet weak var topView3: UIView!
    
    fileprivate var filterType = 1
    
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
        
        self.topViewAction(0)
        
    }
    
    @objc func rightItemAction(){
        let engChatVC = EngChatHistoryViewController()
        self.navigationController?.pushViewController(engChatVC, animated: true)
    }
    
    @IBAction func hideFilterView() {
        self.topViewAction(4)
        self.filterView.isHidden = true
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
    
    
    //MARK:顶部筛选点击事件
    func topViewAction(_ type : Int) {
        func arrow(_ index : Int){
            self.filterType = index
            self.filterView.isHidden = false
            self.leftImgV.image = #imageLiteral(resourceName: "down_arrow1")
            self.leftLbl.textColor = UIColor.RGBS(s: 33)
            self.middleImgV.image = #imageLiteral(resourceName: "down_arrow1")
            self.middleLbl.textColor = UIColor.RGBS(s: 33)
            self.rightImgV.image = #imageLiteral(resourceName: "down_arrow1")
            self.rightLbl.textColor = UIColor.RGBS(s: 33)
            
            if index == 1{
                self.leftImgV.image = #imageLiteral(resourceName: "up_arrow1")
                self.leftLbl.textColor = UIColor.RGB(r: 225, g: 171, b: 38)
            }else if index == 2{
                self.middleImgV.image = #imageLiteral(resourceName: "up_arrow1")
                self.middleLbl.textColor = UIColor.RGB(r: 225, g: 171, b: 38)
            }else if index == 3{
                self.rightImgV.image = #imageLiteral(resourceName: "up_arrow1")
                self.rightLbl.textColor = UIColor.RGB(r: 225, g: 171, b: 38)
            }
            self.filterTableView.reloadData()
        }
        
        if type == 4{
            arrow(type)
            return
        }
        
        self.topView1.addTapActionBlock {
            arrow(1)
        }
        
        self.topView2.addTapActionBlock {
            arrow(2)
        }
        
        self.topView3.addTapActionBlock {
            arrow(3)
        }
        
    }
    

}


extension JobListViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return 2
        }else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)
            
            return cell
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "jobListFilterCell")
            if cell == nil{
                cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "jobListFilterCell")
            }
            cell?.textLabel?.text = "123456"
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.textColor = Text_Color
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView{
            return 104
        }else{
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView{
            let jobDetailVC = JobDetailViewController.spwan()
            if self.isEng{
                jobDetailVC.idType = 1
            }else{
                //jobDetailVC.idType = 2
                jobDetailVC.idType = 3
            }
            self.navigationController?.pushViewController(jobDetailVC, animated: true)
        }else{
            if self.filterType == 1{
                self.leftLbl.text = "123"
            }else if self.filterType == 2{
                self.middleLbl.text = "456"
            }else if self.filterType == 3{
                self.rightLbl.text = "789"
            }
            self.hideFilterView()
        }
    }
    
    
    
    
}
