//
//  EPBillListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPBillListViewController: UITableViewController {

    var business_id = ""
    fileprivate var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "账单"
        self.tableView.register(UINib.init(nibName: "EnterpriseBillCell", bundle: Bundle.main), forCellReuseIdentifier: "EnterpriseBillCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        
        self.loadBillList()
        
    }

    //获取列表数据
    func loadBillList() {
        LYProgressHUD.showLoading()
        let params = ["business_id" : self.business_id]
        NetTools.requestData(type: .post, urlString: EnterpriseAccountBillApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.tableView.es.stopPullToRefresh()
            self.resultJson = resultJson
            self.tableView.reloadData()
        }) { (error) in
            self.tableView.es.stopPullToRefresh()
            LYProgressHUD.showError(error ?? "获取企业信息失败！")
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.resultJson.arrayValue.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnterpriseBillCell", for: indexPath) as! EnterpriseBillCell
        if self.resultJson.arrayValue.count > indexPath.row{
            cell.subJson = self.resultJson.arrayValue[indexPath.row]
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.resultJson.arrayValue.count > indexPath.row{
            let json = self.resultJson.arrayValue[indexPath.row]
            let epVC = EPBillDetailViewController.spwan()
            epVC.buyerId = json["user_id"].stringValue
            self.navigationController?.pushViewController(epVC, animated: true)
        }
        
    }
    /*
     {
     "non_checkout_total" : "0",
     "account_checkout_total" : "0",
     "user_id" : "24",
     "user_tel" : "18612334082",
     "business_id" : "26",
     "user_name" : "ly"
     },
     */


}
