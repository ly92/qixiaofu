//
//  HomeMoreCourseController.swift
//  qixiaofu
//
//  Created by 李勇 on 2018/3/14.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeMoreCourseController: BaseTableViewController {
    //课程
    fileprivate var courseArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefresh()
        
        self.tableView.separatorStyle = .none
         self.tableView.register(UINib.init(nibName: "DiscoverCourseCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeMoreCourseCell")
        self.navigationItem.title = "沙龙"
        self.loadCourseData()
    }

    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadCourseData()
        }
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadCourseData()
        }
        
    }
    
    //加载课程列表数据
    func loadCourseData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        
        NetTools.requestData(type: .post, urlString: HomeMoreCourseApi, parameters: params, succeed: { (resultJson, msg) in
            
            let result = resultJson["salon_list"]
            //停止刷新
            if self.curpage == 1{
                self.tableView.es.stopPullToRefresh()
                self.courseArray.removeAll()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            //是否有更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            for subJson in result.arrayValue{
                self.courseArray.append(subJson)
            }
            
            if self.courseArray.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
            self.tableView.reloadData()
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.courseArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMoreCourseCell", for: indexPath) as! DiscoverCourseCell
            if self.courseArray.count > indexPath.row{
                let subJson = self.courseArray[indexPath.row]
                cell.courseJson = subJson
            }
            return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (kScreenW - 16) / 2.0 + 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.courseArray.count > indexPath.row{
            var json = self.courseArray[indexPath.row]
            if json["type"].stringValue.intValue == 1{
                let courseDetailVC = HomeCourseDetailViewController.spwan()
                courseDetailVC.courseId = json["id"].stringValue
                self.navigationController?.pushViewController(courseDetailVC, animated: true)
            }else{
                let courseDetailVC = CourseDetailViewController.spwan()
                courseDetailVC.courseId = json["id"].stringValue
                courseDetailVC.coursePaySuccessBlock = {(num) in
                    json["is_sign"] = JSON("1")
                    json["count"] = JSON(String.init(format: "%d", json["count"].stringValue.intValue + num))
                    self.courseArray.remove(at: indexPath.row)
                    self.courseArray.insert(json, at: indexPath.row)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                self.navigationController?.pushViewController(courseDetailVC, animated: true)
            }
            
        }
        
    }

}
