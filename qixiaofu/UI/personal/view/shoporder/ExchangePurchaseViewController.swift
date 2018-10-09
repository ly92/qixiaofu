//
//  ExchangePurchaseViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class ExchangePurchaseViewController: BaseViewController {
    class func spwan() -> ExchangePurchaseViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! ExchangePurchaseViewController
    }
    
    var orderId = ""
    
    
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var contentTextV: UITextView!
    @IBOutlet weak var imgsView: UIView!
    @IBOutlet weak var imgsViewH: NSLayoutConstraint!
    @IBOutlet weak var btnsView: UIView!
    @IBOutlet weak var purchaseBtn: UIButton!
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    fileprivate var photoView : LYMultiplePhotoBrowseView!//图片容器
    fileprivate var sns = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnsView.layer.cornerRadius = 5;
        self.submitBtn.layer.cornerRadius = 20;
        self.navigationItem.title = "退换货"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "联系客服", target: self, action: #selector(ExchangePurchaseViewController.rightItemAction))
        
        self.setUpImgView()
        
//        self.view.addTapActionBlock { 
//            if self.contentTextV.isFirstResponder{
//                self.contentTextV.resignFirstResponder()
//            }
//        }
        
        self.snLbl.addTapActionBlock { 
            //选择sn
            let replacementVC = ReplacementPartListViewController()
            replacementVC.orerId = self.orderId
            replacementVC.isPurchaseExchange = true
            replacementVC.finishChooseSnsBlock = {[weak self] (array) in
                self?.sns = array.joined(separator: ",")
                self?.snLbl.text = "共选择" + "\(array.count)" + "个"
            }
            self.navigationController?.pushViewController(replacementVC, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.contentTextV.resignFirstResponder()
    }
    
    @objc func rightItemAction() {
        //联系客服
        //登录环信
        esmobLogin()
        let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
        self.navigationController?.pushViewController(chatVC!, animated: true)
    }

    
    func setUpImgView() {
        self.photoView = LYMultiplePhotoBrowseView.init(frame: CGRect.init(x: 8, y: 0, width: kScreenW - 16, height: self.imgsViewH.constant),superVC:self)
        self.photoView.backgroundColor = UIColor.white
        self.photoView.heightBlock = { (height) in
            self.imgsViewH.constant = height
        }
        self.photoView.maxPhotoNum = 9
        self.imgsView.addSubview(self.photoView)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        self.contentTextV.resignFirstResponder()
        
        if sender.tag == 11{
            //退货
            self.purchaseBtn.backgroundColor = Normal_Color
            self.exchangeBtn.backgroundColor = UIColor.lightGray
            self.purchaseBtn.isSelected = true
            self.exchangeBtn.isSelected = false
        }else if sender.tag == 22{
            //换货
            self.purchaseBtn.backgroundColor = UIColor.lightGray
            self.exchangeBtn.backgroundColor = Normal_Color
            self.purchaseBtn.isSelected = false
            self.exchangeBtn.isSelected = true
        }else{
            //提交
            self.submitAction()
            
        }
    }
    
    //提交
    func submitAction() {
        let content = self.contentTextV.text
        if (content?.isEmpty)!{
            LYProgressHUD.showError("请输入退换货的原因")
            return;
        }
        
        if self.sns.isEmpty{
            LYProgressHUD.showError("请选择备件sn码")
            return;
        }
        
        func request(_ images : String){
            var params : [String : Any] = [:]
            params["store_id"] = "1"
            params["order_id"] = self.orderId
            params["message"] = content
            params["goods_image"] = images
            if self.exchangeBtn.isSelected{
                params["type"] = "2"
            }else{
                params["type"] = "1"
            }
            params["goods_sn"] = self.sns
            
            NetTools.requestData(type: .post, urlString: PurchaseExchangeApiStepOne, parameters: params, succeed: { (result, msg) in
                //刷新列表和详情的通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESHSHOPORDERTABLEANDDETAIL"), object: nil)
                LYProgressHUD.showSuccess("提交成功，等待审核！")
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
        
        LYProgressHUD.showLoading()
        NetTools.upLoadImage(urlString : UploadAllImageApi,imgArray: self.photoView.imgArray, success: { (result) in
            request(result)
        }, failture: { (error) in
            LYProgressHUD.showError("图片上传失败！")
        })
        
        
        
        
        
    }

}

extension ExchangePurchaseViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeHolderLbl.isHidden = false
        }else{
            self.placeHolderLbl.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.contentTextV.resignFirstResponder()
            return false
        }
        return true
    }
    
    
}
