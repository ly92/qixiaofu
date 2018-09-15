//
//  AgencySealViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/1.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class AgencySealViewController: BaseViewController {
    class func spwan() -> AgencySealViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! AgencySealViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    //订单状态  stuff_state   代卖状态 (1已代卖完成   2代卖取消  3代卖中 0不代卖 4代卖删除 5 代卖待审核 6代卖审核不通过) 8:代卖已退货  传空值为全部
//    fileprivate var titleArray = ["待审核","审核失败","代卖中","完成","已取消"]
//    fileprivate var stateArray = ["5","6","3","1","2"]
    fileprivate var btnView = UIView()
    fileprivate var line = UIView()
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "代卖订单"
        
        self.tableView.register(UINib.init(nibName: "TestServiceOrderCell", bundle: Bundle.main), forCellReuseIdentifier: "TestServiceOrderCell")
        self.tableView.register(UINib.init(nibName: "TestServiceBtnCell", bundle: Bundle.main), forCellReuseIdentifier: "TestServiceBtnCell")
        
        self.loadData()
        self.addRefresh()
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //加载数据
    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["stuff_state"] = ""
        NetTools.requestData(type: .post, urlString: AgencySealListApi, parameters: params, succeed: { (result, msg) in
            //停止刷新
            self.curpage == 1 ? self.tableView.es.stopPullToRefresh() : self.tableView.es.stopLoadingMore()
            //判断是否可以加载更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //添加数据
            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            //是否为空
            if self.dataArray.count == 0{
                self.emptyView.frame = self.tableView.frame
                self.showEmptyView()
            }else{
                self.hideEmptyView()
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            self.curpage == 1 ? self.tableView.es.stopPullToRefresh() : self.tableView.es.stopLoadingMore()
            LYProgressHUD.showError(error!)
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
    
}


extension AgencySealViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestServiceOrderCell", for: indexPath) as! TestServiceOrderCell
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.sealJson = subJson
        }
        cell.parentVC = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataArray.count > indexPath.row{
            let orderDetailVC = AgencySealDetailViewController.spwan()
            orderDetailVC.orderId = self.dataArray[indexPath.row]["id"].stringValue
            orderDetailVC.refreshBlock = {() in
                self.curpage = 1
                self.loadData()
            }
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        }
    }
    
    
}

