//
//  EPSettingTableViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/20.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import StoreKit

class EPSettingTableViewController: BaseTableViewController {
    
    fileprivate let titleArray = [["设置支付密码","修改登录密码","收货地址","实名认证"],["清理缓存","关于我们","关于App","给我五星评价"],["用户协议","意见反馈"],["退出账号"]]
    
    var isSetPayPwd = false//是否已设置支付密码
    var isReal : Int = 0//is_real 企业会员是否实名 0未实名 1已实名 2实名审核中
    var isEpReal = false//企业信息是否已审核通过
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = BG_Color
        self.tableView.separatorStyle = .none
        self.navigationItem.title = "设置"
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.titleArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell")
        if cell == nil{
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SettingCell")
        }
        cell!.textLabel?.textColor = Text_Color
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell!.textLabel?.text = self.titleArray[indexPath.section][indexPath.row]
        cell!.detailTextLabel?.textColor = UIColor.lightGray
        cell!.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
        if indexPath.section == 1 && indexPath.row == 2{
            cell!.detailTextLabel?.text = appVersion()
        }else if indexPath.section == 1 && indexPath.row == 0{
            cell!.detailTextLabel?.text = self.getFileSize()
        }else if indexPath.section == 0 && indexPath.row == 3{
            if self.isReal == 1{
                //已实名
                cell!.detailTextLabel?.text = "已实名"
            }else if self.isReal == 2{
                //实名审核中
                cell!.detailTextLabel?.text = "实名审核中"
            }else{
                //未实名
                cell!.detailTextLabel?.text = "未实名"
            }
        }else{
            cell!.detailTextLabel?.text = ""
        }
        let line = UIView(frame:CGRect.init(x: 0, y: 43, width: kScreenW, height: 1))
        line.backgroundColor = BG_Color
        cell!.addSubview(line)
        if indexPath.section == 3{
            cell!.textLabel?.textAlignment = .center
            cell!.accessoryType = .none
            cell!.textLabel?.textColor = Normal_Color
        }else{
            if indexPath.section == 0 && indexPath.row == 0 && self.isSetPayPwd{
                cell!.textLabel?.text = "修改支付密码"
            }
            cell!.textLabel?.textAlignment = .left
            cell!.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    
    
    func getFileSize() -> String {
        // 路径
        guard let basePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else{
            return "0MB"
        }
        let fileManager = FileManager.default
        // 遍历出所有缓存文件加起来的大小
        func caculateCache() -> Float{
            var total: Float = 0
            if fileManager.fileExists(atPath: basePath){
                let childrenPath = fileManager.subpaths(atPath: basePath)
                if childrenPath != nil{
                    for path in childrenPath!{
                        let childPath = basePath.appending("/").appending(path)
                        do{
                            let attr:NSDictionary = try fileManager.attributesOfItem(atPath: childPath) as NSDictionary
                            let fileSize = attr["NSFileSize"] as! Float
                            total += fileSize
                        }catch _{
                        }
                    }
                }
            }
            // 缓存文件大小
            return total
        }
        // 调用函数
        let totalCache = caculateCache()
        return NSString(format: "%.2f MB", totalCache / 1024.0 / 1024.0 ) as String
    }
    
    // 清除缓存
    func clearCache() {
        // 取出cache文件夹目录 缓存文件都在这个目录下
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else{
            return
        }
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath)
        if fileArr == nil{
            return
        }
        // 遍历删除
        for file in fileArr! {
            // 拼接文件路径
            let path = cachePath.appending("/\(file)")
            if FileManager.default.fileExists(atPath: path) {
                // 循环删除
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    // 删除失败
                }
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0{
            if indexPath.row == 0{
//                UserViewModel.haveTrueName(parentVC: self) {
                    if self.isSetPayPwd{
                        //修改支付密码
                        let setPayPwdVc = ChangePasswordViewController.spwan()
                        setPayPwdVc.type = .changePayPwd
                        self.navigationController?.pushViewController(setPayPwdVc, animated: true)
                    }else{
                        //设置支付密码
                        let changePayPwdVc = ChangePasswordViewController.spwan()
                        changePayPwdVc.type = .setPayPwd
                        changePayPwdVc.setPayPwdSuccessBlock = {() in
                            self.isSetPayPwd = true
                            self.tableView.reloadData()
                        }
                        self.navigationController?.pushViewController(changePayPwdVc, animated: true)
                    }
//                }
            }else if indexPath.row == 1{
                //修改登录密码
                let changePwdVc = ChangePasswordViewController.spwan()
                changePwdVc.type = .changeEPPwd
                self.navigationController?.pushViewController(changePwdVc, animated: true)
            }else if indexPath.row == 2{
                //收货地址
                let addressVC = AddressListViewController()
                self.navigationController?.pushViewController(addressVC, animated: true)
            }else if indexPath.row == 3{
                //去实名
                let idVC = IdentityViewController.spwan()
                self.navigationController?.pushViewController(idVC, animated: true)
            }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                //清理缓存
                LYAlertView.show("提示", "是否清除缓存的文件，包括缓存的视频", "取消", "确定",{
                    self.clearCache()
                    LYProgressHUD.showSuccess("清理成功！")
                    self.tableView.reloadData()
                })
                
            }else if indexPath.row == 1{
                //关于我们
                let webVC = BaseWebViewController.spwan()
                webVC.titleStr = "关于我们"
                webVC.urlStr = usedServer + "download/about/about.html"
                self.navigationController?.pushViewController(webVC, animated: true)
                
            }else if indexPath.row == 2{
                //关于App
                let aboutApp = AboutAppViewController()
                self.navigationController?.pushViewController(aboutApp, animated: true)
            }else if indexPath.row == 3{
                //给我五星评价
                if #available(iOS 10.3, *){
                    SKStoreReviewController.requestReview()
                }else{
                    let urlStr = "itms-apps://itunes.apple.com/cn/app/id1171281585?mt=8"
                    if UIApplication.shared.canOpenURL(URL(string:urlStr)!){
                        UIApplication.shared.openURL(URL(string:urlStr)!)
                    }else{
                        LYProgressHUD.showInfo("暂时无法评价！")
                    }
                }
                //                https://itunes.apple.com/us/app/七小服/id1171281585?l=zh&ls=1&mt=8
            }
        }else if indexPath.section == 2{
            if indexPath.row == 0{
                //用户协议
                let webVC = BaseWebViewController.spwan()
                webVC.titleStr = "用户协议"
                webVC.urlStr = usedServer + "download/xieyi/xieyi.html"
                self.navigationController?.pushViewController(webVC, animated: true)
            }else if indexPath.row == 1{
                //意见反馈
                let feedbackVC = SendTaskSureViewController.spwan()
                feedbackVC.isFeedback = true
                self.navigationController?.pushViewController(feedbackVC, animated: true)
            }
        }else{
            //退出
           self.logout()
        }
    }
    
    func logout(){
        func logoutOperation(){
            //退出
            self.navigationController?.popToRootViewController(animated: false)
            //登录页
            showLoginController()
        }
        
        var params : [String : Any] = [:]
        params["company_tel"] = LocalData.getUserPhone()
        params["client"] = "ios"
        NetTools.requestData(type: .post, urlString: EnterpriseLogoutApi, parameters: params, succeed: { (result, msg) in
            logoutOperation()
        }) { (error) in
            LYProgressHUD.dismiss()
            LYAlertView.show("提示", "退出失败，是否强制退出？","取消","确定", {
                logoutOperation()
            })
        }
    }
}