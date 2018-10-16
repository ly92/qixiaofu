//
//  DiscoverViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/12/8.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

enum DiscoverViewType : Int {
    case discover//发现
    case choiceness//更多本周精选
    case course//更多最新培训
}

class DiscoverViewController: BaseViewController {
    class func spwan() -> DiscoverViewController{
        return self.loadFromStoryBoard(storyBoard: "Knowledge") as! DiscoverViewController
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var middleTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    @IBOutlet weak var sortCollectionView: UICollectionView!
    @IBOutlet weak var sortLeftView: UIView!
    @IBOutlet weak var scrollViewW: NSLayoutConstraint!
    @IBOutlet weak var sortViewH: NSLayoutConstraint!
    @IBOutlet weak var courseBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var knowledgeBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var topScrolView: UIView!
    @IBOutlet weak var topScrolViewW: NSLayoutConstraint!
    @IBOutlet weak var knowledgeSortView: UIView!
    @IBOutlet weak var newBtn: UIButton!
    @IBOutlet weak var hotBtn: UIButton!
    @IBOutlet weak var videoSortCollectionView: UICollectionView!
    @IBOutlet weak var videoSortViewH: NSLayoutConstraint!
    
    //是否为精选或者最新评论
    var discoverType : DiscoverViewType = .discover
    
    //视频数据
    fileprivate var videoArray : Array<JSON> = Array<JSON>()
    //视频筛选
    fileprivate var videoSortArray : Array<JSON> = Array<JSON>()
    fileprivate var needRefreshVideoSort = false
    //课程
    fileprivate var courseArray : Array<JSON> = Array<JSON>()
    //知识库
    fileprivate var knowledgeArray : Array<JSON> = Array<JSON>()
    fileprivate var knowledgeSortArray : Array<JSON> = Array<JSON>()
    
    //知识库筛选
    fileprivate let secOneLbl = UILabel()
    //知识库筛选
    fileprivate let secTwoLbl = UILabel()
    //顶部红线
    fileprivate let btnLine = UIView()
    fileprivate var curpage1 = 1
    fileprivate var curpage2 = 1
    fileprivate var curpage3 = 1
    fileprivate var keyWord = ""
    fileprivate var typeId = "0"
    fileprivate var sortId = "0"
    fileprivate var selectedSecOneIndex = 0
    fileprivate let searchBar : UISearchBar = UISearchBar()
    fileprivate var selectedVideoSortIndex = 0
    fileprivate var videoType = "1"
    fileprivate var currentOffsetY : CGFloat = 0
    
    fileprivate var pageNum : CGFloat = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addRefresh()
        self.setUPTableConfig()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showSortView(show: false)
        
//        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
//            //返回按钮
//            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(DiscoverViewController.backClick))
//        }else{
//            self.navigationItem.leftBarButtonItem = nil
//        }
    }
    
//    @objc func backClick() {
//        AppDelegate.sharedInstance.resetRootViewController(1)
//    }
    
    func setUPTableConfig() {
        self.scrollViewW.constant = kScreenW * self.pageNum
        self.topScrolViewW.constant = kScreenW
        
        
        
        self.middleTableView.register(UINib.init(nibName: "DiscoverVideoCell", bundle: Bundle.main), forCellReuseIdentifier: "DiscoverVideoCell")
        self.leftTableView.register(UINib.init(nibName: "DiscoverCourseCell", bundle: Bundle.main), forCellReuseIdentifier: "DiscoverCourseCell")
        self.rightTableView.register(UINib.init(nibName: "KnowledgeListCell", bundle: Bundle.main), forCellReuseIdentifier: "KnowledgeListCell")
        self.sortCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SortCollectionCell")
        self.videoSortCollectionView.register(UINib.init(nibName: "VideoSortCell", bundle: Bundle.main), forCellWithReuseIdentifier: "VideoSortCell")
        
        self.secOneLbl.text = "品牌:"
        self.secOneLbl.font = UIFont.systemFont(ofSize: 14.0)
        self.secOneLbl.textColor = UIColor.colorHex(hex: "575757")
        self.secOneLbl.textAlignment = .center
        self.sortLeftView.addSubview(secOneLbl)
        self.secTwoLbl.text = "系列:"
        self.secTwoLbl.font = UIFont.systemFont(ofSize: 14.0)
        self.secTwoLbl.textColor = UIColor.colorHex(hex: "575757")
        self.secTwoLbl.textAlignment = .center
        self.sortLeftView.addSubview(secTwoLbl)
        
        self.btnLine.backgroundColor = Normal_Color
        self.btnLine.frame = CGRect.init(x: 0, y: self.topScrolView.h-3, width: 50, height: 2)
        self.topScrolView.addSubview(self.btnLine)
        self.courseBtn.w = kScreenW / self.pageNum
        
        
        if self.discoverType == .course{
            self.topView.isHidden = true
            self.topViewH.constant = 0
            self.scrollView.isScrollEnabled = false
            self.navigationItem.title = "最新培训"
            self.topBtnAction(self.courseBtn)
        }else if self.discoverType == .choiceness{
            self.topView.isHidden = true
            self.topViewH.constant = 0
            self.navigationItem.title = "本周精选"
            self.topBtnAction(self.videoBtn)
            DispatchQueue.main.async {
                self.scrollView.contentOffset = CGPoint.init(x: kScreenW, y: 0)
            }
            self.scrollView.isScrollEnabled = false
        }else{
            self.topView.isHidden = false
            self.topViewH.constant = 50
            self.topBtnAction(self.courseBtn)
        }
        
        self.newBtn.setTitleColor(Normal_Color, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //知识库上方筛选
    @IBAction func sortBtnAction(_ sender: UIButton) {
        if sender.tag == 111{
            self.hotBtn.setTitleColor(UIColor.RGBS(s: 145), for: .normal)
            self.newBtn.setTitleColor(Normal_Color, for: .normal)
            self.sortId = "1"
            self.loadKnowledgeData()
            self.showSortView(show: false)
        }else if sender.tag == 222{
            self.newBtn.setTitleColor(UIColor.RGBS(s: 145), for: .normal)
            self.hotBtn.setTitleColor(Normal_Color, for: .normal)
            self.sortId = "2"
            self.loadKnowledgeData()
            self.showSortView(show: false)
        }else if sender.tag == 333{
            if self.knowledgeSortView.isHidden {
                self.loadKnowledgeSort()
            }else{
                self.showSortView(show: false)
            }
        }
    }
    
    //展示知识库筛选
    func showSortView(show : Bool) {
        if show && self.knowledgeSortView.isHidden{
            self.knowledgeSortView.isHidden = false
        }else{
            self.knowledgeSortView.isHidden = true
        }
    }
    
    
    //课程,视频,知识库筛选
    @IBAction func topBtnAction(_ sender: UIButton) {
        if sender.isSelected == true {return}
        
        self.courseBtn.isSelected = false
        self.videoBtn.isSelected = false
        self.knowledgeBtn.isSelected = false
        sender.isSelected = true
        UIView.animate(withDuration: 0.25) {
            self.btnLine.x = sender.centerX - 25
        }
        
        if sender.tag == 11{
            if self.courseArray.count == 0{
                self.curpage1 = 1
                self.loadCourseData()
            }
            self.scrollView.scrollRectToVisible(CGRect.init(x:0, y: 0, width: kScreenW, height: self.scrollView.h), animated: true)
            self.cancelAction()
            self.setUpRightItem(show: false)
        }else if sender.tag == 22{
            if self.videoArray.count == 0{
                self.needRefreshVideoSort = true
                self.curpage2 = 1
                self.loadVideoData()
            }
            self.scrollView.scrollRectToVisible(CGRect.init(x:kScreenW, y: 0, width: kScreenW, height: self.scrollView.h), animated: true)
            if self.navigationItem.titleView == nil{
                self.setUpRightItem(show: true)
            }
        }else if sender.tag == 33{
            if self.knowledgeArray.count == 0{
                self.curpage3 = 1
                self.loadKnowledgeData()
            }
            self.scrollView.scrollRectToVisible(CGRect.init(x:kScreenW * 2, y: 0, width: kScreenW, height: self.scrollView.h), animated: true)
            if self.navigationItem.titleView == nil{
                self.setUpRightItem(show: true)
            }
        }
    }
    
    
}

//加载数据
extension DiscoverViewController {
    
    func addRefresh() {
        self.leftTableView.es.addPullToRefresh {
            self.curpage1 = 1
            self.loadCourseData()
        }
        self.leftTableView.es.addInfiniteScrolling {
            self.curpage1 += 1
            self.loadCourseData()
        }
        self.middleTableView.es.addPullToRefresh {
            self.curpage2 = 1
            self.loadVideoData()
        }
        self.middleTableView.es.addInfiniteScrolling {
            self.curpage2 += 1
            self.loadVideoData()
        }
        self.rightTableView.es.addPullToRefresh {
            self.curpage3 = 1
            self.loadKnowledgeData()
        }
        self.rightTableView.es.addInfiniteScrolling {
            self.curpage3 += 1
            self.loadKnowledgeData()
        }
        
    }
    
    
    //加载课程列表数据
    func loadCourseData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage1
        
        NetTools.requestData(type: .post, urlString: KCourseListApi, parameters: params, succeed: { (result, msg) in
            //停止刷新
            if self.curpage1 == 1{
                self.leftTableView.es.stopPullToRefresh()
                self.courseArray.removeAll()
            }else{
                self.leftTableView.es.stopLoadingMore()
            }
            //是否有更多
            if result.arrayValue.count < 10{
                self.leftTableView.es.noticeNoMoreData()
            }else{
                self.leftTableView.es.resetNoMoreData()
            }
            
            for subJson in result.arrayValue{
                self.courseArray.append(subJson)
            }
            
            if self.courseArray.count > 0{
                //self.hideEmptyView()
            }else{
                //self.showEmptyView()
            }
            self.leftTableView.reloadData()
            
        }) { (error) in
            self.leftTableView.es.noticeNoMoreData()
self.leftTableView.es.resetNoMoreData()
            LYProgressHUD.showError(error!)
        }
    }
    
    //加载视频列表数据
    func loadVideoData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage2
        params["keywords"] = self.keyWord
        params["type_id"] = self.videoType
        
        NetTools.requestData(type: .post, urlString: KVideoListApi1, parameters: params, succeed: { (result, msg) in
            //停止刷新
            if self.curpage2 == 1{
                self.middleTableView.es.stopPullToRefresh()
                self.videoArray.removeAll()
            }else{
                self.middleTableView.es.stopLoadingMore()
            }
            //是否有更多
            if result["mv_list"].arrayValue.count < 10{
                self.middleTableView.es.noticeNoMoreData()
            }else{
                self.middleTableView.es.resetNoMoreData()
            }
            
            for subJson in result["mv_list"].arrayValue{
                self.videoArray.append(subJson)
            }

            if self.videoArray.count > 0{
                //self.hideEmptyView()
            }else{
                //self.showEmptyView()
            }
            self.middleTableView.reloadData()
            //是否需要刷新视频分类
            if self.needRefreshVideoSort{
                self.needRefreshVideoSort = false
                self.videoSortArray.removeAll()
                for subJson in result["mv_type"].arrayValue{
                    self.videoSortArray.append(subJson)
                }
                self.videoSortCollectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    print("1")
                    self.videoSortViewH.constant = self.videoSortCollectionView.contentSize.height + 20
                })
            }
            
        }) { (error) in
            self.middleTableView.es.stopPullToRefresh()
            self.middleTableView.es.stopLoadingMore()
            LYProgressHUD.showError(error!)
        }
    }
    
    //加载知识库列表数据
    func loadKnowledgeData() {
        var params : [String : Any] = [:]
        params["type_id"] = self.typeId
        params["sortid"] = self.sortId
        params["curpage"] = self.curpage3
        params["keyword"] = self.keyWord
        
        NetTools.requestData(type: .post, urlString: KnowledgeListApi, parameters: params, succeed: { (result, msg) in
            //停止刷新
            if self.curpage3 == 1{
                self.rightTableView.es.stopPullToRefresh()
                self.knowledgeArray.removeAll()
            }else{
                self.rightTableView.es.stopLoadingMore()
            }
            print("--------------------------\(result.arrayValue.count)")
            //是否有更多
            if result.arrayValue.count < 10{
                self.rightTableView.es.noticeNoMoreData()
            }else{
                self.rightTableView.es.resetNoMoreData()
            }
            
            for subJson in result.arrayValue{
                self.knowledgeArray.append(subJson)
            }
            
            if self.knowledgeArray.count > 0{
                //self.hideEmptyView()
            }else{
                //self.showEmptyView()
            }
            self.rightTableView.reloadData()
            
        }) { (error) in
            self.rightTableView.es.stopLoadingMore()
            self.rightTableView.es.stopPullToRefresh()
            LYProgressHUD.showError(error!)
        }
    }
    
    //加载知识库筛选条件
    func loadKnowledgeSort() {
        self.knowledgeSortArray.removeAll()
        NetTools.requestData(type: .post, urlString: KnowledgeCategoryApi, succeed: { (result, msg) in
            let json = JSON(["id" : "0", "name" : "所有品牌", "smallList" : [["id" : "0", "name" : "所有系列"]]])
            self.knowledgeSortArray.append(json)
            for subJson in result.arrayValue{
                self.knowledgeSortArray.append(subJson)
            }
            
            self.sortCollectionView.reloadData()
            self.showSortView(show: true)
        }) { (error) in
            //            LYProgressHUD.showError("获取筛选条件失败！")
        }
    }
}

extension DiscoverViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.leftTableView{
            return self.courseArray.count
        }else if tableView == self.middleTableView{
            return self.videoArray.count
        }else if tableView == self.rightTableView{
            return self.knowledgeArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.leftTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCourseCell", for: indexPath) as! DiscoverCourseCell
            if self.courseArray.count > indexPath.row{
                let subJson = self.courseArray[indexPath.row]
                cell.subJson = subJson
            }
            return cell
        }else if tableView == self.middleTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverVideoCell", for: indexPath) as! DiscoverVideoCell
            if self.videoArray.count > indexPath.row{
                let subJson = self.videoArray[indexPath.row]
                cell.subJson = subJson
            }
            return cell
        }else if tableView == self.rightTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "KnowledgeListCell", for: indexPath) as! KnowledgeListCell
            if self.knowledgeArray.count > indexPath.row{
                let subJson = self.knowledgeArray[indexPath.row]
                cell.subJson = subJson
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.leftTableView{
            
            return (kScreenW - 16) / 2.0 + 20
        }else if tableView == self.middleTableView{
            return (kScreenW - 16) / 2.0 + 20
        }else if tableView == self.rightTableView{
            return 125
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == self.leftTableView{
            NetTools.qxfClickCount("10")
            if self.courseArray.count > indexPath.row{
                var subJson = self.courseArray[indexPath.row]
//                let status = subJson["lession_enroll_state"].stringValue.intValue
//                if status == 2{
//                    //已结束
//                    if subJson["video_id"].stringValue.trim.isEmpty{
//                        LYProgressHUD.showError("培训已结束，对应视频即将投放...")
//                    }else{
//                        let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
//                        videoPlayVC.videoId = subJson["video_id"].stringValue
//                        self.navigationController?.pushViewController(videoPlayVC, animated: true)
//                    }
//                }else{
                let courseDetailVC = CourseDetailViewController.spwan()
                courseDetailVC.courseId = subJson["lession_id"].stringValue
//                courseDetailVC.videoId = subJson["video_id"].stringValue
//                courseDetailVC.status = subJson["lession_enroll_state"].stringValue
                courseDetailVC.coursePaySuccessBlock = {(num) in
                    subJson["lession_enroll_state"] = JSON("1")
                    subJson["lession_num"] = JSON(String.init(format: "%d", subJson["lession_num"].stringValue.intValue + num))
                    self.courseArray.remove(at: indexPath.row)
                    self.courseArray.insert(subJson, at: indexPath.row)
                    self.leftTableView.reloadRows(at: [indexPath], with: .none)
                }
                self.navigationController?.pushViewController(courseDetailVC, animated: true)
//                }
            }
        }else if tableView == self.middleTableView{
            NetTools.qxfClickCount("11")
            //播放视频
            if self.videoArray.count > indexPath.row{
                let subJson = self.videoArray[indexPath.row]
                let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
                videoPlayVC.videoId = subJson["mv_id"].stringValue
                self.navigationController?.pushViewController(videoPlayVC, animated: true)
            }
        }else if tableView == self.rightTableView{
            NetTools.qxfClickCount("12")
            if self.knowledgeArray.count > indexPath.row{
                let subJson = self.knowledgeArray[indexPath.row]
                let detailVC = KnowledgeDetailViewController.spwan()
                detailVC.knowledgeId = subJson["post_id"].stringValue
                detailVC.dataChangeBlock = {[weak self] (result : JSON) in
                    //                    var params : [String : Any] = [:]
                    //                    params["post_id"] = subJson["post_id"].stringValue
                    //                    NetTools.requestData(type: .post, urlString: KnowledgeDetailApi, parameters: params, succeed: { (result, msg) in
                    self?.knowledgeArray.remove(at: indexPath.row)
                    self?.knowledgeArray.insert(result, at: indexPath.row)
                    self?.rightTableView.reloadRows(at: [indexPath], with: .automatic)
                    //                    }) { (error) in
                    //                    }
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView as? UITableView == self.middleTableView{
            self.currentOffsetY = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView{
            if self.discoverType == .discover{
                if scrollView.contentOffset.x == 0{
                    self.topBtnAction(self.courseBtn)
                }else if scrollView.contentOffset.x == scrollView.w{
                    self.topBtnAction(self.videoBtn)
                }else if scrollView.contentOffset.x == scrollView.w * 2{
                    self.topBtnAction(self.knowledgeBtn)
                }
            }
        }else if scrollView as? UITableView == self.rightTableView{
            self.showSortView(show: false)
            self.searchBar.resignFirstResponder()
        }else if scrollView as? UITableView == self.middleTableView{
            if self.searchBar.text != nil && self.searchBar.isFirstResponder{
                if self.searchBar.text!.isEmpty{
                    self.keyWord = ""
                    self.loadVideoData()
                }
            }
            self.searchBar.resignFirstResponder()

            if self.middleTableView.contentSize.height > self.middleTableView.h{
                let point = scrollView.panGestureRecognizer.translation(in: self.scrollView.superview)
                //视频筛选的隐藏与否
                if point.y > 0{
                    if self.currentOffsetY < scrollView.contentOffset.y{
                        self.videoSortViewH.constant = 0
                    }else{
                        self.videoSortViewH.constant = self.videoSortCollectionView.contentSize.height + 20
                    }
                }else{
                    if self.currentOffsetY < scrollView.contentOffset.y + self.videoSortCollectionView.contentSize.height + 20{
                        self.videoSortViewH.constant = 0
                    }else{
                        self.videoSortViewH.constant = self.videoSortCollectionView.contentSize.height + 20
                    }
                }
            }
        }
    }
    
}

extension DiscoverViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == sortCollectionView{
            self.sortViewH.constant = 200
            return 2
        }else{
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sortCollectionView{
            if section == 0{
                return self.knowledgeSortArray.count
            }else{
                if self.knowledgeSortArray.count > self.selectedSecOneIndex{
                    let smallList = self.knowledgeSortArray[self.selectedSecOneIndex]["smallList"].arrayValue
                    return smallList.count
                }
            }
            return 0
        }else{
            return self.videoSortArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sortCollectionView{
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "SortCollectionCell", for: indexPath)
            for view in item.subviews{
                view.removeFromSuperview()
            }
            var str = ""
            if indexPath.section == 0{
                if self.knowledgeSortArray.count > indexPath.row{
                    str = self.knowledgeSortArray[indexPath.row]["name"].stringValue
                }
            }else{
                if self.knowledgeSortArray.count > self.selectedSecOneIndex{
                    let smallList = self.knowledgeSortArray[self.selectedSecOneIndex]["smallList"].arrayValue
                    if smallList.count > indexPath.row{
                        str = smallList[indexPath.row]["name"].stringValue
                    }
                }
            }
            let lbl = UILabel(frame:item.bounds)
            lbl.textAlignment = .center
            lbl.font = UIFont.systemFont(ofSize: 14.0)
            lbl.textColor = UIColor.RGBS(s: 33)
            lbl.text = str
            item.addSubview(lbl)
            if indexPath.row == 0{
                if indexPath.section == 0{
                    self.secOneLbl.frame = CGRect.init(x: 0, y: item.y, width: self.sortLeftView.w, height: 25)
                }else{
                    self.secTwoLbl.frame = CGRect.init(x: 0, y: item.y, width: self.sortLeftView.w, height: 25)
                }
            }
            if indexPath.section == 1{
                let smallList = self.knowledgeSortArray[self.selectedSecOneIndex]["smallList"].arrayValue
                if indexPath.row == smallList.count - 1{
                    self.sortViewH.constant = item.frame.maxY + 30
                }
            }
            return item
        }else{
            let item  = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoSortCell", for: indexPath) as! VideoSortCell
            if self.videoSortArray.count > indexPath.row{
                let json = self.videoSortArray[indexPath.row]
                item.titleLbl.text = json["type_name"].stringValue
                
                item.bgImgV.image = #imageLiteral(resourceName: "login_btn_white")
                item.titleLbl.textColor = UIColor.RGB(r: 255, g: 86, b: 42)
                if self.selectedVideoSortIndex == indexPath.row{
                    item.bgImgV.image = #imageLiteral(resourceName: "login_btn_red")
                    item.titleLbl.textColor = UIColor.white
                }
            }
            return item
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //        if indexPath.row == 0{
    //            if indexPath.section == 0{
    //                self.secOneLbl.frame = CGRect.init(x: 0, y: cell.y, width: self.sortLeftView.w, height: 25)
    //            }else{
    //                self.secTwoLbl.frame = CGRect.init(x: 0, y: cell.y, width: self.sortLeftView.w, height: 25)
    //            }
    //        }else if indexPath.section == 1 && indexPath.row == 5{
    //            self.sortViewH.constant = cell.frame.maxY
    //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if collectionView == sortCollectionView{
            if indexPath.section == 0{
                if self.knowledgeSortArray.count > indexPath.row{
                    self.typeId = self.knowledgeSortArray[indexPath.row]["id"].stringValue
                    self.selectedSecOneIndex = indexPath.row
                    collectionView.reloadData()
                }
            }else{
                if self.knowledgeSortArray.count > self.selectedSecOneIndex{
                    let smallList = self.knowledgeSortArray[self.selectedSecOneIndex].arrayValue
                    if smallList.count > indexPath.row{
                        self.typeId = smallList[indexPath.row]["id"].stringValue
                    }
                    self.showSortView(show: false)
                }
            }
            self.loadKnowledgeData()
        }else{
            if self.videoSortArray.count > indexPath.row{
                self.selectedVideoSortIndex = indexPath.row
                let json = self.videoSortArray[indexPath.row]
                self.curpage2 = 1
                self.videoType = json["id"].stringValue
                self.loadVideoData()
                self.videoSortCollectionView.reloadData()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sortCollectionView{
            return CGSize.init(width: 70, height: 25)
        }else{
            return CGSize.init(width: 70, height: 25)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == sortCollectionView{
            return 1
        }else{
            return 4
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == sortCollectionView{
            return 2
        }else{
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == sortCollectionView{
            return CGSize.init(width: collectionView.w, height: 15)
        }else{
            return CGSize.zero
        }
        
    }
    
}


extension DiscoverViewController : UISearchBarDelegate{
    
    //
    func setUpRightItem(show : Bool) {
        if show{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_search"), target: self, action: #selector(DiscoverViewController.setUpSearchNavView))
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    //取消搜索
    func cancelAction() {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_search"), target: self, action: #selector(DiscoverViewController.setUpSearchNavView))
        if self.discoverType == .course{
            self.navigationItem.title = "最新培训"
        }else if self.discoverType == .choiceness{
            self.navigationItem.title = "本周精选"
        }else{
            self.navigationItem.title = "发现"
        }
        if self.searchBar.isFirstResponder{
            self.searchBar.resignFirstResponder()
        }
        searchBar.text = ""
        self.keyWord = ""
        self.curpage2 = 1
        self.curpage3 = 1
        //        self.loadData()
        if self.videoBtn.isSelected{
            self.loadVideoData()
        }else if self.knowledgeBtn.isSelected{
            self.loadKnowledgeData()
        }
    }
    
    //设置搜索框
    @objc func setUpSearchNavView() {
        searchBar.placeholder = "请输入关键字搜索"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text?.isEmpty)!{
            self.keyWord = searchBar.text!
            self.curpage2 = 1
            self.curpage3 = 1
            //            self.loadData()
            if self.videoBtn.isSelected{
                self.loadVideoData()
            }else if self.knowledgeBtn.isSelected{
                self.loadKnowledgeData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelAction()
    }
    
    
}
