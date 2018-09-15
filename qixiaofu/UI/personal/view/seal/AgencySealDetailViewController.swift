//
//  AgencySealDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class AgencySealDetailViewController: BaseViewController {
    class func spwan() -> AgencySealDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! AgencySealDetailViewController
    }
    
    var refreshBlock : (() -> Void)?
    
    var orderId = ""
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var pnLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var evaluateLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var storageLeftDayLbl: UILabel!
    @IBOutlet weak var storageBtn: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var subViewH: NSLayoutConstraint!
    @IBOutlet weak var contentVH: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var storageSubView: UIView!
    @IBOutlet weak var storageSubViewH: NSLayoutConstraint!//套餐框高度与屏幕高度比例95+collectionView.height
    
    fileprivate var photoBrowseView = LYPhotoBrowseView.init(frame: CGRect())
    fileprivate var subJson : JSON = JSON()
    fileprivate var storageJson : JSON = []
    fileprivate var selectedIndex = 0//仓储套餐
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "代卖详情"
        
        self.loadDetailData()
        self.loadStorageData()
        
        self.storageSubView.layer.cornerRadius = 5
        self.collectionView.register(UINib.init(nibName: "StoragePriceCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StoragePriceCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "代卖规则", target: self, action: #selector(AgencySealDetailViewController.rightItemAction))
    }

    @objc func rightItemAction() {
        let webVC = BaseWebViewController.spwan()
        webVC.titleStr = "代卖规则"
        webVC.urlStr = "http://www.7xiaofu.com/download/help/sale-regulation.html"
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //展示评估标准
    @IBAction func showPriceDescAction() {
        let dict1 = ["title" : "估价标准", "desc" : "平台根据备件成色及市场价由估价师给出价格区间 "]
        let dict2 = ["title" : "9成新", "desc" : "有轻微划痕，标签无损伤 "]
        let dict3 = ["title" : "8成新", "desc" : "有轻微划痕  锈迹 "]
        let dict4 = ["title" : "8成新以下", "desc" : "明显损伤 划痕  锈迹 "]
        NoticeView.showWithText("提示",[dict1,dict2,dict3,dict4])
    }
    
    //加载详情
    func loadDetailData() {
        var params : [String : Any] = [:]
        params["id"] = self.orderId
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: AgencySealDetailApi,parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.subJson = resultJson
            self.prepareUISet()
        }, failure: { (error) in
            LYProgressHUD.showError(error ?? "操作失败！")
        })
        /**
         {
         "listData" : [
         {
         "consignment_price" : "300.00",
         "test_photo" : [
         "http:\/\/10.216.2.11\/download\/app\/beijian24921521513079.JPG,http:\/\/10.216.2.11\/download\/app\/beijian90641521513079.jpg"
         ],
         "determinand_sn" : "Err",
         "id" : "221",
         "min_price" : "200.00",
         "storage_choice" : 1526970460,
         "test_adjunct" : "http:\/\/10.216.2.11\/download\/app\/fujian1521513079.png",
         "stuff_state" : "5",
         "determinand_pn" : "yyy",
         "remain_day" : 60,
         "max_price" : "100.00"
         }
         ],
         "repMsg" : "",
         "repCode" : "00"
         }
         */
    }
    
    //填充数据
    func prepareUISet() {
        self.nameLbl.text = self.subJson["goods_name"].stringValue
        self.pnLbl.text = self.subJson["determinand_pn"].stringValue
        self.snLbl.text = self.subJson["determinand_sn"].stringValue
        self.evaluateLbl.text = self.subJson["min_price"].stringValue + "~" + self.subJson["max_price"].stringValue
        self.priceLbl.text = self.subJson["consignment_price"].stringValue
        if self.subJson["remain_day"].stringValue.floatValue > 0 {
            self.storageLeftDayLbl.text = "剩余" + self.subJson["remain_day"].stringValue + "天"
        }else{
            self.storageLeftDayLbl.text = "过期" + "\(-self.subJson["remain_day"].intValue)" + "天"
        }
        photoBrowseView = LYPhotoBrowseView.init(frame: CGRect.init(x: 10, y: 35, width: kScreenW - 20, height: self.subView.h-43), superVC: self)
        self.subView.addSubview(photoBrowseView)
        photoBrowseView.heightBlock = { (height) in
            self.subViewH.constant = 43 + height
            if 233 + self.subViewH.constant  > kScreenH - 50{
                self.contentVH.constant = 233 + self.subViewH.constant
            }else{
                self.contentVH.constant = kScreenH - 50
            }
        }
        var arr : Array<String> = Array<String>()
        for str in self.subJson["test_photo"].arrayValue{
            arr.append(str.stringValue)
        }
        self.photoBrowseView.showImgUrlArray = arr
        self.photoBrowseView.showDeleteBtn = false
        self.photoBrowseView.canTakePhoto = false
        
        //设置按钮
        self.btn1.isHidden = true
        self.btn2.isHidden = true
        self.btn3.isHidden = true
        self.btn1.setTitle("", for: .normal)
        self.btn2.setTitle("", for: .normal)
        self.btn3.setTitle("", for: .normal)
        self.storageBtn.isHidden = true
        self.priceBtn.isHidden = true
        let state = self.subJson["stuff_state"].stringValue
        switch state.intValue {
        case 0:
            //不代卖
            print("不代卖")
        case 1:
            //已代卖完成
            if subJson["is_aftersale"].intValue == 1{
                self.setTitle(title: "查看售后问题", btn: self.btn3)
            }else{
                self.setTitle(title: "删除", btn: self.btn3)
            }
        case 2:
            //代卖取消
            let audit_status = self.subJson["audit_status"].stringValue
            if audit_status.intValue == 12{
                //商家待发货
                self.setTitle(title: "七小服将会在2～3个工作日寄回", btn: self.btn3)
            }else if audit_status.intValue == 8{
               //客户待收货
                self.setTitle(title: "确认收货", btn: self.btn3)
            }else if audit_status.intValue == 9{
                //订单完成
                self.setTitle(title: "删除", btn: self.btn3)
            }
        case 3:
            //代卖中
            self.setTitle(title: "取消代卖", btn: self.btn3)
            self.storageBtn.isHidden = false
            self.priceBtn.isHidden = false
        case 4:
            //代卖删除
            print("代卖删除")
        case 5:
            //代卖待审核
            self.setTitle(title: "取消", btn: self.btn3)
            self.storageBtn.isHidden = false
            self.priceBtn.isHidden = false
        case 6:
            //代卖审核不通过
            self.setTitle(title: "删除", btn: self.btn3)
        case 8:
            //代卖已退货
            self.setTitle(title: "删除", btn: self.btn3)
        default:
            //
            print("我去，这是什么")
        }
    }
    
    //测报附件
    @IBAction func testResultAction() {
        let webVC = BaseWebViewController.spwan()
        webVC.titleStr = "测报附件"
        webVC.urlStr = self.subJson["test_adjunct"].stringValue
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    //续租仓储
    @IBAction func addStorageDay() {
        if self.storageView.isHidden{
            if self.subJson["stuff_state"].intValue == 3 || self.subJson["stuff_state"].intValue == 5{
                if self.subJson["remain_day"].stringValue.floatValue < 5 {
                    LYProgressHUD.showInfo("剩余5天内才可续租！")
                }else{
                    self.storageView.isHidden = false
                }
            }else{
                LYProgressHUD.showInfo("当前状态不可续租！")
                self.selectedIndex = 0
            }
        }else{
            self.storageView.isHidden = true
        }
    }
    //购买仓储套餐
    @IBAction func storageAction() {
        if self.storageJson.arrayValue.count > self.selectedIndex{
            self.storageView.isHidden = true
            let json = self.storageJson.arrayValue[self.selectedIndex]
            
            let dict = ["sys_id" : self.subJson["sys_id"].stringValue, "pay" : json["preferential_price"].stringValue]
            let arr = [dict]
            let sysStr = arr.jsonString()
            
            //去支付
            let payVC = PaySendTaskViewController.spwan()
            payVC.isJustPay = true
            payVC.isStorageMeal = true
            payVC.systermPrice = sysStr
            payVC.totalMoney = json["preferential_price"].stringValue.doubleValue
            payVC.orderId = self.orderId
            payVC.storageDays = json["days"].stringValue
            payVC.rePayOrderSuccessBlock = {[weak self] () in
                self?.loadDetailData()
            }
            self.navigationController?.pushViewController(payVC, animated: true)
        }
    }
    
    //更改价格
    @IBAction func editPriceAction() {
        if self.subJson["stuff_state"].intValue == 3 || self.subJson["stuff_state"].intValue == 5{
            UserViewModel.haveTrueName(parentVC: self) {
                let customAlertView = UIAlertView.init(title: "更改价格", message: "请输入新的价格", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                customAlertView.alertViewStyle = .plainTextInput
                let nameField = customAlertView.textField(at: 0)
                nameField?.keyboardType = .default
                nameField?.placeholder = "请输入新的价格"
                customAlertView.show()
            }
        }else{
            LYProgressHUD.showInfo("当前状态不允许更改价格！")
        }
    }
    

    //设置按钮标题
    func setTitle(title : String, btn : UIButton) {
        btn.isHidden = false
        btn.setTitle(title, for: .normal)
    }
    
    
    @IBAction func btn3Action() {
        let state = self.subJson["stuff_state"].stringValue
        switch state.intValue {
        case 0:
            //不代卖
            print("不代卖")
        case 1:
            //已代卖完成
            if self.subJson["is_aftersale"].intValue == 1{
                //申请售后中
                let afterSaleVC = SaleServiceDetailViewController.spwan()
                afterSaleVC.goods_id = self.subJson["id"].stringValue
                afterSaleVC.operationBlock = {() in
                    //退款后刷新数据
                    self.loadDetailData()
                }
                self.navigationController?.pushViewController(afterSaleVC, animated: true)
            }else{
                self.deleteGoods()
            }
        case 2:
            //代卖取消
            let audit_status = self.subJson["audit_status"].stringValue
            if audit_status.intValue == 12{
                //商家待发货
                self.setTitle(title: "七小服将会在2～3个工作日寄回", btn: self.btn3)
            }else if audit_status.intValue == 8{
                //客户待收货
                self.consigneeGoods()
            }else if audit_status.intValue == 9{
                //订单完成
                self.deleteGoods()
            }
        case 3:
            //代卖中
            self.cancelSealGoods()
        case 4:
            //代卖删除
            print("代卖删除")
        case 5:
            //代卖待审核
            self.cancelSealGoods()
        case 6:
            //代卖审核不通过
            self.deleteGoods()
        case 8:
            //代卖已退货
            self.deleteGoods()
        default:
            //
            print("我去，这是什么")
        }
    }
    
    @IBAction func btn2Action() {
    }
    
    @IBAction func btn1Action() {
    }
    
    //取消订单--代卖
    func cancelSealGoods() {
        LYAlertView.show("提示", "是否取消此单，取消操作不可逆", "放弃取消", "确定取消",{
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: CancelSealApi,parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
                self.loadDetailData()
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "取消失败！")
            })
        })
    }

    //删除订单
    func deleteGoods() {
        LYAlertView.show("提示", "是否删除此单，删除后不可找回", "取消", "删除",{
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: DeleteSealApi,parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "删除失败！")
            })
        })
    }
    
    //代卖取消客户确认收货
    func consigneeGoods() {
        LYAlertView.show("提示", "是否确认已收到所有物品", "取消", "确认",{
            var params : [String : Any] = [:]
            params["goods_id"] = self.subJson["id"].stringValue
            NetTools.requestData(type: .post, urlString: SealConsigneeApi,parameters: params, succeed: { (resultJson, msg) in
                if self.refreshBlock != nil{
                    self.refreshBlock!()
                }
                self.loadDetailData()
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            })
        })
    }
}


extension AgencySealDetailViewController : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            let nameField = alertView.textField(at: 0)
            guard let price = nameField?.text else{
                LYProgressHUD.showError("请重试！")
                return
            }
            if price.isEmpty{
                LYProgressHUD.showError("不可为空！")
                return
            }
            if price.doubleValue <= 0{
                LYProgressHUD.showError("请输入正确的价钱格式，如“1000”")
                return
            }
            
            var params : [String : Any] = [:]
            params["id"] = self.subJson["id"].stringValue
            params["consignment_price"] = price
            NetTools.requestData(type: .post, urlString: ChangeSealPriceApi,parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.showSuccess("修改成功！")
                self.loadDetailData()
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "操作失败！")
            })
            
        }
    }
}


//MARK: - 仓储套餐
extension AgencySealDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //仓储套餐数据
    func loadStorageData() {
        var params : [String : Any] = [:]
        params["id"] = self.orderId
        NetTools.requestData(type: .post, urlString: StoragePriceApi, parameters: params, succeed: { (resultJson, msg) in
            self.storageJson = resultJson
            self.collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                self.storageSubViewH.constant = self.collectionView.contentSize.height + 100
                self.storageSubViewH.constant = self.storageSubViewH.constant > kScreenH * 0.8 ? kScreenH * 0.8 : self.storageSubViewH.constant
            })
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络错误，请重试")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.storageJson.arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoragePriceCell", for: indexPath) as! StoragePriceCell
        
        cell.bgImgV.image = #imageLiteral(resourceName: "img_bg_top_gray")
        if self.storageJson.arrayValue.count > indexPath.row{
            let json = self.storageJson.arrayValue[indexPath.row]
            cell.originPriceLbl.text = "原价:" + json["cost_price"].stringValue  + "元"
            cell.priceLbl.text = json["preferential_price"].stringValue + "元/" + json["days"].stringValue + "天"
            cell.priceLbl.textColor = UIColor.RGBS(s: 33)
            if self.selectedIndex == indexPath.row{
                cell.bgImgV.image = #imageLiteral(resourceName: "textboder_bg_red")
                cell.priceLbl.textColor = Normal_Color
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if self.storageJson.arrayValue.count > indexPath.row{
            self.selectedIndex = indexPath.row
            self.collectionView.reloadData()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(kScreenW * 0.8 - 30) / 2.0, height:55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,left: 0,bottom: 5,right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
