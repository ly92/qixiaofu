//
//  AddCommentViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/3.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit



class AddCommentViewController: BaseViewController {
    class func spwan() -> AddCommentViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! AddCommentViewController
    }
    
    var orderId = ""
    var parentId = ""
    var addCommentSuccessBlock : (() -> Void)?
    
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var starDescLbl: UILabel!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    

    
    var isShowStartView = true
    fileprivate var star = StarLevelView.init(frame: CGRect(x:20, y:50, width:120, height:20),level:1)
    
    var isEngineer = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "评价"
        if self.isShowStartView{
            self.star.canChangeStar = true
            self.topView.addSubview(star)
        }else{
            self.topViewH.constant = 0
            self.topView.isHidden = true
        }
        self.submitBtn.layer.cornerRadius = 20
        
        self.view.addTapActionBlock {
            self.view.endEditing(true)
        }
        
        if self.isEngineer{
            self.starDescLbl.text = "给客户打个分吧"
        }else{
            self.starDescLbl.text = "给工程师的服务打个分吧"
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitAction() {
        if self.contentTextView.text.isEmpty{
            LYProgressHUD.showError("请输入评论内容")
            return
        }
        
        if self.isShowStartView{
            var params : [String : Any] = [:]
            params["id"] = self.orderId
            params["stars"] = self.star.level
            params["content"] = self.contentTextView.text
            var url = AddCommentToEngineerApi
            if self.isEngineer{
                url = AddCommentToCustomerApi
            }
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("评价成功")
                //返回刷新
                if self.addCommentSuccessBlock != nil{
                    self.addCommentSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }else{
            var params : [String : Any] = [:]
            params["parent_id"] = self.parentId
            params["content"] = self.contentTextView.text
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: ReplayCommentApi, parameters: params, succeed: { (result, msg) in
                LYProgressHUD.showSuccess("评价成功")
                //返回刷新
                if self.addCommentSuccessBlock != nil{
                    self.addCommentSuccessBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
        
    }

    

}

extension AddCommentViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeHolderLbl.isHidden = false
        }else{
            self.placeHolderLbl.isHidden = true
        }
    }

    
    
}



