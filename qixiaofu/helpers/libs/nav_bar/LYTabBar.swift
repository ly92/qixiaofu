//
//  LYTabBar.swift
//  qixiaofu
//
//  Created by ly on 2018/12/4.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

protocol LYTabBarDelegate {
    func clickAction(tabbar : LYTabBar)
}


class LYTabBar: UITabBar {
    var lyTabBarDelegate : LYTabBarDelegate?
    let btn = UIButton()
    let lbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addButton() {
        btn.setBackgroundImage(UIImage.init(named: "Alipay"), for: .normal)
        btn.setBackgroundImage(UIImage.init(named: "wechat_pay"), for: .highlighted)
        
        btn.addTarget(self, action: #selector(LYTabBar.btnAction), for: .touchUpInside)
        self.addSubview(btn)
    }
    
    
    @objc func btnAction() {
        self.lyTabBarDelegate?.clickAction(tabbar: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
        self.btn.centerX = self.centerX
        self.btn.centerY = self.height * 0.5 - 1.5 * 10 * 2
        
        self.btn.size = self.btn.currentBackgroundImage?.size
        
        self.lbl.text = "哈哈"
        self.lbl.font = UIFont.systemFont(ofSize: 10)
        self.lbl.textColor = UIColor.gray
        self.lbl.sizeToFit()
        self.lbl.centerX = self.btn.centerX
        self.lbl.centerY = self.btn.frame.maxY + 0.5 * 10 + 0.5
        self.addSubview(self.lbl)
        
        var index = 0
        for view in self.subviews{
            
            let UITabBarButton = NSClassFromString("UITabBarButton") ?? UITabBarItem.self
            
            if view.isKind(of: UIImageView.self) && view.height < 1{
                view.isHidden = true
            }else if view.isKind(of: UITabBarButton){
                view.width = self.width / 5.0
                view.x = view.width * CGFloat(index)
                index += 1
                if index == 2{
                    index += 1
                }
            }
            self.bringSubview(toFront: view)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden{
            return super.hitTest(point, with: event)
        }else{
            let btnPoint = self.convert(point, to: self.btn)
            let lblPoint = self.convert(point, to: self.lbl)
            
            if self.btn.point(inside: btnPoint, with: event){
                return self.btn
            }else if self.lbl.point(inside: lblPoint, with: event){
                return self.btn
            }else{
                return super.hitTest(point, with: event)
            }
        }
    }
    
    
}
