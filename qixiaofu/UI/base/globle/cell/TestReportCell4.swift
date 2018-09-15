//
//  TestReportCell4.swift
//  qixiaofu
//
//  Created by ly on 2018/6/21.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class TestReportCell4: UITableViewCell {
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    var reportUrl = ""{
        didSet{
            guard let url = URL.init(string: reportUrl) else {
                return
            }
            let request = URLRequest.init(url: url)
            if self.curHeight == 0{
                self.webView.loadRequest(request)
            }
        }
    }
    
    fileprivate var curHeight : CGFloat = 0
    
    var refreshHeightBlock : ((CGFloat) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


extension TestReportCell4 : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        LYProgressHUD.showLoading()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        LYProgressHUD.dismiss()
        if self.curHeight != self.webView.scrollView.contentSize.height + 164{
            if self.refreshHeightBlock != nil{
                self.refreshHeightBlock!(self.webView.scrollView.contentSize.height + 164)
            }
            self.curHeight = self.webView.scrollView.contentSize.height + 164
        }
        
    }
}
