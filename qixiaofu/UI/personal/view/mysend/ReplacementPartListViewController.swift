//
//  ReplacementPartListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/7.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReplacementPartListViewController: BaseTableViewController {

    var isUsedSns = false
    var isReplacementOrder = false//是否为补单
    var isPurchaseExchange = false//是否为退换货
    var isServiceBill = false//是否为服务单
    
    
    var orerId = ""
    var finishSuccessBlock : (() -> Void)?
    var finishChooseSnsBlock : ((Array<String>) -> Void)?
    var finishChooseSnBlock : ((String, String) -> Void)?//
    
    
    
    fileprivate var curpage = 1
    var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var selectedArray : Array<String> = Array<String>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        self.tableView.backgroundColor = BG_Color
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "ReplacementPartCell", bundle: Bundle.main), forCellReuseIdentifier: "ReplacementPartCell")

        
        
        if self.isUsedSns{
            self.navigationItem.title = "所用备件"
        }else{
            self.loadData()
            //添加刷新
            self.addRefresh()

            self.navigationItem.title = "选择备件"
            //确认完成订单时使用备件
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", target: self, action: #selector(ReplacementPartListViewController.rightItemAction))
        }
        
        
    }

    //确认完成订单时使用备件
    @objc func rightItemAction() {
        if self.selectedArray.count == 0{
            LYProgressHUD.showError("请选择使用的备件")
            return
        }
        if self.isServiceBill{
            if self.finishChooseSnBlock != nil{
                //返回选中的sn
                let id = self.selectedArray[0]
                for subJson in self.dataArray{
                    if id == subJson["id"].stringValue{
                        self.finishChooseSnBlock!(id, subJson["goods_sn"].stringValue)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }else if self.isPurchaseExchange{
            if self.finishChooseSnsBlock != nil{
                //返回选中的sn
                var arr = Array<String>()
                for subJson in self.dataArray{
                    if self.selectedArray.contains(subJson["id"].stringValue){
                        arr.append(subJson["goods_sn"].stringValue)
                    }
                }
                self.finishChooseSnsBlock!(arr)
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            LYAlertView.show("提示", "确认使用选中的备件", "取消", "确认", {
                //完成订单
                var params : [String : Any] = [:]
                params["id"] = self.orerId
                params["goods_id"] = self.selectedArray.joined(separator: ",")
                
                var url = EngineerFinishOrderApi
                if self.isReplacementOrder{
                    url = CustomerFinishOrderApi
                }
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("操作成功！")
                    if self.finishSuccessBlock != nil{
                        self.finishSuccessBlock!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            })
        }
        
        
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
    
    //加载数据
    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        
        var url = ReplacementPartListApi
        if self.isPurchaseExchange{
            params["order_id"] = self.orerId
            url = PurchaseExchangeSnsApi
        }
        
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in

            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            
            //拼接数据
            for subJson in result.arrayValue{
                if self.isPurchaseExchange{
                    //退换货时不显示第三方代卖的sn
                    if subJson["seller_type"].intValue == 2{
                        //第三方代卖
                    }else{
                        self.dataArray.append(subJson)
                    }
                }else{
                    self.dataArray.append(subJson)
                }
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
        
    }
    
}

extension ReplacementPartListViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplacementPartCell", for: indexPath) as! ReplacementPartCell
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.nameLbl.text = subJson["goods_name"].stringValue
            cell.snLbl.text = subJson["goods_sn"].stringValue
            if self.selectedArray.contains(subJson["id"].stringValue){
                cell.iconBtn.isSelected = true
            }else{
                cell.iconBtn.isSelected = false
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            if self.isServiceBill{
                if self.selectedArray.contains(subJson["id"].stringValue){
                    self.selectedArray.remove(at: self.selectedArray.index(of: subJson["id"].stringValue)!)
                }else{
                    if self.selectedArray.count > 0{
                        self.selectedArray.removeAll()
                    }
                    self.selectedArray.append(subJson["id"].stringValue)
                }
            }else{
                if self.selectedArray.contains(subJson["id"].stringValue){
                    self.selectedArray.remove(at: self.selectedArray.index(of: subJson["id"].stringValue)!)
                }else{
                    self.selectedArray.append(subJson["id"].stringValue)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}
