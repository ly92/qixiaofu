//
//  EPMyCouponViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/27.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPMyCouponViewController: BaseViewController {
    class func spwan() -> EPMyCouponViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPMyCouponViewController
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var middleBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var lineLeftDis: NSLayoutConstraint!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var emptyView2: UIView!
    
    var shopOrderPrice = ""
    var selectedCouponBlock : ((JSON?) -> Void)?
    var selectedJson : JSON? //选择的优惠券
    
    var isFromPay = false//支付时选择优惠券
    
    fileprivate var couponArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    fileprivate var useType = "1" // 1为未使用列表 2为已使用列表 3为已过期列表
    fileprivate lazy var couponCenterBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kScreenW-120, y: kScreenH-150, width: 100, height: 100)
        btn.setImage(#imageLiteral(resourceName: "coupon_center_icon"), for: .normal)
        btn.addTarget(self, action: #selector(EPMyCouponViewController.goCouponCenter), for: .touchUpInside)
        return btn
    }()//领券中心按钮
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "MyCouponCell", bundle: Bundle.main), forCellReuseIdentifier: "MyCouponCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        
        self.navigationItem.title = "我的优惠券"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "优惠券规则", target: self, action: #selector(EPMyCouponViewController.rightItemAction))
        
        if self.isFromPay{
            self.topViewH.constant = 0
            self.navigationItem.title = "可用优惠券"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", target: self, action: #selector(EPMyCouponViewController.rightItemAction))
            self.loadUsefulCoupon()
        }else{
            self.loadCouponList()
            self.addRefresh()
        }

    }
    
    
    @objc func rightItemAction() {
        if self.isFromPay{
            if self.selectedCouponBlock != nil{
                self.selectedCouponBlock!(self.selectedJson)
            }
            self.navigationController?.popViewController(animated: true)
        }else{
            let webVC = BaseWebViewController.spwan()
            webVC.titleStr = "优惠券规则"
            webVC.urlStr = "http://www.7xiaofu.com/download/help/coupon-regulation.html"
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.isFromPay{
            self.setUpCouponCenterBtn()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.isFromPay{
            self.removeCouponCenterBtn()
        }
    }
    
    //刷新
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadCouponList()
        }
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadCouponList()
        }
    }
    
    //加载优惠券列表
    func loadCouponList() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["type"] = self.useType
        NetTools.requestData(type: .post, urlString: EPMyCouponListApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            //停止刷新
            if self.curpage == 1{
                self.tableView.es.stopPullToRefresh()
                self.couponArray.removeAll()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            //是否有更多
            if resultJson.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            for subJson in resultJson.arrayValue{
                self.couponArray.append(subJson)
            }
            
            if self.couponArray.count > 0{
                self.emptyView2.isHidden = true
            }else{
                self.emptyView2.isHidden = false
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取失败，请重试！")
        }
    }
    
    //可用优惠券
    func loadUsefulCoupon() {
        var params : [String : Any] = [:]
        params["price"] = self.shopOrderPrice
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: EPShopUsefulCouponApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            for subJson in resultJson.arrayValue{
                self.couponArray.append(subJson)
            }
            if self.couponArray.count > 0{
                self.emptyView2.isHidden = true
            }else{
                self.emptyView2.isHidden = false
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取失败，请重试！")
        }
    }
    
    @IBAction func topBtnAction(_ btn: UIButton) {
        if btn.isSelected{
            return
        }
        self.leftBtn.isSelected = false
        self.middleBtn.isSelected = false
        self.rightBtn.isSelected = false
        btn.isSelected = true
        var lineDis : CGFloat = 0
        if btn.tag == 11{
            //未使用
            self.useType = "1"
        }else if btn.tag == 22{
            //已使用
            lineDis = kScreenW / 3.0
            self.useType = "2"
        }else if btn.tag == 33{
            //已过期
            lineDis = kScreenW * 2 / 3.0
            self.useType = "3"
        }
        UIView.animate(withDuration: 0.2) {
            self.lineLeftDis.constant = lineDis
        }
        self.loadCouponList()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension EPMyCouponViewController{
    //MARK:领券中心
    func setUpCouponCenterBtn() {
        UIApplication.shared.keyWindow?.addSubview(self.couponCenterBtn)
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(ServiceBillViewController.panDirection(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delaysTouchesBegan = true
        pan.delaysTouchesEnded = true
        pan.cancelsTouchesInView = true
        self.couponCenterBtn.addGestureRecognizer(pan)
    }
    
    func removeCouponCenterBtn() {
        NotificationCenter.default.removeObserver(self)
        self.couponCenterBtn.removeFromSuperview()
    }
    
    @objc func panDirection(_ pan:UIPanGestureRecognizer) {
        if pan.state != .failed && pan.state != .recognized{
            guard let keyWindow = UIApplication.shared.keyWindow else{
                return
            }
            self.couponCenterBtn.center = pan.location(in: keyWindow)
            if self.couponCenterBtn.x < 0{
                self.couponCenterBtn.frame = CGRect.init(x: 0, y: self.couponCenterBtn.y, width: self.couponCenterBtn.w, height: self.couponCenterBtn.h)
            }
            if self.couponCenterBtn.x > keyWindow.w - self.couponCenterBtn.w{
                self.couponCenterBtn.frame = CGRect.init(x: keyWindow.w - self.couponCenterBtn.w, y: self.couponCenterBtn.y, width: self.couponCenterBtn.w, height: self.couponCenterBtn.h)
            }
            
            if self.couponCenterBtn.y < 0{
                self.couponCenterBtn.frame = CGRect.init(x: self.couponCenterBtn.x, y: 0, width: self.couponCenterBtn.w, height: self.couponCenterBtn.h)
            }
            
            if self.couponCenterBtn.y > keyWindow.h - self.couponCenterBtn.h{
                self.couponCenterBtn.frame = CGRect.init(x: self.couponCenterBtn.x, y: keyWindow.h - self.couponCenterBtn.h, width: self.couponCenterBtn.w, height: self.couponCenterBtn.h)
            }
            
        }
    }
    
    
    @objc func goCouponCenter() {
        //领券中心
        let couponVC = CouponListViewController()
        self.navigationController?.pushViewController(couponVC, animated: true)
    }
    
    
    
    
}



extension EPMyCouponViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.couponArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCouponCell", for: indexPath) as! MyCouponCell
        if self.couponArray.count > indexPath.row{
            let json = self.couponArray[indexPath.row]
            cell.subJson = json
            if self.isFromPay {
                cell.selectedBtnW.constant = 22
                cell.selectedBtn.setImage(#imageLiteral(resourceName: "btn_checkbox_n"), for: .normal)
                if self.selectedJson != nil{
                    if json["id"].stringValue == self.selectedJson!["id"].stringValue{
                        cell.selectedBtn.setImage(#imageLiteral(resourceName: "btn_checkbox_s"), for: .normal)
                    }
                }
            }else{
                cell.selectedBtnW.constant = 0
            }
        }
        
        if self.isFromPay{
            cell.countView.isHidden = true
        }else{
            cell.countView.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.isFromPay{
            if self.couponArray.count > indexPath.row{
                let json = self.couponArray[indexPath.row]
                if self.selectedJson != nil{
                    if self.selectedJson!["id"].stringValue == json["id"].stringValue{
                        self.selectedJson = nil
                    }else{
                        self.selectedJson = json
                    }
                }else{
                    self.selectedJson = json
                }
                self.tableView.reloadData()
            }
        }
    }
    
}
