//
//  BaseViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/1.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
import ESPullToRefresh

class BaseViewController: UIViewController {

    //MARK: -定义content属性
    var contentView : UIView?
    //MARK: -动画
    fileprivate lazy var animImgV : UIImageView = {[unowned self] in
        let imgV = UIImageView(image: UIImage(named:"img_loading_1"))
        imgV.contentMode = UIViewContentMode.scaleAspectFill
        imgV.center = self.view.center
        imgV.animationImages = [UIImage(named:"img_loading_1")!, UIImage(named:"img_loading_2")!]
        imgV.animationDuration = 0.5
        imgV.animationRepeatCount = LONG_MAX
        imgV.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        return imgV
    }()
    
    lazy var emptyView : UIView = {
        let emptyView = UIView(frame: self.view.bounds)
        emptyView.backgroundColor = BG_Color
        
        let imgV = UIImageView(image:UIImage(named:"emptyimage"))
        imgV.x = emptyView.w / 2.0 - 62.5
        imgV.y = emptyView.h / 2.0 - 45
        imgV.w = 125
        imgV.h = 90
        
        emptyView.addSubview(imgV)
        
        return emptyView
    }()
    
    //MARK: - 系统回调
    override func viewDidLoad() {
        super.viewDidLoad()
        //视图在导航器中显示默认四边距离
        self.edgesForExtendedLayout = []
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
}

extension BaseViewController{
        
    @objc func setUpMainView() {
        //1.隐藏内容
        contentView?.isHidden = true
        //2.添加动画imgv
        view.addSubview(animImgV)
        //3.开始执行动画
        animImgV.startAnimating()
        //4.设置view的背景颜色
        view.backgroundColor = UIColor.RGBS(s: 250)
    }
    func loadDataFinished() {
        //1.停止动画
        animImgV.stopAnimating()
        //2.隐藏animimgview
        animImgV.isHidden = true
        //3.显示内容的view
        contentView?.isHidden = false
    }
    
    
    
    
    func showEmptyView() {
        if self.view.subviews.contains(self.emptyView){
            self.view.bringSubview(toFront: self.emptyView)
        }else{
            self.view.addSubview(self.emptyView)
        }
    }
    
    func hideEmptyView() {
        if self.view.subviews.contains(self.emptyView){
            self.emptyView.removeFromSuperview()
        }
    }}

