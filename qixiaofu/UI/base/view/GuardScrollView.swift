//
//  GuardScrollView.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/5/30.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class GuardScrollView: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.bounces = false
        self.isPagingEnabled = true
        self.contentSize = CGSize(width: kScreenW * 2, height: kScreenH)
        
        self.setUpMainView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GuardScrollView{
    fileprivate func setUpMainView() {
        for i in 1...2{
            let imgV = UIImageView(frame: CGRect(x:kScreenW * CGFloat(i-1), y:0, width:kScreenW, height:kScreenH))
            let imgName = "new_feature_" + "\(i)" + "_iphone"
            imgV.image = UIImage(named: imgName)
            self.addSubview(imgV)
            if (i == 2){
                let btn = UIButton(frame:CGRect(x:kScreenW * 1, y:kScreenH-200, width:kScreenW,height:200))
                btn.addTarget(self, action: #selector(GuardScrollView.EnterApp(_:)), for: UIControlEvents.touchUpInside)
                self.addSubview(btn)
                
            }
        }
    }
    
    @objc func EnterApp(_ sender: UIButton){
        sender.isUserInteractionEnabled = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KEnterAppNotification), object: nil, userInfo: ["sender":sender])
    }
}
