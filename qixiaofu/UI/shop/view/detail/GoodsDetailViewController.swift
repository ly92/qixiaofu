//
//  GoodsDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/18.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class GoodsDetailViewController: BaseViewController {
    class func spwan() -> GoodsDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! GoodsDetailViewController
    }
    
    var goodsId = ""
    
    fileprivate var resultJson : JSON = []
    fileprivate var isCollected = false
    fileprivate var isBuying = true
    
    
    fileprivate var goodsDescH : CGFloat = 0
    fileprivate var goodsParamsH : CGFloat = 0
    
    fileprivate var leftNavBtn = UIButton()
    fileprivate var rightNavBtn = UIButton()
    fileprivate var navLine = UIView()
    
    
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyCountLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatBuyBtn: UIButton!
    @IBOutlet weak var shopCarBtn: UIButton!
    @IBOutlet weak var buyBtn: UIButton!
    
    //三方比价的价格
    fileprivate var price2 = ""
    fileprivate var price3 = ""
    
    
    lazy var bannerView : LYAnimateBannerView = {
        let bannerView = LYAnimateBannerView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenW), delegate: self)
        bannerView.backgroundColor = UIColor.white
        bannerView.showPageControl = true
        return bannerView
    }()
    
    /**
     buymobile    sale_type   seller_avatar  seller_nickname
     电话号码         商品属性      代卖人头像  代卖人昵称
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib.init(nibName: "ShopInventoryCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopInventoryCell")
        self.tableView.register(UINib.init(nibName: "WebViewCell", bundle: Bundle.main), forCellReuseIdentifier: "WebViewCell")
        self.tableView.register(UINib.init(nibName: "SaleAfterDescCell", bundle: Bundle.main), forCellReuseIdentifier: "SaleAfterDescCell")
        self.tableView.register(UINib.init(nibName: "GoodsFromCell", bundle: Bundle.main), forCellReuseIdentifier: "GoodsFromCell")
        self.tableView.register(UINib.init(nibName: "GoodsDetailPriceCell", bundle: Bundle.main), forCellReuseIdentifier: "GoodsDetailPriceCell")
        self.tableView.register(UINib.init(nibName: "GoodsOtherPriceCell", bundle: Bundle.main), forCellReuseIdentifier: "GoodsOtherPriceCell")
        
        if #available(iOS 11.0, *){
            self.tableView.contentInsetAdjustmentBehavior = .never
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.loadDetailData()
        self.navigationItem.title = "商品详情"
//        self.setUpNavView()
        
        self.buyCountLbl.text = "1"
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    //导航view
//    func setUpNavView() {
//        let view = UIView(frame:CGRect.init(x: 0, y: 0, width: 120, height: 40))
//        self.leftNavBtn = UIButton(frame:CGRect.init(x: 0, y: 0, width: 60, height: 40))
//        leftNavBtn.setTitle("商品", for: .normal)
//        leftNavBtn.setTitleColor(Normal_Color, for: .normal)
//        leftNavBtn.addTarget(self, action: #selector(GoodsDetailViewController.leftNavAction), for: .touchUpInside)
//
//        self.rightNavBtn = UIButton(frame:CGRect.init(x: 60, y: 0, width: 60, height: 40))
//        rightNavBtn.setTitle("详情", for: .normal)
//        rightNavBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
//        rightNavBtn.addTarget(self, action: #selector(GoodsDetailViewController.rightNavAction), for: .touchUpInside)
//
//        self.navLine = UIView(frame:CGRect.init(x: 0, y: 39, width: 60, height: 1.5))
//        navLine.backgroundColor = Normal_Color
//
//        view.addSubview(leftNavBtn)
//        view.addSubview(rightNavBtn)
//        view.addSubview(navLine)
//        //        self.navigationItem.titleView = view
//        self.navigationItem.title = "商品详情"
//        self.setUpRightItems()
//    }
//
//    @objc func leftNavAction() {
//        if self.navLine.x != 0{
//            self.navLine.x = 0
//            self.leftNavBtn.setTitleColor(Normal_Color, for: .normal)
//            self.rightNavBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
//
//            self.showGoodsTable = false
//            self.tableView.reloadData()
//        }
//    }
//
//    @objc func rightNavAction() {
//        if self.navLine.x != 60{
//            self.navLine.x = 60
//            self.leftNavBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
//            self.rightNavBtn.setTitleColor(Normal_Color, for: .normal)
//
//            self.showGoodsTable = true
//            self.tableView.reloadData()
//        }
//    }
    
    //收藏按钮和分享按钮
    func setUpRightItems() {
        self.navigationItem.title = "商品详情"
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_share"), target: self, action: #selector(GoodsDetailViewController.shareAction))
        }else{
            var searchItem = UIBarButtonItem()
            if self.isCollected{
                searchItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_collect_red"), target: self, action: #selector(GoodsDetailViewController.collectAction))
            }else{
                searchItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_collect"), target: self, action: #selector(GoodsDetailViewController.collectAction))
            }
            let filtrateItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_share"), target: self, action: #selector(GoodsDetailViewController.shareAction))
            self.navigationItem.rightBarButtonItems = [filtrateItem,searchItem]
        }
        
    }
    
    //隐藏选择购买数量的view
    @IBAction func hideBuyView() {
        self.buyView.isHidden = true
        self.buyCountLbl.text = "1"
    }
    
    //确定购买或者加入购物车
    @IBAction func sureBuyView() {
        let count = self.buyCountLbl.text?.intValue
        if isBuying{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                
                if !LocalData.getYesOrNotValue(key: IsEPApproved){
                    LYProgressHUD.showInfo("企业信息未审核！")
                    return
                }
                
                if !LocalData.getYesOrNotValue(key: IsTrueName){
                    LYAlertView.show("提示", "您尚未进行实名认证，请您先去认证", "取消","去认证",{
                        //实名认证
                        let idVC = IdentityViewController.spwan()
                        self.navigationController?.pushViewController(idVC, animated: true)
                    })
                    return
                }
                
                var icon = ""
                if resultJson["img_list"].arrayValue.count > 0{
                    icon = resultJson["img_list"].arrayValue[0].stringValue
                }
                let goods : JSON = ["name" : resultJson["goods_name"].stringValue,
                                    "icon" : icon,
                                    "price" : resultJson["goods_price"].stringValue,
                                    "id" : self.goodsId,
                                    "count" : "\(count ?? 1)"
                ]
                let payVC = EPShopPayViewController.spwan()
                payVC.isFromShopCar = false
                payVC.goodsArray = [goods]
                self.navigationController?.pushViewController(payVC, animated: true)
            }else{
                let goods : JSON = ["name" : resultJson["goods_info"]["goods_name"].stringValue,
                                    "icon" : resultJson["goods_image"].arrayValue[0],
                                    "price" : resultJson["goods_info"]["goods_price"].stringValue,
                                    "sys" : resultJson["goods_info"]["gc_id_3"].stringValue,
                                    "count" : "\(count ?? 1)"
                ]
                let payVC = PayGoodsViewController.spwan()
                payVC.cartId = self.goodsId + "|" + "\(count ?? 1)"
                payVC.isFromShopCar = false
                payVC.goodsArray = [goods]
                self.navigationController?.pushViewController(payVC, animated: true)
            }
             self.hideBuyView()
        }else{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                var params : [String : Any] = [:]
                params["goods_commonid"] = self.goodsId
                params["goods_num"] = "\(count ?? 1)"
                NetTools.requestData(type: .post, urlString: EPAddGoodsToCarApi, parameters: params, succeed: { (resultJson, msg) in
                    LYProgressHUD.showSuccess("添加购物车成功！")
                    self.hideBuyView()
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }else{
                var params : [String : Any] = [:]
                params["store_id"] = "1";
                params["goods_id"] = self.goodsId
                params["quantity"] = "\(count ?? 1)"
                NetTools.requestData(type: .post, urlString: GoodsAddToCarApi, parameters: params, succeed: { (resultJson, msg) in
                    LYProgressHUD.showSuccess("添加购物车成功！")
                    self.hideBuyView()
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }
        }
    }
    //增加或者减少
    @IBAction func buyCountAction(_ sender: UIButton) {
        if sender.tag == 11{
            //+
            let count = (self.buyCountLbl.text?.intValue)! + 1
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                if count > resultJson["goods_storage"].stringValue.intValue{
                    self.buyCountLbl.text = "\(count - 1)"
                    LYProgressHUD.showInfo("库存量不足")
                }else{
                    self.buyCountLbl.text = "\(count)"
                }
            }else{
                if count > resultJson["goods_info"]["goods_storage"].stringValue.intValue{
                    self.buyCountLbl.text = "\(count - 1)"
                    LYProgressHUD.showInfo("库存量不足")
                }else{
                    self.buyCountLbl.text = "\(count)"
                }
            }
        }else{
            //-
            let count = (self.buyCountLbl.text?.intValue)! - 1
            if count < 1{
                self.buyCountLbl.text = "\(1)"
                LYProgressHUD.showInfo("不能再少啦！")
            }else{
                self.buyCountLbl.text = "\(count)"
            }
        }
    }
    
    @IBAction func bottomAction(_ sender: UIButton) {
        var tempJson = JSON()
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            tempJson = resultJson
        }else{
            tempJson = resultJson["goods_info"]
        }
        
        if sender.tag == 11{
            //加入购物车
            if tempJson["goods_storage"].stringValue.intValue > 0{
                self.buyView.isHidden = false
                self.isBuying = false
            }else{
                LYProgressHUD.showInfo("商品库存不足！")
            }
        }else if sender.tag == 22{
            //购买
            if tempJson["goods_storage"].stringValue.intValue > 0{
                self.buyView.isHidden = false
                self.isBuying = true
            }else{
                LYProgressHUD.showInfo("商品库存不足！")
            }
        }else if sender.tag == 33{
            //聊天
            if tempJson["sale_type"].stringValue.intValue == 2{
                //联系卖家
                if LocalData.getUserPhone() == tempJson["buymobile"].stringValue{
                    LYProgressHUD.showInfo("不可以联系自己哦!")
                    return
                }
                if tempJson["buymobile"].stringValue.isEmpty{
                    LYProgressHUD.showInfo("卖家没有留下联系方式！")
                    return
                }
                DispatchQueue.global().async {
                    HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
                }
                let chatVC = EaseMessageViewController.init(conversationChatter: tempJson["buymobile"].stringValue, conversationType: EMConversationType.init(0))
                //保存聊天页面数据
                LocalData.saveChatUserInfo(name: tempJson["seller_nickname"].stringValue, icon: tempJson["seller_avatar"].stringValue, key: tempJson["buymobile"].stringValue)
                chatVC?.title = tempJson["seller_nickname"].stringValue
                self.navigationController?.pushViewController(chatVC!, animated: true)
                
            }else{
                //客服
                /**商品信息*/
                var goodsInfo :  [AnyHashable : Any] =  [AnyHashable : Any]()
                goodsInfo["type"] = "track"
                goodsInfo["title"] = tempJson["goods_name"].stringValue
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    if resultJson["img_list"].arrayValue.count > 0{
                        goodsInfo["desc"] = resultJson["img_list"].arrayValue[0].stringValue
                        goodsInfo["img_url"] = resultJson["img_list"].arrayValue[0].stringValue
                    }else{
                        goodsInfo["desc"] = ""
                    }
                    goodsInfo["item_url"] = tempJson["intransit_url"].stringValue
                }else{
                    if resultJson["goods_image"].arrayValue.count > 0{
                        goodsInfo["desc"] = resultJson["goods_image"].arrayValue[0].stringValue
                        goodsInfo["img_url"] = resultJson["goods_image"].arrayValue[0].stringValue
                    }else{
                        goodsInfo["desc"] = ""
                    }
                    goodsInfo["item_url"] = tempJson["share"].stringValue
                }
                goodsInfo["price"] = tempJson["goods_price"].stringValue
                DispatchQueue.global().async {
                    HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
                }
                let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
                chatVC?.commodityInfo = goodsInfo
                self.navigationController?.pushViewController(chatVC!, animated: true)
            }
        }else if sender.tag == 44{
            //call phone
            var tel  = self.resultJson["goods_info"]["service_tel"].stringValue
            if tel.isEmpty{
                tel = "15600923777"
            }
            UIApplication.shared.openURL(URL(string: "telprompt:" + tel)!)
        }
    }
    
    
    //商品详情
    func loadDetailData() {
        var params : [String : Any] = [:]
        params["goods_id"] = self.goodsId
        var url = ShopGoodsDetailApi
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPGoodsDetailApi
        }
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: url,parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                //banner
                var arrM = Array<String>()
                for subJson in resultJson["img_list"].arrayValue{
                    arrM.append(subJson.stringValue)
                }
                self.bannerView.imageUrlArray = arrM
                if arrM.count < 2{
                    self.bannerView.showPageControl = false
                }
//                //库存数量
//                if resultJson["goods_storage"].stringValue.intValue > 0{
//                    self.buyBtn.isEnabled = true
//                    self.shopCarBtn.isEnabled = true
//                }else{
//                    self.buyBtn.isEnabled = false
//                    self.shopCarBtn.isEnabled = false
//                }
            }else{
                //banner
                var arrM = Array<String>()
                for subJson in resultJson["goods_image"].arrayValue{
                    arrM.append(subJson.stringValue)
                }
                self.bannerView.imageUrlArray = arrM
                if arrM.count < 2{
                    self.bannerView.showPageControl = false
                }
//                //库存数量
//                if resultJson["goods_info"]["goods_storage"].stringValue.intValue > 0{
//                    self.buyBtn.isEnabled = true
//                    self.shopCarBtn.isEnabled = true
//                }else{
//                    self.buyBtn.isEnabled = false
//                    self.shopCarBtn.isEnabled = false
//                }
                //是否被收藏
                if resultJson["is_fav"].intValue == 1{
                    self.isCollected = true
                }
            }
            self.setUpRightItems()
            self.resultJson = resultJson
            self.loadOtherPrice()
        }) { (error) in
            LYProgressHUD.dismiss()
        }
    }
    
    //三方比价的价格
    func loadOtherPrice() {
        var params : [String : Any] = [:]
        params["goods_id"] = self.goodsId
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            params["price1"] = resultJson["goods_price"].stringValue
        }else{
            params["price1"] = resultJson["goods_info"]["goods_price"].stringValue
        }
        NetTools.requestData(type: .post, urlString: EPGoodsPriceApi,parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            self.price2 = result["price2"].stringValue
            self.price3 = result["price3"].stringValue
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.dismiss()
        }
        
    }
    
}

extension GoodsDetailViewController : LYAnimateBannerViewDelegate, UIWebViewDelegate{
    func LY_AnimateBannerViewClick(banner: LYAnimateBannerView, index: NSInteger) {
        
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //        self.webViewH = self.detailWebView.scrollView.contentSize.height + 30
        self.tableView.reloadData()
    }
    //收藏或者取消收藏
    @objc func collectAction() {
        var params : [String : Any] = [:]
        params["store_id"] = "1"
        var url = ""
        if self.isCollected{
            params["fav_id"] = self.goodsId
            url = CancelCollectGoodsApi
        }else{
            params["goods_id"] = self.goodsId
            url = CollectGoodsApi
        }
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: url,parameters: params, succeed: { (resultJson, msg) in
            if self.isCollected{
                LYProgressHUD.showSuccess("取消成功！")
            }else{
                LYProgressHUD.showSuccess("收藏成功！")
            }
            self.isCollected = !self.isCollected
            self.setUpRightItems()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    //分享
    @objc func shareAction() {
        func shareWithImage(image:UIImage?){
            var url = ""
            var title = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                url = self.resultJson["intransit_url"].stringValue
                title = self.resultJson["goods_name"].stringValue
            }else{
                url = self.resultJson["goods_info"]["share"].stringValue
                title = self.resultJson["goods_info"]["goods_name"].stringValue
            }
            ShareView.show(url: url, title: title, desc: "七小服备件商品", image:image, viewController: self)
        }
        var imgs = JSON()
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            imgs = resultJson["img_list"]
        }else{
            imgs = resultJson["goods_image"]
        }
        if imgs.arrayValue.count > 0{
            let imgV = UIImageView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 100, height: 100)))
            imgV.kf.setImage(with: URL(string:(imgs.arrayValue.first?.stringValue)!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (img, error, memory, imgUrl) in
                shareWithImage(image: img)
            })
        }else{
            shareWithImage(image: nil)
        }
    }
}

extension GoodsDetailViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        var goods_spec = ""
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            goods_spec = self.resultJson["goods_spec"].stringValue
        }else{
            goods_spec = resultJson["goods_info"]["goods_table"].stringValue
        }
        if goods_spec.isEmpty{
            return 3
        }
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 6
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                //图片
                let cell = UITableViewCell()
                cell.addSubview(self.bannerView)
                return cell
            }else if indexPath.row == 1{
                //打折
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsDetailPriceCell", for: indexPath) as! GoodsDetailPriceCell
                cell.subJson = resultJson
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    if resultJson["is_discount"].stringValue.intValue == 1{
                        cell.isHidden = false
                    }else{
                        cell.isHidden = true
                    }
                }else{
                    if resultJson["goods_info"]["is_discount"].stringValue.intValue == 1{
                        cell.isHidden = false
                    }else{
                        cell.isHidden = true
                    }
                }
                return cell
            }else if indexPath.row == 2{
                //名称
                let cell = UITableViewCell()
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    cell.textLabel?.text = resultJson["goods_name"].stringValue
                }else{
                    cell.textLabel?.text = resultJson["goods_info"]["goods_name"].stringValue
                }
                
                cell.textLabel?.textColor = UIColor.RGBS(s: 33)
                let line = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 1))
                line.backgroundColor = BG_Color
                cell.addSubview(line)
                return cell
            }else if indexPath.row == 3{
                //自营/代卖 -- 价格
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsFromCell", for: indexPath) as! GoodsFromCell
                cell.resultJson = self.resultJson
                return cell
            }else if indexPath.row == 4{
                //三方比价
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsOtherPriceCell", for: indexPath) as! GoodsOtherPriceCell
                cell.priceLbl1.text = "¥ " + self.price2
                cell.priceLbl2.text = "¥ " + self.price3
                return cell
            }else if indexPath.row == 5{
                //描述
                let cell = UITableViewCell()
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell.textLabel?.textColor = UIColor.darkGray
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    var str = resultJson["goods_body"].stringValue
                    str = str.replacingOccurrences(of: "<div>", with: "")
                    str = str.replacingOccurrences(of: "</div>", with: "")
                    cell.textLabel?.text = str
                }else{
                    var str = resultJson["goods_info"]["mobile_body"].stringValue
                    str = str.replacingOccurrences(of: "<div>", with: "")
                    str = str.replacingOccurrences(of: "</div>", with: "")
                    cell.textLabel?.text = str
                }
                
                return cell
            }
        }else if indexPath.section == 1{
            //库存
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopInventoryCell", for: indexPath) as! ShopInventoryCell
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                cell.shopInventoryLbl.text = resultJson["goods_storage"].stringValue
                cell.engineerInventoryLbl.isHidden = true
                cell.engineerLbl.isHidden = true
            }else{
                cell.engineerInventoryLbl.isHidden = false
                cell.engineerLbl.isHidden = false
                cell.shopInventoryLbl.text = resultJson["goods_info"]["goods_storage"].stringValue
                cell.engineerInventoryLbl.text = resultJson["goods_info"]["engineer_storage"].stringValue
            }
            return cell
        }else if indexPath.section == 2{
            var goods_spec = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                goods_spec = self.resultJson["goods_spec"].stringValue
            }else{
                goods_spec = resultJson["goods_info"]["goods_table"].stringValue
            }
            if goods_spec.isEmpty{
                //包装售后
                let cell = tableView.dequeueReusableCell(withIdentifier: "SaleAfterDescCell", for: indexPath) as! SaleAfterDescCell
                cell.parentVC = self
                return cell
            }else{
                //规格参数
                let cell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell", for: indexPath) as! WebViewCell
                cell.isHidden = false
                cell.setHtmlStr(goods_spec)
                cell.webCellHeightBlock = {[weak self] (height , webView) in
                    if self?.goodsParamsH != height{
                        self?.goodsParamsH = height
                        self?.tableView.reloadData()
                    }
                }
                return cell
            }
        }else if indexPath.section == 3{
            //包装售后
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaleAfterDescCell", for: indexPath) as! SaleAfterDescCell
            cell.parentVC = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1{
            let goodsLocationVC = GoodsLocationViewController()
            goodsLocationVC.goodsId = self.goodsId
            self.navigationController?.pushViewController(goodsLocationVC, animated: true)
        }else if indexPath.section == 0 && indexPath.row == 2 {
            var name = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                name = resultJson["goods_name"].stringValue
            }else{
                name = resultJson["goods_info"]["goods_name"].stringValue
            }
            UIPasteboard.general.string = name
            LYProgressHUD.showInfo("复制成功")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0{
                //图片
                return kScreenW
            }else if indexPath.row == 1{
                //打折
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    if resultJson["is_discount"].stringValue.intValue == 1{
                        return 60
                    }
                }else{
                    if resultJson["goods_info"]["is_discount"].stringValue.intValue == 1{
                        return 60
                    }
                }
                return 0
                
            }else if indexPath.row == 2{
                //名称
                return 44
            }else  if indexPath.row == 3{
                //价格 --自营/代卖
//                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
//                    if resultJson["is_discount"].stringValue.intValue == 1{
//                        return 0
//                    }
//                }else{
//                    if resultJson["goods_info"]["is_discount"].stringValue.intValue == 1{
//                        return 0
//                    }
//                }
                return 30
            }else if indexPath.row == 4{
                //三方比价
                return 50
            }else if indexPath.row == 5{
                //描述
                var str = ""
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    str = resultJson["goods_body"].stringValue
                }else{
                    str = resultJson["goods_info"]["mobile_body"].stringValue
                    str = str.replacingOccurrences(of: "<div>", with: "")
                    str = str.replacingOccurrences(of: "</div>", with: "")
                }
                let heigh = str.sizeFit(width: kScreenW-20, height: CGFloat(MAXFLOAT), fontSize: 14.0).height
                if heigh > 44{
                    return heigh + 10
                }else{
                    return 44
                }
            }
        }else if indexPath.section == 1{
            //库存
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                 return 50
            }else{
                 return 80
            }

        }else if indexPath.section == 2{
            var goods_spec = ""
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                goods_spec = self.resultJson["goods_spec"].stringValue
            }else{
                goods_spec = resultJson["goods_info"]["goods_table"].stringValue
            }
            if goods_spec.isEmpty{
                //包装售后
                if kScreenW > 320 {
                    return 350
                }else{
                    return 380
                }
            }else{
                //规格参数
                return self.goodsParamsH
            }
        }else if indexPath.section == 3{
            //包装售后
            if kScreenW > 320 {
                return 350
            }else{
                return 380
            }
        }
        return 0
    }
    
}

