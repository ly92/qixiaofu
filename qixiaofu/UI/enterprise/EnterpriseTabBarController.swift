//
//  EnterpriseTabBarController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/17.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class EnterpriseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarAppear = UITabBarItem.appearance()
        tabBarAppear.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.orange], for: UIControlState.selected)
        
        self.setUpAllChildViewControllers()
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "关闭", target: self, action: #selector(EnterpriseTabBarController.rightItemAction))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func rightItemAction() {
        AppDelegate.sharedInstance.resetRootViewController(1)
//        self.navigationController?.popViewController(animated: true)
        
//        self.dismiss(animated: true) {
//            LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setUpAllChildViewControllers () {
        let titles = ["商城","发现","我"]
        let normalImgs = ["pub_icon_shop_n","find","pub_icon_me_n"]
        let selectedImgs = ["pub_icon_shop_s","find_on","pub_icon_me_s"]

        let secVC = ShopViewController.spwan()
        setUpNavRootViewController(vc: secVC, title: titles[0], imageName: normalImgs[0], selectedImageName: selectedImgs[0])
        
        let thirVC = DiscoverViewController.spwan()
        setUpNavRootViewController(vc: thirVC, title: titles[1], imageName: normalImgs[1], selectedImageName: selectedImgs[1])
        
        let fourVC = EnterpriseCenterViewController.spwan()
        setUpNavRootViewController(vc: fourVC, title: titles[2], imageName: normalImgs[2], selectedImageName: selectedImgs[2])
    }
    
    fileprivate func setUpNavRootViewController(vc: UIViewController, title: String, imageName: String, selectedImageName: String) {
        vc.title = title
        vc.tabBarItem.image = UIImage(named:imageName)
        vc.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.addChildViewController(LYNavigationController(rootViewController: vc))
    }

}


extension EnterpriseTabBarController{
    
    
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
