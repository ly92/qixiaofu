//
//  EnterpriseAccountViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnterpriseAccountViewController: BaseViewController {
    class func spwan() -> EnterpriseAccountViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EnterpriseAccountViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    fileprivate var curpage = 1
    fileprivate var dataArray1 : Array<JSON> = Array<JSON>()
    fileprivate var dataArray2 : Array<JSON> = Array<JSON>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "账户管理"
        self.addBtn.layer.cornerRadius = 20
        self.tableView.register(UINib.init(nibName: "EnterpriseManagerAccountCell", bundle: Bundle.main), forCellReuseIdentifier: "EnterpriseManagerAccountCell")
        self.tableView.register(UINib.init(nibName: "EPStartUseAccountCell", bundle: Bundle.main), forCellReuseIdentifier: "EPStartUseAccountCell")
        self.loadAccountData()
        self.addRefresh()
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            self.curpage = 1
            self.loadAccountData()
        }
        self.tableView.es.addInfiniteScrolling {
            self.curpage += 1
            self.loadAccountData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAccountData() {
        let params = ["curpage" : self.curpage]
        NetTools.requestData(type: .post, urlString: EnterpriseManagerAccountApi, parameters: params, succeed: { (resultJson, msg) in
            if self.curpage == 1{
                self.dataArray1.removeAll()
                self.dataArray2.removeAll()
                self.tableView.es.stopPullToRefresh()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            if resultJson.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            for json in resultJson.arrayValue{
                if json["is_del"].stringValue.intValue == 1{
                    self.dataArray2.append(json)
                }else{
                    self.dataArray1.append(json)
                }
                
            }
            self.tableView.reloadData()
        }) { (error) in
            if self.curpage == 1{
                self.tableView.es.stopPullToRefresh()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            LYProgressHUD.showError(error ?? "数据获取失败，请重试！")
        }
    }
    
    
    @IBAction func addAcountAction() {
        let addAcountVC = EnterpriseAddAccountViewController.spwan()
        addAcountVC.addSuccessBlock = {() in
            self.curpage = 1
            self.loadAccountData()
        }
        self.navigationController?.pushViewController(addAcountVC, animated: true)
    }
    
}



// MARK: - tableview
extension EnterpriseAccountViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //只展示可用账户
//        if self.dataArray2.count > 0{
//            return 2
//        }else{
//            return 1
//        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.dataArray1.count
        }else{
            return self.dataArray2.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if self.dataArray1.count > indexPath.row{
                let subJson = self.dataArray1[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "EnterpriseManagerAccountCell", for: indexPath) as! EnterpriseManagerAccountCell
                cell.subJson = subJson
                cell.operationBlock = {(type) in
                    //11:设置为主账户 22:编辑 33:删除
                    var params : [String : Any] = [:]
                    params["newuser_id"] = subJson["user_id"].stringValue
                    params["business_id"] = subJson["business_id"].stringValue
                    if type == 11{
                        
                        
                        LYAlertView.show("提示", "确定将此账户设置为主账户，当前登录账户将会变为子账户", "取消", "确定",{
                            NetTools.requestData(type: .post, urlString: EnterpriseSetMainAccountApi, parameters: params, succeed: { (resultJson, msg) in
                                LYProgressHUD.showSuccess("设置成功！")
                                
                                //注销操作
                                var params2 : [String : Any] = [:]
                                params2["company_tel"] = LocalData.getUserPhone()
                                params2["client"] = "ios"
                                NetTools.requestData(type: .post, urlString: EnterpriseLogoutApi, parameters: params2, succeed: { (result, msg) in
                                }) { (error) in
                                }
                                //登录页
                                showLoginController()
                            }, failure: { (error) in
                                LYProgressHUD.showError(error ?? "设置失败，请重新尝试")
                            })
                        })
                    }else if type == 22{
                        let addAcountVC = EnterpriseAddAccountViewController.spwan()
                        addAcountVC.editJson = subJson
                        addAcountVC.addSuccessBlock = {() in
                            self.curpage = 1
                            self.loadAccountData()
                        }
                        self.navigationController?.pushViewController(addAcountVC, animated: true)
                    }else if type == 33{
                        LYAlertView.show("提示", "确定删除此账户，删除后账户订单信息不会被删除", "取消", "删除",{
                            NetTools.requestData(type: .post, urlString: EnterpriseDeleteAccountApi, parameters: params, succeed: { (resultJson, msg) in
                                LYProgressHUD.showSuccess("删除成功！")
                                self.curpage = 1
                                self.loadAccountData()
                            }, failure: { (error) in
                                LYProgressHUD.showError(error ?? "删除失败，请重新尝试")
                            })
                        })
                    }
                }
                return cell
            }
        }else{
            if self.dataArray2.count > indexPath.row{
                let subJson = self.dataArray2[indexPath.row]
                if subJson["is_del"].stringValue.intValue == 1{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EPStartUseAccountCell", for: indexPath) as! EPStartUseAccountCell
                    cell.subJson = subJson
                    cell.operationBlock = {() in
                        var params : [String : Any] = [:]
                        params["newuser_id"] = subJson["user_id"].stringValue
                        params["business_id"] = subJson["business_id"].stringValue
                        LYAlertView.show("提示", "确定启用此账户？", "取消", "确定",{
                            NetTools.requestData(type: .post, urlString: EnterpriseUnDeleteAccountApi, parameters: params, succeed: { (resultJson, msg) in
                                LYProgressHUD.showSuccess("设置成功！")
                                self.curpage = 1
                                self.loadAccountData()
                            }, failure: { (error) in
                                LYProgressHUD.showError(error ?? "设置失败，请重新尝试")
                            })
                        })
                    }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 70
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 40
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 40))
            let lbl = UILabel(frame: CGRect.init(x: 10, y: 15, width: kScreenW-20, height: 20))
            lbl.textColor = Text_Color
            lbl.font = UIFont.systemFont(ofSize: 15.0)
            lbl.text = "禁用账号"
            view.addSubview(lbl)
            return view
        }
        return nil
    }
}

