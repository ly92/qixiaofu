//
//  NoticeListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/1/9.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class NoticeListViewController: BaseTableViewController {

    fileprivate var noticeListArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "公告列表"
        self.loadNoticeList()
        self.addRefresh()
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        
        self.tableView.register(UINib.init(nibName: "NoticeCell", bundle: Bundle.main), forCellReuseIdentifier: "NoticeCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
            self?.loadNoticeList()
        }
        
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            self?.loadNoticeList()
        }
    }
    
    //加载公告列表
    func loadNoticeList() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        NetTools.requestData(type: .post, urlString: NoticeListApi, parameters: params, succeed: { (resultJson, msg) in
            if self.curpage == 1{
                self.noticeListArray.removeAll()
                self.tableView.es.stopPullToRefresh()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            for json in resultJson.arrayValue{
                self.noticeListArray.append(json)
            }
            if resultJson.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            if self.noticeListArray.count == 0{
                self.showEmptyView()
            }else{
                self.hideEmptyView()
            }
            
            self.tableView.reloadData()
        }) { (error) in
            self.stopRefresh()
            LYProgressHUD.showError(error!)
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.noticeListArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as! NoticeCell
        if self.noticeListArray.count > indexPath.row{
            let json = self.noticeListArray[indexPath.row]
            cell.titleLbl.text = json["notice_title"].stringValue
            cell.timeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: json["input_time"].stringValue)
            if json["notice_img"].stringValue.isEmpty{
                cell.imageV.isHidden = true
            }else{
                cell.imageV.isHidden = false
                cell.imageV.setImageUrlStr(json["notice_img"].stringValue)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.noticeListArray.count > indexPath.row{
            let json = self.noticeListArray[indexPath.row]
            let noticeDetailVC = NoticeDetailViewController.spwan()
            noticeDetailVC.noticeId = json["notice_id"].stringValue
            noticeDetailVC.noticeTitle = json["notice_title"].stringValue
            self.navigationController?.pushViewController(noticeDetailVC, animated: true)
        }
    }
    
//    //MARK:组头
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 40))
//        let imgV = UIImageView
//
//
//        return view
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return 40
//    }
    
    
}
