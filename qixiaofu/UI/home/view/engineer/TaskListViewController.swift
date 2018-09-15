//
//  TaskListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


class TaskListViewController: BaseViewController {
    class func spwan() -> TaskListViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! TaskListViewController
    }
    
    
    var isHomeMore : Bool = false
    var isHomeAllTaskList : Bool = false
    
    var gc_id : String = ""
    var gc_name : String?
    
    //子栏目分类数据
    var categoryArray = Array<JSON>()
    
    fileprivate var keywords : String = ""//发单名称 【模糊搜索】
    fileprivate var service_sprice : String = ""//起始价格
    fileprivate var service_eprice : String = ""//结束价格
    fileprivate var service_stime : String = ""//起始预约时间【时间戳】
    fileprivate var service_etime : String = ""//结束预约时间【时间戳】
    fileprivate var address : String = ""//筛选地区
    fileprivate var curpage : NSInteger = 1
    
    
    @IBOutlet weak var tableView: UITableView!//列表
    @IBOutlet weak var topView1: UIView!
    @IBOutlet weak var arrow1: UIImageView!
    @IBOutlet weak var topLbl1: UILabel!
    @IBOutlet weak var topView2: UIView!
    @IBOutlet weak var arrow2: UIImageView!
    @IBOutlet weak var topLbl2: UILabel!
    @IBOutlet weak var topView3: UIView!
    @IBOutlet weak var arrow3: UIImageView!
    @IBOutlet weak var topLbl3: UILabel!
    @IBOutlet weak var topView4: UIView!
    @IBOutlet weak var arrow4: UIImageView!
    @IBOutlet weak var topLbl4: UILabel!
    @IBOutlet weak var bigFilterView: UIView!//筛选母版
    @IBOutlet weak var classifyLeftTableView: UITableView!//全部分类左侧
    @IBOutlet weak var classifyRightTableView: UITableView!//全部分类右侧
    @IBOutlet weak var filterTableView: UITableView!//金额以及预约时间
    @IBOutlet weak var filterLeftTF: UITextField!//输入框
    @IBOutlet weak var filterRightTF: UITextField!//输入框
    @IBOutlet weak var sureFilterBtn: UIButton!
    @IBOutlet weak var subFilterView1: UIView!//分类筛选母版
    @IBOutlet weak var subFilterView2: UIView!//金额以及预约时间筛选母版
    @IBOutlet weak var emptyView2: UIView!
    
    fileprivate var classifyFilterData : JSON = []//全部分类的数据
    fileprivate var selectedClassifyIndex = 0//选中的索引
    fileprivate var subscribeFilterData = ("全部","2000",("2000","5000"),"5000")//预约时间
    fileprivate var priceFilterData = ("全部","7",("7","15"),"15")//价格
    fileprivate var isFilteringPrice = false//是否正在筛选价格
    
    
    fileprivate lazy var dataArray : NSMutableArray = {
        let dataArray = NSMutableArray()
        return dataArray
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "HomeTaskListCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeTaskListCell")
        self.classifyLeftTableView.register(UINib.init(nibName: "SubCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "SubCategoryCell")
        self.classifyRightTableView.register(UINib.init(nibName: "SubCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "SubCategoryCell")
        self.filterTableView.register(UINib.init(nibName: "SubCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "SubCategoryCell")
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        //切弧角
        self.sureFilterBtn.layer.cornerRadius = 5
        //添加刷新
        self.addRefresh()
        
        //筛选所用数据
        self.prepareFilterData()
        
        self.navigationItem.title = "接单"
        self.setUpRightItems()
        self.loadAllReceiveableTaskList()
        
        LYProgressHUD.showLoading()
        
        self.topViewAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //筛选所用数据
    func prepareFilterData() {
        //全部分类的数据
        NetTools.requestData(type: .post, urlString: HomeMainApi, succeed: { (resultDict, error) in
            self.classifyFilterData = resultDict["class_list"]
        }) { (error) in
        }
        
    }
    
    //MARK:顶部筛选点击事件
    func topViewAction() {
        self.topView1.addTapActionBlock {
            if self.bigFilterView.isHidden{
                self.bigFilterView.isHidden = false
                self.subFilterView1.isHidden = false
                self.setUpArrowAndLbl(1)
            }else{
                if self.subFilterView2.isHidden{
                    self.setUpArrowAndLbl(0)
                }else{
                    self.subFilterView1.isHidden = false
                    self.subFilterView2.isHidden = true
                    self.setUpArrowAndLbl(1)
                }
            }
        }
        
        self.topView2.addTapActionBlock {
            if self.bigFilterView.isHidden{
                self.bigFilterView.isHidden = false
                self.subFilterView2.isHidden = false
                self.setUpArrowAndLbl(2)
            }else{
                if self.subFilterView1.isHidden && !self.isFilteringPrice{
                    self.setUpArrowAndLbl(0)
                }else{
                    self.subFilterView1.isHidden = true
                    self.subFilterView2.isHidden = false
                    self.setUpArrowAndLbl(2)
                    
                }
            }
            self.isFilteringPrice = false
        }
        
        
        self.topView3.addTapActionBlock {
            
            if self.bigFilterView.isHidden{
                self.bigFilterView.isHidden = false
                self.subFilterView2.isHidden = false
                self.setUpArrowAndLbl(3)
            }else{
                if self.subFilterView1.isHidden && self.isFilteringPrice{
                    self.setUpArrowAndLbl(0)
                }else{
                    self.subFilterView1.isHidden = true
                    self.subFilterView2.isHidden = false
                    self.setUpArrowAndLbl(3)
                    
                }
            }
            self.isFilteringPrice = true
        }
        
        self.topView4.addTapActionBlock {
            self.subFilterView1.isHidden = true
            self.subFilterView2.isHidden = true
            self.bigFilterView.isHidden = true
            self.setUpArrowAndLbl(0)
            let filtView = FiltrateView2.loadFromNib() as! FiltrateView2
            filtView.show()
            filtView.filtRateBlock = {[weak self] (params) -> Void in
                print(params)
//                self?.service_stime = params["service_stime"] as! String
//                self?.service_etime = params["service_etime"] as! String
//                self?.service_sprice = params["service_sprice"] as! String
//                self?.service_eprice = params["service_eprice"] as! String
                self?.address = params["address"] as! String
                self?.curpage = 1
                self?.loadAllReceiveableTaskList()
            }
            
        }
    }
    
    //箭头方向以及字体颜色
    func setUpArrowAndLbl(_ index : Int) {
        switch index {
        case 1:
            //点击全部
            self.arrow1.image = #imageLiteral(resourceName: "up_arrow1")
            self.topLbl1.textColor = UIColor.RGB(r: 225, g: 171, b: 38)
            self.arrow2.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl2.textColor = UIColor.RGBS(s: 33)
            self.arrow3.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl3.textColor = UIColor.RGBS(s: 33)
            self.classifyLeftTableView.reloadData()
            self.classifyRightTableView.reloadData()
        case 2:
            //点击预约
            self.arrow1.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl1.textColor = UIColor.RGBS(s: 33)
            self.arrow2.image = #imageLiteral(resourceName: "up_arrow1")
            self.topLbl2.textColor = UIColor.RGB(r: 225, g: 171, b: 38)
            self.arrow3.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl3.textColor = UIColor.RGBS(s: 33)
            self.filterLeftTF.text = ""
            self.filterRightTF.text = ""
            self.filterLeftTF.placeholder = "最早时间"
            self.filterRightTF.placeholder = "最晚时间"
            self.filterTableView.reloadData()
        case 3:
            //点击金额
            self.arrow1.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl1.textColor = UIColor.RGBS(s: 33)
            self.arrow2.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl2.textColor = UIColor.RGBS(s: 33)
            self.arrow3.image = #imageLiteral(resourceName: "up_arrow1")
            self.topLbl3.textColor = UIColor.RGB(r: 225, g: 171, b: 38)
            self.filterLeftTF.text = ""
            self.filterRightTF.text = ""
            self.filterLeftTF.placeholder = "最低价格"
            self.filterRightTF.placeholder = "最高价格"
            self.filterTableView.reloadData()
        default:
            self.arrow1.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl1.textColor = UIColor.RGBS(s: 33)
            self.arrow2.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl2.textColor = UIColor.RGBS(s: 33)
            self.arrow3.image = #imageLiteral(resourceName: "down_arrow1")
            self.topLbl3.textColor = UIColor.RGBS(s: 33)
            self.subFilterView1.isHidden = true
            self.subFilterView2.isHidden = true
            self.bigFilterView.isHidden = true
        }
    }
    
    
    //确定筛选
    @IBAction func filterAction() {
        guard let minStr = self.filterLeftTF.text else {
            return
        }
        guard let maxStr = self.filterRightTF.text else {
            return
        }
        if self.isFilteringPrice{
            self.service_sprice = minStr
            self.service_eprice = maxStr
            self.topLbl3.text = minStr + "~" + maxStr
        }else{
            self.service_stime = Date.dateWithDaysAfterNow(days: minStr.doubleValue).phpTimestamp()
            self.service_etime = Date.dateWithDaysAfterNow(days: maxStr.doubleValue).phpTimestamp()
            self.topLbl2.text = minStr + "~" + maxStr + "天"
        }
        self.view.endEditing(true)
        self.curpage = 1
        self.loadAllReceiveableTaskList()
        self.setUpArrowAndLbl(0)
    }
    //隐藏筛选器
    @IBAction func hideBigFilterViewAction() {
        self.setUpArrowAndLbl(0)
    }
    
    
    //停止刷新
    func stopRefresh() {
        if self.dataArray.count > 0{
            self.hideEmptyView()
        }else{
            self.showEmptyView()
        }
    }
}

extension TaskListViewController{
    
    func setUpRightItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"icon_search"), target: self, action: #selector(TaskListViewController.searchAction))
    }
    
    //搜索
    @objc func searchAction() {
        let searchVC = SearchViewController.spwan()
        searchVC.callBackBlock { (keyWord) in
            print(keyWord)
            self.keywords = keyWord
            self.curpage = 1
            if (self.isHomeAllTaskList){
                self.loadAllReceiveableTaskList()
            }else{
                self.loadTaskData()
            }
        }
        
        let nav = LYNavigationController.init(rootViewController: searchVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
    
    //设置空闲时间
    func setUpSpaceTime() {
        let setSpaceTimeVC = SetSpaceTimeViewController.spwan()
        setSpaceTimeVC.setSpaceTimeBlock = {[weak self] () in
            self?.curpage = 1
            self?.loadAllReceiveableTaskList()
        }
        self.navigationController?.pushViewController(setSpaceTimeVC, animated: true)
    }
    
    
    
}

//MARK: - UISearchBarDelegate
extension TaskListViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        self.dataArray.removeAllObjects()
        self.keywords = searchBar.text!
        self.curpage = 1
        //        self.loadAllReceiveableTaskList()
        if (self.isHomeAllTaskList){
            self.loadAllReceiveableTaskList()
        }else{
            self.loadTaskData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.dataArray.removeAllObjects()
        self.keywords = searchText
        self.curpage = 1
        if (self.isHomeAllTaskList){
            self.loadAllReceiveableTaskList()
        }else{
            self.loadTaskData()
        }
        //        self.loadAllReceiveableTaskList()
    }
}

//MARK: - 加载数据
extension TaskListViewController{
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
            if (self?.isHomeMore)!{
                self?.loadRecommandData()
            }else if (self?.isHomeAllTaskList)!{
                self?.loadAllReceiveableTaskList()
            }else{
                self?.loadTaskData()
            }
        }
        
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            if (self?.isHomeMore)!{
                self?.loadRecommandData()
            }else if (self?.isHomeAllTaskList)!{
                self?.loadAllReceiveableTaskList()
            }else{
                self?.loadTaskData()
            }
        }
    }
    
    
    //根据服务种类加载数据
    func loadTaskData() {
        var params : [String : Any] = [:]
        params["curpage"] = (self.curpage)
        params["gc_id"] = self.gc_id
        if !self.keywords.isEmpty{
            params["keywords"] = self.keywords
        }
        //        if !self.keywords.isEmpty{
        //            params["keywords"] = self.keywords
        //        }
        //        if !self.service_sprice.isEmpty{
        //            params["service_sprice"] = self.service_sprice
        //        }
        //        if !self.service_eprice.isEmpty{
        //            params["service_eprice"] = self.service_eprice
        //        }
        //        if !self.service_stime.isEmpty{
        //            params["service_stime"] = self.service_stime
        //        }
        //        if !self.service_etime.isEmpty{
        //            params["service_etime"] = self.service_etime
        //        }
        
        NetTools.requestData(type: .post, urlString: HomeTaskListApi, parameters: params, succeed: { (resultDict, error) in
            
            if self.curpage == 1{
                self.dataArray.removeAllObjects()
            }
            
            for subJson in resultDict.arrayValue{
                self.dataArray.add(subJson)
            }
            
            //停止刷新
            self.stopRefresh()
            
            //判断是否可以加载更多
            if resultDict.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //重加载tabble
            self.tableView.reloadData()
            
        }) { (error) in
            //停止刷新
            self.stopRefresh()
        }
    }
    //小七推荐的任务列表
    func loadRecommandData() {
        var params : [String : Any] = [:]
        params["curpage"] = (self.curpage)
        NetTools.requestData(type: .post, urlString: HomeRecommandTaskListApi, parameters: params, succeed: { (resultDict, error) in
            
            if self.curpage == 1{
                self.dataArray.removeAllObjects()
            }
            
            for subJson in resultDict.arrayValue{
                self.dataArray.add(subJson)
            }
            
            //停止刷新
            self.stopRefresh()
            
            //判断是否可以加载更多
            if resultDict.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //重加载tabble
            self.tableView.reloadData()
            
        }) { (error) in
            //停止刷新
            self.stopRefresh()
        }
        
    }
    //导航栏点击接单时显示的所有任务列表
    func loadAllReceiveableTaskList() {
        var params : [String : Any] = [:]
        params["curpage"] = (self.curpage)
        params["gc_id"] = self.gc_id
        if !self.keywords.isEmpty{
            params["keywords"] = self.keywords
        }
        if !self.service_sprice.isEmpty{
            params["service_sprice"] = self.service_sprice
        }
        if !self.service_eprice.isEmpty{
            params["service_eprice"] = self.service_eprice
        }
        if !self.service_stime.isEmpty{
            params["service_stime"] = self.service_stime
        }
        if !self.service_etime.isEmpty{
            params["service_etime"] = self.service_etime
        }
        if !self.address.isEmpty{
            params["address"] = self.address
        }
        
        NetTools.requestData(type: .post, urlString: HomeAllTaskListApi, parameters: params, succeed: { (resultDict, error) in
            //停止刷新
            LYProgressHUD.dismiss()
            if self.curpage == 1{
                self.dataArray.removeAllObjects()
                self.tableView.es.stopPullToRefresh()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            
            for subJson in resultDict.arrayValue{
                self.dataArray.add(subJson)
            }
            
            //判断是否可以加载更多
            if resultDict.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            //重加载tabble
            self.tableView.reloadData()
            
            if self.dataArray.count > 0{
                self.emptyView2.isHidden = true
            }else{
                self.emptyView2.isHidden = false
            }
            
        }) { (error) in
            //停止刷新
            LYProgressHUD.dismiss()
            self.tableView.es.stopPullToRefresh()
            self.tableView.es.stopLoadingMore()
        }
    }
    
    
}


//MARK: -  UITableViewDelegate,UITableViewDataSource
extension TaskListViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return self.dataArray.count
        }else if tableView == self.classifyLeftTableView{
            return self.classifyFilterData.arrayValue.count + 1
        }else if tableView == self.classifyRightTableView{
            if self.selectedClassifyIndex == 0{
                return 1
            }else{
                if self.classifyFilterData.arrayValue.count > self.selectedClassifyIndex{
                    let json = self.classifyFilterData.arrayValue[self.selectedClassifyIndex]
                    return json["list"].arrayValue.count + 1
                }
            }
            
        }else if tableView == self.filterTableView{
            return 4
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTaskListCell", for: indexPath) as! HomeTaskListCell
            if self.dataArray.count > indexPath.row{
                let subJson = self.dataArray[indexPath.row] as! JSON
                cell.jsonModel = subJson
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
            if tableView == self.classifyLeftTableView{
                if indexPath.row == 0{
                    cell.titleLbl.text = "全部"
                }else{
                    let json = self.classifyFilterData.arrayValue[indexPath.row-1]
                    cell.titleLbl.text = json["gc_name"].stringValue
                }
                if self.selectedClassifyIndex == indexPath.row{
                    cell.titleLbl.textColor = UIColor.RGB(r: 225, g: 171, b: 38)
                }else{
                    cell.titleLbl.textColor = UIColor.RGBS(s: 33)
                }
            }else if tableView == self.classifyRightTableView{
                if indexPath.row == 0{
                    cell.titleLbl.text = "全部"
                }else{
                    if self.classifyFilterData.arrayValue.count > self.selectedClassifyIndex-1{
                        let jsonArray = self.classifyFilterData.arrayValue[self.selectedClassifyIndex-1]["list"].arrayValue
                        if jsonArray.count > indexPath.row{
                            let json = jsonArray[indexPath.row]
                            cell.titleLbl.text = json["gc_name"].stringValue
                        }
                    }
                }
                cell.titleLbl.textColor = UIColor.RGBS(s: 33)
            }else if tableView == self.filterTableView{
                if self.isFilteringPrice{
                    switch indexPath.row{
                    case 0:
                        cell.titleLbl.text = "全部"
                    case 1:
                        cell.titleLbl.text = "小于2000"
                    case 2:
                        cell.titleLbl.text = "2000～5000"
                    case 3:
                        cell.titleLbl.text = "5000以上"
                    default:
                        print("")
                    }
                }else{
                    switch indexPath.row{
                    case 0:
                        cell.titleLbl.text = "全部"
                    case 1:
                        cell.titleLbl.text = "7天以内"
                    case 2:
                        cell.titleLbl.text = "7～15天"
                    case 3:
                        cell.titleLbl.text = "15天以上"
                    default:
                        print("")
                    }
                }
                cell.titleLbl.textColor = UIColor.RGBS(s: 33)
            }
            if self.categoryArray.count > indexPath.row{
                cell.titleLbl.text = self.categoryArray[indexPath.row]["gc_name"].stringValue
            }
            return cell
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView{
            return 155
        }else{
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if tableView == self.tableView{
            if self.dataArray.count > indexPath.row{
                let jsonModel = self.dataArray[indexPath.row] as! JSON
                if jsonModel[""].stringValue.intValue != 0{
                    let orderDetailVC = MySendOrderDetailViewController.spwan()
                    orderDetailVC.orderId = jsonModel["id"].stringValue
                    orderDetailVC.isMyReceive = true
                    orderDetailVC.moveState = ""
                    self.navigationController?.pushViewController(orderDetailVC, animated: true)
                }else{
                    let detailVC = TaskReceiveDetailViewController.spwan()
                    detailVC.task_id = jsonModel["id"].stringValue
                    detailVC.dataChangeBlock = {(type) in//1:刷新 2:删除
                        if type == 1{
                            let params :[String : Any] = ["id" : jsonModel["id"].stringValue]
                            NetTools.requestData(type: .post, urlString: HomeTaskDetailApi, parameters: params, succeed: { (resultDict, error) in
                                if self.dataArray.count > indexPath.row{
                                    self.dataArray.removeObject(at: indexPath.row)
                                    self.dataArray.insert(resultDict, at: indexPath.row)
                                }
                            }) { (error) in
                            }
                        }else if type == 2{
                            self.dataArray.removeObject(at: indexPath.row)
                        }
                        self.tableView.reloadData()
                    }
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
        }else if tableView == self.classifyLeftTableView{
            self.selectedClassifyIndex = indexPath.row
            self.classifyRightTableView.reloadData()
            self.classifyLeftTableView.reloadData()
        }else if tableView == self.classifyRightTableView{
            if indexPath.row == 0{
                if self.selectedClassifyIndex == 0{
                    self.gc_id = ""
                }else{
                    let json = self.classifyFilterData.arrayValue[self.selectedClassifyIndex-1]
                    self.gc_id = json["gc_id"].stringValue
                }
                self.topLbl1.text = "全部"
            }else{
                if self.classifyFilterData.arrayValue.count > self.selectedClassifyIndex{
                    let jsonArray = self.classifyFilterData.arrayValue[self.selectedClassifyIndex-1]["list"].arrayValue
                    if jsonArray.count > indexPath.row{
                        let json = jsonArray[indexPath.row]
                        self.gc_id = json["gc_id"].stringValue
                        self.topLbl1.text = json["gc_name"].stringValue
                    }
                }
            }
            self.curpage = 1
            self.loadAllReceiveableTaskList()
            self.setUpArrowAndLbl(0)
        }else if tableView == self.filterTableView{
            if self.isFilteringPrice{
                switch indexPath.row{
                case 0:
                    self.service_sprice = ""
                    self.service_eprice = ""
                    self.topLbl3.text = "全部"
                case 1:
                    self.service_sprice = "0"
                    self.service_eprice = "2000"
                    self.topLbl3.text = "0~2000"
                case 2:
                    self.service_sprice = "2000"
                    self.service_eprice = "5000"
                    self.topLbl3.text = "2000~5000"
                case 3:
                    self.service_sprice = "5000"
                    self.service_eprice = ""
                    self.topLbl3.text = "5000以上"
                default:
                    print("")
                }
            }else{
                switch indexPath.row{
                case 0:
                    self.service_stime = ""
                    self.service_etime = ""
                    self.topLbl2.text = "全部"
                case 1:
                    self.service_stime = Date.phpTimestamp()
                    self.service_etime = Date.dateWithDaysAfterNow(days: 7).phpTimestamp()
                    self.topLbl2.text = "7天以内"
                case 2:
                    self.service_stime = Date.phpTimestamp()
                    self.service_etime = Date.dateWithDaysAfterNow(days: 15).phpTimestamp()
                    self.topLbl2.text = "7～15天"
                case 3:
                    self.service_stime = Date.dateWithDaysAfterNow(days: 15).phpTimestamp()
                    self.service_etime = ""
                    self.topLbl2.text = "15天以上"
                default:
                    print("")
                }
            }
            self.curpage = 1
            self.loadAllReceiveableTaskList()
            self.setUpArrowAndLbl(0)
        }
    }
    
}

