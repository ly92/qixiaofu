//
//  TestReportDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/6/21.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestReportDetailViewController: BaseViewController {
    class func spwan() -> TestReportDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Globle") as! TestReportDetailViewController
    }
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var numLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var topViewTopDis: NSLayoutConstraint!
    
    var testId = ""
    
    fileprivate var resultJson = JSON()
    fileprivate var webHeight : CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载测报信息
        self.loadData()
        self.navigationItem.title = "测报详情"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //加载测报信息
    func loadData() {
        let params : [String : Any] = ["id" : self.testId]
        NetTools.requestData(type: .get, urlString: "tp.php/Home/Public/sel", parameters: params, succeed: { (result, msg) in
            self.resultJson = result
            self.nameLbl.text = self.resultJson["name"].stringValue + "    FEATURE"
            self.numLbl.text = self.resultJson["outbound_no"].stringValue
            self.snLbl.text = self.resultJson["sn"].stringValue
//            self.timeLbl.text = "测试时间" + Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: self.resultJson["add_time"].stringValue)
            guard let url = URL.init(string: self.resultJson["test_report"].stringValue) else {
                return
            }
            let request = URLRequest.init(url: url)
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取信息失败！")
        }
    }
}

extension TestReportDetailViewController : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        LYProgressHUD.showLoading()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        LYProgressHUD.dismiss()
    }
}
