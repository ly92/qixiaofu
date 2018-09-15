//
//  CollectListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/14.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollectListViewController: BaseTableViewController {
    
    
    var isCollect : Bool = false
    var titleStr = ""
    var gc_id = "0"
    
    fileprivate var rsg_msg = ""
    fileprivate var curpage : NSInteger = 1
    
    fileprivate lazy var dataArray : Array<JSON> = {
        let dataArray = Array<JSON>()
        return dataArray
    }()
    
    fileprivate var area_list : JSON = []
    fileprivate var selectedIds : Array<String> = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isCollect{
            self.navigationItem.title = "收藏"
        }else{
            self.navigationItem.title = self.titleStr
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "筛选", target: self, action: #selector(CollectListViewController.filtrateAction))
        }
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.register(UINib.init(nibName: "CollectGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "CollectGoodsCell")
        
        if self.isCollect{
            self.loadCollectData()
        }else{
            self.loadData()
        }
        
        self.addRefresh()
    }
    
    @objc func filtrateAction() {
        let filtV = FiltrateView.loadFromNib() as! FiltrateView
        filtV.selectedIds = self.selectedIds
        filtV.show(with: self.area_list)
        filtV.filtrateBlock = {[weak self] (array) -> Void in
            self?.selectedIds = array
            self?.curpage = 1
            self?.loadData()
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
            if (self?.isCollect)!{
                self?.loadCollectData()
            }else{
                self?.loadData()
            }
            
        }
        
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            if (self?.isCollect)!{
                self?.loadCollectData()
            }else{
                self?.loadData()
            }
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
    
    //3.右侧列表数据
    func loadData() {
        var params : [String : Any] = [:]
        params["store_id"] = "1"//店铺ID
//        params["gc_id"] = self.gc_id//商品分类ID
        params["key"] = "1"// 排序类型【1:销量】【2:人气（访问量）】【3:价格】【4:新品】
        params["order"] = "1"//排序方式【1:升序】【2:降序】
        params["curpage"] = "\(self.curpage)"//页数
        if !titleStr.isEmpty{
            params["keyword"] = titleStr
        }
        
        if self.selectedIds.count > 0{
            let ids = self.selectedIds.joined(separator: ",")
            params["area_id"] = ids
        }
        
        NetTools.requestData(type: .post, urlString: SearchShopGoodsListApi, parameters: params, succeed: { (resultJson, msg) in
            
            
            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            
            for subJson in resultJson["goods_list"].arrayValue{
                self.dataArray.append(subJson)
            }
            
            self.area_list = resultJson["area_list"]
            
            self.rsg_msg = resultJson["res.msg"].stringValue
            
            //停止刷新
            self.stopRefresh()
            
            //判断是否可以加载更多
            if resultJson["goods_list"].arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //重加载tabble
            self.tableView.reloadData()
            
        }) { (error) in
            self.stopRefresh()
            LYProgressHUD.showError(error!)
        }
    }
    
    //收藏列表
    func loadCollectData() {
        var params : [String : Any] = [:]
        params["store_id"] = "1"//店铺ID
        params["curpage"] = "\(self.curpage)"//页数
        NetTools.requestData(type: .post, urlString: CollectGoodsListApi, parameters: params, succeed: { (result, msg) in
            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            //停止刷新
            self.stopRefresh()
            
            //判断是否可以加载更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //重加载tabble
            self.tableView.reloadData()
        }) { (error) in
            self.stopRefresh()
            LYProgressHUD.showError(error!)
            
        }
    }
    
}


//MARK: -   UITableViewDelegate,UITableViewDataSource
extension CollectListViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectGoodsCell", for: indexPath) as! CollectGoodsCell
        if self.dataArray.count > indexPath.row{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                cell.epSubJson = self.dataArray[indexPath.row]
            }else{
                cell.subJson = self.dataArray[indexPath.row]
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            let detailVC = GoodsDetailViewController.spwan()
            detailVC.goodsId = subJson["goods_id"].stringValue
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.rsg_msg.isEmpty{
            return nil
        }else{
            let view = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 40))
            view.backgroundColor = UIColor.RGB(r: 253, g: 250, b: 230)
            let lbl = UILabel(frame:CGRect.init(x: 10, y: 0, width: kScreenW - 20, height: 40))
            lbl.numberOfLines = 0
            lbl.textColor = Text_Color
            lbl.font = UIFont.systemFont(ofSize: 14.0)
            lbl.text = self.rsg_msg
            view.addSubview(lbl)
            return view
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isCollect{
            return 0.001
        }
        if self.rsg_msg.isEmpty{
            return 0.001
        }
        return 40
    }
    
}
