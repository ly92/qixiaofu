//
//  InventoryListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/10.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class InventoryListViewController: BaseTableViewController {

    
    fileprivate var curPage = 1
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate let searchBar : UISearchBar = UISearchBar()
    
    fileprivate var searchKey = ""
    fileprivate var searchType = 1
    fileprivate var isSearching = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "小库存"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_search"), target: self, action: #selector(InventoryListViewController.rightItemAction))
        
        self.tableView.backgroundColor = BG_Color
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "InventoryCell", bundle: Bundle.main), forCellReuseIdentifier: "InventoryCell")
        
        self.loadData()
        self.addRefresh()
    }
    
    //搜索
    @objc func rightItemAction() {
        self.setUpSearchNavView()
    }
    
    //加载数据
    func loadData() {
        self.searchAction()
        /*
        var params : [String : Any] = [:]
        params["curpage"] = self.curPage
        
        NetTools.requestData(type: .post, urlString: ReplacementPartListApi, parameters: params, succeed: { (result, msg) in
            //清除数据
            if self.curPage == 1{
                self.dataArray.removeAll()
            }
            
            //拼接数据
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            self.stopRefresh()
            
            //是否有更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            self.stopRefresh()
            LYProgressHUD.showError(error!)
        }
 */
    }
    
    //刷新
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curPage = 1
            if (self?.isSearching)!{
                self?.searchAction()
            }else{
                self?.loadData()
            }
        }
        
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curPage += 1
            if (self?.isSearching)!{
                self?.searchAction()
            }else{
                self?.loadData()
            }
        }
    }
    
    
    //停止刷新
    override func stopRefresh() {
        super.stopRefresh()
        if self.dataArray.count == 0{
            self.showEmptyView()
        }else{
            self.hideEmptyView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension InventoryListViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as! InventoryCell
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.subJson = subJson
        }
        cell.parentVC = self
        cell.refreshBlock = {[weak self] () in
            self?.curPage = 1
            self?.loadData()
        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.dataArray.count > indexPath.row{
//            let subJson = self.dataArray[indexPath.row]
//            
//            self.tableView.reloadData()
//        }
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.searchBar.isFirstResponder{
            self.searchBar.resignFirstResponder()
        }
    }
}

extension InventoryListViewController : UISearchBarDelegate{
    
    //
    func searchAction() {
        if self.searchBar.isFirstResponder{
            self.searchBar.resignFirstResponder()
        }
        
        var params : [String : Any] = [:]
        params["curpage"] = self.curPage
        params["search_type"] = self.searchType
        params["search_key"] = self.searchKey
//        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: SearchInventoryApi, parameters: params, succeed: { (result, msg) in
            //清除数据
            if self.curPage == 1{
                self.dataArray.removeAll()
            }
            
            //拼接数据
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            self.stopRefresh()
            
            //是否有更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            self.tableView.reloadData()
            LYProgressHUD.dismiss()
        }) { (error) in
            self.stopRefresh()
            LYProgressHUD.showError(error!)
        }
        
    }
    
    
    //设置搜索框
    func setUpSearchNavView() {
        
        self.curPage = 1
        
        searchBar.placeholder = "请输入备件的SN码"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchBar
        
        
        let cancelItem = UIBarButtonItem(title: "取消", target: self, action: #selector(InventoryListViewController.cancelAction))
//        let filtrateItem = UIBarButtonItem(title: "筛选", target: self, action: #selector(InventoryListViewController.filtrateAction))
//        self.navigationItem.rightBarButtonItems = [cancelItem,filtrateItem]
        self.navigationItem.rightBarButtonItem = cancelItem
    }

    //筛选
    func filtrateAction() {
        LYPickerView.show(titles: ["全部","按照SN码","按照订单号","按照配件名称"], selectBlock: {(title,index) in
            self.searchType = index
            if index == 1{
                self.searchBar.placeholder = "请输入备件的SN码"
            }else if index == 2{
                self.searchBar.placeholder = "请输入备件的订单号"
            }else if index == 3{
                self.searchBar.placeholder = "请输入备件的名称"
            }
            
            self.curPage = 1
            self.searchAction()
        })
    }
    //取消搜索
    @objc func cancelAction() {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_search"), target: self, action: #selector(InventoryListViewController.rightItemAction))
        self.navigationItem.title = "小库存"
        if self.searchBar.isFirstResponder{
            self.searchBar.resignFirstResponder()
        }
        searchBar.text = ""
        self.searchKey = ""
        self.curPage = 1
        self.searchAction()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text?.isEmpty)!{
            self.searchKey = searchBar.text!
            self.curPage = 1
            self.searchAction()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    

    
}


