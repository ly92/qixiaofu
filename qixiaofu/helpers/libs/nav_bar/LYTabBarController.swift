//
//  LYTabBarController.swift
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

class LYTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarAppear = UITabBarItem.appearance()
        tabBarAppear.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.orange], for: UIControlState.selected)
        
        self.setUpAllChildViewControllers()
        
        
        
//        let lyTabBar = LYTabBar()
//        lyTabBar.delegate = self
//        self.setValue(lyTabBar, forKey: "tabBar")
        
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        self.tabBar.tintColor =
//    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func resetChildViewController(){
//        for vc in self.childViewControllers{
//            vc.removeFromParentViewController()
//        }
//
//        self.setUpAllChildViewControllers()
//        
//    }
    
    fileprivate func setUpAllChildViewControllers () {
        let titles = ["首页","商城","消息","我"]
        let normalImgs = ["pub_icon_home_n","pub_icon_shop_n","pub_news_n","pub_icon_me_n"]
        let selectedImgs = ["pub_icon_home_s","pub_icon_shop_s","pub_news_s","pub_icon_me_s"]
        
        if !LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            let firstVC = HomeViewController.spwan()
            setUpNavRootViewController(vc: firstVC, title: titles[0], imageName: normalImgs[0], selectedImageName: selectedImgs[0])
        }

        let secVC = ShopViewController.spwan()
        setUpNavRootViewController(vc: secVC, title: titles[1], imageName: normalImgs[1], selectedImageName: selectedImgs[1])
        
        let thirVC = MessageViewController()
        setUpNavRootViewController(vc: thirVC, title: titles[2], imageName: normalImgs[2], selectedImageName: selectedImgs[2])
        
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            let fourVC = EnterpriseCenterViewController.spwan()
            setUpNavRootViewController(vc: fourVC, title: titles[3], imageName: normalImgs[3], selectedImageName: selectedImgs[3])
        }else{
            let fourVC = PersonalViewController.spwan()
            setUpNavRootViewController(vc: fourVC, title: titles[3], imageName: normalImgs[3], selectedImageName: selectedImgs[3])
        }
    }
    
    fileprivate func setUpNavRootViewController(vc: UIViewController, title: String, imageName: String, selectedImageName: String) {
        vc.title = title
        vc.tabBarItem.image = UIImage(named:imageName)
        vc.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.addChildViewController(LYNavigationController(rootViewController: vc))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LYTabBarController{
    
    
    open override var shouldAutorotate: Bool{
        get{
            guard let value = self.selectedViewController?.shouldAutorotate else {
                return true
            }
            return value
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            guard let value = self.selectedViewController?.supportedInterfaceOrientations else {
                return .portrait
            }
            return value
        }
    }
}



extension LYTabBarController : LYTabBarDelegate{
    func clickAction(tabbar: LYTabBar) {
        print("12345678954321`12345678987654322345678987654321234567")
    }
}
