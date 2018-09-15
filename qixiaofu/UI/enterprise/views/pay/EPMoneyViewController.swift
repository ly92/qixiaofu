//
//  EPMoneyViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/27.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPMoneyViewController: BaseViewController {
    class func spwan() -> EPMoneyViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPMoneyViewController
    }
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView2: UIView!
    fileprivate lazy var dataArray : Array<JSON> = {
        let dataArray = Array<JSON>()
        return dataArray
    }()
    fileprivate var curpage = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "WalletDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "WalletDetailCell")
        self.addRefresh()
        self.checkPayPassword()
        self.loadMoneyData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "", target: self, action: #selector(EPMoneyViewController.backAction))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.edgesForExtendedLayout = UIRectEdge.top
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.statusBarStyle = .default
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadMoneyData()
        }
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadMoneyData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //检查是否设置了密码
    func checkPayPassword() {
        NetTools.requestData(type: .post, urlString: EPCheckPayPwdApi, succeed: { (resultJson, error) in
            if resultJson["statu"].stringValue.intValue != 1{
                LYAlertView.show("提示", "您还未设置支付密码，将会影响您的支付体验", "先等等","去设置",{
                    //设置支付密码
                    let changePayPwdVc = ChangePasswordViewController.spwan()
                    changePayPwdVc.type = .setPayPwd
                    self.navigationController?.pushViewController(changePayPwdVc, animated: true)
                })
            }
            self.moneyLbl.text = resultJson["available_predeposit"].stringValue
        }) { (error) in
        }
    }
    
    //收支明细
    func loadMoneyData() {
        LYProgressHUD.showLoading()
        var params : [String:Any] = [:]
        params["curpage"] = self.curpage
        NetTools.requestData(type: .post, urlString: EPMoneyInfoApi, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            if self.curpage == 1{
                self.tableView.es.stopPullToRefresh()
                self.dataArray.removeAll()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            
            if resultJson.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            for json in resultJson.arrayValue{
                self.dataArray.append(json)
            }
            
            if self.dataArray.count > 0{
                self.emptyView2.isHidden = true
            }else{
                self.emptyView2.isHidden = false
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取信息失败！")
        }
    }
    
    @IBAction func bottomBtnAction(_ sender: UIButton) {
        if sender.tag == 11{
            //提现
            let withDrawVC = RechargeViewController.spwan()
            withDrawVC.vcType = 2
            withDrawVC.refreshBlock = {() in
                self.curpage = 1
                self.loadMoneyData()
                self.checkPayPassword()
            }
            self.navigationController?.pushViewController(withDrawVC, animated: true)
        }else if sender.tag == 22{
            //充值
            let rechargeVC = RechargeViewController.spwan()
            rechargeVC.vcType = 1
            rechargeVC.refreshBlock = {() in
                self.curpage = 1
                self.loadMoneyData()
                self.checkPayPassword()
            }
            self.navigationController?.pushViewController(rechargeVC, animated: true)
        }
    }

}


extension EPMoneyViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletDetailCell", for: indexPath) as! WalletDetailCell
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.subJson = subJson
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            let size = subJson["lg_desc"].stringValue.sizeFit(width: kScreenW - 16, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height > 21{
                return size.height + 50
            }
        }
        return 72
    }
}




