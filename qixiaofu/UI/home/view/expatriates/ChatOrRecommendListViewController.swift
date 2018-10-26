//
//  ChatOrRecommendListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatOrRecommendListViewController: BaseViewController {
    class func spwan() -> ChatOrRecommendListViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! ChatOrRecommendListViewController
    }
    
    var isChatHistory = false
    var JobId = ""
    
    fileprivate var curpage = 1
    
    
    @IBOutlet weak var remindLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    fileprivate var recommendList : Array<JSON> = Array<JSON>()
    fileprivate var chatList : Array<JSON> = Array<JSON>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "RecommendEngCell", bundle: Bundle.main), forCellReuseIdentifier: "RecommendEngCell")
        self.tableView.register(UINib.init(nibName: "JobChatHistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "JobChatHistoryCell")
        
        if self.isChatHistory{
            self.navigationItem.title = "沟通历史"
        }else{
            self.navigationItem.title = "推荐工程师"
        }
        
        self.emptyView.frame = self.tableView.frame
        if self.isChatHistory{
            self.loadChatList()
        }else{
            self.loadRecommendList()
        }
        
        self.addRefresh()
        
    }
    
    
    //停止刷新
    func stopRefresh() {
        if self.curpage == 1{
            self.tableView.es.stopPullToRefresh()
        }else{
            self.tableView.es.stopLoadingMore()
        }
        if self.isChatHistory{
            if self.chatList.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
        }else{
            if self.recommendList.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
        }
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            if self.isChatHistory{
                self.loadChatList()
            }else{
                self.loadRecommendList()
            }
        }
        
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            if self.isChatHistory{
                self.loadChatList()
            }else{
                self.loadRecommendList()
            }
        }
    }
    
    
    
    @IBAction func buyChat() {
        let buyVC = BuyChatViewController.spwan()
        self.navigationController?.pushViewController(buyVC, animated: true)
    }

    //推荐工程师列表
    func loadRecommendList() {
        var params : [String : Any] = [:]
        params["id"] = self.JobId
        params["curpage"] = self.curpage
        NetTools.requestData(type: .post, urlString: JobRecommendEngListApi, parameters: params, succeed: { (resultJson, msg) in
            if self.curpage == 1{
                self.recommendList.removeAll()
            }
            
            for json in resultJson.arrayValue{
                self.recommendList.append(json)
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
    
    //沟通过的工程师列表
    func loadChatList() {
        var params : [String : Any] = [:]
        params["id"] = self.JobId
        params["curpage"] = self.curpage
        NetTools.requestData(type: .post, urlString: JobRecommendEngListApi, parameters: params, succeed: { (resultJson, msg) in
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

    
}


extension ChatOrRecommendListViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isChatHistory{
            return self.chatList.count
        }else{
            return self.recommendList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isChatHistory{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobChatHistoryCell", for: indexPath) as! JobChatHistoryCell
            cell.parentVC = self
            if self.chatList.count > indexPath.row{
                let json = self.chatList[indexPath.row]
                cell.subJson = json
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendEngCell", for: indexPath) as! RecommendEngCell
            cell.parentVC = self
            if self.recommendList.count > indexPath.row{
                let json = self.recommendList[indexPath.row]
                cell.subJson = json
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isChatHistory{
            return 120
        }else{
            return 70
        }
    }
    
    
    
    
}
