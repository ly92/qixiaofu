//
//  FreeTimeListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/9.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class FreeTimeListViewController: BaseTableViewController {

    
    
    fileprivate var curpage = 1
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "空闲时间"
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.register(UINib.init(nibName: "FreeTimeCell", bundle: Bundle.main), forCellReuseIdentifier: "FreeTimeCell")
        
        //加载数据
        self.loadData()
        
        //
        self.addRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //停止刷新
    override func stopRefresh() {
        super.stopRefresh()
        if self.dataArray.count > 0{
            self.hideEmptyView()
        }else{
            self.showEmptyView()
        }
    }

    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        
        if self.curpage == 1{
            self.dataArray.removeAll()
        }
        
//        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: FreeTimeListApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            
            
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            //如果是默认数据则不给予显示
            if self.dataArray.count == 1{
                if self.dataArray[0]["tack_arrays"].arrayValue.count == 0{
                    self.dataArray.removeAll()
                }
            }
            self.stopRefresh()
            //是否有更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            if self.dataArray.count == 0{
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "新增", target: self, action: #selector(FreeTimeListViewController.rightItemAction))
            }else{
                self.navigationItem.rightBarButtonItem = nil
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            self.stopRefresh()
            LYProgressHUD.showError(error!)
        }
        
    }
    
    
    @objc func rightItemAction() {
        let setSpaceTimeVC = SetSpaceTimeViewController.spwan()
        setSpaceTimeVC.setSpaceTimeBlock = {[weak self] () in
            self?.curpage = 1
            self?.loadData()
        }
        self.navigationController?.pushViewController(setSpaceTimeVC, animated: true)
    }
    
}

extension FreeTimeListViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FreeTimeCell", for: indexPath) as! FreeTimeCell
        if self.dataArray.count > indexPath.row{
            cell.subJson = self.dataArray[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataArray.count > indexPath.row{
            let setSpaceTimeVC = SetSpaceTimeViewController.spwan()
            setSpaceTimeVC.subJson = self.dataArray[indexPath.row]
                setSpaceTimeVC.setSpaceTimeBlock = {[weak self] () in
                    self?.curpage = 1
                    self?.loadData()
            }
            self.navigationController?.pushViewController(setSpaceTimeVC, animated: true)
        }
        
    }
    
}
