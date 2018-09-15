//
//  SaleServiceDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/29.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SaleServiceDetailViewController: BaseViewController {
    class func spwan() -> SaleServiceDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! SaleServiceDetailViewController
    }
    
    var goods_id = ""
    
    var operationBlock : (() -> Void)?
    
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var imgsView: UIView!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var imgsVH: NSLayoutConstraint!
    @IBOutlet weak var contentVH: NSLayoutConstraint!
    @IBOutlet weak var waringLbl: UILabel!
    
    fileprivate var photoBrowseView = LYPhotoBrowseView.init(frame: CGRect())
    fileprivate var descHeight : CGFloat = 0
    fileprivate var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "问题描述"
        
        photoBrowseView = LYPhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 20, height: self.imgsView.h), superVC: self)
        self.imgsView.addSubview(photoBrowseView)
        let _ = self.waringLbl.resizeHeight()
        photoBrowseView.heightBlock = { (height) in
            self.imgsVH.constant = height
            if self.descHeight + 144 + self.waringLbl.resizeHeight() + height > kScreenH{
                self.contentVH.constant = self.descHeight + 144 + self.waringLbl.resizeHeight() + height
            }else{
                self.contentVH.constant = kScreenH
            }
        }
        
        self.loadDetail()
    }
    
    func loadDetail() {
        //申请售后中
        var params : [String : Any] = [:]
        params["goods_id"] = self.goods_id
        NetTools.requestData(type: .post, urlString: AfterSaleDetailApi,parameters: params, succeed: { (resultJson, msg) in
            self.resultJson = resultJson
            self.contentLbl.text = resultJson["aftersale_reason"].stringValue
            self.descHeight = self.contentLbl.resizeHeight()
            var arrM = Array<String>()
            for subJson in resultJson["aftersale_photo"].arrayValue{
                arrM.append(subJson.stringValue)
            }
//            arrM = resultJson["aftersale_photo"].stringValue.components(separatedBy: ",")
            self.photoBrowseView.showImgUrlArray = arrM
            self.photoBrowseView.showDeleteBtn = false
            self.photoBrowseView.canTakePhoto = false
            
            if self.descHeight + 144 + self.waringLbl.resizeHeight() + self.photoBrowseView.heightValue > kScreenH{
                self.contentVH.constant = self.descHeight + 144 + self.waringLbl.resizeHeight() + self.photoBrowseView.heightValue
            }else{
                self.contentVH.constant = kScreenH
            }
        }, failure: { (error) in
            LYProgressHUD.showError(error ?? "取消失败！")
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backMoney() {
        LYAlertView.show("确定退款？", "请您确认收到买家退回的商品后再同意退款", "取消", "确定",{
            LYProgressHUD.showLoading()
            var params : [String : Any] = [:]
            params["goods_id"] = self.goods_id
            params["aftersale_tel"] = self.resultJson["aftersale_tel"].stringValue
            NetTools.requestData(type: .post, urlString: AfterSaleRefundApi,parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.showSuccess("退款成功！")
                if self.operationBlock != nil{
                    self.operationBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "取消失败！")
            })
        })
    }
    
    @IBAction func callPhoneAction() {
        let phone = self.resultJson["aftersale_tel"].stringValue
        if phone.isEmpty{
            LYProgressHUD.showError("手机号为空！")
        }else{
            UIApplication.shared.openURL(URL(string: "telprompt:" + phone)!)
        }
        
//        LYAlertView.show("提示", "是否","未解决","已解决",{
//
//        })
    }
    

}
