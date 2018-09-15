//
//  BaseWebViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/12.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class BaseWebViewController: BaseViewController {

    @IBOutlet weak var webView: UIWebView!

    var isFromAdVC = false
    
    public var urlStr : String = ""
    public var titleStr: String = ""
    
    
    class func spwan() -> BaseWebViewController{
        return self.loadFromStoryBoard(storyBoard: "Main") as! BaseWebViewController
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LYProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isFromAdVC{
            titleStr = "广告详情"
        }
        self.navigationItem.title = titleStr

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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(BaseWebViewController.backClick))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "delete_icon"), target: self, action: #selector(BaseWebViewController.closeClick))
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func backClick() {
        if self.webView.canGoBack{
            self.webView.goBack()
        }else{
            if self.isFromAdVC{
                AppDelegate.sharedInstance.setupRootViewController()
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @objc func closeClick() {
        self.webView.stopLoading()
        if self.isFromAdVC{
            AppDelegate.sharedInstance.setupRootViewController()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


extension BaseWebViewController : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {

    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        LYProgressHUD.dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        LYProgressHUD.dismiss()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (request.url?.absoluteString.hasPrefix("itms-apps://itunes.apple.com"))!{
            return false
        }else if (request.url?.absoluteString.hasPrefix("qixiaofu://"))!{
            if AppDelegate.sharedInstance.isRootViewAdNav(){
                LocalData.saveYesOrNotValue(value: "1", key: KIsLaunchInfoFromAppWebKey)
            }
        }
        
        LYProgressHUD.showLoading()
        
        return true
    }
}
