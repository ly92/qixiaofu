//
//  CommentListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentListViewController: BaseTableViewController {
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    
//    lazy var orderDataArray : NSMutableArray = {
//        let orderDataArray = NSMutableArray()
//        return orderDataArray
//    }()
    


    
    fileprivate var curpage : NSInteger = 1
    var member_id : String?
    var isFromPersonalInfo = false//从个人信息来的可进行回复操作
    var orderId = ""//我的接单，接单详情，我的发单，发单详情中的订单号
    var isCustomerList = false//是否为对某客户的评价列表
//    var isEngineerList = false//是否为对工程师的评价列表
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if self.orderId.isEmpty{
            self.navigationItem.title = "评价列表"
            //添加刷新
            self.addRefresh()
            LYProgressHUD.showLoading()
            self.loadCommentData()
        }else{
            self.navigationItem.title = "评价记录"
            //根据某单加载评价
            self.loadOrderCommentList()
        }
        
        self.tableView.register(UINib.init(nibName: "EngineerCommentCell", bundle: Bundle.main), forCellReuseIdentifier: "EngineerCommentCell")
        self.tableView.register(UINib.init(nibName: "EngineerReplyCell", bundle: Bundle.main), forCellReuseIdentifier: "EngineerReplyCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.estimatedRowHeight = 110
        
        
       
        
        // Do any additional setup after loading the view.
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

extension CommentListViewController{
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
            self?.loadCommentData()
        }
        
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            self?.loadCommentData()
        }
    }
    

    
    
    
    //我的接单，接单详情，我的发单，发单详情中查看评价
    func loadOrderCommentList() {
        var params : [String : Any] = [:]
        params["id"] = self.orderId
        NetTools.requestData(type: .post, urlString: HomeOrderCommentListApi, parameters: params, succeed: { (result, msg) in
            
            let model1 : JSON = ["member_avatar" : result["list"]["bill_user_avatar"].stringValue,
                                 "member_truename" : result["list"]["bill_nik_name"].stringValue,
                                 "time" : result["list"]["inputtime"].stringValue,
                                 "stars" : result["list"]["stars"].stringValue,
                                 "content" : result["list"]["content"].stringValue
            ]
            let model2 : JSON = ["member_avatar" : result["list"]["ot_user_avatar"].stringValue,
                                 "member_truename" : result["list"]["ot_nik_name"].stringValue,
                                 "time" : result["list"]["eng_inputtime"].stringValue,
                                 "stars" : result["list"]["star_to_user"].stringValue,
                                 "content" : result["list"]["content_to_user"].stringValue
            ]
            
            if !model1["time"].stringValue.isEmpty{
                self.dataArray.append(model1)
            }
            
            if !model2["time"].stringValue.isEmpty{
                self.dataArray.append(model2)
            }
            if self.dataArray.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
            self.tableView.reloadData()
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //评价列表
    func loadCommentData() {
        var params : [String : Any] = [:]
        params["curpage"] = (self.curpage)
        params["member_id"] = self.member_id!
        
        var url = ""
        if isCustomerList{
            url = HomeCustomerCommentListApi
        }else{
            url = HomeEngineerCommentListApi
        }
        
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultDict, error) in
            
            
            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            for subJson in resultDict.arrayValue{
                self.dataArray.append(subJson)
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

extension CommentListViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if self.dataArray.count > section{
        //            let subJson = self.dataArray[section] as! JSON
        //            if subJson["reply_list"].arrayValue.count > 0{
        //                return 2
        //            }
        //        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
            if self.dataArray.count > indexPath.section{
                cell.setUpDataReplyHeight(json: self.dataArray[indexPath.section])
            }
            cell.selectionStyle = self.isFromPersonalInfo ? .default : .none//cell是否可点击
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerReplyCell", for: indexPath) as! EngineerReplyCell
            if self.dataArray.count > indexPath.section{
                cell.jsonModel = self.dataArray[indexPath.section]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        //        if indexPath.row == 0{
        //            let cell = self.tableView(tableView, cellForRowAt: indexPath) as! EngineerCommentCell
        //            if self.dataArray.count > indexPath.section{
        //                return cell.setUpDataReplyHeight(json: self.dataArray[indexPath.section] as! JSON)
        //            }
        //        }else{
        //            if self.dataArray.count > indexPath.section{
        //                return 0
        //            }
        //        }
        
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if self.isFromPersonalInfo && indexPath.row == 0{
            //可进行回复操作
            if self.dataArray.count > indexPath.section{
                let replayVC = AddCommentViewController.spwan()
                replayVC.parentId = self.dataArray[indexPath.section]["eval_id"].stringValue
                replayVC.isShowStartView = false
                replayVC.addCommentSuccessBlock = {[weak self] () in
                    self?.loadCommentData()
                }
                self.navigationController?.pushViewController(replayVC, animated: true)
            }
        }
        
    }
    
}
