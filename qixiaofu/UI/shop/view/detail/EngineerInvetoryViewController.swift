//
//  EngineerInvetoryViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/19.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngineerInvetoryViewController: BaseTableViewController {
    
    var titleStr = ""
    
    var goodsId = ""
    var areaId = ""
    fileprivate var engListArray : Array<JSON> = Array<JSON>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.titleStr
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "地图", target: self, action: #selector(EngineerInvetoryViewController.rightItemAction))
        
        self.tableView.backgroundColor = BG_Color
        self.tableView.register(UINib.init(nibName: "EngineerInvetoryCell", bundle: Bundle.main), forCellReuseIdentifier: "EngineerInvetoryCell")
        self.tableView.separatorStyle = .none
        
        self.loadData()
    }
    
    func loadData() {
        var params : [String : Any] = [:]
        params["goods_id"] = self.goodsId
        params["area_id"] = self.areaId
        params["store_id"] = "1"
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: EngineersLocationApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            for subJson in resultJson.arrayValue{
                self.engListArray.append(subJson)
            }
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    @objc func rightItemAction() {
        let mapMatchVC = MapMatchEngineerViewController()
        mapMatchVC.engListArray = self.engListArray
        self.navigationController?.pushViewController(mapMatchVC, animated: true)
    }
    
}


extension EngineerInvetoryViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.engListArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerInvetoryCell", for: indexPath) as! EngineerInvetoryCell
        if self.engListArray.count > indexPath.row{
            cell.subJson = self.engListArray[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.engListArray.count > indexPath.row{
            let subJson = self.engListArray[indexPath.row]
            //登录环信
            esmobLogin()
            let chatVC = EaseMessageViewController.init(conversationChatter: subJson["call_name"].stringValue, conversationType: EMConversationType.init(0))
            //保存聊天页面数据
            LocalData.saveChatUserInfo(name: subJson["call_nik_name"].stringValue, icon: subJson["duifangtouxiang"].stringValue, key: subJson["call_name"].stringValue)
            chatVC?.title = subJson["call_nik_name"].stringValue
            self.navigationController?.pushViewController(chatVC!, animated: true)
        }
    }
}
