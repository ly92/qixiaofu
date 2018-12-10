//
//  AddCertificateViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/26.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class AddCertificateViewController: BaseViewController {
    class func spwan() -> AddCertificateViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! AddCertificateViewController
    }
    
    @IBOutlet weak var certNameTextV: UITextView!
    @IBOutlet weak var placeholderLbl: UILabel!
    
    @IBOutlet weak var certImgView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var isFromAddTest = false
    var addTestBlock : ((String,String) -> Void)?
    var deleteTestBlock : (() -> Void)?
    var operationBlock : (() -> Void)?
    
    var certName = ""
    var certImg : UIImage?
    var depth = ""
    var certId = ""
    var imgUrl = ""
    
    var photoView = LYPhotoBrowseView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.deleteBtn.layer.cornerRadius = 15
        
        if self.isFromAddTest{
            self.navigationItem.title = "上传图片"
            self.placeholderLbl.text = "请输入SN号(选填)，图片必须要拍到SN"
        }else{
            self.navigationItem.title = "上传职业证书"
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", target: self, action: #selector(AddCertificateViewController.rightItemAction))
        
        self.photoView = LYPhotoBrowseView.init(frame: CGRect.init(x: 5, y: 5, width: 50, height: 50),superVC:self)
        self.photoView.backgroundColor = UIColor.white
        self.photoView.maxPhotoNum = 1
        self.photoView.canTakePhoto = true
        self.photoView.showDeleteBtn = true
        self.photoView.imageBlock = { (img) in

        }
        
        self.certImgView.addSubview(self.photoView)
        
        if self.certImg != nil{
            self.deleteBtn.isHidden = false
            self.photoView.imgArray = [self.certImg!]
            self.photoView.imgUrlArray = [self.imgUrl]
            if self.certName.isEmpty{
                self.placeholderLbl.isHidden = false
            }else{
                self.placeholderLbl.isHidden = true
            }
            self.certNameTextV.text = self.certName
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteAction() {
        
        if self.isFromAddTest{
            if self.deleteTestBlock != nil{
                self.deleteTestBlock!()
                if self.operationBlock != nil{
                    self.operationBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            var params : [String : Any] = [:]
            params["depth"] = self.certId
            NetTools.requestData(type: .post, urlString: DeleteCertificateApi, parameters: params, succeed: { (result, msg) in
                if self.operationBlock != nil{
                    self.operationBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
    }
    
    //
    @objc func rightItemAction() {
        
        if self.photoView.imgUrlArray.count == 0{
            if self.isFromAddTest{
                LYProgressHUD.showError("请上传图片")
            }else{
                LYProgressHUD.showError("请上传证书图片")
            }
            return
        }
        if self.certNameTextV.text.isEmpty{
            if self.isFromAddTest{
//                LYProgressHUD.showError("请输入SN号")
            }else{
                LYProgressHUD.showError("请填写证书名称")
                return
            }
        }
        
        self.imgUrl = self.photoView.imgUrlArray.last!
        
        if self.isFromAddTest{
            if self.addTestBlock != nil{
                if self.certNameTextV.text.isEmpty{
                    self.addTestBlock!(" ",self.imgUrl)
                }else{
                    self.addTestBlock!(self.certNameTextV.text!,self.imgUrl)
                }
                if self.operationBlock != nil{
                    self.operationBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            var params : [String : Any] = [:]
            params["cer_image"] = self.imgUrl
            params["cer_name"] = self.certNameTextV.text
            params["depth"] = self.depth
            NetTools.requestData(type: .post, urlString: AddCertificateApi, parameters: params, succeed: { (result, msg) in
                if self.operationBlock != nil{
                    self.operationBlock!()
                }
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                LYProgressHUD.showError(error!)
            }
        }
        
    }

    

}

extension AddCertificateViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
        self.placeholderLbl.isHidden = false
        }else{
        self.placeholderLbl.isHidden = true
        }
    }
}
