//
//  ShopViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Photos


class ShopViewController: BaseViewController ,WXApiDelegate{
    class func spwan() -> ShopViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! ShopViewController
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    @IBOutlet weak var suspendTableView: UITableView!
    @IBOutlet weak var suspendTopDis: NSLayoutConstraint!
    @IBOutlet weak var suspendTableH: NSLayoutConstraint!
    @IBOutlet weak var blackBgBtn: UIButton!
    @IBOutlet weak var emptyImgV: UIView!
    
    fileprivate let searchBar : UISearchBar = UISearchBar()
    
    fileprivate var leftDataArray : JSON = []
    fileprivate var suspendDataArray : JSON = []
    fileprivate var rightDataArray : Array<JSON> = Array<JSON>()
    fileprivate var pluginDataArray : Array<JSON> = Array<JSON>()
    fileprivate var bannerListArray : Array<JSON> = Array<JSON>()
    fileprivate var haveMore = true
    fileprivate lazy var shopCarBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kScreenW-120, y: kScreenH-150, width: 60, height: 60)
        btn.setImage(#imageLiteral(resourceName: "shop_car_icon"), for: .normal)
        btn.addTarget(self, action: #selector(ShopViewController.goShopCar), for: .touchUpInside)
        return btn
    }()//购物车按钮
    
    
    /**
     企业采购-----开始
     */
    //商品分类和banner 的json数据
    fileprivate var epClassicJson = JSON()
    
    
    /**
     企业采购-----结束
     */
    
    fileprivate var curPage = 1
    fileprivate var gcId = "0"
    
    fileprivate var selectedLeftRow = 0
    
    fileprivate var isPlugInShow = false
    
    fileprivate var ocrVC : UIViewController?
    
    
    fileprivate lazy var bannerView : LYAnimateBannerView = {
        let bannerView = LYAnimateBannerView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenW * 320 / 750), delegate: self)
        bannerView.backgroundColor = UIColor.white
        bannerView.showPageControl = true
        self.topView.addSubview(bannerView)
        return bannerView
    }()
    
    //隐藏状态栏
    fileprivate var isStatusBarHidden = false{
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    fileprivate var photoView : LYPhotoBrowseView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *){
            self.leftTableView.contentInsetAdjustmentBehavior = .never
            self.rightTableView.contentInsetAdjustmentBehavior = .never
            self.suspendTableView.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.topViewH.constant = kScreenW * 320 / 750
        
        self.rightTableView.register(UINib.init(nibName: "CollectGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "CollectGoodsCell")
        self.leftTableView.register(UINib.init(nibName: "LeftCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "LeftCategoryCell")
        self.suspendTableView.register(UINib.init(nibName: "LeftCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "LeftCategoryCell")
        
        self.addRefresh()
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            self.gcId = "266"
        }
        
        self.setUpSearchNavView()
        
        
        //百度OCR身份认证
        AipOcrService.shard().auth(withAK: "nGMwZNOcsVQIUkdbpkHShXUm", andSK: "iiUto12cC9cNmwrwDtlyzGOUAaujCDD4")
    }
    
    //隐藏状态栏
    override var prefersStatusBarHidden: Bool{
        return self.isStatusBarHidden
    }
    
    func setUpSearchNavView() {
        searchBar.placeholder = "请输入品牌、名称、类别等搜索"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "photo"), target: self, action: #selector(ShopViewController.rightItemAction))
    }
    
    @objc func rightItemAction(){
        self.camera()
//        let sheet = UIActionSheet.init(title: "识别图片", delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: nil, otherButtonTitles: "相册", "拍照")
//        sheet.show(in: self.view)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            self.loadEpClassicData()
            self.loadEpGoodsList()
        }else{
            self.loadRightData()
            self.loadLeftData()
        }
        self.setUpShopCarBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            //返回按钮
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(ShopViewController.backClick))
        }else{
            self.navigationItem.leftBarButtonItem = nil
        }
        
        
    }
    
    @objc func backClick() {
        AppDelegate.sharedInstance.resetRootViewController(1)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideSuspendTable()
        self.bannerView.timer?.invalidate()
        
        self.removeShopCarBtn()
    }
    
    
    @IBAction func hideSuspendTable() {
        self.suspendTableView.isHidden = true
        self.blackBgBtn.isHidden = true
        
    }
    
    func showSuspendTable() {
        self.suspendTableView.isHidden = false
        self.blackBgBtn.isHidden = false
        if self.suspendDataArray.count * 55 > 220{
            self.suspendTableH.constant = 220
        }else{
            self.suspendTableH.constant = CGFloat(self.suspendDataArray.count * 55)
        }
        self.leftTableView.contentSize = CGSize.init(width: self.leftTableView.contentSize.width, height: CGFloat(55 * (self.selectedLeftRow + 1 + self.suspendDataArray.count)))
        //        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
        //            self.leftTableView.contentSize = CGSize.init(width: self.leftTableView.contentSize.width, height: CGFloat(55 * (self.epClassicJson.arrayValue.count + self.suspendDataArray.count)))
        //        }else{
        //            self.leftTableView.contentSize = CGSize.init(width: self.leftTableView.contentSize.width, height: CGFloat(55 * (self.leftDataArray.count + self.suspendDataArray.count)))
        //        }
    }
}


//MARK: - loadData
extension ShopViewController {
    //1.左侧列表数据,banner数据
    func loadLeftData() {
        var params : [String : Any] = [:]
        params["store_id"] = "1"
        params["gc_id"] = "0"
        //        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: ShopCategoryDataApi,parameters: params, succeed: { (resultJson, msg) in
            //设置banner的图片
            var bannerUrls : Array<String> = Array()
            self.bannerListArray.removeAll()
            for subJson in resultJson["banner_list"].arrayValue{
                bannerUrls.append(subJson["banner_image"].stringValue)
                self.bannerListArray.append(subJson)
            }
            //            if bannerUrls.count <= 1{
            //                self.bannerView.showPageControl = false
            //            }
            self.bannerView.imageUrlArray = bannerUrls
            
            //左侧列表数据
            self.leftDataArray = resultJson["class_list"]
            if self.leftDataArray.arrayValue.count > 0{
                self.leftTableView.reloadData()
            }
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    
    //2.悬浮列表数据
    func loadSuspendDataWithGcId(gcId : String) {
        var params : [String : Any] = [:]
        params["store_id"] = "1"
        params["gc_id"] = gcId
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: ShopCategoryDataApi,parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            //左侧列表数据
            self.suspendDataArray = resultJson["class_list"]
            if self.suspendDataArray.arrayValue.count > 0{
                self.scrollViewDidScroll(self.leftTableView)
                self.showSuspendTable()
                if self.suspendDataArray.arrayValue.count > 0{
                    self.suspendTableView.reloadData()
                }
            }else{
                self.hideSuspendTable()
            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //
    func addRefresh() {
        self.rightTableView.es.addPullToRefresh {
            [weak self] in
            self?.curPage = 1
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self?.loadEpGoodsList()
            }else{
                if (self?.isPlugInShow)!{
                    self?.loadPluginData()
                }else{
                    self?.loadRightData()
                }
            }
        }
        
        //        self.rightTableView.es.addInfiniteScrolling {
        //            [weak self] in
        //            self?.curPage += 1
        //            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
        //                self?.loadEpGoodsList()
        //            }else{
        //                if (self?.isPlugInShow)!{
        //                    self?.loadPluginData()
        //                }else{
        //                    self?.loadRightData()
        //                }
        //            }
        //        }
    }
    
    //3.右侧列表数据
    func loadRightData() {
        var params : [String : Any] = [:]
        params["store_id"] = "1"//店铺ID
        params["gc_id"] = self.gcId//商品分类ID
        params["key"] = "4"// 排序类型【1:销量】【2:人气（访问量）】【3:价格】【4:新品】
        params["order"] = "2"//排序方式【1:升序】【2:降序】
        params["curpage"] = "\(self.curPage)"//页数
        //        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: ShopGoodsListApi, parameters: params, succeed: { (resultJson, msg) in
            //            self.rightDataArray = resultJson["goods_list"]
            if self.curPage == 1{
                self.rightTableView.es.stopPullToRefresh()
                self.rightDataArray.removeAll()
            }else{
                self.rightTableView.es.stopLoadingMore()
            }
            for subJson in resultJson["goods_list"].arrayValue{
                self.rightDataArray.append(subJson)
            }
            
            //判断是否有更多
            if resultJson["goods_list"].arrayValue.count < 10{
                self.rightTableView.es.noticeNoMoreData()
                self.haveMore = false
            }else{
                self.rightTableView.es.resetNoMoreData()
                self.haveMore = true
            }
            
            if self.rightDataArray.count > 0{
                self.emptyImgV.isHidden = true
                self.rightTableView.reloadData()
            }else{
                self.emptyImgV.isHidden = false
            }
            
            
            LYProgressHUD.dismiss()
        }) { (error) in
            if self.curPage == 1{
                self.rightTableView.es.stopPullToRefresh()
            }else{
                self.rightTableView.es.stopLoadingMore()
            }
            LYProgressHUD.showError(error!)
        }
    }
    
    
    //插件列表数据
    func loadPluginData() {
        var params : [String : Any] = [:]
        params["curpage"] = "\(self.curPage)"//页数
        NetTools.requestData(type: .post, urlString: PluginListApi, parameters: params, succeed: { (result, msg) in
            if self.curPage == 1{
                self.rightTableView.es.stopPullToRefresh()
                self.pluginDataArray.removeAll()
            }else{
                self.rightTableView.es.stopLoadingMore()
            }
            for subJson in result.arrayValue{
                self.pluginDataArray.append(subJson)
            }
            
            //判断是否有更多
            if result.arrayValue.count < 10{
                self.rightTableView.es.noticeNoMoreData()
                self.haveMore = false
            }else{
                self.rightTableView.es.resetNoMoreData()
                self.haveMore = true
            }
            
            if self.pluginDataArray.count > 0{
                self.emptyImgV.isHidden = true
                self.rightTableView.reloadData()
            }else{
                self.emptyImgV.isHidden = false
            }
            
        }) { (error) in
            if self.curPage == 1{
                self.rightTableView.es.stopPullToRefresh()
            }else{
                self.rightTableView.es.stopLoadingMore()
            }
            LYProgressHUD.showError(error!)
        }
        
    }
    
    //企业采购---商品分类和banner
    func loadEpClassicData() {
        //        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: EPShopClassicApi, succeed: { (resultJson, msg) in
            //设置banner的图片
            var bannerUrls : Array<String> = Array()
            self.bannerListArray.removeAll()
            for subJson in resultJson["banner"].arrayValue{
                bannerUrls.append(subJson["banner_img"].stringValue)
                self.bannerListArray.append(subJson)
            }
            self.bannerView.imageUrlArray = bannerUrls
            //左侧列表数据
            self.epClassicJson = resultJson["type"]
            if self.epClassicJson.arrayValue.count > 0{
                self.leftTableView.reloadData()
            }
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //企业采购---商品列表接口
    func loadEpGoodsList() {
        var params : [String : Any] = [:]
        params["gc_id"] = self.gcId//商品分类ID
        params["keywords"] = ""
        params["curpage"] = "\(self.curPage)"//页数
        NetTools.requestData(type: .post, urlString: EPGoodsListApi, parameters: params, succeed: { (resultJson, msg) in
            if self.curPage == 1{
                self.rightTableView.es.stopPullToRefresh()
                self.rightDataArray.removeAll()
            }else{
                self.rightTableView.es.stopLoadingMore()
            }
            for subJson in resultJson.arrayValue{
                self.rightDataArray.append(subJson)
            }
            
            //判断是否有更多
            if resultJson.arrayValue.count < 10{
                self.rightTableView.es.noticeNoMoreData()
                self.haveMore = false
            }else{
                self.rightTableView.es.resetNoMoreData()
                self.haveMore = true
            }
            
            if self.rightDataArray.count > 0{
                self.emptyImgV.isHidden = true
                self.rightTableView.reloadData()
            }else{
                self.emptyImgV.isHidden = false
            }
            LYProgressHUD.dismiss()
        }) { (error) in
            if self.curPage == 1{
                self.rightTableView.es.stopPullToRefresh()
            }else{
                self.rightTableView.es.stopLoadingMore()
            }
            LYProgressHUD.showError(error!)
        }
    }
    
}




//MARK: - LYBannerViewDelegate
extension ShopViewController : LYAnimateBannerViewDelegate,UISearchBarDelegate{
    func LY_AnimateBannerViewClick(banner: LYAnimateBannerView, index: NSInteger) {
        NetTools.qxfClickCount("6")
        let subJson = self.bannerListArray[index]
        if subJson["banner_url"].stringValue.trim.isEmpty{
            return
        }
        let webVC = BaseWebViewController.spwan()
        webVC.urlStr = subJson["banner_url"].stringValue
        webVC.titleStr = subJson["banner_title"].stringValue
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let searchVC = GoodsSearchListViewController.spwan()
        self.navigationController?.pushViewController(searchVC, animated: true)
        return false
    }
}


//MARK: - UITableView
extension ShopViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.leftTableView{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                return self.epClassicJson.arrayValue.count
            }else{
                return self.leftDataArray.arrayValue.count + 1
            }
            
            //            return self.leftDataArray.arrayValue.count + 2
            //            return self.leftDataArray.arrayValue.count + 3
        }else if tableView == self.rightTableView{
            if self.isPlugInShow{
                return self.pluginDataArray.count
            }
            return self.rightDataArray.count
        }else if tableView == self.suspendTableView{
            return self.suspendDataArray.arrayValue.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.leftTableView || tableView == self.suspendTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftCategoryCell", for: indexPath) as! LeftCategoryCell
            if tableView == self.leftTableView{
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    if self.epClassicJson.arrayValue.count > indexPath.row {
                        let subJson = self.epClassicJson.arrayValue[indexPath.row]
                        cell.nameLbl.text = subJson["gc_name"].stringValue
                    }
                }else{
                    if indexPath.row == 0{
                        cell.nameLbl.text = "全部商品"
                    }else if indexPath.row == self.leftDataArray.arrayValue.count + 1{
                        cell.nameLbl.text = "七小服代测"
                        //                    cell.nameLbl.text = "附加软件"
                    }else if indexPath.row == self.leftDataArray.arrayValue.count + 2{
                        cell.nameLbl.text = "附加软件"
                    }else{
                        if self.leftDataArray.arrayValue.count > indexPath.row - 1 {
                            let subJson = self.leftDataArray.arrayValue[indexPath.row - 1]
                            cell.nameLbl.text = subJson["gc_name"].stringValue
                        }
                    }
                }
                if self.selectedLeftRow == indexPath.row{
                    cell.nameLbl.backgroundColor = UIColor.white
                }else{
                    cell.nameLbl.backgroundColor = UIColor.RGBS(s: 240)
                }
            }else{
                if self.suspendDataArray.arrayValue.count > indexPath.row {
                    let subJson = self.suspendDataArray.arrayValue[indexPath.row]
                    cell.nameLbl.text = subJson["gc_name"].stringValue
                    cell.nameLbl.backgroundColor = UIColor.white
                }
            }
            return cell
        }else if tableView == self.rightTableView{
            if self.isPlugInShow{
                var cell = tableView.dequeueReusableCell(withIdentifier: "PlugListCell")
                if cell == nil{
                    cell = UITableViewCell.init(style: .value1, reuseIdentifier: "PlugListCell")
                }
                if self.pluginDataArray.count > indexPath.row{
                    let json = self.pluginDataArray[indexPath.row]
                    cell!.textLabel?.text = json["plugname"].stringValue
                    cell!.detailTextLabel?.text = "销量:" + json["paynum"].stringValue
                    cell?.textLabel?.textColor = Text_Color
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.detailTextLabel?.textColor = Text_Color
                    cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    cell?.accessoryType = .disclosureIndicator
                    let line = UIView(frame:CGRect.init(x: 0, y: 49, width: self.rightTableView.w, height: 1))
                    line.backgroundColor = BG_Color
                    cell!.addSubview(line)
                }
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectGoodsCell", for: indexPath) as! CollectGoodsCell
                if self.rightDataArray.count > indexPath.row{
                    let subJson = self.rightDataArray[indexPath.row]
                    if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                        cell.epSubJson = subJson
                    }else{
                        cell.subJson = subJson
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.rightTableView{
            if self.isPlugInShow{
                return 50
            }
            return 100
        }else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.leftTableView{
            self.isPlugInShow = false
            self.suspendTopDis.constant = CGFloat(indexPath.row * 55)
            self.selectedLeftRow = indexPath.row
            self.leftTableView.reloadData()
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                if self.epClassicJson.arrayValue.count > indexPath.row {
                    let subJson = self.epClassicJson.arrayValue[indexPath.row]
                    //左侧列表数据
                    self.suspendDataArray = subJson["child"]
                    if self.suspendDataArray.arrayValue.count > 0{
                        self.scrollViewDidScroll(self.leftTableView)
                        self.showSuspendTable()
                        if self.suspendDataArray.arrayValue.count > 0{
                            self.suspendTableView.reloadData()
                        }
                    }else{
                        self.curPage = 1
                        let subJson = self.epClassicJson.arrayValue[indexPath.row]
                        self.gcId = subJson["gc_id"].stringValue
                        self.rightTableView.setContentOffset(CGPoint.zero, animated: false)
                        self.loadEpGoodsList()
                        self.hideSuspendTable()
                    }
                }
            }else{
                if indexPath.row == 0{
                    if self.leftDataArray.arrayValue.count > indexPath.row {
                        self.gcId = "0"
                        self.curPage = 1
                        self.loadRightData()
                        self.hideSuspendTable()
                    }
                }else if indexPath.row == self.leftDataArray.arrayValue.count + 1{
                    
                    //                self.hideSuspendTable()
                    //                self.isPlugInShow = true
                    //                self.curPage = 1
                    //                self.loadPluginData()
                }else if indexPath.row == self.leftDataArray.arrayValue.count + 2{
                    self.hideSuspendTable()
                    self.isPlugInShow = true
                    self.curPage = 1
                    self.loadPluginData()
                }else{
                    if self.leftDataArray.arrayValue.count > indexPath.row - 1 {
                        let subJson = self.leftDataArray.arrayValue[indexPath.row - 1]
                        self.loadSuspendDataWithGcId(gcId: subJson["gc_id"].stringValue)
                    }
                }
            }
            
            
        }else if tableView == self.suspendTableView{
            self.hideSuspendTable()
            if self.suspendDataArray.arrayValue.count > indexPath.row {
                self.curPage = 1
                let subJson = self.suspendDataArray.arrayValue[indexPath.row]
                self.gcId = subJson["gc_id"].stringValue
                self.rightTableView.setContentOffset(CGPoint.zero, animated: false)
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    self.loadEpGoodsList()
                }else{
                    self.loadRightData()
                }
            }
        }else if tableView == self.rightTableView{
            tableView.deselectRow(at: indexPath, animated: false)
            if self.isPlugInShow{
                NetTools.qxfClickCount("8")
                if self.pluginDataArray.count > indexPath.row{
                    let plugInDetailVC = PlugInDetailViewController.spwan()
                    plugInDetailVC.plugId = self.pluginDataArray[indexPath.row]["plugid"].stringValue
                    self.navigationController?.pushViewController(plugInDetailVC, animated: true)
                }
            }else{
                //商品详情
                NetTools.qxfClickCount("7")
                if self.rightDataArray.count > indexPath.row{
                    let subJson = self.rightDataArray[indexPath.row]
                    let detailVC = GoodsDetailViewController.spwan()
                    if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                        detailVC.goodsId = subJson["goods_commonid"].stringValue
                    }else{
                        detailVC.goodsId = subJson["goods_id"].stringValue
                    }
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.rightTableView{
            if self.isPlugInShow{
                if indexPath.row == self.pluginDataArray.count - 1 && self.haveMore{
                    self.curPage += 1
                    self.loadPluginData()
                }
            }else{
                if indexPath.row == self.rightDataArray.count - 1 && self.haveMore{
                    self.curPage += 1
                    if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                        self.loadEpGoodsList()
                    }else{
                        self.loadRightData()
                    }
                }
            }
        }
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tempTable = scrollView as? UITableView
        if self.leftTableView.isDecelerating || self.leftTableView.isDragging || (tempTable != nil && tempTable == self.leftTableView){
            self.suspendTopDis.constant = CGFloat(self.selectedLeftRow * 55) - self.leftTableView.contentOffset.y
        }
    }
    
}



extension ShopViewController{
    //MARK:购物车
    func setUpShopCarBtn() {
        UIApplication.shared.keyWindow?.addSubview(self.shopCarBtn)
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(ServiceBillViewController.panDirection(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delaysTouchesBegan = true
        pan.delaysTouchesEnded = true
        pan.cancelsTouchesInView = true
        self.shopCarBtn.addGestureRecognizer(pan)
    }
    
    func removeShopCarBtn() {
        NotificationCenter.default.removeObserver(self)
        self.shopCarBtn.removeFromSuperview()
    }
    
    @objc func panDirection(_ pan:UIPanGestureRecognizer) {
        if pan.state != .failed && pan.state != .recognized{
            guard let keyWindow = UIApplication.shared.keyWindow else{
                return
            }
            self.shopCarBtn.center = pan.location(in: keyWindow)
            if self.shopCarBtn.x < 0{
                self.shopCarBtn.frame = CGRect.init(x: 0, y: self.shopCarBtn.y, width: self.shopCarBtn.w, height: self.shopCarBtn.h)
            }
            if self.shopCarBtn.x > keyWindow.w - self.shopCarBtn.w{
                self.shopCarBtn.frame = CGRect.init(x: keyWindow.w - self.shopCarBtn.w, y: self.shopCarBtn.y, width: self.shopCarBtn.w, height: self.shopCarBtn.h)
            }
            
            if self.shopCarBtn.y < 0{
                self.shopCarBtn.frame = CGRect.init(x: self.shopCarBtn.x, y: 0, width: self.shopCarBtn.w, height: self.shopCarBtn.h)
            }
            
            if self.shopCarBtn.y > keyWindow.h - self.shopCarBtn.h{
                self.shopCarBtn.frame = CGRect.init(x: self.shopCarBtn.x, y: keyWindow.h - self.shopCarBtn.h, width: self.shopCarBtn.w, height: self.shopCarBtn.h)
            }
            
        }
    }
    
    
    @objc func goShopCar() {
        //购物车
        let shopCarVC = ShopCarListViewController.spwan()
        self.navigationController?.pushViewController(shopCarVC, animated: true)
    }
    
    
    
    
}

extension ShopViewController : UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1{
            //相册
            self.photoAlbum()
        }else if buttonIndex == 2{
            //相机
            self.camera()
        }
    }
    
    //相机
    func camera() {
        
        //隐藏状态栏
        self.isStatusBarHidden = true
        
        //是否允许使用相机
        self.ocrVC = AipGeneralVC.viewController { (image) in
            LYProgressHUD.showLoading()
            let options = ["language_type":"CHN_ENG","detect_direction":"true"]
            AipOcrService.shard().detectTextBasic(from: image, withOptions: options, successHandler: { (result) in
                print(result ?? "-------------------------")
                if result != nil{
                    let resultJson = JSON.init(result as Any)
                    if resultJson["words_result_num"].intValue == 0{
                        LYProgressHUD.showError("未识别到信息，请保持手机方向与图片方向一致")
                    }else{
                        let keys = self.getKeywordString(resultJson)
                        print(keys)
                        if keys.isEmpty{
                            LYProgressHUD.showError("未识别到备件PN，请尝试放大图片，更换更高清的图片！")
                        }else{
                            DispatchQueue.main.async {
                                let searchVC = GoodsSearchListViewController.spwan()
                                searchVC.ocrKeys = keys
                                self.navigationController?.pushViewController(searchVC, animated: true)
                                self.dismissVC()
                            }
                        }
                    }
                }else{
                    LYProgressHUD.showError("未识别到信息，请保持手机方向与图片方向一致")
                }
            }, failHandler: { (error) in
                //展示状态栏
                self.isStatusBarHidden = false
                LYProgressHUD.showError("图片识别失败，请重试！")
            })
        }
        if self.ocrVC != nil{
            self.present(self.ocrVC!, animated: true, completion: nil)
        }
    }
    
    //相册
    func photoAlbum() {
        //是否允许使用相册
        switch PHPhotoLibrary.authorizationStatus() {
        case .restricted,.denied:
            LYAlertView.show("提示", "请允许App访问相册", "取消", "去设置", {
                //打开设置页面
                let url = URL(string:UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            })
            return
        case .authorized,.notDetermined:
            break
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.navigationBar.tintColor = UIColor.RGBS(s: 33)
            self.present(picker, animated: true, completion: nil)
        }else{
            LYProgressHUD.showError("不允许访问相册")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        let options = ["language_type":"CHN_ENG","detect_direction":"true"]
        AipOcrService.shard().detectTextBasic(from: img, withOptions: options, successHandler: { (result) in
            print(result ?? "-------------------------")
            if result != nil{
                let resultJson = JSON.init(result as Any)
                if resultJson["words_result_num"].intValue == 0{
                    LYProgressHUD.showError("未识别到信息，请保持手机方向与图片方向一致")
                }else{
                    let keys = self.getKeywordString(resultJson)
                    print(keys)
                    if keys.isEmpty{
                        LYProgressHUD.showError("未识别到备件PN，请尝试放大图片，更换更高清的图片！")
                    }else{
                        DispatchQueue.main.async {
                            let searchVC = GoodsSearchListViewController.spwan()
                            searchVC.ocrKeys = keys
                            self.navigationController?.pushViewController(searchVC, animated: true)
                            self.dismissVC()
                        }
                    }
                }
            }else{
                LYProgressHUD.showError("未识别到信息，请保持手机方向与图片方向一致")
            }
        }, failHandler: { (error) in
            LYProgressHUD.showError("图片识别失败，请重试！")
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func dismissVC() {
        //展示状态栏
        self.isStatusBarHidden = false
        
        if self.ocrVC != nil{
            self.ocrVC?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func getKeywordString(_ resultJson : JSON) -> String {
        var keys : Array<String> = []
        //内部函数
        func stepOne(_ orgStr : String,_ pn : String, sn : String) -> String{
            if orgStr.lowercased().contains(pn){
                let word = orgStr.lowercased().replacingOccurrences(of: ":", with: "").replacingOccurrences(of: " ", with: "")
                let wordArr = word.components(separatedBy: pn)
                if wordArr.count == 2{
                    let pnStr = wordArr[1]
                    let pnArr = pnStr.components(separatedBy: sn)
                    if pnArr.count > 0{
                        let key = pnArr[0].trim.replacingOccurrences(of: "number", with: "")
                        return key
                    }
                }
            }
            return ""
        }
        func stepTwo(_ orgStr : String) -> String {
            var keys : Array<String> = []
            for pre_str in orgStr.components(separatedBy: " "){
                print("-------------------------------------------------------------------------------")
                print(pre_str)
                var str = pre_str
                if pre_str.hasPrefix("*") && pre_str.hasSuffix("x"){
                    str.remove(at: String.Index.init(encodedOffset: pre_str.count))
                }
                str = pre_str.replacingOccurrences(of: "*", with: "")
                print(str)
                if str.count > 4 && str.count < 7{
                    //一般是5-6位 数字和字母混合
                    let regex1 = try! NSRegularExpression(pattern: "[A-Za-z]+", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    let regex2 = try! NSRegularExpression(pattern: "[0-9]+", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    if regex1.numberOfMatches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count)) > 0{
                        if regex2.numberOfMatches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count)) > 0{
                            let regex = try! NSRegularExpression(pattern: "[A-Za-z0-9]{5,6}", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                            let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
                            if results.count == 1{
                                keys.append(str)
                            }
                        }
                    }
                    
                }else if str.count == 7{
                    //42D0638 两位数字一位字母四位数字
                    let regex = try! NSRegularExpression(pattern: "[0-9]{2}[A-Za-z][0-9]{4}", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
                    if results.count == 1{
                        keys.append(str)
                    }
                }else if str.count == 9{
                    //CX VNX AX 系列硬盘是纯9位数字
                    let regex = try! NSRegularExpression(pattern: "[0-9]{9}", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
                    if results.count == 1{
                        keys.append(str)
                    }
                    //HDS XP: PN 7位数字+字母
                    let regex1 = try! NSRegularExpression(pattern: "[0-9]{7}-[A-Za-z]", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    let results1 = regex1.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
                    if results1.count == 1{
                        keys.append(str)
                    }
                }else if str.count == 10{
                    //dell: 9FM066-057
                    let regex = try! NSRegularExpression(pattern: "[0-9][A-Za-z]{2}[0-9]{3}-[0-9]{3}", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
                    if results.count == 1{
                        keys.append(str)
                    }
                }else if str.count == 11{
                    //DMX 系列是***—***—*** 9位数字之间有横杠；
                    let regex = try! NSRegularExpression(pattern: "[0-9]{3}-[0-9]{3}-[0-9]{3}", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
                    if results.count == 1{
                        keys.append(str)
                    }
                }else if str.count == 12{
                    //CA07237-E042  两位字母 五位数字-字母 3位数字
                    let regex = try! NSRegularExpression(pattern: "[A-Za-z]{2}[0-9]{5}-[A-Za-z][0-9]{3}", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
                    let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
                    if results.count == 1{
                        keys.append(str)
                    }
                }
            }
            print(keys)
            return keys.joined(separator: ",")
        }
        
        for words in resultJson["words_result"].arrayValue{
            if words["words"].stringValue.lowercased().contains("p/n"){
                let key = stepOne(words["words"].stringValue, "p/n", sn: "s/n")
                if !key.isEmpty{
                    keys.append(key)
                }
            }else if words["words"].stringValue.lowercased().contains("pn"){
                let key = stepOne(words["words"].stringValue, "pn", sn: "sn")
                if !key.isEmpty{
                    keys.append(key)
                }
            }else if words["words"].stringValue.lowercased().contains("fru"){
                let key = stepOne(words["words"].stringValue, "fru", sn: "--")
                if !key.isEmpty{
                    keys.append(key)
                }
            }else if words["words"].stringValue.lowercased().contains("fc"){
                let key = stepOne(words["words"].stringValue, "fc", sn: "--")
                if !key.isEmpty{
                    keys.append(key)
                }
            }else if words["words"].stringValue.lowercased().contains("spare"){
                let key = stepOne(words["words"].stringValue, "spare", sn: "--")
                if !key.isEmpty{
                    keys.append(key)
                }
            }
        }
        if keys.count > 0{
            return keys.joined(separator: ",")
        }else{
            //通过普通筛选未得到关键字，使用正则表达式
            //42D0638 两位数字一位字母四位数字
            //500203-061　六位数字横杠三位数字或者字母
            //AB423-69001 一位或者两位大写字母开头 横杠五位数字
            //CX VNX AX 系列硬盘是纯9位数字
            //DMX 系列是***—***—*** 9位数字之间有横杠；
            //HDS XP: PN 7位数字+字母
            //540-7156-01 三位数字 - 四位数字-两位数字
            //CA07237-E042  两位字母 五位数字-字母 3位数字
            //108-00205+B2 三位数字-五位数字+字母数字 
            //291A-R5 三位数字字母-字母数字 第一位可以以X开始 X306A-R5
            //一般是5-6位 数字和字母混合
            for words in resultJson["words_result"].arrayValue{
                let stepTwoResult = stepTwo(words["words"].stringValue.lowercased())
                if !stepTwoResult.isEmpty{
                    keys.append(stepTwoResult)
                }
            }
            return keys.joined(separator: ",")
        }
    }
}

