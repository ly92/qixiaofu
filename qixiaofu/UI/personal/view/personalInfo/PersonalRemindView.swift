//
//  PersonalRemindView.swift
//  qixiaofu
//
//  Created by ly on 2017/7/27.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

private let remindStr = "1、填写的项目较多，谢谢您的耐心和支持。\n2、由于中国相关法规的规定，同时为了保障您的合法权益，您需要完善资料才能接单，敬请谅解。\n3、部分信息为系统备案需要，不会显示给客户。\n4、实名认证，通过实名认证后，可以进行在线发单及接单。\n5、技术领域，选择好您所擅长的技术领域后，系统会定向推送适合您的订单消息。\n6、设置空闲时间，设置好您的空闲时间段后，系统会定向推送适合您的订单消息。"

class PersonalRemindView: UIView {

    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH))
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpViews() {
        
        //lbl btn
        var remindViewH : CGFloat = 0
        let remindViewW : CGFloat = kScreenW - 60
        
        
        //1.背景
        let bgBtn = UIButton(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH))
        bgBtn.backgroundColor = UIColor.colorHexWithAlpha(hex:"000000", alpha: 0.3)
        bgBtn.addTarget(self, action: #selector(PersonalRemindView.hide), for: .touchUpInside)
        self.addSubview(bgBtn)

        //label
        let titleLbl = UILabel(frame:CGRect.init(x: 5, y: 5, width: remindViewW - 10, height: 21))
        titleLbl.textColor = Text_Color
        titleLbl.textAlignment = .center
        titleLbl.font = UIFont.systemFont(ofSize: 16.0)
        titleLbl.text = "温馨提示"
        
        //label
        let lbl = UILabel(frame:CGRect.init(x: 5, y: 30, width: remindViewW - 10, height: 0))
        lbl.textColor = Text_Color
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.text = remindStr
        lbl.h = lbl.resizeHeight()
        
//        remindViewH = 5 + 21 + 5 + lbl.h + 15 + 30
        remindViewH = 76 + lbl.h
        
        //提示框
        let remindView = UIView(frame:CGRect.init(x: (kScreenW - remindViewW)/2.0, y: (kScreenH - remindViewH)/2.0, width: remindViewW, height: remindViewH))
        remindView.clipsToBounds = true
        remindView.layer.cornerRadius = 10
        remindView.backgroundColor = UIColor.white
        self.addSubview(remindView)
        
        remindView.addSubview(titleLbl)
        remindView.addSubview(lbl)
        
        //关闭按钮
        let closeBtn = UIButton(frame:CGRect.init(x: 0, y: remindViewH - 30, width: remindViewW, height: 30))
        closeBtn.clipsToBounds = true
        closeBtn.backgroundColor = Normal_Color
        closeBtn.setTitle("知道了", for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        closeBtn.setTitleColor(UIColor.white, for: .normal)
        closeBtn.addTarget(self, action: #selector(PersonalRemindView.hide), for: .touchUpInside)
        remindView.addSubview(closeBtn)
    }
    
    
    @objc func hide() {
        UIView.animate(withDuration: 0.25, animations: { 
            self.layer.transform = CATransform3DMakeScale(2, 2, 2)
            self.alpha = 0
        }) { (completion) in
            self.removeFromSuperview()
        }
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
        self.alpha = 0
        UIView.animate(withDuration: 0.25) { 
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.alpha = 1
        }
    }

}
