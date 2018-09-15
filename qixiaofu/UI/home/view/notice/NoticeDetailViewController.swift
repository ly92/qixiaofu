//
//  NoticeDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/1/9.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class NoticeDetailViewController: BaseViewController {
    class func spwan() -> NoticeDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! NoticeDetailViewController
    }
    
    
    var noticeId = ""
    var noticeTitle = ""
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.noticeTitle
        self.loadNotice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNotice() {
        LYProgressHUD.showLoading()
        var params : [String : Any] = [:]
        params["notice_id"] = self.noticeId
        NetTools.requestData(type: .post, urlString: NoticeDetailApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.contentTextView.text = resultJson["notice_content"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(format: Date.datesFormatString(), timeStamps: resultJson["input_time"].stringValue)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }

    

}
