//
//  EngineerListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/26.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngineerListViewController: BaseTableViewController {
    
var isHomeMore : Bool = false
    var gc_id : String?
    var gc_name : String?
    fileprivate var curpage : NSInteger = 1
    
    fileprivate lazy var dataArray : NSMutableArray = {
        let dataArray = NSMutableArray()
        return dataArray
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "HomeEngineerCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeEngineerCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        
        //添加刷新
        self.addRefresh()
        
        
        if self.isHomeMore{
            self.navigationItem.title = "小七推荐"
            self.loadRecommandEngineer()
        }else{
            //初次加载
            self.loadEngineerData()
            self.navigationItem.title = self.gc_name
        }
        LYProgressHUD.showLoading()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //停止刷新
    override func stopRefresh() {
        super.stopRefresh()
        
        if self.dataArray.count > 0{
            self.hideEmptyView()
        }else{
            self.showEmptyView()
        }
    }

}

extension EngineerListViewController{
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
            if (self?.isHomeMore)!{
                self?.loadRecommandEngineer()
            }else{
                self?.loadEngineerData()
            }
        }
        
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            if (self?.isHomeMore)!{
                self?.loadRecommandEngineer()
            }else{
                self?.loadEngineerData()
            }
        }
    }
    
    
    //
    func loadEngineerData() {
        var params : [String : Any] = [:]
        params["curpage"] = (self.curpage)
         params["gc_id"] = self.gc_id!
        NetTools.requestData(type: .post, urlString: HomeEngineerListApi, parameters: params, succeed: { (resultDict, error) in
            
            if self.curpage == 1{
                self.dataArray.removeAllObjects()
            }
            
            for subJson in resultDict.arrayValue{
                self.dataArray.add(subJson)
            }
            
            //停止刷新
            self.stopRefresh()
            
            //判断是否可以加载更多
            if resultDict.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //重加载tabble
            self.tableView.reloadData()
            
        }) { (error) in
            //停止刷新
            self.stopRefresh()
        }

    }
    
    func loadRecommandEngineer() {
        var params : [String : Any] = [:]
        params["curpage"] = (self.curpage)
        NetTools.requestData(type: .post, urlString: HomeRecommandEngineerListApi, parameters: params, succeed: { (resultDict, error) in
            
            if self.curpage == 1{
                self.dataArray.removeAllObjects()
            }
            
            for subJson in resultDict.arrayValue{
                self.dataArray.add(subJson)
            }
            
            //停止刷新
            self.stopRefresh()
            
            //判断是否可以加载更多
            if resultDict.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //重加载tabble
            self.tableView.reloadData()
            
        }) { (error) in
            //停止刷新
            self.stopRefresh()
        }

    }
}

//MARK: -  UITableViewDelegate,UITableViewDataSource
extension EngineerListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeEngineerCell", for: indexPath) as! HomeEngineerCell
        if self.dataArray.count > indexPath.row{
            cell.jsonModel = self.dataArray[indexPath.row] as! JSON
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 167
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.dataArray.count > indexPath.row{
            let jsonModel = self.dataArray[indexPath.row] as! JSON
            let engineerDetailVC = EngineerDetailViewController()
            engineerDetailVC.member_id = jsonModel["member_id"].stringValue
            self.navigationController?.pushViewController(engineerDetailVC, animated: true)
        }
    }
    
}


