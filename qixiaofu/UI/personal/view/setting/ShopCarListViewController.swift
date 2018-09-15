//
//  ShopCarListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/31.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopCarListViewController: BaseViewController {
    class func spwan() -> ShopCarListViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! ShopCarListViewController
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selecteBtn: UIButton!
    @IBOutlet weak var totalMoneyLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewH: NSLayoutConstraint!
    
    fileprivate var dataArray : JSON = []
    
    fileprivate var invalidDataArray : JSON = []//已过期
    fileprivate var validDataArray : JSON = []//未过期
    
    fileprivate lazy var selectedArray : Array<String> = {
        let selectedArray = Array<String>()
        return selectedArray
    }()
    
    fileprivate var totalMoney : Float = 0
//    var isSelectedAll = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "购物车"
        
        self.tableView.register(UINib.init(nibName: "ShopCarGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "ShopCarGoodsCell")
        
        self.loadData()
        
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        var params : [String : Any] = [:]
        var url = ""
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPShopCarListApi
        }else{
            url = ShopCarListApi
            params["store_id"] = "1"
        }
        
//        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            self.tableView.es.stopPullToRefresh()
            LYProgressHUD.dismiss()
            
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                self.invalidDataArray = result["invalid"]
                self.validDataArray = result["valid"]
                if self.invalidDataArray.count + self.validDataArray.arrayValue.count > 0{
                    self.bottomView.isHidden = false
                    self.bottomViewH.constant = 89
                    self.hideEmptyView()
                }else{
                    self.bottomView.isHidden = true
                    self.bottomViewH.constant = 0
                    self.showEmptyView()
                }
            }else{
                self.dataArray = result["cart_list"]
                if self.dataArray.count > 0{
                    self.bottomView.isHidden = false
                    self.bottomViewH.constant = 89
                    self.hideEmptyView()
                }else{
                    self.bottomView.isHidden = true
                    self.bottomViewH.constant = 0
                    self.showEmptyView()
                }
                
            }
            
            self.tableView.reloadData()
            //计算价钱
            self.calculateMoney()
        }) { (error) in
            self.tableView.es.stopPullToRefresh()
            LYProgressHUD.showError(error!)
        }
    }
    
    //计算总价钱
    func calculateMoney() {
        totalMoney = 0
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            for subJson in self.validDataArray.arrayValue {
                if self.selectedArray.contains(subJson["goods_commonid"].stringValue){
                    totalMoney += subJson["goods_price"].stringValue.floatValue * subJson["goods_num"].stringValue.floatValue
                }
            }
        }else{
            for subJson in self.dataArray.arrayValue {
                if self.selectedArray.contains(subJson["cart_id"].stringValue){
                    totalMoney += subJson["goods_price"].stringValue.floatValue * subJson["goods_num"].stringValue.floatValue
                }
            }
        }
        self.totalMoneyLbl.text = "¥" + String.init(format: "%.2f", totalMoney) + "元"
    }

    
    @IBAction func selectedAllAction() {
        self.selecteBtn.isSelected = !self.selecteBtn.isSelected
        self.selectedArray.removeAll()
        if self.selecteBtn.isSelected{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                for subJson in self.validDataArray.arrayValue {
                    self.selectedArray.append(subJson["goods_commonid"].stringValue)
                }
            }else{
                for subJson in self.dataArray.arrayValue {
                    self.selectedArray.append(subJson["cart_id"].stringValue)
                }
            }
        }
        self.tableView.reloadData()
        //计算价钱
        self.calculateMoney()
    }

    @IBAction func goPayAction() {
        
        if self.selectedArray.count == 0{
            LYProgressHUD.showError("请至少选择一件商品！")
            return
        }
        
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
            
            var goodses : Array<JSON> = Array<JSON>()
            for subJson in self.validDataArray.arrayValue {
                if self.selectedArray.contains(subJson["goods_commonid"].stringValue){
                    let goods : JSON = ["name" : subJson["goods_name"].stringValue,
                                        "icon" : subJson["goods_image"].stringValue,
                                        "price" : subJson["goods_price"].stringValue,
                                        "id" : subJson["goods_commonid"].stringValue,
                                        "count" : subJson["goods_num"].stringValue
                    ]
                    goodses.append(goods)
                }
            }
            let payVC = EPShopPayViewController.spwan()
            payVC.isFromShopCar = true
            payVC.goodsArray = goodses
            payVC.refreshBlock = {() in
                self.loadData()
            }
            self.navigationController?.pushViewController(payVC, animated: true)
        }else{
            var cartIds : Array<String> = Array<String>()
            var goodses : Array<JSON> = Array<JSON>()
            for subJson in self.dataArray.arrayValue {
                if self.selectedArray.contains(subJson["cart_id"].stringValue){
                    let goods : JSON = ["name" : subJson["goods_name"].stringValue,
                                        "icon" : subJson["goods_image_url"].stringValue,
                                        "price" : subJson["goods_price"].stringValue,
                                        "sys" : subJson["gc_id_3"].stringValue,
                                        "count" : subJson["goods_num"].stringValue
                    ]
                    goodses.append(goods)
                    cartIds.append(subJson["cart_id"].stringValue + "|" + subJson["goods_num"].stringValue)
                }
            }
            let payVC = PayGoodsViewController.spwan()
            payVC.cartId = cartIds.joined(separator: ",")
            payVC.isFromShopCar = true
            payVC.goodsArray = goodses
            self.navigationController?.pushViewController(payVC, animated: true)
        }
        
        
    }
}

extension ShopCarListViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            if self.invalidDataArray.count > 0{
                return 2
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            if section == 0{
                return self.validDataArray.arrayValue.count
            }else{
                return self.invalidDataArray.arrayValue.count
            }
        }else{
            return self.dataArray.arrayValue.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCarGoodsCell", for: indexPath) as! ShopCarGoodsCell
        var subJson = JSON()
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            if indexPath.section == 0{
                if self.validDataArray.arrayValue.count > indexPath.row{
                    subJson = self.validDataArray.arrayValue[indexPath.row]
                    cell.invalidationLbl.isHidden = true
                    cell.invalidationDescLbl.isHidden = true
                }
            }else{
                if self.invalidDataArray.arrayValue.count > indexPath.row{
                    subJson = self.invalidDataArray.arrayValue[indexPath.row]
                    cell.invalidationLbl.isHidden = false
                    cell.invalidationDescLbl.isHidden = false
                }
            }
        }else{
            if self.dataArray.arrayValue.count > indexPath.row{
                subJson = self.dataArray.arrayValue[indexPath.row]
                cell.invalidationLbl.isHidden = true
                cell.invalidationDescLbl.isHidden = true
            }
        }
        cell.subJson = subJson
        
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            //是否选中
            if self.selectedArray.contains(subJson["goods_commonid"].stringValue){
                cell.selectedBtn.isSelected = true
            }else{
                cell.selectedBtn.isSelected = false
            }
            //选中
            cell.selectBlock = {(count) in
                //是否选中
                if self.selectedArray.contains(subJson["goods_commonid"].stringValue){
                    self.selectedArray.remove(at: self.selectedArray.index(of: subJson["goods_commonid"].stringValue)!)
                }else{
                    self.selectedArray.append(subJson["goods_commonid"].stringValue)
                }
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    self.selecteBtn.isSelected = self.selectedArray.count == self.validDataArray.arrayValue.count
                }else{
                    self.selecteBtn.isSelected = self.selectedArray.count == self.dataArray.arrayValue.count
                }
                self.tableView.reloadData()
                //计算价钱
                self.calculateMoney()
            }
        }else{
            //是否选中
            if self.selectedArray.contains(subJson["cart_id"].stringValue){
                cell.selectedBtn.isSelected = true
            }else{
                cell.selectedBtn.isSelected = false
            }
            //选中
            cell.selectBlock = {(count) in
                //是否选中
                if self.selectedArray.contains(subJson["cart_id"].stringValue){
                    self.selectedArray.remove(at: self.selectedArray.index(of: subJson["cart_id"].stringValue)!)
                }else{
                    self.selectedArray.append(subJson["cart_id"].stringValue)
                }
                self.selecteBtn.isSelected = self.selectedArray.count == self.dataArray.arrayValue.count
                self.tableView.reloadData()
                //计算价钱
                self.calculateMoney()
            }
        }
        //加
        cell.plusBlock = {[weak self] (count) in
            self?.loadData()
        }
        //减
        cell.reduceBlock = {[weak self] (count) in
            self?.loadData()
        }
        cell.parentVC = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            var subJson = JSON()
            if indexPath.section == 0{
                if self.validDataArray.count > indexPath.row{
                    subJson = self.validDataArray[indexPath.row]
                }
            }else{
//                if self.invalidDataArray.count > indexPath.row{
//                    subJson = self.invalidDataArray[indexPath.row]
//                }
            }
            if !subJson["goods_commonid"].stringValue.isEmpty{
                let detailVC = GoodsDetailViewController.spwan()
                detailVC.goodsId = subJson["goods_commonid"].stringValue
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }else{
            if self.dataArray.arrayValue.count > indexPath.row{
                let subJson = self.dataArray.arrayValue[indexPath.row]
                let detailVC = GoodsDetailViewController.spwan()
                detailVC.goodsId = subJson["goods_id"].stringValue
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 60))
            view.backgroundColor = BG_Color
            let subView = UIView(frame: CGRect.init(x: 0, y: 20, width: kScreenW, height: 40))
            subView.backgroundColor = UIColor.white
            view.addSubview(subView)
            
            let lbl1 = UILabel(frame: CGRect.init(x: 10, y: 14, width: kScreenW - 150, height: 20))
            lbl1.textColor = Text_Color
            lbl1.font = UIFont.systemFont(ofSize: 14.0)
            lbl1.text = "失效宝贝" + "\(self.invalidDataArray.count)" + "件"
            subView.addSubview(lbl1)
            
            let lbl2 = UILabel(frame: CGRect.init(x: kScreenW - 150, y: 15, width: 140, height: 20))
            lbl2.textColor = Normal_Color
            lbl2.textAlignment = .right
            lbl2.text = "清除失效宝贝"
            lbl2.font = UIFont.systemFont(ofSize: 14.0)
            subView.addSubview(lbl2)
            
            lbl2.addTapActionBlock {
                
                LYAlertView.show("提示", "确认从购物车中删除此商品？", "取消", "确认",{
                    var arr : Array<String> = Array<String>()
                    for json in self.invalidDataArray.arrayValue{
                        arr.append(json["id"].stringValue)
                    }
                    let ids = arr.joined(separator: ",")
                    var params : [String : Any] = [:]
                    params["id"] = ids
                    LYProgressHUD.showLoading()
                    NetTools.requestData(type: .post, urlString: EPDeleteShopCarSingleApi,parameters: params, succeed: { (resultJson, msg) in
                        LYProgressHUD.dismiss()
                        self.loadData()
                    }) { (error) in
                        LYProgressHUD.showError(error!)
                    }
                })
            }
            
            return view
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 60
        }
        return 0.001
    }
    
    
    //MARK:删除
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                var subJson = JSON()
                if indexPath.section == 0{
                    if self.validDataArray.count > indexPath.row{
                        subJson = self.validDataArray[indexPath.row]
                    }
                }else{
                    if self.invalidDataArray.count > indexPath.row{
                        subJson = self.invalidDataArray[indexPath.row]
                    }
                }
                if !subJson["goods_commonid"].stringValue.isEmpty{
                    LYAlertView.show("提示", "确认从购物车中删除此商品？", "取消", "确认",{
                        var params : [String : Any] = [:]
                        params["id"] = subJson["id"].stringValue
                        LYProgressHUD.showLoading()
                        NetTools.requestData(type: .post, urlString: EPDeleteShopCarSingleApi,parameters: params, succeed: { (resultJson, msg) in
                            LYProgressHUD.dismiss()
                            self.loadData()
                        }) { (error) in
                            LYProgressHUD.showError(error!)
                        }
                    })
                }
            }else{
                if self.dataArray.arrayValue.count > indexPath.row{
                    LYAlertView.show("提示", "确认从购物车中删除此商品？", "取消", "确认",{
                        let subJson = self.dataArray.arrayValue[indexPath.row]
                        var params : [String : Any] = [:]
                        params["store_id"] = "1"
                        params["cart_id"] = subJson["cart_id"].stringValue
                        LYProgressHUD.showLoading()
                        NetTools.requestData(type: .post, urlString: ShopCarDeleteGoodsApi,parameters: params, succeed: { (resultJson, msg) in
                            LYProgressHUD.dismiss()
                            self.loadData()
                        }) { (error) in
                            LYProgressHUD.showError(error!)
                        }
                    })
                }
            }
            
        }
    }
    
}
