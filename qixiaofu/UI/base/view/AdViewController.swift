//
//  AdViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/29.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class AdViewController: BaseViewController {


    
    fileprivate var canSkip = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imgV = UIImageView(frame:self.view.bounds)
        
        imgV.kf.setImage(with: URL(string:usedServer + "download/start.png"), placeholder: #imageLiteral(resourceName: "ad_icon"), options: [.forceRefresh])
        
        imgV.addTapActionBlock {
            self.canSkip = false
            //
            let webVC = BaseWebViewController.spwan()
            webVC.isFromAdVC = true
            webVC.urlStr = usedServer + "download/start.html"
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        self.view.addSubview(imgV)
        
        let skipBtn = UIButton(frame:CGRect.init(x: kScreenW - 100, y: 20, width: 80, height: 30))
        skipBtn.backgroundColor = UIColor.RGBSA(s: 0, a: 0.3)
        skipBtn.setTitle("跳过", for: .normal)
        skipBtn.setTitleColor(UIColor.white, for: .normal)
        skipBtn.clipsToBounds = true
        skipBtn.layer.cornerRadius = 5
        skipBtn.addTarget(self, action: #selector(AdViewController.skipAction), for: .touchDown)
        self.view.addSubview(skipBtn)
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //准备展示公告页
        LocalData.saveYesOrNotValue(value: "1", key: IsBeShowNoticeView)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.skipAction()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    
    @objc func skipAction() {
        if canSkip{
            AppDelegate.sharedInstance.setupRootViewController()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
