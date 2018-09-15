//
//  QxfStandDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/3.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class QxfStandDetailViewController: BaseViewController {
    class func spwan() -> QxfStandDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! QxfStandDetailViewController
    }
    
    @IBOutlet weak var webView: UIWebView!
    var resultJson = JSON()
    var isPackageStandard = false
    fileprivate var urlStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isPackageStandard{
            self.navigationItem.title = self.resultJson["package_name"].stringValue
        }else{
            self.navigationItem.title = self.resultJson["test_name"].stringValue
        }
        self.urlStr = self.resultJson["url"].stringValue
        LYProgressHUD.showLoading()
        if !urlStr.isEmpty{
            if !urlStr.hasPrefix("http://") && !urlStr.hasPrefix("https://"){
                urlStr = "http://" + urlStr
            }
            urlStr = urlStr.replacingOccurrences(of: " ", with: "")
            //如果是广告页，则忽略缓存
            if urlStr.trim.hasSuffix("/download/start.html"){
                let request = URLRequest.init(url: URL(string:urlStr)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval:10)
                self.webView.loadRequest(request)
            }else{
                let request = URLRequest.init(url: URL(string:urlStr)!)
                self.webView.loadRequest(request)
            }
        }
        
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(QxfStandDetailViewController.backClick))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "delete_icon"), target: self, action: #selector(QxfStandDetailViewController.closeClick))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LYProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnAction() {
        //使用此标准
        var params : [String:String] = [:]
        var url = ""
        params["id"] = self.resultJson["id"].stringValue
        if self.isPackageStandard{
            url = ChoosePackageStandardApi
        }else{
            url = ChooseTestStandardApi
        }
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("操作成功！")
            self.navigationController?.popToRootViewController(animated: true)
        }) { (error) in
            LYProgressHUD.showError(error ?? "操作失败，请重试！")
        }
    }
    
    
    @objc func backClick() {
        if self.webView.canGoBack{
            self.webView.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func closeClick() {
        self.webView.stopLoading()
        self.navigationController?.popViewController(animated: true)
    }
    
}



extension QxfStandDetailViewController : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        LYProgressHUD.dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        LYProgressHUD.dismiss()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        LYProgressHUD.showLoading()
        return true
    }
}
