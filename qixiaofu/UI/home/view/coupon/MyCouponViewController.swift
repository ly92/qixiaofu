//
//  MyCouponViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyCouponViewController: BaseViewController {
    class func spwan() -> MyCouponViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! MyCouponViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var middleBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var lineLeftDis: NSLayoutConstraint!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var emptyView2: UIView!
    
    var isFromPay = false//支付时选择优惠券
    var couponType = ""//优惠券类别值待测为1代卖为2代存为3商城优惠券为4
    var payMoney : CGFloat = 0//本次支付所需要的钱数
    var paySys = ""//商城支付时商品的类别
    var systermPrice = ""//按照类型区分的价格 json字符串
    var selectedJson : JSON? //选择的优惠券
    var selectedCouponBlock : ((JSON?) -> Void)?
    
    var isFromCouponList = false//领券中心的更多按钮
    var couponJson = JSON()
    
    fileprivate var couponArray : Array<JSON> = Array<JSON>()
    fileprivate var curpage = 1
    fileprivate var useType = "1" // 1为未使用列表 2为已使用列表 3为已过期列表
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib.init(nibName: "MyCouponCell", bundle: Bundle.main), forCellReuseIdentifier: "MyCouponCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        
        if self.isFromCouponList{
            self.topViewH.constant = 0
            self.navigationItem.title = self.couponJson["member_name"].stringValue
            for subJson in self.couponJson["coupon_list"].arrayValue{
                self.couponArray.append(subJson)
            }
            if self.couponArray.count > 0{
                self.emptyView2.isHidden = true
            }else{
                self.emptyView2.isHidden = false
            }
            self.tableView.reloadData()
        }else if self.isFromPay{
            self.topViewH.constant = 0
            self.navigationItem.title = "可用优惠券"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", target: self, action: #selector(MyCouponViewController.rightItemAction))
            self.loadUsefulCoupon()
        }else{
            self.topViewH.constant = 50
            
            self.navigationItem.title = "我的优惠券"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "优惠券规则", target: self, action: #selector(MyCouponViewController.rightItemAction))
            self.loadCouponList()
            self.addRefresh()
        }
    }

    //使用优惠券
    @objc func rightItemAction() {
        if self.isFromCouponList{
            
        }else if self.isFromPay{
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
        params["type"] = self.useType//分类(type=1为可用 2为已用 3为已过期)
        NetTools.requestData(type: .post, urlString: MyCouponListApi, parameters: params, succeed: { (resultJson, msg) in
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
    
    //支付时加载可用优惠券
    func loadUsefulCoupon() {
        LYProgressHUD.showLoading()
        var url = ""
        var params : [String : Any] = [:]
        if self.couponType.intValue == 4{
            params["pay"] = self.payMoney
            params["sys"] = self.paySys
            url = CouponCanShopUseApi
        }else{
            params["coupon_type"] = self.couponType
            url = CouponCanUseApi
        }
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (resultJson, msg) in
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
        
//        NetTools.requestDataTest(urlString: CouponCanUseApi, parameters: params, succeed: { (result) in
//            print(result)
//        }) { (error) in
//            LYProgressHUD.showError(error ?? "---")
//        }
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

    // MARK: - Table view data source

}

extension MyCouponViewController : UITableViewDelegate,UITableViewDataSource{
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
        
        if self.isFromCouponList{
            cell.countView.isHidden = true
        }else if self.isFromPay{
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
        if self.isFromCouponList{
            if self.couponArray.count > indexPath.row{
                let json = self.couponArray[indexPath.row]
                if json["is_have"].intValue == 1{
                    LYProgressHUD.showInfo("只可以领一张，不要贪心哦！")
                    return
                }
                var params : [String : Any] = [:]
                params["coupon_id"] = json["id"].stringValue
                params["use_type"] = json["use_type"].stringValue
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: CouponTakeApi, parameters: params, succeed: { (resultJson, msg) in
                    LYProgressHUD.showSuccess("领券成功！")
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: KPickCouponSuccessNotification), object: nil)
                }) { (error) in
                    LYProgressHUD.showError(error ?? "领取失败，请重试！")
                }
            }
        }else if self.isFromPay{
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
