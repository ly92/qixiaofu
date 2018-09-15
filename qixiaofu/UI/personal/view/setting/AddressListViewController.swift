//
//  AddressListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


typealias AddressListViewControllerBlock = (JSON) -> Void
class AddressListViewController: BaseTableViewController {

    fileprivate var addressArray : JSON = []
    
    var isChooseAddress = false//是否为选择地址
    var chooseAddressBlock : AddressListViewControllerBlock?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "我的收货地址"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "增加", target: self, action: #selector(AddressListViewController.addAddressAction))
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.register(UINib.init(nibName: "PayAddressCell", bundle: Bundle.main), forCellReuseIdentifier: "PayAddressCell")
        
        self.loadAddressList()
        
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.loadAddressList()
        }
    }
    
    @objc func addAddressAction() {
        let editVC = AddAddressViewController.spwan()
        editVC.editAddressBlock = {[weak self] (json) in
            //重新加载
            self?.loadAddressList()
        }
        self.navigationController?.pushViewController(editVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadAddressList() {
        var params : [String : Any] = [:]
        var url = ""
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPAddressListApi
        }else{
            url = AddressListApi
            params["store_id"] = "1"
        }
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            //停止刷新
            self.tableView.es.stopPullToRefresh()
            self.addressArray = result
            
            if result.arrayValue.count == 0{
                self.showEmptyView()
            }else{
                self.hideEmptyView()
            }
            self.tableView.reloadData()
            LYProgressHUD.dismiss()
        }) { (error) in
            //停止刷新
            self.tableView.es.stopPullToRefresh()
            LYProgressHUD.showError(error!)
        }
        
    }

}

extension AddressListViewController{
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayAddressCell", for: indexPath) as! PayAddressCell
        if self.addressArray.count > indexPath.row{
            let json = self.addressArray[indexPath.row]
            cell.jsonModel = json
            
            //设置为默认
            cell.setDefaultBlock = {[weak self] () in
                if json["is_default"].stringValue.intValue == 1{
                    return
                }
                var params : [String : Any] = [:]
                var url = ""
                
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    url = EPSetDefaultAddressApi
                    params["company_address_id"] = json["company_address_id"].stringValue
                }else{
                    url = SetDefaultAddressApi
                    params["store_id"] = "1"
                    params["address_id"] = json["address_id"].stringValue
                }
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("设置成功！")
                    //重新加载
                    self?.loadAddressList()
                }, failure: { (error) in
                    LYProgressHUD.showError(error!)
                })
            }
            
            //编辑
            cell.editBlock = {[weak self] () in
                let editVC = AddAddressViewController.spwan()
                editVC.jsonModel = json
                editVC.isEditAddress = true
                editVC.editAddressBlock = {[weak self] (json) in
                    //重新加载
                    self?.loadAddressList()
                }
                self?.navigationController?.pushViewController(editVC, animated: true)
            }
            
            //删除
            cell.deleteBlock = {[weak self] () in
                LYAlertView.show("提示", "您确定要删除此地址", "取消","删除", {
                    var params : [String : Any] = [:]
                    var url = ""
                    
                    if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                        url = EPDeleteAddressApi
                        params["company_address_id"] = json["company_address_id"].stringValue
                    }else{
                        params["store_id"] = "1"
                        params["address_id"] = json["address_id"].stringValue
                        url = DeleteAddressApi
                    }
                    LYProgressHUD.showLoading()
                    NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                        LYProgressHUD.showSuccess("删除成功！")
                        //重新加载
                        self?.loadAddressList()
                    }, failure: { (error) in
                        LYProgressHUD.showError(error!)
                    })
                })
            }

        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.addressArray.count > indexPath.row{
            let json = self.addressArray[indexPath.row]
            let str = json["area_info"].stringValue + json["address"].stringValue
            let height = str.sizeFit(width: kScreenW - 35, height: CGFloat(MAXFLOAT), fontSize: 13.0).height
            if height > 20{
                return 85 + height
            }else{
                return 100
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.isChooseAddress{
            if self.addressArray.count > indexPath.row{
                let json = self.addressArray[indexPath.row]
                if self.chooseAddressBlock != nil{
                    self.chooseAddressBlock!(json)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
}
