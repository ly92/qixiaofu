//
//  GoodsLocationViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/19.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class GoodsLocationViewController: BaseTableViewController {

    var goodsId = ""
    
    fileprivate var eng_list : JSON = []
    fileprivate var shop_list : JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "商品位置"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "地图", target: self, action: #selector(GoodsLocationViewController.rightItemAction))
        
        self.tableView.backgroundColor = BG_Color
        
        
        self.loadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func rightItemAction() {
        //加载数据
        LYProgressHUD.showLoading()
        var params : [String : Any] = [:]
        params["goods_id"] = self.goodsId
        params["store_id"] = "1"
        NetTools.requestData(type: .post, urlString: MapMatchEngineerListApi,parameters: params, succeed: { (resultJson, error) in
            LYProgressHUD.dismiss()
            let mapMatchVC = MapMatchEngineerViewController()
            mapMatchVC.engListArray = resultJson.arrayValue
            self.navigationController?.pushViewController(mapMatchVC, animated: true)
//            self.stopRefresh()
            //判断是否可以加载更多
//            if resultJson.arrayValue.count < 10{
//                self.tableView.es_noticeNoMoreData()
//            }else{
//                self.tableView.es_resetNoMoreData()
//            }
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    
    func loadData() {
        var params : [String : Any] = [:]
        params["goods_id"] = self.goodsId
        params["store_id"] = "1"
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: GoodsLocationApi, parameters: params, succeed: { (resultJson, msg) in
            self.eng_list = resultJson["eng_list"]
            self.shop_list = resultJson["shop_list"]
            self.tableView.reloadData()
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
}

extension GoodsLocationViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.shop_list.arrayValue.count
        }else{
            return self.eng_list.arrayValue.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GoodsLocationViewControllerCell")
        if cell == nil{
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "GoodsLocationViewControllerCell")
        }
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell!.textLabel?.textColor = UIColor.RGBS(s: 33)
        cell!.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell!.detailTextLabel?.textColor = UIColor.RGBS(s: 33)
        
        if indexPath.section == 0{
            cell!.accessoryType = .none
            cell!.selectionStyle = .none
            if self.shop_list.arrayValue.count > indexPath.row{
                let subJson = self.shop_list.arrayValue[indexPath.row]
                cell!.textLabel?.text = subJson["name"].stringValue
                cell!.detailTextLabel?.text = subJson["count"].stringValue
            }
        }else{
            cell!.accessoryType = .disclosureIndicator
            cell!.selectionStyle = .gray
            if self.eng_list.arrayValue.count > indexPath.row{
                let subJson = self.eng_list.arrayValue[indexPath.row]
                cell!.textLabel?.text = subJson["name"].stringValue
                cell!.detailTextLabel?.text = subJson["count"].stringValue
            }
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1{
            if self.eng_list.arrayValue.count > indexPath.row{
                let subJson = self.eng_list.arrayValue[indexPath.row]
                let VC = EngineerInvetoryViewController()
                VC.titleStr = subJson["name"].stringValue
                VC.goodsId = self.goodsId
                VC.areaId = subJson["area_id"].stringValue
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 50))
        view.backgroundColor = BG_Color
        let lbl = UILabel(frame:CGRect.init(x: 10, y: 10, width: kScreenW - 20, height: 21))
        lbl.textColor = Text_Color
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        if section == 0{
            lbl.text = "商品库存"
        }else{
            lbl.text = "工程师库存"
        }
        view.addSubview(lbl)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
}
