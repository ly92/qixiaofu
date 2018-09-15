//
//  SystemMaintainingViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/15.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class SystemMaintainingViewController: BaseViewController {
    class func spwan() -> SystemMaintainingViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! SystemMaintainingViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "系统维护中"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reTryAction() {
        //参数
        let params : [String:Any] = ["username" : "11111111111", "password" : "111111".md5String(), "client" : "ios"]
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: LoginApi, parameters: params, succeed: { (resultDict, error) in
            LYProgressHUD.dismiss()
            LocalData.saveYesOrNotValue(value: "0", key: IsSystemMaintaining)
            self.dismiss(animated: true, completion: {
            })
        }) { (error) in
        }
    }

}
