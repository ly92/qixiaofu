//
//  PluginHistoryViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/10/11.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PluginHistoryViewController: BaseTableViewController {
    
    fileprivate var curpage : NSInteger = 1
    fileprivate var dataArray = Array<JSON>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "软件订单"
        
        self.tableView.register(UINib.init(nibName: "PluginHistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "PluginHistoryCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        
        
        self.addRefresh()
        self.loadData()
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
    
    //
    func loadData() {
        NetTools.requestData(type: .post, urlString: PluginBuyHistoryApi, succeed: { (result, msg) in
            //停止刷新
            if self.curpage == 1{
                self.dataArray.removeAll()
                self.tableView.es.stopPullToRefresh()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            //判断是否可以加载更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //是否为空
            if self.dataArray.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
            
            //重加载tabble
            self.tableView.reloadData()
            
        }) { (error) in
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
        return self.dataArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PluginHistoryCell", for: indexPath) as! PluginHistoryCell
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.subJson = subJson
            
            cell.goPayBlock = {[weak self] () in
                var params : [String : Any] = [:]
                params["paycode"] = subJson["paycode"].stringValue
                NetTools.requestData(type: .post, urlString: PluginPayDataApi, parameters: params, succeed: { (result, msg) in
                    //去支付
                    let payVC = PaySendTaskViewController.spwan()
                    payVC.isJustPay = true
                    payVC.totalMoney = result["price"].stringValue.doubleValue
                    payVC.isFromPlugin = true
                    payVC.pluginOrderId = result["id"].stringValue
                    payVC.rePayOrderSuccessBlock = {() in
                        //支付成功
                        LYAlertView.show("提示", "支付成功！客服确认后将会通过邮件与您联系，请注意查收", "知道了")
                    }
                    self?.navigationController?.pushViewController(payVC, animated: true)
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 127
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let plugInDetailVC = PlugInDetailViewController.spwan()
        plugInDetailVC.plugId = self.dataArray[indexPath.row]["plugid"].stringValue
        self.navigationController?.pushViewController(plugInDetailVC, animated: true)
    }

}
