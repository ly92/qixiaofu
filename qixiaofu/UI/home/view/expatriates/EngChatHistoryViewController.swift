//
//  EngChatHistoryViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngChatHistoryViewController: BaseTableViewController {

    fileprivate var curpage = 1
    fileprivate var chatList : Array<JSON> = Array<JSON>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "沟通历史"
        self.tableView.register(UINib.init(nibName: "EngJobChatHistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "EngJobChatHistoryCell")
        self.tableView.separatorStyle = .none
        
        self.loadChatList()
        
        self.addRefresh()
    }

    
    //停止刷新
    override func stopRefresh() {
        if self.curpage == 1{
            self.tableView.es.stopPullToRefresh()
        }else{
            self.tableView.es.stopLoadingMore()
        }
        if self.chatList.count > 0{
            self.hideEmptyView()
        }else{
            self.showEmptyView()
        }
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadChatList()
        }
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadChatList()
        }
    }
    
    //沟通过的工程师列表
    func loadChatList() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["identity"] = "1"
        NetTools.requestData(type: .post, urlString: JobChatHistoryApi, parameters: params, succeed: { (resultJson, msg) in
            if self.curpage == 1{
                self.chatList.removeAll()
            }
            
            for json in resultJson.arrayValue{
                self.chatList.append(json)
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
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EngJobChatHistoryCell", for: indexPath) as! EngJobChatHistoryCell
        cell.parentVC = self
        if self.chatList.count > indexPath.row{
            let json = self.chatList[indexPath.row]
            cell.subJson = json
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }


}
