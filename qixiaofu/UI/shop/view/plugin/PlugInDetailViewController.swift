//
//  PlugInDetailViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/9/7.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class PlugInDetailViewController: BaseViewController {
    class func spwan() -> PlugInDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! PlugInDetailViewController
    }
    
    var plugId = ""
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var functionLbl: UILabel!
    @IBOutlet weak var saleLbl: UILabel!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var contentH: NSLayoutConstraint!
    @IBOutlet weak var urlBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    fileprivate var contentOffet = CGPoint.zero
    fileprivate var subJson : JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "软件详情"

        self.loadDetailData()
        
        self.view.addTapActionBlock { 
            self.codeTF.resignFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.codeTF.resignFirstResponder()
    }

    //加载详情数据
    func loadDetailData() {
        var params : [String : Any] = [:]
        params["plugid"] = self.plugId
        NetTools.requestData(type: .post, urlString: PluginDetailApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.dismiss()
            self.subJson = result
            self.nameLbl.text = result["plugname"].stringValue
            self.descLbl.text = result["pluginfo"].stringValue
            self.saleLbl.text = "销  量：" + result["paynum"].stringValue
            self.urlBtn.setTitle(result["url"].stringValue, for: .normal)
            
            let height = 351 + self.descLbl.h + self.functionLbl.h + 30
            if height > kScreenH - 64{
                self.contentH.constant = height
            }else{
                self.contentH.constant = kScreenH - 64
            }
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func copyUrlAction() {
        self.codeTF.resignFirstResponder()
        UIPasteboard.general.string = self.subJson["url"].stringValue
        LYProgressHUD.showSuccess("复制成功！")
    }

    @IBAction func payAction() {
        if (self.codeTF.text?.isEmpty)!{
            LYProgressHUD.showError("请输入付款码")
            return
        }
        
        var params : [String : Any] = [:]
        params["paycode"] = self.codeTF.text
        NetTools.requestData(type: .post, urlString: PluginPayDataApi, parameters: params, succeed: { (result, msg) in
            //去支付
            let payVC = PaySendTaskViewController.spwan()
            payVC.isJustPay = true
            payVC.totalMoney = result["price"].stringValue.doubleValue
            payVC.isFromPlugin = true
            payVC.pluginOrderId = result["id"].stringValue
            payVC.rePayOrderSuccessBlock = {() in
                //支付成功
                LYAlertView.show("提示", "支付成功！客服确认后将会通过邮件与您联系，请注意查收", "知道了")
            }
            self.navigationController?.pushViewController(payVC, animated: true)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    

}

extension PlugInDetailViewController : UIScrollViewDelegate, UITextFieldDelegate{
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.codeTF.resignFirstResponder()
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.codeTF.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.contentOffet = self.scrollView.contentOffset
        self.scrollView.contentOffset = CGPoint.init(x: 0, y: 200)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.scrollView.contentOffset = self.contentOffet
    }
}
