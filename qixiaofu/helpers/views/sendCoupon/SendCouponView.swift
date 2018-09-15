//
//  SendCouponView.swift
//  qixiaofu
//
//  Created by ly on 2018/7/20.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


class SendCouponView: UIView {

    fileprivate var subView : UIView = UIView()
    fileprivate var textView : UITextView = UITextView()
    fileprivate var couponList : Array<JSON> = Array<JSON>()
    
    func setUpSubViews(_ result : JSON) {
        //1.背景图
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubview(toFront: self)
        self.addTapActionBlock {
            self.cancelAction()
        }
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        //子视图
        let width : CGFloat = kScreenW * 0.9
        let height : CGFloat = width * 1.06
        
        
        let x : CGFloat = (kScreenW - width) / 2.0
        let y : CGFloat = (kScreenH - height) / 2.0
        subView = UIView(frame:CGRect.init(x: x, y: y, width: width, height: height))
        subView.clipsToBounds = true
        subView.layer.cornerRadius = 8
        subView.backgroundColor = UIColor.clear
        
        //背景图
        let bgImgV = UIImageView(frame: subView.bounds)
        bgImgV.image = #imageLiteral(resourceName: "send_coupon_bg")
        subView.addSubview(bgImgV)

        //title
        let lbl = UILabel(frame:CGRect.init(x: 8, y: height*0.35, width: width-16, height: 25))
        lbl.text = String.init(format: "送您%.2f元优惠券", result["count_price"].stringValue.floatValue)
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textColor = UIColor.white
        subView.addSubview(lbl)
        
        //tabble
        self.couponList.removeAll()
        for json in result["coupon_list"].arrayValue{
            self.couponList.append(json)
        }
        let tabble = UITableView.init(frame: CGRect.init(x: width * 0.15, y: lbl.frame.maxY + 15, width: width*0.7, height: height-lbl.frame.maxY-30), style: UITableViewStyle.plain)
        tabble.backgroundColor = UIColor.clear
        tabble.delegate = self
        tabble.dataSource = self
        tabble.separatorStyle = .none
        tabble.clipsToBounds = true
        tabble.layer.cornerRadius = 5
        tabble.register(UINib.init(nibName: "SendCouponCell", bundle: Bundle.main), forCellReuseIdentifier: "SendCouponCell")
        tabble.reloadData()
        subView.addSubview(tabble)
        
        
        //关闭按钮
        let WH : CGFloat = 22
        let R : CGFloat = (WH-2)/2.0
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: WH, height: WH), false, 0)
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: WH-1, y: WH/2.0))
        path.addArc(withCenter: CGPoint.init(x: WH/2.0, y: WH/2.0), radius: R, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        path.close()
    
        path.move(to: CGPoint.init(x: WH/2-R/sqrt(2), y: WH/2-R/sqrt(2)))
        path.addLine(to: CGPoint.init(x: WH/2+R/sqrt(2), y: WH/2+R/sqrt(2)))
        path.move(to: CGPoint.init(x: WH/2+R/sqrt(2), y: WH/2-R/sqrt(2)))
        path.addLine(to: CGPoint.init(x: WH/2-R/sqrt(2), y: WH/2+R/sqrt(2)))
        path.close()
        
        UIColor.white.withAlphaComponent(0.8).setStroke()
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil{
            let closeImgV = UIImageView(frame: CGRect.init(x: width-WH*1.5, y: WH*1.5, width: WH, height: WH))
            closeImgV.image = image
            subView.addSubview(closeImgV)
        }
        
        self.addSubview(subView)
    }
    
    @objc func cancelAction() {
        self.removeFromSuperview()
    }
    
    //展示
    class func showWithJson(_ result : JSON){
        if result["coupon_list"].arrayValue.count > 0 && result["count_price"].stringValue.floatValue > 0{
            SendCouponView().setUpSubViews(result)
        }
    }
    
    
}

extension SendCouponView : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.couponList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendCouponCell", for: indexPath) as! SendCouponCell
        if self.couponList.count > indexPath.row{
            let json = self.couponList[indexPath.row]
            cell.subJson = json
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
