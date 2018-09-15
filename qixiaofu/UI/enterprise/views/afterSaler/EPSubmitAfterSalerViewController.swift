//
//  EPSubmitAfterSalerViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPSubmitAfterSalerViewController: BaseViewController {
    class func spwan() -> EPSubmitAfterSalerViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPSubmitAfterSalerViewController
    }
    
    var orderId = ""//字符串
    var infoStr = ""//json字符串
    var tmpArray : Array<Dictionary<String,String>> = []//选择的sn数据
    var addressInfo = JSON()

    @IBOutlet weak var returnBtn: UIButton!
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goodsLbl: UILabel!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var descTextV: UITextView!
    @IBOutlet weak var descCountLbl: UILabel!
    @IBOutlet weak var imgsView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var tableViewH: NSLayoutConstraint!
    @IBOutlet weak var descSubView: UIView!
    @IBOutlet weak var descViewH: NSLayoutConstraint!
    @IBOutlet weak var contentViewH: NSLayoutConstraint!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressViewH: NSLayoutConstraint!
    
        fileprivate var multiplePhotoView : LYMultiplePhotoBrowseView!//图片容器
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "申请售后服务"
        self.tableView.register(UINib.init(nibName: "EPChooseSnCell", bundle: Bundle.main), forCellReuseIdentifier: "EPChooseSnCell")
        self.tableView.estimatedRowHeight = 30
        
        self.submitBtn.layer.cornerRadius = 20
        self.descSubView.layer.cornerRadius = 8
        //总价
        var totalPrice : Float = 0
        var num = 0
        for dict in self.tmpArray{
            let price = dict["goods_price"]!.floatValue
            let sns = dict["goods_sns"]!.components(separatedBy: ",")
            totalPrice += price * Float(sns.count)
            num += sns.count
        }
        self.goodsLbl.text = "共" + String.init(format: "%d", num) + "件商品 订单金额：" + String.init(format: "%.2f", totalPrice)
        
        self.multiplePhotoView = LYMultiplePhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 30, height: 50),superVC:self)
        self.multiplePhotoView.backgroundColor = UIColor.white
        self.multiplePhotoView.heightBlock = {(height) in
            self.descViewH.constant = 170 + height
            self.contentViewH.constant = 210 + self.tableViewH.constant + self.descViewH.constant + self.addressViewH.constant
        }
        self.multiplePhotoView.maxPhotoNum = 9
        self.imgsView.addSubview(self.multiplePhotoView)
        
        self.addressView.addTapActionBlock {
            //收货地址
            let addressVC = AddressListViewController()
            addressVC.isChooseAddress = true
            addressVC.chooseAddressBlock = {[weak self] (json) in
                self?.addressInfo = json
                self?.resetContentViewHeight()
            }
            self.navigationController?.pushViewController(addressVC, animated: true)
        }
        
        self.resetContentViewHeight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.descTextV.isFirstResponder{
            self.descTextV.resignFirstResponder()
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //设置页面高度
    func resetContentViewHeight() {
        
        self.tableView.reloadData()

        //地址
        self.nameLbl.text = self.addressInfo["company_true_name"].stringValue
        self.phoneLbl.text = self.addressInfo["mob_phone"].stringValue
        self.addressLbl.text = self.addressInfo["area_info"].stringValue + self.addressInfo["address"].stringValue
        let address = self.addressInfo["area_info"].stringValue + self.addressInfo["address"].stringValue
        let size = address.sizeFit(width: kScreenW - 46, height: CGFloat(MAXFLOAT), fontSize: 14.0)
        if size.height > 20{
            self.addressViewH.constant = 103 + size.height
        }else{
            self.addressViewH.constant = 120
        }
        
        self.tableViewH.constant = self.tableView.contentSize.height + 30
        self.descViewH.constant = 170 + 50
        self.contentViewH.constant = 210 + self.tableViewH.constant + self.descViewH.constant + self.addressViewH.constant
        
        
    }
    @IBAction func topBtnAction(_ btn: UIButton) {
        if btn.tag == 11{
            self.addressViewH.constant = 0
            self.addressView.isHidden = true
            self.returnBtn.isSelected = true
            self.exchangeBtn.isSelected = false
        }else if btn.tag == 22{
            self.returnBtn.isSelected = false
            self.addressView.isHidden = false
            self.exchangeBtn.isSelected = true
            self.addressViewH.constant = 103 + 17
        }
        
    }
    
    @IBAction func submitAction() {

        func submit(_ result : String){
            var params : [String:Any] = [:]
            params["order_id"] = self.orderId
            if self.returnBtn.isSelected{
                params["type"] = "1"//1 退货 2换货
            }else{
                params["type"] = "2"//1 退货 2换货
            }
            params["leave_words"] = self.descTextV.text
            params["order_goods_info"] = self.infoStr
            params["img"] = result
            
            NetTools.requestData(type: .post, urlString: EPExcgangeOrReturnApi, parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.dismiss()
                LYAlertView.show("提示", "提交成功，在售后列表中可查看售后进度！", "知道了",{
                    var detailVc : UIViewController?
                    for vc in (self.navigationController?.viewControllers)!{
                        if vc is EPShopOrderDetailViewController{
                            detailVc = vc
                        }
                    }
                    if detailVc != nil{
                        self.navigationController?.popToViewController(detailVc!, animated: true)
                    }else{
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                })
            }) { (error) in
                LYProgressHUD.showError(error ?? "提交失败，请重试！")
            }
            
        }
        
        LYProgressHUD.showLoading()
        if self.multiplePhotoView.imgArray.count > 0{
            LYProgressHUD.showLoading()
            NetTools.upLoadImage(urlString : UploadAllImageApi,imgArray: self.multiplePhotoView.imgArray, success: { (result) in
                submit(result)
            }, failture: { (error) in
                LYProgressHUD.showError("图片上传失败！")
            })
        }else{
            submit("")
        }
        

    }
    


}




extension EPSubmitAfterSalerViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tmpArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tmpArray.count > section{
            let dict = self.tmpArray[section]
            let sns = dict["goods_sns"]!.components(separatedBy: ",")
            return sns.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EPChooseSnCell", for: indexPath) as! EPChooseSnCell
        if self.tmpArray.count > indexPath.section{
            let dict = self.tmpArray[indexPath.section]
            let sns = dict["goods_sns"]!.components(separatedBy: ",")
            if sns.count > indexPath.row{
                cell.snLbl.text = "SN: " + sns[indexPath.row]
            }
            cell.imgVW.constant = 0
            cell.priceLbl.text = "实付 ¥" + dict["goods_price"]!
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.tmpArray.count > indexPath.section{
            let dict = self.tmpArray[indexPath.section]
            let sns = dict["goods_sns"]!.components(separatedBy: ",")
            if sns.count > indexPath.row{
                return 30
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 52))
        view.backgroundColor = BG_Color
        let subView = UIView(frame: CGRect.init(x: 0, y: 1, width: kScreenW, height: 51))
        subView.backgroundColor = UIColor.white
        let imgV = UIImageView(frame: CGRect.init(x: 15, y: 6, width: 40, height: 40))
        subView.addSubview(imgV)
        let lbl = UILabel(frame: CGRect.init(x: 60, y: 12, width: kScreenW - 70, height: 20))
        lbl.textColor = Text_Color
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        subView.addSubview(lbl)
        view.addSubview(subView)
        if self.tmpArray.count > section{
            let dict = self.tmpArray[section]
            imgV.setImageUrlStr(dict["goods_url"]!)
            lbl.text = dict["goods_name"]!
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.descTextV.isFirstResponder{
            self.descTextV.resignFirstResponder()
        }
    }
}

extension EPSubmitAfterSalerViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeHolderLbl.isHidden = false
        }else{
            self.placeHolderLbl.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count > 499 && text != ""{
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.descCountLbl.text = "\(textView.text.count)/500"
    }
}
