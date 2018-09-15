//
//  TestSealPriceViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/7.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestSealPriceViewController: BaseViewController {
    class func spwan() -> TestSealPriceViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! TestSealPriceViewController
    }
    
    
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var priceViewH: NSLayoutConstraint!
    @IBOutlet weak var contentH: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    var subJson = JSON()
    fileprivate var storageJson : JSON = []
    fileprivate var selectedIndex = 0//仓储套餐
    
    var refreshBlock : (() -> Void)?
    var goodsId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "代卖"
        self.descLbl.text = self.subJson["sale_info"].stringValue
        self.loadStorageData()
        self.collectionView.register(UINib.init(nibName: "StoragePriceCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StoragePriceCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "代卖规则", target: self, action: #selector(TestSealPriceViewController.rightItemAction))
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
    
    //仓储套餐数据
    func loadStorageData() {
        var params : [String : Any] = [:]
        params["id"] = self.goodsId
        NetTools.requestData(type: .post, urlString: StoragePriceApi, parameters: params, succeed: { (resultJson, msg) in
            self.storageJson = resultJson
            self.collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                self.priceViewH.constant = self.collectionView.contentSize.height + 50
                if self.descLbl.frame.maxY > kScreenH - 50{
                    self.contentH.constant = self.descLbl.frame.maxY + 10
                }else{
                    self.contentH.constant = kScreenH
                }
            })
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络错误，请重试")
        }
    }
    
    @IBAction func sureAction() {
        guard let price = self.priceTF.text else {
            LYProgressHUD.showError("请输入价格")
            return
        }
        if price.floatValue <= 0{
            LYProgressHUD.showError("价格必须大于0")
            return
        }
        
        if self.storageJson.arrayValue.count > self.selectedIndex{
            let storage = self.storageJson[self.selectedIndex]
            //            if storage["price"].stringValue.floatValue > 0{
            
            let dict = ["sys_id" : self.subJson["sys_id"].stringValue, "pay" : storage["preferential_price"].stringValue]
            let arr = [dict]
            let sysStr = arr.jsonString()
            
            //去支付
            let payVC = PaySendTaskViewController.spwan()
            payVC.isJustPay = true
            payVC.isPrepareToSeal = true
            payVC.sealPrice = price
            payVC.systermPrice = sysStr
            payVC.totalMoney = storage["preferential_price"].stringValue.doubleValue
            payVC.orderId = self.goodsId
            payVC.storageDays = storage["days"].stringValue
            payVC.rePayOrderSuccessBlock = {[weak self] () in
                if self?.refreshBlock != nil{
                    self?.refreshBlock!()
                }
                self?.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(payVC, animated: true)
        }else{
            LYProgressHUD.showError("请重新选择仓储套餐")
        }
        
        //
        
        
    }
    
    
}

extension TestSealPriceViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        return 1
    //    }
    
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
            if self.priceTF.isFirstResponder{
                self.priceTF.resignFirstResponder()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(kScreenW - 40) / 3.0, height:65)
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
    
    
}

extension TestSealPriceViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView{
            self.view.endEditing(true)
        }
    }
}
