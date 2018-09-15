//
//  TestOrderDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/6.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
class TestOrderDetailViewController: BaseViewController {
    class func spwan() -> TestOrderDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! TestOrderDetailViewController
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var logisticsBtn: UIButton!
    @IBOutlet weak var payViewBottomDis: NSLayoutConstraint!
    @IBOutlet weak var payBottomView: UIView!
    
//    var refreshTableBlock : (() -> Void)?
    //订单状态  0：待审核  1：待支付 2：订单取消 3：测试中 4:测试完成 5:审核失败 6：商家待收货 7:待发货 8:客户待收货 9:订单完成
    var orderId = ""
    fileprivate var dataArray : Array<JSON> = Array<JSON>()
    fileprivate var resultJson : JSON = []
    fileprivate var totalMoney : CGFloat = 0
    var state = "0"//订单状态
    
    fileprivate var systermPrice = ""//按照类型区分的价格
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "订单详情"
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.loadDetail()
            self?.tableView.es.stopPullToRefresh()
        }
        
        self.tableView.register(UINib.init(nibName: "TestServiceDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "TestServiceDetailCell")
        self.tableView.register(UINib.init(nibName: "TestServiceBtnCell", bundle: Bundle.main), forCellReuseIdentifier: "TestServiceBtnCell")
        
        self.loadDetail()
        
        if self.state.intValue == 1 || self.state.intValue == 7{
            self.payViewBottomDis.constant = 0
            self.payBottomView.isHidden = false
            if self.state.intValue == 7 {
                self.logisticsBtn.isHidden = false
                self.logisticsBtn.setTitle("去发货", for: .normal)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "邮寄地址", target: self, action: #selector(TestOrderDetailViewController.qxfAddress))
            }
            //            else if self.state.intValue == 8{
            //                self.logisticsBtn.isHidden = false
            //                self.logisticsBtn.setTitle("确认收货", for: .normal)
            //            }
        }else{
            self.payViewBottomDis.constant = -50
            self.payBottomView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //展示收货地址
    @objc func qxfAddress() {
        let dict1 = ["title" : "收货人", "desc" : "七小服"]
        let dict2 = ["title" : "手机号", "desc" : "15600923777"]
        let dict3 = ["title" : "收货地址", "desc" : "北京市海淀区清河小营桥北侧青尚办公区106室"]
        NoticeView.showWithText("",[dict1,dict2,dict3])
    }
    
    @objc func loadDetail() {
        var params : [String : Any] = [:]
        params["order_id"] = self.orderId
        NetTools.requestData(type: .post, urlString: TestOrderDetailApi,parameters: params, succeed: { (resultJson, msg) in
            self.dataArray.removeAll()
            self.resultJson = resultJson
            for subJson in resultJson.arrayValue{
                if subJson["mail"].stringValue.trim.isEmpty{
                    for sub in subJson["data"].arrayValue{
                        self.dataArray.append(sub)
                    }
                }
            }
            self.setUpDataView()
        }, failure: { (error) in
            LYProgressHUD.showError(error ?? "删除失败！")
        })
        
    }
    
    func setUpDataView() {
        var totalMoney : CGFloat = 0
        var sysPriceArr : Array<Dictionary<String,String>> = Array<Dictionary<String,String>>()
        for subJson in self.dataArray{
            if subJson["audit_status"].stringValue.intValue == 1{
                var temPrice : CGFloat = 0
                if subJson["choice_type"].stringValue.intValue == 1{
                    temPrice = CGFloat(subJson["test_price"].stringValue.floatValue)
                }else{
//                    totalMoney += CGFloat(subJson["test_price"].stringValue.floatValue)
                    temPrice = CGFloat(subJson["package_price"].stringValue.floatValue)
                }
                totalMoney += temPrice
                
                var have = false
                var index : Int?
                for dict in sysPriceArr{
                    if dict["sys_id"] == subJson["sys_id"].stringValue{
                        have = true
                        index = sysPriceArr.index(of: dict)
                    }
                }
                
                if have{
                    if index != nil{
                        let dict1 = sysPriceArr[index!]
                        let dict = ["sys_id" : subJson["sys_id"].stringValue, "pay" : String.init(format: "%.2f", temPrice + CGFloat(dict1["pay"]!.floatValue))]
                        sysPriceArr.remove(at: index!)
                        sysPriceArr.append(dict)
                    }
                }else{
                    let dict = ["sys_id" : subJson["sys_id"].stringValue, "pay" : String.init(format: "%.2f", temPrice)]
                    sysPriceArr.append(dict)
                }
                
            }
        }
        let str = sysPriceArr.jsonString()
        self.systermPrice = str
        print(self.systermPrice)
        self.totalPriceLbl.text = "合计: ¥" + String.init(format: "%.2f", totalMoney)
        self.totalMoney = totalMoney
        self.tableView.reloadData()
    }
    
    
    @IBAction func goLogistics() {
        if self.state.intValue == 7{
            let logisticsVC = LogisticsNumberViewController.spwan()
            logisticsVC.orderId = self.orderId
            logisticsVC.isFromTestService = true
            logisticsVC.logisticsNumberSuccessBlock = {() in
                //刷新列表的通知
                self.loadDetail()
                self.payViewBottomDis.constant = -50
                self.payBottomView.isHidden = true
                NotificationCenter.default.post(name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
            }
            self.navigationController?.pushViewController(logisticsVC, animated: true)
        }
//        else if self.state.intValue == 8{
//            LYAlertView.show("提示", "是否确认已经收到所有物品", "取消", "确定",{
//                var params : [String : Any] = [:]
//                params["id"] = self.orderId
//                NetTools.requestData(type: .post, urlString: TestSureLogisticsApi,parameters: params, succeed: { (resultJson, msg) in
//                    //刷新列表的通知
//                    self.loadDetail()
//                    self.payViewBottomDis.constant = -50
//                    NotificationCenter.default.post(name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
//                }, failure: { (error) in
//                    LYProgressHUD.showError(error ?? "取消失败！")
//                })
//            })
//        }
        
        
    }
    
    @IBAction func goPay() {
        if self.totalMoney > 0{
//            func refresh(){
//                if self.refreshTableBlock != nil{
//                    self.refreshTableBlock!()
//                }
//            }
            let payVc = PayTestServiceViewController.spwan()
            payVc.price = self.totalMoney
            payVc.orderId = self.orderId
            payVc.systermPrice = self.systermPrice
            payVc.payRefreshBlock = {() in
                self.loadDetail()
                self.state = "7"
                NotificationCenter.default.post(name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
                self.logisticsBtn.isHidden = false
            }
            self.navigationController?.pushViewController(payVc, animated: true)
        }else{
            LYProgressHUD.showError("不可支付！")
        }
    }
    
}


extension TestOrderDetailViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.resultJson.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultJson.arrayValue.count > section{
            let subJson = self.resultJson.arrayValue[section]
            return subJson["data"].arrayValue.count
        }
        return 0
        //        if self.dataArray.count > section{
        //            let subJson = self.dataArray[section]
        //            if subJson["audit_status"].intValue == 1{
        //                return 2
        //            }else{
        //                return 1
        //            }
        //        }
        //        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestServiceDetailCell", for: indexPath) as! TestServiceDetailCell
        
        if self.resultJson.arrayValue.count > indexPath.section{
            let json = self.resultJson.arrayValue[indexPath.section]
            if json["data"].arrayValue.count > indexPath.row{
                let subJson = json["data"].arrayValue[indexPath.row]
                cell.parentVC = self
                cell.subJson = subJson
                if json["mail"].stringValue.trim.isEmpty{
                    cell.bottomDis.constant = 8
                }else{
                    if subJson["audit_status"].intValue == 8 || subJson["audit_status"].intValue == 9{
                        cell.bottomDis.constant = 1
                    }
                }
                cell.deleteSingleBlock = {() in
                    var params : [String : Any] = [:]
                    params["id"] = subJson["id"].stringValue
                    params["order_price"] = subJson["order_price"].stringValue
                    NetTools.requestData(type: .post, urlString: TestServiceDeleteOneApi,parameters: params, succeed: { (resultJson, msg) in
                        self.loadDetail()
                        NotificationCenter.default.post(name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
                    }, failure: { (error) in
                        LYProgressHUD.showError(error ?? "删除失败！")
                    })
                }
                cell.refreBlock = {() in
                    self.loadDetail()
                }
                
                cell.backOwnerBlock = {() in
                    var params : [String : Any] = [:]
                    params["id"] = subJson["id"].stringValue
                    NetTools.requestData(type: .post, urlString: TestServiceBackOwnerApi,parameters: params, succeed: { (resultJson, msg) in
                        self.loadDetail()
                        NotificationCenter.default.post(name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
                        LYProgressHUD.showSuccess("操作成功！")
                    }, failure: { (error) in
                        LYProgressHUD.showError(error ?? "操作失败！")
                    })
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.resultJson.arrayValue.count > indexPath.section{
            let json = self.resultJson.arrayValue[indexPath.section]
            if json["data"].arrayValue.count > indexPath.row{
                let subJson = json["data"].arrayValue[indexPath.row]
                let reasonStr = subJson["audit_reason"].stringValue
                var height : CGFloat = 0
                let size = reasonStr.sizeFit(width: kScreenW-30, height: CGFloat(MAXFLOAT), fontSize: 14.0)
                if  subJson["audit_status"].intValue == 6 || subJson["audit_status"].intValue == 7 {
                    if size.height < 10{
                        height = 105
                    }else{
                      height = 115 + size.height
                    }
                }else{
                    if size.height < 10{
                        height = 140
                    }else{
                        height = 150 + size.height
                    }
                }
                //是否为多张图片
                if subJson["order_photo"].arrayValue.count > 1{
                    return height + 55
                }else{
                    return height
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.resultJson.arrayValue.count > section{
            let subJson = self.resultJson.arrayValue[section]
            if !subJson["mail"].stringValue.trim.isEmpty{
                let view = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 40))
                view.backgroundColor = UIColor.white
                let leftLbl = UILabel(frame:CGRect.init(x: 10, y: 10, width: kScreenW/2 , height: 21))
                leftLbl.text = "物流号:" + subJson["mail"].stringValue
                leftLbl.textColor = Text_Color
                leftLbl.font = UIFont.systemFont(ofSize: 14)
                view.addSubview(leftLbl)
                
                let rightLbl = UILabel(frame:CGRect.init(x: kScreenW/2+10 , y: 10, width: kScreenW/2 - 20 , height: 21))
                rightLbl.textColor = Normal_Color
                rightLbl.textAlignment = .right
                rightLbl.font = UIFont.systemFont(ofSize: 14)
                view.addSubview(rightLbl)
                if subJson["data"].arrayValue.count > 0{
                    let json = subJson["data"].arrayValue[0]
                    if json["audit_status"].intValue == 8{
                        rightLbl.text = "待收货"
                    }else if json["audit_status"].intValue == 9{
                        rightLbl.text = "已收货"
                    }
                }
                
                let line = UIView(frame:CGRect.init(x: 0, y: 40, width: kScreenW, height: 1))
                line.backgroundColor = BG_Color
                view.addSubview(line)
                return view
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.resultJson.arrayValue.count > section{
            let subJson = self.resultJson.arrayValue[section]
            if !subJson["mail"].stringValue.trim.isEmpty{
                let view = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 45))
                view.backgroundColor = UIColor.white
                
                if subJson["data"].arrayValue.count > 0{
                    let json = subJson["data"].arrayValue[0]
                    if json["audit_status"].intValue == 8{
                        let btn1 = UIButton(frame:CGRect.init(x: kScreenW-190, y: 6, width: 80, height: 25))
                        btn1.setBackgroundImage(#imageLiteral(resourceName: "img_bg_top"), for: .normal)
                        btn1.setTitle("确认收货", for: .normal)
                        btn1.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
                        btn1.setTitleColor(Normal_Color, for: .normal)
                        btn1.tag = section
                        btn1.addTarget(self, action: #selector(TestOrderDetailViewController.sureLogistics(btn:)), for: .touchUpInside)
                        view.addSubview(btn1)
                    }
                }
                let btn2 = UIButton(frame:CGRect.init(x: kScreenW-100, y: 6, width: 80, height: 25))
                btn2.setBackgroundImage(#imageLiteral(resourceName: "img_bg_top"), for: .normal)
                btn2.setTitle("查看物流", for: .normal)
                btn2.setTitleColor(Normal_Color, for: .normal)
                btn2.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
                btn2.tag = section
                btn2.addTarget(self, action: #selector(TestOrderDetailViewController.logisticsDetail(btn:)), for: .touchUpInside)
                view.addSubview(btn2)
                
                let line = UIView(frame:CGRect.init(x: 0, y: 40, width: kScreenW, height: 13))
                line.backgroundColor = BG_Color
                view.addSubview(line)
                return view
            }
        }
        return nil
    }
    
    //查看物流
    @objc func logisticsDetail(btn:UIButton) {
        //查看物流
        if self.resultJson.arrayValue.count > btn.tag{
            let subJson = self.resultJson.arrayValue[btn.tag]
            if !subJson["mail"].stringValue.trim.isEmpty{
                let logisticsVC = LogisticsInfoViewController()
                logisticsVC.number = subJson["mail"].stringValue.trim
                self.navigationController?.pushViewController(logisticsVC, animated: true)
                
//                let webVC = BaseWebViewController.spwan()
//                webVC.titleStr = "查看物流"
//                webVC.urlStr = usedServer + "/shop/index.php?act=login&op=wuliuxiangqing&order_id=" + subJson["mail"].stringValue.trim
//                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
    }
    
    //确认收货
    @objc func sureLogistics(btn:UIButton) {
        if self.resultJson.arrayValue.count > btn.tag{
            let subJson = self.resultJson.arrayValue[btn.tag]
            if !subJson["mail"].stringValue.trim.isEmpty{
                var arr : Array<String> = Array<String>()
                for json in subJson["data"].arrayValue{
                    arr.append(json["id"].stringValue)
                }
                LYAlertView.show("提示", "是否确认已经收到此物流中的所有物品", "取消", "确定",{
                    var params : [String : Any] = [:]
                    params["goods_id"] = arr.joined(separator: ",")
                    NetTools.requestData(type: .post, urlString: TestSureLogisticsApi,parameters: params, succeed: { (resultJson, msg) in
                        //刷新列表的通知
                        self.loadDetail()
                        NotificationCenter.default.post(name: NSNotification.Name.init("RefreshTestTableView"), object: nil)
                    }, failure: { (error) in
                        LYProgressHUD.showError(error ?? "取消失败！")
                    })
                })
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.resultJson.arrayValue.count > section{
            let subJson = self.resultJson.arrayValue[section]
            if !subJson["mail"].stringValue.trim.isEmpty{
                return 40
            }
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.resultJson.arrayValue.count > section{
            let subJson = self.resultJson.arrayValue[section]
            if !subJson["mail"].stringValue.trim.isEmpty{
                return 50
            }
        }
        return 0.01
    }
}


