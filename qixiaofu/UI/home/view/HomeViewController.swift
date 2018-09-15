//
//  HomeViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class HomeViewController: BaseViewController {
    class func spwan() -> HomeViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! HomeViewController
    }
    
    @IBOutlet weak var contentViewH: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewH: NSLayoutConstraint!
    @IBOutlet weak var recommendView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewH: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var orderViewH: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftImgV: UIImageView!
    @IBOutlet weak var leftNameLbl: UILabel!
    @IBOutlet weak var leftTimeLbl: UILabel!
    @IBOutlet weak var rightImgV: UIImageView!
    @IBOutlet weak var rightNameLbl: UILabel!
    @IBOutlet weak var rightTimeLbl: UILabel!
    
    fileprivate var currentOffsetY : CGFloat = 0//最新订单列表的offset
    var timer : Timer?
    fileprivate var isAutoScrolling = true
    
    fileprivate lazy var bannerView1 : LYAnimateBannerView = {
        let bannerView = LYAnimateBannerView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenW * 320 / 750), delegate: self)
        bannerView.backgroundColor = UIColor.white
        bannerView.showPageControl = true
        return bannerView
    }()
    
    fileprivate lazy var bannerView2 : LYUpScrollBannerView = {
        let bannerView = LYUpScrollBannerView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 44), delegate: self)
        bannerView.backgroundColor = UIColor.white
        return bannerView
    }()
    fileprivate var class_list : JSON = []//公告
    fileprivate var banner_list : JSON = []//顶部banner
    fileprivate var notice_list : JSON = []//公告
    fileprivate var hot_list : JSON = []//精选
    fileprivate var new_list : JSON = []//最新
    fileprivate var allbill_list : JSON = []//最新订单
    fileprivate var transaction_list : JSON = []//成交信息
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.addSubview(self.bannerView1)
        self.recommendView.addSubview(self.bannerView2)
        
        self.tableView.register(UINib.init(nibName: "HomeTaskCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeTaskCell")
        self.leftImgV.layer.cornerRadius = 3
        self.rightImgV.layer.cornerRadius = 3
        
        self.setUpMainView()
        
        //优惠券大礼包
        self.loadCouponGiftData()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //加载数据
        self.loadMainData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bannerView1.timer?.invalidate()
        self.bannerView2.timer?.invalidate()
        self.removeTimer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func moreTaskAction() {
        //去接单
        let taskVC = TaskListViewController.spwan()
        taskVC.isHomeAllTaskList = true
        self.navigationController?.pushViewController(taskVC, animated: true)
    }
    @IBAction func moreChoicenessAction() {
        //沙龙
        let courseVC = HomeMoreCourseController()
        self.navigationController?.pushViewController(courseVC, animated: true)
    }
    
    
}

extension HomeViewController{
    
    override func setUpMainView() {
        //        super.setUpMainView()
        
        self.headerViewH.constant = kScreenW * 320 / 750
        //Collection的布局设置
        self.setUpCollectionFlowLayout()
        //titleview
        self.navigationItem.title = "七小服"
        //二维码
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "scan_icon"), target: self, action: #selector(HomeViewController.leftItemAction))
    }
    
    
    //Collection的布局设置
    func setUpCollectionFlowLayout() {
        self.collectionView.register(UINib.init(nibName: "HomeCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        
        let layout = UICollectionViewFlowLayout()
        //        let w = (kScreenW - 20) / 4 - 2
        let w = 70
        let merge = (kScreenW - 280) / 5 - 1
        layout.itemSize = CGSize(width:w, height:w)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = merge
        layout.sectionInset = UIEdgeInsets(top: 10,left: merge,bottom: 10,right: merge)
        
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    
    //轮播图-banner
    func setUpBannerView() {
        var bannerArray3 = Array<String>()
        for subJson : JSON in self.banner_list.arrayValue {
            bannerArray3.append(subJson["banner_img"].stringValue)
        }
        self.bannerView1.imageUrlArray = bannerArray3
    }
    //轮播图-公告
    func setUpBannerView2() {
        var bannerArray4 = Array<String>()
        for subJson : JSON in self.notice_list.arrayValue {
            bannerArray4.append(subJson["notice_title"].stringValue)
        }
        //        self.bannerView2.titleArray = bannerArray4
        self.bannerView2.transactionArray = self.transaction_list
        
    }
    //message
    @objc func rightItemAction(){
        let messageVC = MessageViewController()
        self.navigationController?.pushViewController(messageVC, animated: true)
    }
    
    //加载数据
    func loadMainData() {
        NetTools.requestData(type: .post, urlString: HomeMainNewApi, succeed: { (resultDict, error) in
            self.loadDataFinished()
            self.class_list = resultDict["main_list"]
            self.hot_list = resultDict["hot"]
            self.new_list = resultDict["new_list"]
            self.banner_list = resultDict["banner"]
            self.notice_list = resultDict["notice"]
            self.allbill_list = resultDict["data_allbill_list"]
            self.transaction_list = resultDict["data_shouyilog_list"]
            
            //collection view height
            if self.class_list.arrayValue.count > 4{
                self.collectionViewH.constant = CGFloat(70 * 2 + 22)
            }else{
                self.collectionViewH.constant = CGFloat(70 + 22)
            }
            
            /*
             新首页第一版本的写法
             var height : CGFloat = 0
             //先清理底部视图
             for view in self.bottomView.subviews{
             view.removeFromSuperview()
             }
             //底部视图
             if self.new_list.arrayValue.count == 1{
             self.bottomView.addSubview(self.createBottomView(CGRect.init(x: 0, y: 5, width: kScreenW, height: 250), 1))
             height += 250
             }else if self.new_list.arrayValue.count == 2{
             self.bottomView.addSubview(self.createBottomView(CGRect.init(x: 0, y: 5, width: kScreenW, height: 200), 1))
             height += 200
             }
             if self.hot_list.arrayValue.count == 1{
             self.bottomView.addSubview(self.createBottomView(CGRect.init(x: 0, y: 210, width: kScreenW, height: 250), 2))
             height += 250
             }else if self.hot_list.arrayValue.count == 2{
             self.bottomView.addSubview(self.createBottomView(CGRect.init(x: 0, y: 210, width: kScreenW, height: 200), 2))
             height += 200
             }
             */
            
            //刷新最新订单
            self.tableView.reloadData()
            if self.allbill_list.arrayValue.count > 0{
                self.orderView.isHidden = false
                if self.allbill_list.arrayValue.count > 4{
                    self.orderViewH.constant = 144
                }else{
                    self.orderViewH.constant = CGFloat(self.allbill_list.arrayValue.count * 25 + 44)
                }
            }else{
                self.orderView.isHidden = true
                self.orderViewH.constant = 0
            }
            //autoscroll
            self.addTimer()
            
            //本周精选
            if self.new_list.arrayValue.count == 2{
                let json1 = self.new_list.arrayValue[0]
                let json2 = self.new_list.arrayValue[1]
                self.leftImgV.setImageUrlStr(json1["img"].stringValue)
                self.leftNameLbl.text = json1["name"].stringValue
                self.leftTimeLbl.text = Date.dateStringFromDate(format: Date.dateFormatString(), timeStamps: json1["start_time"].stringValue)
                self.rightImgV.setImageUrlStr(json2["img"].stringValue)
                self.rightNameLbl.text = json2["name"].stringValue
                self.rightTimeLbl.text = Date.dateStringFromDate(format: Date.dateFormatString(), timeStamps: json2["start_time"].stringValue)
                
                self.leftImgV.addTapActionBlock(action: {
                    let courseDetailVC = HomeCourseDetailViewController.spwan()
                    courseDetailVC.courseId = json1["id"].stringValue
                    self.navigationController?.pushViewController(courseDetailVC, animated: true)
                })
                self.rightImgV.addTapActionBlock(action: {
                    let courseDetailVC = HomeCourseDetailViewController.spwan()
                    courseDetailVC.courseId = json2["id"].stringValue
                    self.navigationController?.pushViewController(courseDetailVC, animated: true)
                })
            }
            
            
            //轮播图
            self.setUpBannerView()
            self.setUpBannerView2()
            //刷新collection
            self.collectionView.reloadData()
            
            //本周精选里面图片高度
            let imgH = (kScreenW - 24) / 2.0 * 9 / 16
            let bottomViewH = imgH + 91
            self.bottomView.h = bottomViewH
            //headerview高度=200，纯collectioncell高度collecViewH, 44公告高度，self.orderViewH.constant最新订单，self.bottomView的高度
            self.contentViewH.constant = self.headerViewH.constant + self.collectionViewH.constant + 44 + self.orderViewH.constant + bottomViewH
            
        }) { (error) in
            self.loadDataFinished()
            LYProgressHUD.showError(error!)
        }
    }
    
    //MARK：最新订单位置的自动滚动
    //设置定时器
    func addTimer()  {
        //        DispatchQueue.main.async {
        //            self.tableView.contentOffset = CGPoint.zero
        //            UIView.animate(withDuration: 10, animations: {
        //                self.tableView.contentOffset = CGPoint.init(x: 0, y: self.tableView.contentSize.height-self.tableView.height)
        //            }, completion: { (completion) in
        //                self.addTimer()
        //            })
        //        }
        self.removeTimer()
        if self.allbill_list.arrayValue.count <= 4{
            return
        }
        self.currentOffsetY = self.tableView.contentOffset.y
        self.timer = Timer(timeInterval: 1, target: self, selector: #selector(LYUpScrollBannerView.nextPage), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .defaultRunLoopMode)
        timer!.fire()
        self.isAutoScrolling = true
    }
    //移除定时器
    func removeTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.tableView.contentOffset = CGPoint.zero
        self.currentOffsetY = 0
    }
    
    @objc func nextPage() {
        if !self.isAutoScrolling{
            return
        }
        self.currentOffsetY += 25
        if self.currentOffsetY > (self.tableView.contentSize.height - self.tableView.h){
            self.currentOffsetY = 0
        }
        
        self.tableView.scrollRectToVisible(CGRect.init(x: 0, y: self.currentOffsetY, width: self.tableView.w, height: self.tableView.h), animated: true)
    }
    
    /*
     老版本的首页接口
     NetTools.requestData(type: .post, urlString: HomeMainApi, succeed: { (resultDict, error) in
     self.loadDataFinished()
     self.class_list = resultDict["class_list"]
     self.bill_list = resultDict["bill_list"]
     self.member_list = resultDict["member_list"]
     self.eng_banner_list = resultDict["eng_banner_list"]
     self.banner_list = resultDict["banner_list"]
     self.notice_list = resultDict["notice_list"]
     //轮播图
     self.setUpBannerView()
     self.setUpBannerView2()
     //刷新collection
     self.collectionView.reloadData()
     
     var collecViewH : CGFloat = 0
     if kScreenW == 320{
     if self.class_list.arrayValue.count % 3 == 0{
     collecViewH = CGFloat(self.class_list.arrayValue.count / 3 * 100)
     }else{
     collecViewH = CGFloat(self.class_list.arrayValue.count / 3 * 100 + 100)
     }
     }else{
     if self.class_list.arrayValue.count % 4 == 0{
     collecViewH = CGFloat(self.class_list.arrayValue.count / 4 * 100)
     }else{
     collecViewH = CGFloat(self.class_list.arrayValue.count / 4 * 100 + 100)
     }
     }
     //headerview高度=200，纯collectioncell高度collecViewH，collectionview的内边距top10,bottom10
     self.contentViewH.constant = self.headerViewH.constant + collecViewH + 20
     
     }) { (error) in
     self.loadDataFinished()
     LYProgressHUD.showError(error!)
     }
     }
     */
    
}
/*
 //MARK: - 底部页面搭建
 extension HomeViewController{
 //type: 1:最新培训。2:本周精选
 func createBottomView(_ rect:CGRect, _ type:Int) -> UIView{
 let view = UIView(frame:rect)
 //1、title & more btn
 let tipView = UIView(frame:CGRect.init(x: 10, y: 12, width: 2, height: 12))
 tipView.backgroundColor = Normal_Color
 view.addSubview(tipView)
 let moreBtn = UIButton(frame:CGRect.init(x: kScreenW-70, y: 8, width: 70, height: 25))
 moreBtn.tag = type
 moreBtn.setTitle("更多>>", for: .normal)
 moreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
 moreBtn.contentMode = .right
 moreBtn.setTitleColor(UIColor.darkGray, for: .normal)
 moreBtn.addTarget(self, action: #selector(HomeViewController.moreBtnAction(btn:)), for: .touchUpInside)
 view.addSubview(moreBtn)
 let titleLbl = UILabel(frame:CGRect.init(x: 18, y: 8, width: kScreenW - 120, height: 21))
 if type == 2{
 titleLbl.text = "最新培训"
 }else{
 titleLbl.text = "本周精选"
 }
 titleLbl.textColor = UIColor.darkGray
 titleLbl.font = UIFont.systemFont(ofSize: 14.0)
 view.addSubview(titleLbl)
 //2、images
 if type == 1{
 func goToCourseDetail(json : JSON){
 if json["type"].stringValue.intValue == 1{
 let courseDetailVC = HomeCourseDetailViewController.spwan()
 courseDetailVC.courseId = json["id"].stringValue
 self.navigationController?.pushViewController(courseDetailVC, animated: true)
 }else{
 let courseDetailVC = CourseDetailViewController.spwan()
 courseDetailVC.courseId = json["id"].stringValue
 //                    courseDetailVC.videoId = json["mv_id"].stringValue
 self.navigationController?.pushViewController(courseDetailVC, animated: true)
 }
 }
 if self.new_list.arrayValue.count == 1 {
 let json = self.new_list.arrayValue[0]
 let singleView = self.createItemView(rect: CGRect.init(x: 15, y: 40, width: kScreenW-30, height: 200), imageUrl: json["img"].stringValue, name: json["name"].stringValue, time: json["start_time"].stringValue)
 singleView.addTapActionBlock(action: {
 goToCourseDetail(json: json)
 })
 view.addSubview(singleView)
 }else if self.new_list.arrayValue.count == 2{
 let json1 = self.new_list.arrayValue[0]
 let json2 = self.new_list.arrayValue[1]
 let view1 = self.createItemView(rect: CGRect.init(x: 15, y: 40, width: (kScreenW-40)/2.0, height: 150), imageUrl: json1["img"].stringValue, name: json1["name"].stringValue, time: json1["start_time"].stringValue)
 let view2 = self.createItemView(rect: CGRect.init(x: 15 + (kScreenW-30)/2.0 + 5, y: 40, width: (kScreenW-40)/2.0, height: 150), imageUrl: json2["img"].stringValue, name: json2["name"].stringValue, time: json2["start_time"].stringValue)
 view1.addTapActionBlock(action: {
 goToCourseDetail(json: json1)
 })
 view2.addTapActionBlock(action: {
 goToCourseDetail(json: json2)
 })
 view.addSubview(view1)
 view.addSubview(view2)
 }
 }else{
 func goToVideoDetail(json : JSON){
 let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
 videoPlayVC.videoId = json["mv_id"].stringValue
 self.navigationController?.pushViewController(videoPlayVC, animated: true)
 }
 if self.hot_list.arrayValue.count == 1 {
 let json = self.hot_list.arrayValue[0]
 let singleView = self.createItemView(rect: CGRect.init(x: 15, y: 40, width: kScreenW-30, height: 200), imageUrl: json["mv_img"].stringValue, name: json["mv_name"].stringValue, time: json["mv_time"].stringValue)
 singleView.addTapActionBlock(action: {
 goToVideoDetail(json: json)
 })
 view.addSubview(singleView)
 }else if self.hot_list.arrayValue.count == 2{
 let json1 = self.hot_list.arrayValue[0]
 let json2 = self.hot_list.arrayValue[1]
 let view1 = self.createItemView(rect: CGRect.init(x: 15, y: 40, width: (kScreenW-40)/2.0, height: 150), imageUrl: json1["mv_img"].stringValue, name: json1["mv_name"].stringValue, time: json1["mv_time"].stringValue)
 let view2 = self.createItemView(rect: CGRect.init(x: 15 + (kScreenW-30)/2.0 + 5, y: 40, width: (kScreenW-40)/2.0, height: 150), imageUrl: json2["mv_img"].stringValue, name: json2["mv_name"].stringValue, time: json2["mv_time"].stringValue)
 view1.addTapActionBlock(action: {
 goToVideoDetail(json: json1)
 })
 view2.addTapActionBlock(action: {
 goToVideoDetail(json: json2)
 })
 view.addSubview(view1)
 view.addSubview(view2)
 }
 }
 view.backgroundColor = UIColor.white
 return view
 }
 
 func createItemView(rect:CGRect, imageUrl:String, name:String, time:String) -> UIView {
 let view = UIView(frame:rect)
 let singleImgV = UIImageView(frame:CGRect.init(x: 0, y: 0, width: rect.width, height: rect.height-50))
 singleImgV.setImageUrlStr(imageUrl)
 singleImgV.clipsToBounds = true
 singleImgV.layer.cornerRadius = 5
 singleImgV.contentMode = .scaleAspectFill
 view.addSubview(singleImgV)
 let lbl1 = UILabel(frame:CGRect.init(x: 0, y: rect.height-45, width: rect.width, height: 21))
 lbl1.text = name
 lbl1.textColor = UIColor.RGBS(s: 33)
 lbl1.font = UIFont.systemFont(ofSize: 14.0)
 view.addSubview(lbl1)
 let lbl2 = UILabel(frame:CGRect.init(x: 0, y: rect.height-25, width: rect.width, height: 21))
 lbl2.text = Date.dateStringFromDate(format: Date.dateFormatString(), timeStamps: time)
 lbl2.textColor = UIColor.darkGray
 lbl2.font = UIFont.systemFont(ofSize: 12.0)
 view.addSubview(lbl2)
 return view
 }
 
 //btn action
 @objc func moreBtnAction(btn : UIButton) {
 if btn.tag == 1{
 let courseVC = HomeMoreCourseController()
 self.navigationController?.pushViewController(courseVC, animated: true)
 }else if btn.tag == 2{
 let discoverVC = DiscoverViewController.spwan()
 discoverVC.discoverType = .choiceness
 self.navigationController?.pushViewController(discoverVC, animated: true)
 }
 }
 }
 */

//LYBannerViewDelegate
extension HomeViewController : LYAnimateBannerViewDelegate, LYUpScrollBannerViewDelegate{
    
    func LY_UpScrollBannerViewClick(index: NSInteger) {
        NetTools.qxfClickCount("5")
        //        if self.notice_list.arrayValue.count > index{
        //            let json = self.notice_list.arrayValue[index]
        //            let noticeDetailVC = NoticeDetailViewController.spwan()
        //            noticeDetailVC.noticeId = json["notice_id"].stringValue
        //            noticeDetailVC.noticeTitle = json["notice_title"].stringValue
        //            self.navigationController?.pushViewController(noticeDetailVC, animated: true)
        //        }
    }
    
    func LY_AnimateBannerViewClick(banner:LYAnimateBannerView, index: NSInteger) {
        NetTools.qxfClickCount("4")
        if self.banner_list.count > index{
            let subJson = self.banner_list[index]
            if subJson["url"].stringValue.trim.isEmpty{
                return
            }
            let webVC = BaseWebViewController.spwan()
            webVC.urlStr = subJson["banner_jump"].stringValue
            webVC.titleStr = subJson["banner_name"].stringValue
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
}

// MARK: UICollectionViewDelegate,UICollectionViewDataSource
extension HomeViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.class_list.arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item : HomeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        if self.class_list.arrayValue.count > indexPath.row{
            let json = self.class_list.arrayValue[indexPath.row]
            item.titleLbl.text = json["list_name"].stringValue
            item.iconImgV.setImageUrlStr(json["list_img"].stringValue)
            if LocalData.ContentPointNum(num: json["sort_type"].stringValue.intValue){
                item.redPointView.isHidden = false
            }else{
                item.redPointView.isHidden = true
            }
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        NetTools.qxfClickCount("3")
        if self.class_list.arrayValue.count > indexPath.row{
            let subJson = self.class_list[indexPath.row]
            let list_type = subJson["list_type"].stringValue//1:本地 2:web
            if list_type.intValue == 2{
                let webVC = BaseWebViewController.spwan()
                webVC.urlStr = subJson["sort_url"].stringValue
                webVC.titleStr = subJson["list_name"].stringValue
                self.navigationController?.pushViewController(webVC, animated: true)
            }else{
                let sort_type = subJson["sort_type"].stringValue
                if sort_type.isEmpty{
                    return
                }
                functionSkipAction(type: sort_type, controller: self)
            }
        }
        
    }
}

extension HomeViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allbill_list.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTaskCell", for: indexPath) as! HomeTaskCell
        if self.allbill_list.arrayValue.count > indexPath.row{
            let json = self.allbill_list.arrayValue[indexPath.row]
            cell.nameLbl.text = "[" + json["service_city"].stringValue + "]" + json["entry_name"].stringValue
            cell.priceLbl.text = "服务价格:¥" + json["service_price"].stringValue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.allbill_list.arrayValue.count > indexPath.row{
            let jsonModel = self.allbill_list.arrayValue[indexPath.row]
            let detailVC = TaskReceiveDetailViewController.spwan()
            detailVC.task_id = jsonModel["id"].stringValue
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView as? UITableView == self.tableView{
            self.isAutoScrolling = false
            self.removeTimer()
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView as? UITableView == self.tableView{
            self.addTimer()
        }
    }
}


extension HomeViewController{
    //二维码扫描
    @objc func leftItemAction() {
        let scanVC = ScanActionViewController()
        scanVC.scanResultBlock = {(result) in
            if result.trim == "http://www.7xiaofu.com/download/popularize/qixiaofuPopularize.html" || result.trim == "rechargebean" || result.trim.lowercased().contains("rechargebean") || result.trim.lowercased().contains("qixiaofuPopularize"){
                //充值
                let rechargeVC = RechargeViewController.spwan()
                rechargeVC.vcType = 3
                self.navigationController?.pushViewController(rechargeVC, animated: true)
            }else if result.trim == "qixiaofu-breakfast"{
                //早餐扫码
                let localVersion = appVersion().replacingOccurrences(of: ".", with: "").intValue
                let params : [String : Any] = [
                    "version_num" : localVersion,
                    "client" : "ios"
                ]
                NetTools.requestData(type: .post, urlString: HaveBreakfastApi, parameters: params, succeed: { (result, msg) in
                    self.playAudio(result["type"].stringValue)
                }) { (error) in
                    LYProgressHUD.showError(error ?? "扫码发生错误，请重试！")
                }
            }else if result.trim.lowercased().contains("tp.php/Home/Core/sweep_qrcode".lowercased()) {
                //http://10.216.2.11/tp.php/Home/Core/sweep_qrcode?id=15
                let arr = result.trim.components(separatedBy: "=")
                if arr.count == 2{
                    let id = arr[1]
                    let testReportVC = TestReportPictureViewController.spwan()
                    testReportVC.testId = id
                    self.navigationController?.pushViewController(testReportVC, animated: true)
                }
            }else{
                let url = URL(string:result)
                if url != nil{
                    if UIApplication.shared.canOpenURL(url!){
                        UIApplication.shared.openURL(url!)
                    }
                }
            }
        }
        
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    //播放音频 type: 1、请用早餐 2、提示升级App 3、非用餐时间 4、请用午餐 5 晚餐
    func playAudio(_ type : String) {
        if type.intValue == 1{
            //请用餐
            LYProgressHUD.showError("早上好，请用餐！")
            guard let path = Bundle.main.path(forResource: "have_breakfast", ofType: ".mp3") else{
                return
            }
            let fileUrl = URL.init(fileURLWithPath: path)
            var soundID : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
            AudioServicesPlayAlertSound(soundID)
        }else if type.intValue == 2{
            //提示升级App
            LYProgressHUD.showError("请升级App后重新扫码！")
            guard let path = Bundle.main.path(forResource: "rescan", ofType: ".mp3") else{
                return
            }
            let fileUrl = URL.init(fileURLWithPath: path)
            var soundID : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
            AudioServicesPlayAlertSound(soundID)
        }else if type.intValue == 3{
            //非用餐时间
            LYProgressHUD.showError("非用餐时间，此次扫码无效")
        }else if type.intValue == 4{
            //午餐
            LYProgressHUD.showError("中午好，请用餐！")
            guard let path = Bundle.main.path(forResource: "have_lunch", ofType: ".mp3") else{
                return
            }
            let fileUrl = URL.init(fileURLWithPath: path)
            var soundID : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
            AudioServicesPlayAlertSound(soundID)
        }else if type.intValue == 5{
            //晚餐
            LYProgressHUD.showError("晚上好，请用餐！")
            guard let path = Bundle.main.path(forResource: "have_dinner", ofType: ".mp3") else{
                return
            }
            let fileUrl = URL.init(fileURLWithPath: path)
            var soundID : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
            AudioServicesPlayAlertSound(soundID)
        }else{
            LYProgressHUD.showError("未知操作，请联系管理员！")
        }
        
    }
    
}

//MARK :- 优惠券大礼包
extension HomeViewController {
    func loadCouponGiftData() {
        if LocalData.getUserPhone().isEmpty{
            return
        }
        var params : [String : Any] = [:]
        params["mobile"] = LocalData.getUserPhone()
        params["type"] = "1"//分类 (1 个人   2企业)
        NetTools.requestData(type: .post, urlString: CouponGiftBagApi, parameters: params, succeed: { (resultJson, msg) in
            SendCouponView.showWithJson(resultJson)
        }) { (error) in
        }
        
    }
    
    
    
}












