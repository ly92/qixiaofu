//
//  LYNavigationController.swift
//  qixiaofu
//   _
//  | |      /\   /\
//  | |      \ \_/ /
//  | |       \_~_/
//  | |        / \
//  | |__/\    [ ]
//  |_|__,/    \_/
//
//  Created by 李勇 on 2017/5/29.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class LYNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.设置导航栏颜色
        self.setupNavAppearance()
        
        //2.创建pan手势
        let target = self.interactivePopGestureRecognizer?.delegate
        let pan = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")))
        
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        //3.禁止系统的局部返回手势
        self.interactivePopGestureRecognizer?.isEnabled = false;

        self.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 拦截push
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //判断是否进入push视图
        if (self.childViewControllers.count > 0){
            //隐藏要push的控制器的tabbar
            viewController.hidesBottomBarWhenPushed = true
            
//            let backBtn = UIButton(image: UIImage(named:"btn_back"), highlightedImage: UIImage(named:"btn_back"), title:"返回", target: self, action: #selector(LYNavigationController.backClick))
//            //设置按钮内容左对齐
//            backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
//            backBtn.frame = CGRect(x:0, y:0, width:40, height:33)
//            //内边距
//            backBtn.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 10)
//            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(LYNavigationController.backClick))
        }
        super.pushViewController(viewController, animated: true)
    }
    
    @objc fileprivate func backClick(){
        popViewController(animated: true)
    }
    
}

extension LYNavigationController : UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        let velocity = pan.velocity(in: self.childViewControllers.last?.view)
        if velocity.x < 0{
            return false
        }
        
        //我要接单页面不可用
        if (self.childViewControllers.last?.isKind(of: SetSpaceTimeViewController.self))!{
            return false
        }
        //购物车列表
        if (self.childViewControllers.last?.isKind(of: ShopCarListViewController.self))!{
            return false
        }
        //地图页面
        if (self.childViewControllers.last?.isKind(of: MapMatchEngineerViewController.self))!{
            return false
        }
        if (self.childViewControllers.last?.isKind(of: WorkTrackViewController.self))!{
            return false
        }
        
        
        //判断是否为根控制器
        if self.childViewControllers.count == 1 {
            return false
        }
        
        return true
    }
}

extension LYNavigationController {
    fileprivate func setupNavAppearance() {
        let navBar = UINavigationBar.appearance()
        if (Double(UIDevice.current.systemVersion)) > 8.0{
            navBar.isTranslucent = true
        }else{
            self.navigationBar.isTranslucent = true
        }
        //导航栏字体颜色
//        navBar.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.RGBS(s: 150), NSFontAttributeName:UIFont.boldSystemFont(ofSize: 18)]
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.RGBS(s: 150), NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 17.0)]
    }
    
   
    
    open override var shouldAutorotate: Bool{
        get{
            guard let value = self.visibleViewController?.shouldAutorotate else{
                return true
            }
            return value
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            guard let value = self.visibleViewController?.supportedInterfaceOrientations else{
                return .portrait
            }
            return value
        }
    }

}

extension LYNavigationController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is LoginViewController{
            navigationController.navigationBar.barTintColor = UIColor.white
        }else{
            navigationController.navigationBar.barTintColor = UIColor.white
        }
    }
}
