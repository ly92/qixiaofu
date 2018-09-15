//
//  ShopOrderListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/11.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopOrderListViewController: BaseViewController {
    class func spwan() -> ShopOrderListViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! ShopOrderListViewController
    }
    
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollContentVW: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var titleArray = ["全部","待付款","待发货","待收货","已完成","退换货","已取消"]
    fileprivate var stateArray = ["","1","2","3","4","6","0"]
    fileprivate var btnView = UIView()
    fileprivate var line = UIView()
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    fileprivate var orderState = "" //订单状态 【空字符串 所有订单】【1，待付款】【2，已支付】【3，待收货】【4，待评价】【5，已完成】
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏以及顶部滚动导航
        self.setUpTopNav()
        
        self.tableView.register(UINib.init(nibName: "ShopOrderCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderStateCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderStateCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderBtnCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderBtnCell")
        self.tableView.register(UINib.init(nibName: "ShopOrderListGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopOrderListGoodsCell")
        
        
        self.loadData()
        self.addRefresh()
        
        //刷新列表和详情的通知
        NotificationCenter.default.addObserver(self, selector: #selector(ShopOrderListViewController.refreshData), name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
        
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
            btn.addTarget(self, action: #selector(ShopOrderListViewController.topBtnAction(btn:)), for: .touchUpInside)
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
        params["store_id"] = "1";
        params["state_type"] = self.orderState//订单状态 【空字符串 所有订单】【1，待付款】【3，待收货】【4，待评价】【5，已完成】
        
        NetTools.requestData(type: .post, urlString: ShopOrderListApi, parameters: params, succeed: { (result, msg) in
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


extension ShopOrderListViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderStateCell", for: indexPath) as! ShopOrderStateCell
            if self.dataArray.count > indexPath.section{
                let subJson = self.dataArray[indexPath.section]
                cell.subJson = subJson
            }
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderCell", for: indexPath) as! ShopOrderCell
            if self.dataArray.count > indexPath.section{
                let subJson = self.dataArray[indexPath.section]
                cell.subJson = subJson
            }
            cell.parentVC = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopOrderBtnCell", for: indexPath) as! ShopOrderBtnCell
            if self.dataArray.count > indexPath.section{
                let subJson = self.dataArray[indexPath.section]
                cell.subJson = subJson
                cell.orderId = subJson["order_id"].stringValue
            }
            cell.parentVC = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 30
        }else if indexPath.row == 1{
            return 88
        }else{
            return 44
        }
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataArray.count > indexPath.section{
            let orderDetailVC = ShopOrderDetailViewController()
            orderDetailVC.orderId = self.dataArray[indexPath.section]["order_id"].stringValue
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        }
    }
    
    
}
