//
//  EPAfterSalerListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPAfterSalerListViewController: BaseViewController {
    class func spwan() -> EPAfterSalerListViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPAfterSalerListViewController
    }
    
    @IBOutlet weak var dealingBtn: UIButton!
    @IBOutlet weak var dealedBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lineLeftDis: NSLayoutConstraint!
    
    //1 审核中  2 审核通过 3 审核不通过 4 商家待收货  5 商家已收货  6 完成 7 取消 8 删除
    
    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    fileprivate var state = "1"//1:处理中 2:已完成
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "售后列表"

        self.tableView.register(UINib.init(nibName: "EPAfterSalerCell", bundle: Bundle.main), forCellReuseIdentifier: "EPAfterSalerCell")
        
        self.topBtnAction(self.dealingBtn)
        self.addRefresh()
    }

    func addRefresh(){
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
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["state"] = self.state //1:处理中 2:已完成
        NetTools.requestData(type: .post, urlString: EPExchangeListApi, parameters: params, succeed: { (result, msg) in
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
            LYProgressHUD.showError(error ?? "获取数据失败，请重试！")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //切换种类
    @IBAction func topBtnAction(_ btn: UIButton) {
        if btn.isSelected{
            return
        }
        
        self.dealedBtn.isSelected = false
        self.dealingBtn.isSelected = false
        btn.isSelected = true
        
        if btn.tag == 11{
            //处理中
            self.lineLeftDis.constant = self.dealingBtn.centerX - 20
            self.state = "1"
        }else if btn.tag == 22{
            //已完成
            self.lineLeftDis.constant = self.dealedBtn.centerX - 20
            self.state = "2"
        }
        self.curpage = 1
        self.loadData()
    }
    
    

}




extension EPAfterSalerListViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EPAfterSalerCell", for: indexPath) as! EPAfterSalerCell
        if self.dataArray.count > indexPath.row{
            let json = self.dataArray[indexPath.row]
            cell.subJson = json
        }
        cell.parentVC = self
        cell.refreshBlock = {() in
            self.curpage = 1
            self.loadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataArray.count > indexPath.row{
            let json = self.dataArray[indexPath.row]
            let detailVC = EPAfterSalerDetailViewController.spwan()
            detailVC.orderId = json["return_id"].stringValue
            detailVC.refreshBlock = {() in
                self.curpage = 1
                self.loadData()
            }
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}
