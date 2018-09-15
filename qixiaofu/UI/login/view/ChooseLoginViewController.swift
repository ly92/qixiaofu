
//
//  ChooseLoginViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/30.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class ChooseLoginViewController: BaseViewController {
    class func spwan() -> ChooseLoginViewController{
        return self.loadFromStoryBoard(storyBoard: "Login") as! ChooseLoginViewController
    }
    @IBOutlet weak var personBtn: UIButton!
    @IBOutlet weak var epBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.personBtn.layer.cornerRadius = 20
        self.epBtn.layer.cornerRadius = 20
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if LocalData.getYesOrNotValue(key: IsLogin) || LocalData.getYesOrNotValue(key: IsEPLogin){
            //显示返回按钮
            self.backBtn.isHidden = false
        }else{
            self.backBtn.isHidden = true
        }
    }
    
    @IBAction func backClick() {
        if LocalData.getYesOrNotValue(key: IsLogin){
            AppDelegate.sharedInstance.resetRootViewController(1)
        }else if LocalData.getYesOrNotValue(key: IsEPLogin){
            AppDelegate.sharedInstance.resetRootViewController(2)
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func personBtnAction() {
        //如果个人账户登录了则直接进个人版
        if LocalData.getYesOrNotValue(key: IsLogin){
            AppDelegate.sharedInstance.resetRootViewController(1)
        }else{
            let personVC = PersonLoginViewController.spwan()
            self.navigationController?.pushViewController(personVC, animated: true)
        }
    }
    
    @IBAction func epBtnAction() {
        //如果企业版登录了则直接进企业版
        if LocalData.getYesOrNotValue(key: IsEPLogin){
            AppDelegate.sharedInstance.resetRootViewController(2)
        }else{
            let epVC = EPLoginViewController.spwan()
            self.navigationController?.pushViewController(epVC, animated: true)
        }
    }
    
}
