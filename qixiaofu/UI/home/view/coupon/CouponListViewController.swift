//
//  CouponListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CouponListViewController: BaseTableViewController {

    
    fileprivate var resultJson = JSON()
    
    fileprivate var couponArray : Array<JSON> = Array<JSON>()//第二版时所有优惠券放在一块
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCouponList()
        self.navigationItem.title = "领券中心"
        self.tableView.register(UINib.init(nibName: "CouponListCell", bundle: Bundle.main), forCellReuseIdentifier: "CouponListCell")
        self.tableView.register(UINib.init(nibName: "CouponListCell2", bundle: Bundle.main), forCellReuseIdentifier: "CouponListCell2")
        self.tableView.backgroundColor = BG_Color
        self.tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(CouponListViewController.loadCouponList), name: NSNotification.Name.init(rawValue: KPickCouponSuccessNotification), object: nil)
        
        self.tableView.es.addPullToRefresh {
            self.loadCouponList()
            self.tableView.es.stopPullToRefresh()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "优惠券规则", target: self, action: #selector(CouponListViewController.rightItemAction))
    }
    
    @objc func rightItemAction() {
        let webVC = BaseWebViewController.spwan()
        webVC.titleStr = "优惠券规则"
        webVC.urlStr = "http://www.7xiaofu.com/download/help/coupon-regulation.html"
        self.navigationController?.pushViewController(webVC, animated: true)
    }

    
    
    //加载优惠券列表
    @objc func loadCouponList() {
        LYProgressHUD.showLoading()
        var url = CouponListApi
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPCouponListApi
        }
        NetTools.requestData(type: .post, urlString: url, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
//            self.resultJson = resultJson
//            self.tableView.reloadData()
            
            self.couponArray.removeAll()
            /**
             
             之前优惠券是按照类别返回的
             
             for json in resultJson.arrayValue{
             for subJson in json["coupon_list"].arrayValue{
             self.couponArray.append(subJson)
             }
             }
             */
            for json in resultJson.arrayValue{
                self.couponArray.append(json)
            }
            
            if self.couponArray.count > 0{
                self.hideEmptyView()
            }else{
                self.showEmptyView()
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取失败，请重试！")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return self.resultJson.arrayValue.count
        return self.couponArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponListCell2", for: indexPath) as! CouponListCell2
        if self.couponArray.count > indexPath.row{
            let subJson = self.couponArray[indexPath.row]
            cell.subJson = subJson
        }
        return cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponListCell", for: indexPath) as! CouponListCell
//        if self.resultJson.arrayValue.count > indexPath.row{
//            let subJson = self.resultJson.arrayValue[indexPath.row]
//            cell.subJson = subJson
//            cell.moreActionBlock = {() in
//                let couponVC = MyCouponViewController()
//                couponVC.isFromCouponList = true
//                couponVC.couponJson = subJson
//                self.navigationController?.pushViewController(couponVC, animated: true)
//            }
//        }
//        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }


}
