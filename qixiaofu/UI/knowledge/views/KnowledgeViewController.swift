//
//  KnowledgeViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/16.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class KnowledgeViewController: BaseViewController {
    class func spwan() -> KnowledgeViewController{
        return self.loadFromStoryBoard(storyBoard: "Knowledge") as! KnowledgeViewController
    }
    
    @IBOutlet weak var leftLbl: UILabel!
    @IBOutlet weak var centerLbl: UILabel!
    @IBOutlet weak var rightLbl: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var centerBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var categoryTable: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var videoTableView: UITableView!
    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var categoryTableLeftDis: NSLayoutConstraint!
    @IBOutlet weak var categoryTableHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrolContentW: NSLayoutConstraint!
    
    fileprivate let searchBar : UISearchBar = UISearchBar()
    fileprivate var leftNavBtn = UIButton()
    fileprivate var rightNavBtn = UIButton()
    fileprivate var navLine = UIView()
    

    
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var leftArray : Array<JSON> = Array<JSON>()
    fileprivate var videoArray : Array<JSON> = Array<JSON>()
    //    fileprivate var centerArray : Array<JSON> = Array<JSON>()
    fileprivate var rightArray : Array<JSON> = Array<JSON>()
    fileprivate var categoryArray : Array<JSON> = Array<JSON>()
    
    fileprivate var curpage = 1
    fileprivate var keyWord = ""
    fileprivate var typeId = "0"
    fileprivate var sortId = "0"
    fileprivate var selectedLeftIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "知识库"
        self.scrollView.isScrollEnabled = false
        self.scrollView.contentOffset = CGPoint.zero
        self.scrolContentW.constant = kScreenW * 2
        
        self.tableView.register(UINib.init(nibName: "KnowledgeListCell", bundle: Bundle.main), forCellReuseIdentifier: "KnowledgeListCell")
        
        self.addRefresh()
        self.rightArray = [JSON(["id" : "0", "name" : "默认排序"]),JSON(["id" : "1", "name" : "按发布时间"]),JSON(["id" : "2", "name" : "按点赞数量"])]
        
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_search"), target: self, action: #selector(KnowledgeViewController.rightItemAction))
        
        self.setUpNavView()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadCategoryData()
        
        //如果没有数据自动加载
        if self.dataArray.count == 0{
            self.loadData()
        }
        
        if self.videoArray.count == 0{
            self.loadVideoData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hidecategoryTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //导航view
    func setUpNavView() {
        return
        let view = UIView(frame:CGRect.init(x: 0, y: 0, width: 120, height: 40))
        self.leftNavBtn = UIButton(frame:CGRect.init(x: 0, y: 0, width: 60, height: 40))
        leftNavBtn.setTitle("文章", for: .normal)
        leftNavBtn.setTitleColor(Normal_Color, for: .selected)
        leftNavBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
        leftNavBtn.addTarget(self, action: #selector(KnowledgeViewController.leftNavAction), for: .touchUpInside)
        
        self.rightNavBtn = UIButton(frame:CGRect.init(x: 60, y: 0, width: 60, height: 40))
        rightNavBtn.setTitle("视频", for: .normal)
        rightNavBtn.setTitleColor(Normal_Color, for: .selected)
        rightNavBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
        rightNavBtn.addTarget(self, action: #selector(KnowledgeViewController.rightNavAction), for: .touchUpInside)
        
        self.navLine = UIView(frame:CGRect.init(x: self.navLine.x, y: 39, width: 60, height: 1.5))
        navLine.backgroundColor = Normal_Color
        
        view.addSubview(leftNavBtn)
        view.addSubview(rightNavBtn)
        view.addSubview(navLine)
        self.navigationItem.titleView = view
        
        if self.navLine.x == 0{
            self.leftNavBtn.isSelected = true
            self.rightNavBtn.isSelected = false
        }else if self.navLine.x == 60{
            self.leftNavBtn.isSelected = false
            self.rightNavBtn.isSelected = true
        }
        
    }
    @objc func leftNavAction() {
        if self.navLine.x != 0{
            self.navLine.x = 0
            self.leftNavBtn.isSelected = true
            self.rightNavBtn.isSelected = false
//            self.leftNavBtn.setTitleColor(Normal_Color, for: .normal)
//            self.rightNavBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
            self.scrollView.contentOffset = CGPoint.zero
            self.curpage = 1
        }
    }
    
    @objc func rightNavAction() {
        if self.navLine.x != 60{
            self.navLine.x = 60
            self.leftNavBtn.isSelected = false
            self.rightNavBtn.isSelected = true
//            self.leftNavBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
//            self.rightNavBtn.setTitleColor(Normal_Color, for: .normal)
            self.scrollView.contentOffset = CGPoint.init(x: kScreenW, y: 0)
            self.curpage = 1
        }
    }
    
    
    //加载筛选条件
    func loadCategoryData() {
        self.leftArray.removeAll()
        NetTools.requestData(type: .post, urlString: KnowledgeCategoryApi, succeed: { (result, msg) in
            let json = JSON(["id" : "0", "name" : "所有品牌", "smallList" : [["id" : "0", "name" : "所有系列"]]])
            self.leftArray.append(json)
            for subJson in result.arrayValue{
                self.leftArray.append(subJson)
            }
        }) { (error) in
//            LYProgressHUD.showError("获取筛选条件失败！")
        }
    }
    
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadData()
        }
        
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadData()
        }
        
        self.videoTableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadVideoData()
        }
        
        self.videoTableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadVideoData()
        }
    }
    
    //加载数据知识库列表
    func loadData() {
        var params : [String : Any] = [:]
        params["type_id"] = self.typeId
        params["sortid"] = self.sortId
        params["curpage"] = self.curpage
        params["keyword"] = self.keyWord
        
        NetTools.requestData(type: .post, urlString: KnowledgeListApi, parameters: params, succeed: { (result, msg) in
            //停止刷新
            if self.curpage == 1{
                self.tableView.es.stopPullToRefresh()
                self.dataArray.removeAll()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            //是否有更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            if self.dataArray.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
            self.tableView.reloadData()
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    
    //加载视频数据
    func loadVideoData(){
        return
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["keywords"] = self.keyWord
        
        NetTools.requestData(type: .post, urlString: KVideoListApi, parameters: params, succeed: { (result, msg) in
            //停止刷新
            if self.curpage == 1{
                self.videoTableView.es.stopPullToRefresh()
                self.videoArray.removeAll()
            }else{
                self.videoTableView.es.stopLoadingMore()
            }
            print("--------------------------\(result.arrayValue.count)")
            //是否有更多
            if result.arrayValue.count < 10{
                self.videoTableView.es.noticeNoMoreData()
            }else{
                self.videoTableView.es.resetNoMoreData()
            }
            
            for subJson in result.arrayValue{
                self.videoArray.append(subJson)
            }
            
            if self.videoArray.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
            self.videoTableView.reloadData()
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //顶部筛选按钮点击
    @IBAction func topBtnAction(_ btn: UIButton) {
        if btn.isSelected{
            self.hidecategoryTable()
            return
        }
        self.leftBtn.isSelected = false
        self.centerBtn.isSelected = false
        self.rightBtn.isSelected = false
        btn.isSelected = true
        self.categoryTableLeftDis.constant = btn.x
        self.categoryTable.isHidden = false
        self.bgBtn.isHidden = false
        
        if btn.tag == 11{
            //品牌
            self.categoryArray = self.leftArray
        }else if btn.tag == 22{
            //系列
            self.categoryArray = self.leftArray[self.selectedLeftIndex]["smallList"].arrayValue
        }else{
            //排序
            self.categoryArray = self.rightArray
        }
        
        if self.categoryArray.count > 4{
            self.categoryTableHeight.constant = 150
        }else{
            self.categoryTableHeight.constant = CGFloat(35 * self.categoryArray.count)
        }
        
        self.categoryTable.reloadData()
    }
    
    //隐藏弹出的table
    @IBAction func hidecategoryTable() {
        self.leftBtn.isSelected = false
        self.centerBtn.isSelected = false
        self.rightBtn.isSelected = false
        self.categoryTable.isHidden = true
        self.bgBtn.isHidden = true
    }
}

extension KnowledgeViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return self.dataArray.count
        }else if tableView == self.categoryTable{
            return self.categoryArray.count
        }else{
            return self.videoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "KnowledgeListCell", for: indexPath) as! KnowledgeListCell
            if self.dataArray.count > indexPath.row{
                let subJson = self.dataArray[indexPath.row]
                cell.subJson = subJson
            }
            return cell
        }else if tableView == self.categoryTable{
            let cell = UITableViewCell()
            if self.categoryArray.count > indexPath.row{
                let subJson = self.categoryArray[indexPath.row]
                let lbl = UILabel(frame:CGRect.init(x: 10, y: 7, width: kScreenW / 3.0 - 20, height: 21))
                lbl.textColor = Text_Color
                lbl.font = UIFont.systemFont(ofSize: 14.0)
                lbl.textAlignment = .center
                cell.addSubview(lbl)
                let line = UIView(frame:CGRect.init(x: 0, y: 35, width: kScreenW / 3.0, height: 1))
                line.backgroundColor = BG_Color
                cell.addSubview(line)
                lbl.text = subJson["name"].stringValue
            }
            return cell
        }else{
            let cell = UITableViewCell()
            cell.accessoryType = .disclosureIndicator
            if self.videoArray.count > indexPath.row{
                let subJson = self.videoArray[indexPath.row]
                cell.textLabel?.text = subJson["mv_name"].stringValue
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView{
            return 125
        }else if tableView == self.categoryTable{
            return 35
        }else{
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableView{
            if self.dataArray.count > indexPath.row{
                let subJson = self.dataArray[indexPath.row]
                let detailVC = KnowledgeDetailViewController.spwan()
                detailVC.knowledgeId = subJson["post_id"].stringValue
                detailVC.dataChangeBlock = {[weak self] (result : JSON) in
//                    var params : [String : Any] = [:]
//                    params["post_id"] = subJson["post_id"].stringValue
//                    NetTools.requestData(type: .post, urlString: KnowledgeDetailApi, parameters: params, succeed: { (result, msg) in
                        self?.dataArray.remove(at: indexPath.row)
                        self?.dataArray.insert(result, at: indexPath.row)
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
//                    }) { (error) in
//                    }
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            
        }else if tableView == self.categoryTable{
            if self.categoryArray.count > indexPath.row{
                let subJson = self.categoryArray[indexPath.row]
                if self.leftBtn.isSelected{
                    self.selectedLeftIndex = indexPath.row
                    self.typeId = subJson["id"].stringValue
                    self.leftLbl.text = subJson["name"].stringValue
                    self.centerLbl.text = "所有系列"
                }else if self.centerBtn.isSelected{
                    self.typeId = subJson["id"].stringValue
                    self.centerLbl.text = subJson["name"].stringValue
                }else{
                    self.sortId = subJson["id"].stringValue
                    self.rightLbl.text = subJson["name"].stringValue
                }
                self.hidecategoryTable()
                self.curpage = 1
                self.loadData()
            }
        }else{
            //播放视频
            if self.videoArray.count > indexPath.row{
                let subJson = self.videoArray[indexPath.row]
                let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
                videoPlayVC.videoId = subJson["mv_id"].stringValue
                self.navigationController?.pushViewController(videoPlayVC, animated: true)
            }
            
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView{
            self.navLine.x = self.scrollView.contentOffset.x / kScreenW * 60
            if self.navLine.x == 0{
                self.leftNavBtn.isSelected = true
                self.rightNavBtn.isSelected = false
            }else if self.navLine.x == 60{
                self.leftNavBtn.isSelected = false
                self.rightNavBtn.isSelected = true
            }
        }else if scrollView as? UITableView == self.tableView{
            if self.searchBar.isFirstResponder{
                self.searchBar.resignFirstResponder()
            }
        }
    }
    
    
    
}


extension KnowledgeViewController : UISearchBarDelegate{
    //搜索
    @objc func rightItemAction() {
        self.setUpSearchNavView()
    }
    
    //取消搜索
    func cancelAction() {
        self.setUpNavView()
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_search"), target: self, action: #selector(KnowledgeViewController.rightItemAction))
        self.navigationItem.title = "知识库"
        if self.searchBar.isFirstResponder{
            self.searchBar.resignFirstResponder()
        }
        searchBar.text = ""
        self.keyWord = ""
        self.curpage = 1
        self.loadData()
    }
    
    //设置搜索框
    func setUpSearchNavView() {
        searchBar.placeholder = "请输入关键字搜索"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = nil
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", target: self, action: #selector(InventoryListViewController.cancelAction))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text?.isEmpty)!{
            self.keyWord = searchBar.text!
            self.curpage = 1
            self.loadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelAction()
    }
    
    
}
