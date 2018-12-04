//
//  SystemMessageViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/16.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SystemMessageViewController: BaseViewController {
    enum SystemMessageType : Int {
        case walletMessageType = 2//资金消息
        case systemMessageType = 1//系统消息
        case taskMessageType = 3//接发单消息
        case epSystemMessageType = 4//企业采购系统消息
    }
    
    var messageType : SystemMessageType = .walletMessageType
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomDis: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var topBtn: UIButton!
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    fileprivate var isChoosing = false
    fileprivate var isSelectedAll = false//是否选择了全部
    fileprivate var selectedIds : Array<String> = Array<String>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.messageType == .walletMessageType{
            self.navigationItem.title = "资金消息"
        }else if self.messageType == .systemMessageType{
            self.navigationItem.title = "系统消息"
        }else if self.messageType == .taskMessageType{
            self.navigationItem.title = "接发单消息"
        }else if self.messageType == .epSystemMessageType{
            self.navigationItem.title = "系统消息"
        }
        
        self.tableView.register(UINib.init(nibName: "SystemMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "SystemMessageCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "编辑", target: self, action: #selector(SystemMessageViewController.rightItemAction))
        
        self.loadData()
        LYProgressHUD.showLoading()
        
        self.addRefresh()
        
        
        self.bottomViewBottomDis.constant = -45
    }
    
    //刷新
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadData()
        }
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadData()
        }
    }

    //加载数据
    func loadData() {
        if self.messageType == .epSystemMessageType{
            var params : [String : Any] = [:]
            params["curpage"] = curpage
            params["message_type"] = "1"//消息类型1 为系统消息
            NetTools.requestData(type: .post, urlString: EPMessageListApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                if self.curpage == 1{
                    self.dataArray.removeAll()
                    self.tableView.es.stopPullToRefresh()
                }else{
                    self.tableView.es.stopLoadingMore()
                }
                //判断是否有更多
                if result.arrayValue.count < 10{
                    self.tableView.es.noticeNoMoreData()
                }else{
                    self.tableView.es.resetNoMoreData()
                }
                for subJson in result.arrayValue{
                    self.dataArray.append(subJson)
                }
                if self.dataArray.count == 0{
                    self.showEmptyView()
                }else{
                    self.tableView.reloadData()
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }else{
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["curpage"] = curpage
            params["op"] = "message_list"
            params["act"] = "member_index"
            params["message_type"] = self.messageType.rawValue
            NetTools.requestData(type: .post, urlString: SysTermMessageApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                if self.curpage == 1{
                    self.dataArray.removeAll()
                    self.tableView.es.stopPullToRefresh()
                }else{
                    self.tableView.es.stopLoadingMore()
                }
                
                //判断是否有更多
                if result.arrayValue.count < 10{
                    self.tableView.es.noticeNoMoreData()
                }else{
                    self.tableView.es.resetNoMoreData()
                }
                
                for subJson in result.arrayValue{
                    self.dataArray.append(subJson)
                }
                
                if self.dataArray.count == 0{
                    self.showEmptyView()
                }else{
                    self.tableView.reloadData()
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func rightItemAction() {
        //编辑
        self.isChoosing = !self.isChoosing
        if self.isChoosing{
            self.topView.isHidden = false
            self.bottomView.isHidden = false
            self.topViewH.constant = 44
            self.bottomViewBottomDis.constant = 0
        }else{
            self.topView.isHidden = true
            self.bottomView.isHidden = true
            self.topViewH.constant = 0
            self.bottomViewBottomDis.constant = -45
            self.selectedIds.removeAll()
            self.isSelectedAll = false
            self.topBtn.setTitle("全选", for: .normal)
        }
        self.tableView.reloadData()
    }
    
    
    @IBAction func btnAction(_ btn: UIButton) {
        if btn.tag == 11{
            //全选／取消全选
            self.isSelectedAll = !self.isSelectedAll
            self.selectedIds.removeAll()
            if self.isSelectedAll{
                self.topBtn.setTitle("取消全选", for: .normal)
                for subJson in self.dataArray {
                    var id = ""
                    if subJson["message_id"].stringValue.isEmpty{
                        id = subJson["id"].stringValue
                    }else{
                        id = subJson["message_id"].stringValue
                    }
                    self.selectedIds.append(id)
                }
            }else{
                self.topBtn.setTitle("全选", for: .normal)
            }
            self.tableView.reloadData()
            
        }else if btn.tag == 22{
            //标为已读
            if self.messageType == .epSystemMessageType{
                self.epOperationAction(1)
            }else{
                self.dealMessage("take_message")
            }
        }else if btn.tag == 33{
            //删除
            if self.messageType == .epSystemMessageType{
                self.epOperationAction(2)
            }else{
                self.dealMessage("del_message")
            }
        }else if btn.tag == 44{
            //取消
            self.rightItemAction()
        }
    }
    

    //type：1标未已读 2:删除
    func epOperationAction(_ type : Int) {
        if self.selectedIds.count == 0{
            LYProgressHUD.showError("请至少选择一条！")
            return
        }
        
        let message_ids = self.selectedIds.joined(separator: ",")
        var params : [String : Any] = [:]
        var url = ""
        
        if type == 1{
            if self.isSelectedAll{
                url = EPMessageReadAllApi
            }else{
                url = EPMessageReadApi
                params["id"] = message_ids
            }
            
        }else if type == 2{
            if self.isSelectedAll{
                url = EPMessageDeleteAllApi
            }else{
                url = EPMessageDeleteApi
                params["id"] = message_ids
            }
        }
        
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("处理成功！")
            self.rightItemAction()
            self.curpage = 1
            self.loadData()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    func dealMessage(_ op : String) {
        if self.selectedIds.count == 0{
            LYProgressHUD.showError("请至少选择一条！")
            return
        }
        
        let message_ids = self.selectedIds.joined(separator: ",")
        var params : [String : Any] = [:]
        params["store_id"] = "1";
        params["op"] = op
        params["act"] = "member_index"
        params["message_id"] = message_ids
        if self.isSelectedAll{
            params["operate_all"] = "1"
        }
        params["message_type"] = self.messageType.rawValue
        
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: SysTermMessageApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("处理成功！")
            self.rightItemAction()
            self.curpage = 1
            self.loadData()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
}


extension SystemMessageViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SystemMessageCell", for: indexPath) as! SystemMessageCell        
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.subJson = subJson
            cell.titleLbl.text = self.navigationItem.title
            if self.isChoosing{
                cell.selecteBtn.isHidden = false
                cell.detailImgV.isHidden = true
                if self.isSelectedAll{
                    cell.selecteBtn.isSelected = true
                }else{
                    var id = ""
                    if subJson["message_id"].stringValue.isEmpty{
                        id = subJson["id"].stringValue
                    }else{
                        id = subJson["message_id"].stringValue
                    }
                    if self.selectedIds.contains(id){
                        cell.selecteBtn.isSelected = true
                    }else{
                        cell.selecteBtn.isSelected = false
                    }
                }
            }else{
                cell.selecteBtn.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            let size = subJson["message_body"].stringValue.sizeFit(width: kScreenW - 26, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            return size.height + 45
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if self.dataArray.count > indexPath.row{
            var subJson = self.dataArray[indexPath.row]
            if self.isChoosing{
                var id = ""
                if subJson["message_id"].stringValue.isEmpty{
                    id = subJson["id"].stringValue
                }else{
                    id = subJson["message_id"].stringValue
                }
                if self.isSelectedAll{
                    self.isSelectedAll = false
                    self.topBtn.setTitle("全选", for: .normal)
                    if self.selectedIds.contains(id){
                        self.selectedIds.remove(at: self.selectedIds.index(of: id)!)
                    }
                }else{
                    if self.selectedIds.contains(id){
                        self.selectedIds.remove(at: self.selectedIds.index(of: id)!)
                    }else{
                        self.selectedIds.append(id)
                    }
                }
                self.tableView.reloadData()
            }else{
                //标示已读
                if self.messageType == .epSystemMessageType{
                    if subJson["is_read"].stringValue.intValue == 0{
                        var params : [String : Any] = [:]
                        params["id"] = subJson["id"].stringValue
                        NetTools.requestData(type: .post, urlString: EPMessageReadApi, parameters: params, succeed: { (result, msg) in
                            subJson["is_read"] = "1"
                            let cell = tableView.cellForRow(at: indexPath) as! SystemMessageCell
                            cell.subJson = subJson
                        }, failure: { (error) in
                        })
                    }
                }else{
                    if subJson["message_open"].stringValue.intValue == 0{
                        var params : [String : Any] = [:]
                        params["store_id"] = "1";
                        params["message_id"] = subJson["message_id"].stringValue
                        NetTools.requestData(type: .post, urlString: MessageDetaileApi, parameters: params, succeed: { (result, msg) in
                            subJson["message_open"] = "1"
                            let cell = tableView.cellForRow(at: indexPath) as! SystemMessageCell
                            cell.subJson = subJson
                        }, failure: { (error) in
                        })
                    }
                    
                    // 【71：项目详情】【72：接单详情】【73：发单详情】【74：跳转到钱包详情里，此时jump_id为空】【75：众筹详情】【76：商城订单详情】
                    if subJson["jump_type"].stringValue.intValue == 71{
                        // 项目详情
                        let orderDetailVC = MySendOrderDetailViewController.spwan()
                        orderDetailVC.orderId = subJson["jump_id"].stringValue
                        self.navigationController?.pushViewController(orderDetailVC, animated: true)
                    }else if subJson["jump_type"].stringValue.intValue == 72{
                        let orderDetailVC = MySendOrderDetailViewController.spwan()
                        orderDetailVC.orderId = subJson["jump_id"].stringValue
                        orderDetailVC.isMyReceive = true
                        orderDetailVC.moveState = subJson["move_state"].stringValue
                        self.navigationController?.pushViewController(orderDetailVC, animated: true)
                    }else if subJson["jump_type"].stringValue.intValue == 73{
                        let orderDetailVC = MySendOrderDetailViewController.spwan()
                        orderDetailVC.orderId = subJson["jump_id"].stringValue
                        self.navigationController?.pushViewController(orderDetailVC, animated: true)
                    }else if subJson["jump_type"].stringValue.intValue == 74{
                        // 资金消息
                        let walletVC = WalletViewController.spwan()
                        walletVC.beanNum = LocalData.getBeanCount().intValue
                        walletVC.userId = LocalData.getNotMd5UserId()
                        self.navigationController?.pushViewController(walletVC, animated: true)
                    }else if subJson["jump_type"].stringValue.intValue == 76{
                        let orderDetailVC = ShopOrderDetailViewController()
                        orderDetailVC.orderId = subJson["jump_id"].stringValue
                        self.navigationController?.pushViewController(orderDetailVC, animated: true)
                    }
                }
                
            }
        }
    }
}
