//
//  TransferOrderViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/9.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class TransferOrderViewController: BaseViewController {
    class func spwan() -> TransferOrderViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! TransferOrderViewController
    }
    
    var transferSuccessBlock : (() -> Void)?
    
    var orderId = ""
    
    
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var contentTV: UITextView!
    @IBOutlet weak var receiverLbl: UILabel!
    @IBOutlet weak var transferBtn: UIButton!
    
    fileprivate var receiverId = ""
    fileprivate var receiverName = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "订单转移"
        self.transferBtn.layer.cornerRadius = 20
        
        self.view.addTapActionBlock { 
            self.view.endEditing(true)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseReceiverAction() {
        //选择接受者
        let associationVC = AssociationViewController()
        associationVC.isTransferOrder = true
        associationVC.transferBlock = {[weak self] (receiverId,receiverName) in
            self?.receiverId = receiverId
            self?.receiverName = receiverName
            self?.receiverLbl.text = receiverName
        }
        self.navigationController?.pushViewController(associationVC, animated: true)
    }

    @IBAction func transferAction() {
        let content = self.contentTV.text
        if (content?.isEmpty)!{
            LYProgressHUD.showError("请输入转移原因")
            return
        }
        if self.receiverId.isEmpty || self.receiverName.isEmpty{
            LYProgressHUD.showError("请选择接受者")
            return
        }
        
        var params : [String : Any] = [:]
        params["move_to_eng_id"] = self.receiverId //接受者的id
        params["id"] = self.orderId//订单id
        params["move_to_eng_name"] = self.receiverName//接受者的昵称
        params["move_reason"] = content
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: TransferOrderApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("转移成功！")
            
            //刷新列表和详情
            if self.transferSuccessBlock != nil{
                self.transferSuccessBlock!()
            }
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }
    
}

extension TransferOrderViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeholderLbl.isHidden = false
        }else{
            self.placeholderLbl.isHidden = true
        }
    }
}
