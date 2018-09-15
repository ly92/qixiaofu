//
//  AfterSaleServiceViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/29.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class AfterSaleServiceViewController: BaseViewController {
    class func spwan() -> AfterSaleServiceViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! AfterSaleServiceViewController
    }
    
    var goodsJson : JSON = JSON()
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var pnLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var imgsView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var descViewH: NSLayoutConstraint!//imgVH + 157
    fileprivate var multiplePhotoView : LYMultiplePhotoBrowseView!//图片容器
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitBtn.layer.cornerRadius = 20
        self.descTextView.layer.cornerRadius = 5
        self.setUpGoodsData()
    }
    
    //设置商品信息
    func setUpGoodsData() {
        self.imgV.setImageUrlStr(self.goodsJson["goods_img"].stringValue)
        self.pnLbl.text = self.goodsJson["goods_name"].stringValue
        self.snLbl.text = self.goodsJson["determinand_sn"].stringValue
        self.priceLbl.text = "¥:" + self.goodsJson["goods_pay_price"].stringValue
        self.countLbl.text = "数量:" + self.goodsJson["goods_num"].stringValue
        
        self.multiplePhotoView = LYMultiplePhotoBrowseView.init(frame: CGRect.init(x: 0, y: 8, width: kScreenW - 20, height: 50),superVC:self)
        self.multiplePhotoView.backgroundColor = UIColor.white
        self.multiplePhotoView.heightBlock = {[weak self] (height) in
            self?.descViewH.constant = height + 160
        }
        self.multiplePhotoView.maxPhotoNum = 9
        self.imgsView.addSubview(self.multiplePhotoView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //提交售后申请
    @IBAction func submitAction() {
        if self.descTextView.text.isEmpty{
            LYProgressHUD.showError("请填写问题描述")
            return
        }
        
        func submit(_ images : String){
            var params : [String : Any] = [:]
            params["goods_id"] = self.goodsJson["determinand_id"].stringValue
            params["aftersale_reason"] = self.descTextView.text
            params["aftersale_tel"] = LocalData.getUserPhone()
            if !images.isEmpty{
                params["aftersale_photo"] = images
            }
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: AddAfterSaleApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("提交成功，等待卖家处理！")
                //刷新列表和详情的通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
                self.navigationController?.popViewController(animated: true)
            }, failure: { (error) in
                LYProgressHUD.showError("提交失败，请重试！")
            })
        }

        if self.multiplePhotoView.imgArray.count > 0{
            LYProgressHUD.showLoading()
            NetTools.upLoadImage(urlString : UploadAllImageApi,imgArray: self.multiplePhotoView.imgArray, success: { (result) in
                LYProgressHUD.dismiss()
                submit(result)
            }, failture: { (error) in
                LYProgressHUD.showError("图片上传失败！")
            })
        }else{
            submit("")
        }
    }
    
    
}

extension AfterSaleServiceViewController : UITextViewDelegate, UIScrollViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.placeholderLbl.isHidden = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeholderLbl.isHidden = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.descTextView.isFirstResponder{
            self.descTextView.resignFirstResponder()
        }
    }
}
