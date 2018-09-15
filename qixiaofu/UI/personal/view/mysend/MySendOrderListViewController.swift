//
//  MySendOrderListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/1.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MySendOrderListViewController: BaseViewController {
    class func spwan() -> MySendOrderListViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! MySendOrderListViewController
    }
    
    var isMyReceive = false
    
    
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollContentVW: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    var titleArray : Array<String> = Array<String>()
    var stateArray : Array<Int> = Array<Int>()
    fileprivate var btnView = UIView()
    fileprivate var line = UIView()
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    fileprivate var billState = 1//发单状态【0 撤销】【1 待接单】【2 已接单】【3 已完成】【4 已过期 or 已失效】【5 已取消】【6 调价中】【7 补单】
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏以及顶部滚动导航
        self.setUpTopNav()
        
        self.tableView.register(UINib.init(nibName: "MySendOrderCell", bundle: Bundle.main), forCellReuseIdentifier: "MySendOrderCell")
        
        self.loadData()
        self.addRefresh()
        
    }
    
    
    //设置导航栏以及顶部滚动导航
    func setUpTopNav() {
        if self.isMyReceive{
            self.navigationItem.title = "我的接单"
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "补单", target: self, action: #selector(MySendOrderListViewController.rightItemAction))
        }else{
            self.navigationItem.title = "我的发单"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "发单", target: self, action: #selector(MySendOrderListViewController.rightItemAction))
        }
        
        let merge = 10
        let btnW = 80
        
        //设置滚动宽度
        self.scrollContentVW.constant = CGFloat((btnW + merge) * self.titleArray.count + merge)
        //按钮容器
        self.btnView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.scrollContentVW.constant, height: 42))
        self.scrollContentView.addSubview(btnView)
        //按钮
        for (i,str) in self.titleArray.enumerated() {
            let btn = UIButton(frame:CGRect.init(x: merge + (btnW + merge) * i, y: 0, width: btnW, height: 42))
            btn.setTitle(str, for: .normal)
            btn.setTitleColor(Normal_Color, for: .selected)
            btn.setTitleColor(Text_Color, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            btn.addTarget(self, action: #selector(MySendOrderListViewController.topBtnAction(btn:)), for: .touchUpInside)
            btn.tag = i
            if i == 0{
                btn.isSelected = true
            }
            self.btnView.addSubview(btn)
        }
        
        //标示线
        self.line = UIView.init(frame: CGRect.init(x: CGFloat(merge), y: 40, width: CGFloat(btnW), height: 1.5))
        self.line.backgroundColor = Normal_Color
        self.scrollContentView?.addSubview(self.line)
        
        
    }
    
    //顶部按钮点击事件
    @objc func topBtnAction(btn : UIButton) {
        for view in self.btnView.subviews {
            let btn1 = view as! UIButton
            btn1.isSelected = false
        }
        btn.isSelected = true
        self.line.x = btn.x
        self.billState = self.stateArray[btn.tag]
//        self.tableView.contentOffset = CGPoint.zero
        self.curpage = 1
        self.loadData()
        
        if btn.x > kScreenW / 2.0{
            if (self.scrollContentVW.constant - btn.x - btn.w / 2.0) > kScreenW / 2.0{
                self.topScrollView.contentOffset = CGPoint.init(x: btn.x - kScreenW / 2.0 + btn.w / 2.0 , y: 0)
            }else{
                self.topScrollView.contentOffset = CGPoint.init(x: self.scrollContentVW.constant - kScreenW, y: 0)
            }
        }
        if (btn.x + btn.w) - self.topScrollView.contentOffset.x < kScreenW / 2.0{
            if kScreenW / 2.0 - btn.x - btn.w / 2.0 < 0 {
                self.topScrollView.contentOffset = CGPoint.init(x: btn.x + btn.w / 2.0 - kScreenW / 2.0 , y: 0)
            }else{
                self.topScrollView.contentOffset = CGPoint.zero
            }
        }
    }
    
    //发单
    @objc func rightItemAction() {
        if self.isMyReceive{
//            //补单
//            if LocalData.getYesOrNotValue(key: IsALevelUser){
//                LYProgressHUD.showInfo("当前用户为A用户，不可补单！")
//                return
//            }
//            let redoOrderVC = SendTaskViewController.spwan()
//            redoOrderVC.isRepairOrder = true
//            self.navigationController?.pushViewController(redoOrderVC, animated: true)
        }else{
            //发单
            let sendTaskVC = SendTaskViewController.spwan()
            self.navigationController?.pushViewController(sendTaskVC, animated: true)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //加载数据
    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        
        var url = ""
        if self.isMyReceive{
            //我的接单
            if self.billState == 1{
                //报名中
                url = MyReceiveEnrollListApi
            }else{
                url = MyReceiveOrderListApi
                params["bill_statu"] = (self.billState)
            }
        }else{
            //我的发单
            if self.billState == 1{
                //报名中
                url = MySendEnrollListApi
            }else{
                url = MySendOrderListApi
                params["bill_statu"] = (self.billState)
            }
        }
        
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
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

extension MySendOrderListViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MySendOrderCell", for: indexPath) as! MySendOrderCell
        if self.dataArray.count > indexPath.row{
            var subJson = self.dataArray[indexPath.row]
            if self.isMyReceive{
                subJson["isMyReceive"] = "1"
            }
            
            cell.subJson = subJson
            cell.parentVC = self
            cell.refreshBlock = {(type) in
                //1:从列表删除 2:原地刷新 3:从数据库删除（删除，撤销）
                if type == 1{
                    if self.dataArray.count > indexPath.row{
                        self.dataArray.remove(at: indexPath.row)
//                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        self.tableView.reloadData()
                    }
                }else if type == 2{
                    self.changeDetailData(indexpath: indexPath, json: subJson)
                }else{
                    if self.dataArray.count > indexPath.row{
                        self.dataArray.remove(at: indexPath.row)
//                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataArray.count > indexPath.row{
            let orderDetailVC = MySendOrderDetailViewController.spwan()
            orderDetailVC.orderId = self.dataArray[indexPath.row]["id"].stringValue
            orderDetailVC.isMyReceive = self.isMyReceive
            if self.isMyReceive{
                orderDetailVC.moveState = self.dataArray[indexPath.row]["move_state"].stringValue
            }else{
                orderDetailVC.enrollNum = self.dataArray[indexPath.row]["num"].stringValue
            }
            orderDetailVC.refreshBlock = {(type) in
                //1:从列表删除 2:原地刷新 3:从数据库删除（删除，撤销）
                if type == 1{
                    if self.dataArray.count > indexPath.row{
                        self.dataArray.remove(at: indexPath.row)
//                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        self.tableView.reloadData()
                    }
                }else if type == 2{
                    self.changeDetailData(indexpath: indexPath, json: self.dataArray[indexPath.row])
                }else{
                    if self.dataArray.count > indexPath.row{
                        self.dataArray.remove(at: indexPath.row)
//                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        self.tableView.reloadData()
                    }
                }
            }
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        }
        
    }
    
    //原地刷新时替换数据
    func changeDetailData(indexpath : IndexPath,json : JSON) {
        if self.isMyReceive{
            var params : [String : Any] = [:]
            params["id"] = json["id"].stringValue
            params["move_state"] = json["move_state"].stringValue
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: ReceiveDetailDataApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                if self.dataArray.count > indexpath.row{
                    self.dataArray.remove(at: indexpath.row)
                    self.dataArray.insert(result, at: indexpath.row)
                    self.tableView.reloadData()
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }else{
            var params : [String : Any] = [:]
            params["id"] = json["id"].stringValue
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: MySendOrderDetailApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                if self.dataArray.count > indexpath.row{
                    self.dataArray.remove(at: indexpath.row)
                    self.dataArray.insert(result, at: indexpath.row)
                    self.tableView.reloadData()
                }
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
    }
    
}
