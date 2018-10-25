//
//  MyJobListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyJobListViewController: BaseTableViewController {

        fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的招聘"
        
        self.tableView.register(UINib.init(nibName: "JobCell", bundle: Bundle.main), forCellReuseIdentifier: "JobCell")
        self.tableView.separatorStyle = .none
        
        self.loadData()
        
        self.addRefresh()
    }
    
    
    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        
        NetTools.requestData(type: .get, urlString: JobListApi, parameters: params, succeed: { (resultJson, msg) in
            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            
            for json in resultJson.arrayValue{
                self.dataArray.append(json)
            }
            
            if resultJson.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            self.tableView.reloadData()
            
            self.stopRefresh()
        }) { (error) in
            self.stopRefresh()
            LYProgressHUD.showError(error ?? "网络请求错误！")
        }
    }
    
    //停止刷新
    override func stopRefresh() {
        if self.curpage == 1{
            self.tableView.es.stopPullToRefresh()
        }else{
            self.tableView.es.stopLoadingMore()
        }
        if self.dataArray.count > 0{
            self.hideEmptyView()
        }else{
            self.showEmptyView()
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
    
    
    
    

    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        if dataArray.count > indexPath.row{
            let json = self.dataArray[indexPath.row]
            cell.subJson = json
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let jobDetailVC = JobDetailViewController.spwan()
        jobDetailVC.idType = 2
        self.navigationController?.pushViewController(jobDetailVC, animated: true)
    }


}
