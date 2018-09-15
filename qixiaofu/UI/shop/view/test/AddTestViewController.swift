//
//  AddTestViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddTestViewController: BaseViewController {
    class func spwan() -> AddTestViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! AddTestViewController
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalMoneyLbl: UILabel!
    @IBOutlet weak var addOneView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var testServiceArray : JSON = []
    var firstSecId = ""

    /**
     id,pn,photos(sn,img),type,hide
     (String,String,Array<(String,String)>,Int,Bool)
     */
    fileprivate var secConfDict : Dictionary<String,(String,String,Array<(String,String)>,Int,Bool)> = Dictionary<String,(String,String,Array<(String,String)>,Int,Bool)>()
    fileprivate let normalSec = ("","",[("","")],2,false)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "提交代测信息"
        self.tableView.register(UINib.init(nibName: "AddTestCell1", bundle: Bundle.main), forCellReuseIdentifier: "AddTestCell1")
        self.tableView.register(UINib.init(nibName: "AddTestCell2", bundle: Bundle.main), forCellReuseIdentifier: "AddTestCell2")
        self.tableView.register(UINib.init(nibName: "AddTestCell3", bundle: Bundle.main), forCellReuseIdentifier: "AddTestCell3")
        self.tableView.register(UINib.init(nibName: "AddTestCell4", bundle: Bundle.main), forCellReuseIdentifier: "AddTestCell4")
        self.categoryCollectionView.register(UINib.init(nibName: "FiltrateCell", bundle: Bundle.main), forCellWithReuseIdentifier: "AddTestFiltrateCell")
        self.categoryCollectionView.contentInset = UIEdgeInsetsMake(10,8, 15, 8)
        self.secConfDict["sec-0"] = self.normalSec
        self.secConfDict["sec-0"]!.0 = self.firstSecId
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAddAction() {
        self.addOneView.isHidden = true
    }
    
    @IBAction func goPay() {
        var params : [String : Any] = [:]
//        params["order_userid"] = LocalData.getUserId()
        params["goods_num"] = "\(self.getOrderTotalNUm())"
        params["order_price"] = self.calculateTotalPrice()
        let goodInfo = self.getOrderString()
        if goodInfo == nil{
            return
        }
        params["goods_info"] = goodInfo!
        
        NetTools.requestData(type: .post, urlString: SubmitTestServiceApi, parameters: params, succeed: { (result, msg) in
            LYAlertView.show("提示", "您的申请已提交，我们将在2个工作日内审核。\n 请到代测订单中查看订单状态！", "知道了",{
                self.navigationController?.popViewController(animated: true)
            })
        }) { (error) in
            LYProgressHUD.showError(error ?? "提交失败，请重试")
        }
        
//        NetTools.requestDataTest(urlString: SubmitTestServiceApi, parameters: params, succeed: { (result) in
//            print(result)
//        }) { (error) in
//            LYProgressHUD.showError(error ?? "---")
//        }
    }
    
    
    //计算总金额
    func calculateTotalPrice() -> CGFloat {
        var totalMoney : CGFloat = 0.0
        for value in self.secConfDict.values{
            var subJson : JSON = []
            for json in self.testServiceArray.arrayValue{
                if json["id"].stringValue == value.0{
                    subJson = json
                }
            }
            var money : CGFloat = 0.0
            if !value.4{
                if value.3 == 1{
                    money = CGFloat(subJson["test_price"].floatValue) * CGFloat(value.2.count)
                }else if value.3 == 2{
//                    money = CGFloat(subJson["test_price"].floatValue) * CGFloat(value.2.count)
                    money += CGFloat(subJson["packing_price"].floatValue) * CGFloat(value.2.count)
                }
            }
            totalMoney += money
        }
        self.totalMoneyLbl.text = "¥"+String.init(format: "%0.2f", totalMoney)
        return totalMoney
    }
    
    //汇总所有
    func getOrderString() -> String? {
        var totalArray : Array<Dictionary<String,String>> = Array<Dictionary<String,String>>()
        for value in self.secConfDict.values{
            if !value.4{
                if value.1.isEmpty{
                    LYProgressHUD.showError("PN号不可为空")
                    return nil
                }
                for sn in value.2{
                    if sn.0.isEmpty || sn.1.isEmpty{
                        LYProgressHUD.showError("图片上传未成功！")
                        return nil
                    }
                    var dict : Dictionary<String,String> = Dictionary<String,String>()
                    dict["sys_id"] = value.0
                    dict["determinand_sn"] = sn.0
                    dict["determinand_pn"] = value.1
                    dict["determinand_photo"] = sn.1
                    dict["choice_type"] = "\(value.3)"
                    totalArray.append(dict)
                }
            }
        }
        return totalArray.jsonString()
    }
    
    //汇总所有
    func getOrderTotalNUm() -> Int {
        var num : Int = 0
        for value in self.secConfDict.values{
            if !value.4{
                num += value.2.count
            }
        }
        return num
    }
}

extension AddTestViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.secIdArray.count + 1
        return self.secConfDict.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == self.secConfDict.count{
            return 1
        }
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == self.secConfDict.count{
            let cell4 = tableView.dequeueReusableCell(withIdentifier: "AddTestCell4", for: indexPath) as! AddTestCell4
            cell4.addBlock = {() in
                self.addOneView.isHidden = false
                self.view.endEditing(true)
            }
            return cell4
        }else{
            let str = "sec-\(indexPath.section)"
            if self.secConfDict[str] != nil && self.secConfDict[str]!.4{
                return UITableViewCell()
            }
            
            if indexPath.row == 0{
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "AddTestCell1", for: indexPath) as! AddTestCell1
                cell1.pnTF.text = self.secConfDict[str]!.1
                cell1.doneEditPNBlock = {(pnStr) in
                    self.secConfDict[str]!.1 = pnStr
                }
                return cell1
            }else if indexPath.row == 1{
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "AddTestCell2", for: indexPath) as! AddTestCell2
                cell2.superVC = self
                var descArr : Array<String> = Array<String>()
                for cupe in self.secConfDict[str]!.2{
                    if !cupe.0.isEmpty && !cupe.1.isEmpty{
                        let arr = cupe.1.components(separatedBy: ",")
                        if arr.count > 0{
                            descArr.append(cupe.0)
                        }
                    }
                }
                cell2.imgDescArray = descArr
                cell2.photoNumChangeBlock = {(descArray,urlArray) in
                    if descArray.count == urlArray.count{
                        var arr : Array<(String,String)> = Array<(String,String)>()
                        for i in 0...descArray.count - 1{
                            arr.append((descArray[i],urlArray[i]))
                        }
                        self.secConfDict[str]!.2 = arr
                        self.tableView.reloadData()
                    }
                }
                return cell2
            }else{
                let cell3 = tableView.dequeueReusableCell(withIdentifier: "AddTestCell3", for: indexPath) as! AddTestCell3
                
                var subJson : JSON = []
                for json in self.testServiceArray.arrayValue{
                    if json["id"].stringValue == self.secConfDict[str]!.0{
                        subJson = json
                    }
                }
                
                cell3.selectBtnBlock = {(index) in
                    if index == 1 || index == 2{
                        self.secConfDict[str]!.3 = index
                        self.tableView.reloadData()
                    }else if index == 3{
                        //仅测试
                        let dict1 = ["title" : "仅测试", "desc" : "仅测试的产品不提供包装和寄回服务，不可在平台代卖，需用户到七小服测试点自提"]
                        let dict2 = ["title" : "测试标准", "desc" : subJson["test_standard"].stringValue]
                        let dict3 = ["title" : "包装标准", "desc" : "静电袋简装"]
                        NoticeView.showWithText("提示",[dict1,dict2,dict3])
                    }else if index == 4{
                        //测试后包装
                        let dict1 = ["title" : "测试后包装", "desc" : "测试后包装的产品提供免费包装和寄回服务需到付，可选择在平台代卖服务"]
                        let dict2 = ["title" : "测试标准", "desc" : subJson["test_standard"].stringValue]
                        let dict3 = ["title" : "包装标准", "desc" : subJson["packing_standard"].stringValue]
                        NoticeView.showWithText("提示",[dict1,dict2,dict3])
                    }
                    
                }
                
                var money : CGFloat = 0.0
                if self.secConfDict[str]!.3 == 1{
                    money = CGFloat(subJson["test_price"].floatValue) * CGFloat(self.secConfDict[str]!.2.count)
                    cell3.btn2.setImage(#imageLiteral(resourceName: "btn_checkbox_n"), for: .normal)
                    cell3.btn1.setImage(#imageLiteral(resourceName: "btn_checkbox_s"), for: .normal)
                }else if self.secConfDict[str]!.3 == 2{
//                    money = CGFloat(subJson["test_price"].floatValue) * CGFloat(self.secConfDict[str]!.2.count)
                    money += CGFloat(subJson["packing_price"].floatValue) * CGFloat(self.secConfDict[str]!.2.count)
                    cell3.btn1.setImage(#imageLiteral(resourceName: "btn_checkbox_n"), for: .normal)
                    cell3.btn2.setImage(#imageLiteral(resourceName: "btn_checkbox_s"), for: .normal)
                }
                cell3.moneyLbl.text = "¥" + String.init(format: "%0.2f", money)
                cell3.deleteBtnBlock = {() in
                    self.secConfDict[str]!.4 = true
                    self.tableView.reloadData()
                }
                let _ = self.calculateTotalPrice()
                return cell3
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == self.secConfDict.count{
            return 70
        }else{
            let str = "sec-\(indexPath.section)"
            if self.secConfDict[str] != nil && self.secConfDict[str]!.4{
                return 0.01
            }
            if indexPath.row == 0{
                return 45
            }else if indexPath.row == 1{
                if self.secConfDict[str] != nil{
                    if self.secConfDict[str]!.2.count > 0{
                        return CGFloat(self.secConfDict[str]!.2.count * 30 + 46)
                    }
                }
                return 80
            }else{
                return 76
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let str = "sec-\(section)"
        if section == 0 || section == self.secConfDict.count  || (self.secConfDict[str] != nil && self.secConfDict[str]!.4){
            return 0.001
        }
        return 8
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView as? UITableView == self.tableView{
            self.view.endEditing(true)
        }
    }
    
}

extension AddTestViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.testServiceArray.arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTestFiltrateCell", for: indexPath) as! FiltrateCell
        if self.testServiceArray.arrayValue.count > indexPath.row{
            let json = self.testServiceArray.arrayValue[indexPath.row]
            item.titleLbl.text = json["systematic_name"].stringValue
            item.titleLbl.backgroundColor = BG_Color
            item.titleLbl.layer.cornerRadius = 5
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.testServiceArray.arrayValue.count > indexPath.row{
            let json = self.testServiceArray.arrayValue[indexPath.row]
            self.addOneView.isHidden = true
            let str = "sec-" + "\(self.secConfDict.count)"
            self.secConfDict[str] = self.normalSec
            self.secConfDict[str]!.0 = json["id"].stringValue
            self.tableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.testServiceArray.arrayValue.count > indexPath.row{
            let json = self.testServiceArray.arrayValue[indexPath.row]
            let str = json["systematic_name"].stringValue
            let size = str.sizeFit(width: CGFloat(MAXFLOAT), height: 21, fontSize: 14)
            return CGSize.init(width: size.width + 20, height: 30)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
