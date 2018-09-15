//
//  AddTestSnViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/11.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class AddTestSnViewController: BaseViewController {
    class func spwan() -> AddTestSnViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! AddTestSnViewController
    }
    
    
    @IBOutlet weak var snTF: UITextField!
    @IBOutlet weak var imgsView: UIView!
    @IBOutlet weak var imgViewH: NSLayoutConstraint!
    @IBOutlet weak var deleteBtn: UIButton!
    var addTestBlock : ((String,String) -> Void)?
    var deleteTestBlock : (() -> Void)?
    var imgUrlArray : Array<String> = Array<String>()
    var snStr = ""
    
    
    fileprivate var multiplePhotoView : LYMultiplePhotoBrowseView!//图片容器
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "上传图片"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", target: self, action: #selector(AddTestSnViewController.rightItemAction))
        self.multiplePhotoView = LYMultiplePhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: 60),superVC:self)
        self.multiplePhotoView.backgroundColor = UIColor.clear
        self.multiplePhotoView.heightBlock = {[weak self] (height) in
            self?.imgViewH.constant = height
        }
        self.multiplePhotoView.maxPhotoNum = 6
        self.imgsView.addSubview(self.multiplePhotoView)
        self.deleteBtn.layer.cornerRadius = 20
        
        if !self.snStr.isEmpty && self.imgUrlArray.count > 0{
            self.snTF.text = self.snStr
            self.multiplePhotoView.imgUrlArray = self.imgUrlArray
            self.deleteBtn.isHidden = false
        }else{
            self.deleteBtn.isHidden = true
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //上传图片
    @objc func rightItemAction() {
        guard let sn = self.snTF.text else {
            return
        }
        if sn.isEmpty{
            LYProgressHUD.showError("请输入或者扫描sn码")
            return
        }
        if self.multiplePhotoView.imgArray.count > 0{
            LYProgressHUD.showLoading("图片上传中...")
            NetTools.upLoadImage(urlString : UploadAllImageApi,imgArray: self.multiplePhotoView.imgArray, success: { (result) in
                LYProgressHUD.dismiss()
                if self.addTestBlock != nil{
                    self.addTestBlock!(sn,result)
                }
                self.navigationController?.popViewController(animated: true)
            }, failture: { (error) in
                LYProgressHUD.showError("图片上传失败！")
            })
        }else{
            LYProgressHUD.showError("请至少上传一张图片！")
        }
        
    }

    //删除
    @IBAction func deleteAction() {
        if self.deleteTestBlock != nil{
            self.deleteTestBlock!()
        }
    }
    
    //扫描
    @IBAction func scanAction() {
        let scanVC = ScanActionViewController()
        scanVC.scanResultBlock = {[weak self] (result) in
            self?.snTF.text = result
        }
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AddTestSnViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.snTF.resignFirstResponder()
        return true
    }
}
