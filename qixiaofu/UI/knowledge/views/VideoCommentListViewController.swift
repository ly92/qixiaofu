//
//  VideoCommentListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/1/31.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class VideoCommentListViewController: BaseTableViewController {

    var videoId = ""
    var curpage = 1
    var commentArray : Array<JSON> = Array<JSON>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "评价列表"
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.register(UINib.init(nibName: "CommentVideoCell", bundle: Bundle.main), forCellReuseIdentifier: "CommentVideoCell")
        
        self.addRefresh()
        self.loadCommentList()
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadCommentList()
        }
        
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadCommentList()
        }
    }
    
    func loadCommentList() {
        var params : [String : Any] = [:]
        params["video_id"] = self.videoId
        params["curpage"] = self.curpage
        NetTools.requestData(type: .post, urlString: KVideoCommentListApi, parameters: params, succeed: { (resultJson, msg) in
            //停止刷新
            if self.curpage == 1{
                self.tableView.es.stopPullToRefresh()
                self.commentArray.removeAll()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            //是否有更多
            if resultJson.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            for json in resultJson.arrayValue{
                self.commentArray.append(json)
            }
            
            if self.commentArray.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络连接失败！，请重试")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentVideoCell", for: indexPath) as! CommentVideoCell
        if self.commentArray.count > indexPath.row{
            let json = self.commentArray[indexPath.row]
            cell.subJson = json
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.commentArray.count > indexPath.row{
            let json = self.commentArray[indexPath.row]
            let content = json["comment_contents"].stringValue
            let size = content.sizeFit(width: kScreenW-16, height: CGFloat(MAXFLOAT), fontSize: 14)
            if size.height > 21{
                return size.height + 70
            }else{
                return 90
            }
        }
        return 0
    }
}
