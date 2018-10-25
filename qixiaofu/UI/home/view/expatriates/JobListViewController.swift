//
//  JobListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    @IBOutlet weak var emptyView2: UIView!
    
    fileprivate var filterType = 1
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    
    var curpage = 1
    var jobType = "0"
    var jobSort = "1"//排序方式，1，发布时间排序，2，活跃时间排序
    var province_id = "0"
    var city_id = "0"
    var county_id = "0"
    
    fileprivate var typeArray = JSON()
    fileprivate var sortArray = ["发布时间","活跃时间"]
    
    
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
        
        
        self.loadTypeData()
        self.loadData()
        
        self.addRefresh()
        
        self.emptyView.frame = self.tableView.frame
        
    }
    
    @objc func rightItemAction(){
        let engChatVC = EngChatHistoryViewController()
        self.navigationController?.pushViewController(engChatVC, animated: true)
    }
    
    //分类数据
    func loadTypeData() {
        NetTools.requestData(type: .get, urlString: JobTypeListApi, succeed: { (resultJson, msg) in
            self.typeArray = resultJson
        }) { (error) in
        }
    }
    
    
    func loadData() {
        var params : [String : Any] = [:]
        params["type"] = self.jobType
        params["sort"] = self.jobSort
        params["province_id"] = self.province_id
        params["city_id"] = self.city_id
        params["county_id"] = self.county_id
        params["curpage"] = self.curpage
        
        NetTools.requestData(type: .get, urlString: JobListApi, parameters: params, succeed: { (resultJson, msg) in
            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            
            for json in resultJson.arrayValue{
                self.dataArray.append(json)
            }
            
            self.tableView.reloadData()
            
            self.stopRefresh()
        }) { (error) in
            
        }
    }
    
    //停止刷新
    func stopRefresh() {
        if self.curpage == 1{
            self.tableView.es.stopPullToRefresh()
        }else{
            self.tableView.es.stopLoadingMore()
        }
        if self.dataArray.count > 0{
            self.emptyView2.isHidden = true
        }else{
            self.emptyView2.isHidden = false
        }
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
            self?.loadData()
        }
        
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            self?.loadData()
        }
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
//            arrow(3)
            //工作地址
            let chooseVc = ChooseAreaViewController()
            chooseVc.chooseAeraBlock = {(provinceId,cityId,areaId,addressArray) in
                self.province_id = provinceId
                self.city_id = cityId
                self.county_id = areaId
                
                self.curpage = 1
                self.loadData()
            }
            self.navigationController?.pushViewController(chooseVc, animated: true)
        }
        
    }
    

}


extension JobListViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return self.dataArray.count
        }else{
            if self.filterType == 1{
                return self.typeArray.count
            }else if self.filterType == 2{
                return self.sortArray.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
            if dataArray.count > indexPath.row{
                let json = self.dataArray[indexPath.row]
                cell.subJson = json
            }
            return cell
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "jobListFilterCell")
            if cell == nil{
                cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "jobListFilterCell")
            }
            
            if self.filterType == 1{
                if self.typeArray.count > indexPath.row{
                    let json = self.typeArray[indexPath.row]
                    cell?.textLabel?.text = json["type_name"].stringValue
                }
                
            }else if self.filterType == 2{
                if self.sortArray.count > indexPath.row{
                    cell?.textLabel?.text = self.sortArray[indexPath.row]
                }
            }
            
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
                if self.typeArray.count > indexPath.row{
                    let json = self.typeArray[indexPath.row]
                    self.leftLbl.text = json["type_name"].stringValue
                    self.jobType = json["id"].stringValue
                }
                
            }else if self.filterType == 2{
                if self.sortArray.count > indexPath.row{
                    self.middleLbl.text = self.sortArray[indexPath.row]
                    self.jobSort = "\(indexPath.row + 1)"
                }
            }
            
            self.curpage = 1
            self.loadData()

            self.hideFilterView()
        }
    }
    
    
    
    
}
