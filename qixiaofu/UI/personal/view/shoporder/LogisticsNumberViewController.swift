//
//  LogisticsNumberViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class LogisticsNumberViewController: BaseViewController {
    class func spwan() -> LogisticsNumberViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! LogisticsNumberViewController
    }
    
    var orderId = ""//订单ID
    var refund_type = ""//退换货类型
    var isFromTestService = false//代测发货给七小服平台
    var isSealerMan = false//是否是代卖者发货
    var isEPExchange = false//是否是企业购退换货
    
    var logisticsNumberSuccessBlock : (() -> Void)?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var contentH: NSLayoutConstraint!
    @IBOutlet weak var tableViewH: NSLayoutConstraint!
    fileprivate var logisticsArray : Array<String> = Array<String>()
    //
    
//    fileprivate var logisticsTF = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "物流编号"
        
        self.submitBtn.layer.cornerRadius = 20
        self.logisticsArray.append("")
        self.resetUI()
        self.tableView.register(UINib.init(nibName: "LogisticsCell", bundle: Bundle.main), forCellReuseIdentifier: "LogisticsCell")
        
        //目前涉及到用户邮寄时都是寄向七小服，暂时写死七小服地址--ly--20180611
//        if self.isFromTestService{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "邮寄地址", target: self, action: #selector(LogisticsNumberViewController.qxfAddress))
//        }
    }
    
    func setUpUI() {
        //1.输入框
//        self.logisticsTF = UITextField(frame:CGRect.init(x: 10, y: 20, width: kScreenW - 20, height: 35))
//        self.logisticsTF.placeholder = "请输入物流编号"
//        self.logisticsTF.font = UIFont.systemFont(ofSize: 14)
//        self.logisticsTF.textColor = Text_Color
//        self.logisticsTF.borderStyle = .roundedRect
//        self.view.addSubview(self.logisticsTF)
        
        //2.按钮
        let submitBtn = UIButton.init(type: .custom)
        submitBtn.frame = CGRect.init(x: 40, y: 90, width: kScreenW - 80, height: 40)
        submitBtn.clipsToBounds = true
        submitBtn.layer.cornerRadius = 20
        submitBtn.backgroundColor = Normal_Color
        submitBtn.setTitle("提交", for: .normal)
        submitBtn.setTitleColor(UIColor.white, for: .normal)
        submitBtn.addTarget(self, action: #selector(LogisticsNumberViewController.submitAction), for: .touchUpInside)
        self.view.addSubview(submitBtn)
        
        
    }
    
    //七小服地址
    @objc func qxfAddress(){
        let dict1 = ["title" : "收货人", "desc" : "七小服"]
        let dict2 = ["title" : "手机号", "desc" : "15600923777"]
        let dict3 = ["title" : "收货地址", "desc" : "北京市海淀区清河小营桥北侧青尚办公区106室"]
        NoticeView.showWithText("",[dict1,dict2,dict3])
    }
    
    @IBAction func submitAction() {
        self.view.endEditing(true)
        
        var array : Array<String> = Array<String>()
        for str in self.logisticsArray{
            if !str.trim.isEmpty{
                array.append(str)
            }
        }
        if array.count == 0{
            LYProgressHUD.showError("请至少填写一个物流编号")
            return
        }
        
        let nums = array.joined(separator: ",")
        
        if self.isFromTestService{
            var params : [String : Any] = [:]
            params["mailing_number"] = nums
            params["id"] = self.orderId
            NetTools.requestData(type: .post, urlString: TestLogisticsApi, parameters: params, succeed: { (result, msg) in
                //刷新列表
                LYProgressHUD.showSuccess("提交成功,等待收获确认！")
                if self.logisticsNumberSuccessBlock != nil{
                    self.logisticsNumberSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
            
        }else if self.isSealerMan{
            var params : [String : Any] = [:]
            params["seller_senderawb"] = nums
            params["id"] = self.orderId
            NetTools.requestData(type: .post, urlString: SealLogisticeApi, parameters: params, succeed: { (result, msg) in
                //刷新列表
                LYProgressHUD.showSuccess("提交成功,等待收获确认！")
                if self.logisticsNumberSuccessBlock != nil{
                    self.logisticsNumberSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }else if self.isEPExchange{
            var params : [String : Any] = [:]
            params["logistics_num"] = nums
            params["id"] = self.orderId
            NetTools.requestData(type: .post, urlString: EPReturnLogisticsApi, parameters: params, succeed: { (result, msg) in
                //刷新列表
                LYProgressHUD.showSuccess("提交成功,等待收获确认！")
                if self.logisticsNumberSuccessBlock != nil{
                    self.logisticsNumberSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }else{
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["order_id"] = self.orderId
            params["fanhui_sn"] = nums
            params["type"] = self.refund_type
            
            NetTools.requestData(type: .post, urlString: PurchaseExchangeApiStepTwo, parameters: params, succeed: { (result, msg) in
                //刷新列表和详情的通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
                LYProgressHUD.showSuccess("提交成功,等待收获确认！")
                if self.logisticsNumberSuccessBlock != nil{
                    self.logisticsNumberSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
    }
  

    //计算tableview高度
    func resetUI() {
        self.tableViewH.constant = CGFloat(self.logisticsArray.count * 40)
        self.contentH.constant = self.tableViewH.constant + 100
        if self.contentH.constant < kScreenH{
             self.contentH.constant = kScreenH
        }
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension LogisticsNumberViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logisticsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogisticsCell", for: indexPath) as! LogisticsCell
        if self.logisticsArray.count > indexPath.row{
            cell.logisticsTF.text = self.logisticsArray[indexPath.row]
            
            cell.minusActionBlock = {() in
                self.logisticsArray.remove(at: indexPath.row)
                self.resetUI()
            }
            
            cell.plusActionBlock = {() in
                self.logisticsArray.append("")
                self.resetUI()
            }
            
            cell.doneEditBlock = {(logistics) in
                self.logisticsArray.remove(at: indexPath.row)
                self.logisticsArray.insert(logistics, at: indexPath.row)
                self.resetUI()
            }
        }
        if self.isFromTestService || self.isEPExchange{
            if indexPath.row == 0{
                cell.minusBtn.isHidden = true
            }else{
                cell.minusBtn.isHidden = false
            }
        }else{
            cell.minusBtn.isHidden = true
            cell.plusBtn.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
