//
//  WebViewCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

typealias WebViewCellBlock = (_ height : CGFloat,_ webView : UIWebView) -> Void

class WebViewCell: UITableViewCell {
    @IBOutlet weak var webView: UIWebView!
    
    var webCellHeightBlock : WebViewCellBlock?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.webView.scrollView.isScrollEnabled = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setHtmlStr(_ str : String) {
        var body = str.replacingOccurrences(of: "&lt;", with: "<")
        body = body.replacingOccurrences(of: "&gt;", with: ">")
        
        let pattern1 = "<span style=\"[a-zA-Z]{1,10}-[a-zA-Z]{1,10}:\\d{0,10}.\\d{0,10}px;\">"
        do{
            let regex = try NSRegularExpression(pattern: pattern1, options: NSRegularExpression.Options(rawValue:0))
            let res = regex.matches(in: body, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, body.count))
            if res.count > 0 {
                for checkRes in res{
                    let start = body.index(body.startIndex, offsetBy: checkRes.range.location)
                    let end = body.index(body.startIndex, offsetBy: (checkRes.range.length + checkRes.range.location))
                    body.removeSubrange(Range(uncheckedBounds: (start, end)))
                }
            }
            body = body.replacingOccurrences(of: "</span>", with: "")
        }catch{
        }
        
        let html = "<html> \n<head> \n <style type=\"text/css\"> \n body {font-size:36px;color:#6e6e6e;font-family: sans-serif;}\n table{width: 100%%;} table, table tr th, table tr td { border: 1px solid #c1c1c1; padding:20px 10px 20px 10px;} table { text-align: left; font-size:36px; border-collapse: collapse;} </style> \n </head> \n <body> <script type='text/javascript'> window.onload = function(){\n var $img = document.getElementsByTagName('img');\n for(var p in  $img){\n  $img[p].style.width = '100%%';\n $img[p].style.height ='auto'\n }\n } </script>" + body + "</body> </html>"
        self.webView.loadHTMLString(html, baseURL: URL(string:"www.baidu.com"))
    }
    
}


extension WebViewCell : UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let height = webView.scrollView.contentSize.height
        
        if self.webCellHeightBlock != nil{
            self.webCellHeightBlock!(height + 37,webView)
        }
    }
}
