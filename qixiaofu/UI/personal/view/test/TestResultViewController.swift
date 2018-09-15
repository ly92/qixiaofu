//
//  TestResultViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/7.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestResultViewController: BaseViewController {
    class func spwan() -> TestResultViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! TestResultViewController
    }
    
    var subJson : JSON = []
    var refreBlock : (() -> Void)?
    @IBOutlet weak var pnLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var subViewH: NSLayoutConstraint! //30 + 5 + imgH + 8
    @IBOutlet weak var contentVH: NSLayoutConstraint!// 233 + subViewH + 44 + storeageViewH 不小于screenH-50
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var storageDescLbl: UILabel!
    @IBOutlet weak var storeageViewH: NSLayoutConstraint!
    fileprivate var photoBrowseView = LYPhotoBrowseView.init(frame: CGRect())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "测报详情"
        self.prepareUISet()
        
    }
    
    //展示评估标准
    @IBAction func showPriceDescAction() {
        let dict1 = ["title" : "估价标准", "desc" : "平台根据备件成色及市场价由估价师给出价格区间 "]
        let dict2 = ["title" : "9成新", "desc" : "有轻微划痕，标签无损伤 "]
        let dict3 = ["title" : "8成新", "desc" : "有轻微划痕  锈迹 "]
        let dict4 = ["title" : "8成新以下", "desc" : "明显损伤 划痕  锈迹 "]
        NoticeView.showWithText("提示",[dict1,dict2,dict3,dict4])
    }
    
    func prepareUISet() {
        self.nameLbl.text = self.subJson["name"].stringValue
        self.pnLbl.text = self.subJson["determinand_pn"].stringValue
        self.snLbl.text = self.subJson["determinand_sn"].stringValue
        self.priceLbl.text = self.subJson["min_price"].stringValue + "~" + self.subJson["max_price"].stringValue
        self.storageDescLbl.text = self.subJson["depot_info"].stringValue
        self.storeageViewH.constant = self.storageDescLbl.resizeHeight() + 15
        
        photoBrowseView = LYPhotoBrowseView.init(frame: CGRect.init(x: 10, y: 35, width: kScreenW - 20, height: self.subView.h-43), superVC: self)
        self.subView.addSubview(photoBrowseView)
        photoBrowseView.heightBlock = { (height) in
            self.subViewH.constant = 43 + height
            if 233 + self.subViewH.constant + self.storeageViewH.constant > kScreenH - 50{
                self.contentVH.constant = 233 + self.subViewH.constant + self.storeageViewH.constant
            }else{
                self.contentVH.constant = kScreenH - 50
            }
            
        }
        var arr : Array<String> = Array<String>()
        for str in self.subJson["test_photo"].arrayValue{
            arr.append(str.stringValue)
        }
        self.photoBrowseView.showImgUrlArray = arr
        self.photoBrowseView.showDeleteBtn = false
        self.photoBrowseView.canTakePhoto = false
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //测报附件
    @IBAction func attachmentAction() {
        let webVC = BaseWebViewController.spwan()
        webVC.titleStr = "测报附件"
        webVC.urlStr = self.subJson["test_adjunct"].stringValue
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
//    @IBAction func sureAction() {
//
//    }
//
//    @IBAction func sealAction() {
//        let sealPriceVC = TestSealPriceViewController.spwan()
//        sealPriceVC.goodsId = self.subJson["id"].stringValue
//        sealPriceVC.refreshBlock = {() in
//            if self.refreBlock != nil{
//                self.refreBlock!()
//            }
//        }
//        self.navigationController?.pushViewController(sealPriceVC, animated: true)
//    }

}
