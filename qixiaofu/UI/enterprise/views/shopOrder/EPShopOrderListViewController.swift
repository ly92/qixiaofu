//
//  EPShopOrderListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPShopOrderListViewController: BaseViewController {
    class func spwan() -> EPShopOrderListViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPShopOrderListViewController
    }
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollContentVW: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var epCenterState : Int?//如果有值表示从企业中心的分类过来的
    fileprivate var titleArray = ["全部","待付款","待发货","待收货","已完成","已取消"]
    fileprivate var stateArray = ["0","1","2","3","4","5"]
    fileprivate var btnView = UIView()
    fileprivate var line = UIView()
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    fileprivate var orderState = "" //order_state        订单状态  0全部  1待支付   2待发货   3待收货  4已完成 5已取消
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏以及顶部滚动导航
        self.setUpTopNav()
        
        self.tableView.register(UINib.init(nibName: "EPShopOrderCell", bundle: Bundle.main), forCellReuseIdentifier: "EPShopOrderCell")
        
        if self.epCenterState == nil{
            self.loadData()
        }else{
            let btn = UIButton()
            btn.tag = self.epCenterState!
            self.topBtnAction(btn)
        }
        self.addRefresh()
        
        //刷新列表和详情的通知
        NotificationCenter.default.addObserver(self, selector: #selector(EPShopOrderListViewController.refreshData), name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
        
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
    
    //设置导航栏以及顶部滚动导航
    func setUpTopNav() {
        self.navigationItem.title = "商城订单"
        
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
            btn.addTarget(self, action: #selector(EPShopOrderListViewController.topBtnAction(_:)), for: .touchUpInside)
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
    @objc func topBtnAction(_ tempBtn : UIButton) {
        var btn = tempBtn
        for view in self.btnView.subviews {
            let btn1 = view as! UIButton
            btn1.isSelected = false
            if btn.tag == btn1.tag{
                btn = btn1
            }
        }
        btn.isSelected = true
        self.line.x = btn.x
        self.orderState = self.stateArray[btn.tag]
        self.tableView.contentOffset = CGPoint.zero
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
    
    
    //加载数据
    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["order_state"] = self.orderState//订单状态  0全部  1待支付   2待发货   3待收货  4已完成 5已取消
        
        NetTools.requestData(type: .post, urlString: EPShopOrderListApi, parameters: params, succeed: { (result, msg) in
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


extension EPShopOrderListViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EPShopOrderCell", for: indexPath) as! EPShopOrderCell
        cell.parentVC = self
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.subJson = subJson
        }
        cell.refreshBlock = {(type) in
            self.curpage = 1
            self.loadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataArray.count > indexPath.row{
            let orderDetailVC = EPShopOrderDetailViewController.spwan()
            orderDetailVC.orderId = self.dataArray[indexPath.row]["id"].stringValue
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        }
    }
    
    
}

