//
//  TestServiceOrderListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/5.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
class TestServiceOrderListViewController: BaseViewController {
    class func spwan() -> TestServiceOrderListViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! TestServiceOrderListViewController
    }

    @IBOutlet weak var tableView: UITableView!
    //订单状态  0：待审核  1：待支付 2：订单取消 3：测试中 4:测试完成 5:审核失败 6：商家待收货 7:待发货 8:客户待收货 9:订单完成
    fileprivate var btnView = UIView()
    fileprivate var line = UIView()
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationItem.title = "代测订单"
        
        self.tableView.register(UINib.init(nibName: "TestServiceOrderCell", bundle: Bundle.main), forCellReuseIdentifier: "TestServiceOrderCell")
        self.tableView.register(UINib.init(nibName: "TestServiceBtnCell", bundle: Bundle.main), forCellReuseIdentifier: "TestServiceBtnCell")
        
        self.loadData()
        self.addRefresh()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
        //刷新列表和详情的通知
        NotificationCenter.default.addObserver(self, selector: #selector(TestServiceOrderListViewController.refreshTable), name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
    }
    
    @objc func refreshTable() {
        self.curpage = 1
        self.loadData()
    }
    
    //刷新列表和详情的通知
    @objc func refreshData() {
        self.curpage = 1
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //加载数据
    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["order_state"] = ""//订单状态  0：待审核  1：待支付 2：已取消 3：测试中 4:测试完成 5:审核失败 6：待收货
        NetTools.requestData(type: .post, urlString: TestOrderListApi, parameters: params, succeed: { (result, msg) in

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


extension TestServiceOrderListViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TestServiceOrderCell", for: indexPath) as! TestServiceOrderCell
            if self.dataArray.count > indexPath.section{
                let subJson = self.dataArray[indexPath.section]
                cell.subJson = subJson
            }
            cell.parentVC = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TestServiceBtnCell", for: indexPath) as! TestServiceBtnCell
            if self.dataArray.count > indexPath.section{
                let subJson = self.dataArray[indexPath.section]
                cell.subJson = subJson
            }
            cell.refreshDeleteListBlock = {() in
                if self.dataArray.count > indexPath.section{
                    self.dataArray.remove(at: indexPath.section)
                    self.tableView.reloadData()
                }
            }
            cell.refreshListBlock = {() in
                self.curpage = 1
                self.loadData()
            }
            cell.parentVC = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 120
        }else{
            return 44
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataArray.count > indexPath.section{
            let orderDetailVC = TestOrderDetailViewController.spwan()
            orderDetailVC.state = self.dataArray[indexPath.section]["order_state"].stringValue
            orderDetailVC.orderId = self.dataArray[indexPath.section]["id"].stringValue
//            orderDetailVC.refreshTableBlock = {() in
//                self.curpage = 1
//                self.loadData()
//            }
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        }
    }
    
    
}

