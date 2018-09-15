//
//  AboutAppViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/10/30.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class AboutAppViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "关于App"
        self.view.backgroundColor = BG_Color
        
        DispatchQueue.main.async {
            AppDelegate.sharedInstance.checkAppUpdate()
        }
        
        self.setUpMainViews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpMainViews() {
        //
        let imgV = UIImageView(frame:CGRect.init(x: (kScreenW-120) / 2.0, y: 100, width: 120, height: 120))
        imgV.image = #imageLiteral(resourceName: "app_icon")
        let lbl = UILabel(frame:CGRect.init(x: imgV.frame.minX, y: imgV.frame.maxY + 10, width: 120, height: 21))
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.textColor = Text_Color
        lbl.textAlignment = .center
        lbl.text = "版本号：" + appVersion()
        
        let lbl2 = UILabel(frame:CGRect.init(x: 10, y: lbl.frame.maxY + 5, width: kScreenW - 20, height: 21))
        lbl2.font = UIFont.systemFont(ofSize: 14.0)
        lbl2.textColor = Text_Color
        lbl2.textAlignment = .center
        lbl2.text = "七小服微信号：qixiaofu-com"
        
        let lbl3 = UILabel(frame:CGRect.init(x: 10, y: lbl2.frame.maxY + 5, width: kScreenW - 20, height: 21))
//        lbl3.font = UIFont.systemFont(ofSize: 14.0)
//        lbl3.textColor = Text_Color
        lbl3.textAlignment = .center
//        lbl3.text = "七小服电话：15600923777"
        let attrStr = NSMutableAttributedString()
        let attrStr1 = NSMutableAttributedString.init(string: "七小服电话：", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : Text_Color])
        let attrStr2 = NSMutableAttributedString.init(string: "15600923777", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : Normal_Color])
        attrStr.append(attrStr1)
        attrStr.append(attrStr2)
        lbl3.attributedText = attrStr
        lbl3.addTapActionBlock {
            UIApplication.shared.openURL(URL(string: "telprompt:15600923777")!)
        }
        
        
        self.view.addSubview(imgV)
        self.view.addSubview(lbl)
        self.view.addSubview(lbl2)
        self.view.addSubview(lbl3)
    }
   
}
