//
//  NoticeView.swift
//  qixiaofu
//
//  Created by ly on 2018/1/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class NoticeView: UIView {
    fileprivate var subView : UIView = UIView()
    fileprivate var textView : UITextView = UITextView()
    
    func setUpSubViews(_ title : String, _ content : NSAttributedString) {
        //1.背景图
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubview(toFront: self)
        self.addTapActionBlock {
            self.cancelAction()
        }
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        //子视图
        let width : CGFloat = kScreenW * 0.7
        var height : CGFloat = kScreenH * 0.7
        
        let contentTemp = content.string
        let contentS = contentTemp.sizeFitTextView(width: width-16, height: CGFloat(MAXFLOAT), fontSize: 14)
        if contentS.height < height - 35-8-40{
//            if contentS.height > kScreenH * 0.5{
                height = contentS.height + 35+8+44
//            }else{
//
//            }
        }
        
        let x : CGFloat = kScreenW * 0.15
        let y : CGFloat = (kScreenH - height) / 2.0
        subView = UIView(frame:CGRect.init(x: x, y: y, width: width, height: height))
        subView.clipsToBounds = true
        subView.layer.cornerRadius = 8
        subView.backgroundColor = UIColor.white
        
        //title
        let lbl = UILabel(frame:CGRect.init(x: 8, y: 8, width: width-16, height: 20))
        lbl.text = title
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textColor = Normal_Color
        subView.addSubview(lbl)
        
        //文字
        self.textView = UITextView(frame:CGRect.init(x: 8, y: 35, width: width-16, height: height - 35 - 8 - 40))
//        self.textView.font = UIFont.systemFont(ofSize: 14.0)
        self.textView.attributedText = content
        self.textView.isEditable = false
        self.textView.dataDetectorTypes = .all
//        self.textView.textColor = UIColor.RGBS(s: 50)
        subView.addSubview(self.textView)
        
        let cancelBtn = UIButton(frame:CGRect.init(x: 0, y: height-40, width: width, height: 40))
        cancelBtn.setTitle("知道了", for: .normal)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.backgroundColor = Normal_Color
        cancelBtn.addTarget(self, action: #selector(ShareView.cancelAction), for: .touchUpInside)
        subView.addSubview(cancelBtn)
        
        self.addSubview(subView)
    }

    @objc func cancelAction() {
        self.removeFromSuperview()
    }
    
    //展示
    class func showWithText(_ title : String,_ content : Array<Dictionary<String,String>>){
        let attrStr = NSMutableAttributedString()
        for dict in content{
            let attrStr1 = NSMutableAttributedString.init(string: "【" + dict["title"]! + "】", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : UIColor.RGBS(s: 50)])
            let attrStr2 = NSMutableAttributedString.init(string: "\n  " + dict["desc"]! + "\n\n", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : UIColor.RGBS(s: 70)])
            attrStr.append(attrStr1)
            attrStr.append(attrStr2)
        }

        NoticeView().setUpSubViews(title,attrStr)
    }
}
