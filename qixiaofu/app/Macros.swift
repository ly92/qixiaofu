//
//  Macros.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/5/30.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import Foundation

//屏幕尺寸
let kScreenSize = UIScreen.main.bounds.size
let kScreenW = UIScreen.main.bounds.width
let kScreenH = UIScreen.main.bounds.height

let NAV_Color = UIColor.white
let Text_Color = UIColor.RGBS(s: 33)
let BG_Color = UIColor.RGBS(s: 240)
let Normal_Color = UIColor.RGB(r: 205, g: 56, b: 37)

//版本号
func appVersion() -> String {
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    return currentVersion
}

//是否允许消息通知
func isMessageNotificationServiceOpen() -> Bool{
    return UIApplication.shared.isRegisteredForRemoteNotifications
}

func GetStateName(state:String) -> String {
    if state.isEmpty{
        return ""
    }
    switch state.intValue {
    case 0:
        return "已撤销"
    case 1:
        return "报名中"
    case 2:
        return "已接单"
    case 3:
        return "已完成"
    case 4:
        return "已失效"
    case 5:
        return "已取消"
    case 6:
        return "调价中"
    case 7:
        return "补单"
    case 8:
        return "工作中"
    default:
        return ""
    }
}



func functionSkipAction(type:String,controller:UIViewController){
    if type.isEmpty{
        return
    }
    
    LocalData.removePointNum(num: type.intValue)
    
    switch type.intValue {
    case 1:
//        BaiDuMap.default.startTrace()
        //去发单
        UserViewModel.haveTrueName(parentVC: controller, {
            NetTools.qxfClickCount("1")
            let sendTaskVC = SendTaskViewController.spwan()
            controller.navigationController?.pushViewController(sendTaskVC, animated: true)
        })
    case 2:
//        BaiDuMap.default.stopTrace()
        //去接单
        let taskVC = TaskListViewController.spwan()
        taskVC.isHomeAllTaskList = true
        controller.navigationController?.pushViewController(taskVC, animated: true)
    case 3:
        //钱包
        let moneyVC = MyMoneyViewController.spwan()
        controller.navigationController?.pushViewController(moneyVC, animated: true)
    case 4:
        //签到
        let signVC = SignInViewController.spwan()
        controller.navigationController?.pushViewController(signVC, animated: true)
    case 5:
        //我的发单
        let mySendVC = MySendOrderListViewController.spwan()
        mySendVC.titleArray = ["报名中","已接单","已完成","调价中","已取消","已失效"]
        mySendVC.stateArray = [1,2,3,6,5,4]
        controller.navigationController?.pushViewController(mySendVC, animated: true)
    case 6:
        //我的接单
        let myReceiveVC = MySendOrderListViewController.spwan()
        myReceiveVC.titleArray = ["报名中","已接单","已完成","已取消","调价中"]
        myReceiveVC.stateArray = [1,2,3,5,6]
        myReceiveVC.isMyReceive = true
        controller.navigationController?.pushViewController(myReceiveVC, animated: true)
    case 7:
        //企业采购
        AppDelegate.sharedInstance.resetRootViewController(2)
        controller.navigationController?.popToRootViewController(animated: false)
    case 8:
        //更多
        let moreVC = MoreFunctionViewController()
        controller.navigationController?.pushViewController(moreVC, animated: true)
    case 9:
        //公告
        let noticeListVC = NoticeListViewController()
        controller.navigationController?.pushViewController(noticeListVC, animated: true)
    case 10 :
        //领券中心
        let couponVC = CouponListViewController()
        controller.navigationController?.pushViewController(couponVC, animated: true)
    case 11 :
        //代测
        let testVC = TestCategoryViewController.spwan()
        controller.navigationController?.pushViewController(testVC, animated: true)
    case 12 :
        //发现
        let discoverVC = DiscoverViewController.spwan()
        controller.navigationController?.pushViewController(discoverVC, animated: true)
    default:
        //
        let toDoVc = ToDoEmptyViewController()
        controller.navigationController?.pushViewController(toDoVc, animated: true)
//        LYProgressHUD.showError("当前版本不支持，快去App Store下载最新版本")
    }
    
}

func showLoginController(){
    
    
    LYProgressHUD.dismiss()
    //清除userid
    if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
        LocalData.saveEPUserId(userId: "")
        //记录已退出
        LocalData.saveYesOrNotValue(value: "0", key: IsEPLogin)
    }else{
        LocalData.saveUserId(userId: "")
        //记录已退出
        LocalData.saveYesOrNotValue(value: "0", key: IsLogin)
    }
    //退出环信
    esmobLogout()
    //设置推送的通用标示
    JPUSHService.setAlias("000000", completion: { (isResCode, alias, seq) in
    }, seq:0)
    DispatchQueue.main.async {
        AppDelegate.sharedInstance.resetRootViewController(3)
    }
}

//企业密码正则
func checkEpPwd(_ pwd : String) -> Bool {
    let regex = try! NSRegularExpression(pattern: "[A-Za-z0-9]{8,16}", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
    let regex1 = try! NSRegularExpression(pattern: "[A-Z]+", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
    let regex2 = try! NSRegularExpression(pattern: "[a-z]+", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
    let regex3 = try! NSRegularExpression(pattern: "[0-9]+", options: [NSRegularExpression.Options.dotMatchesLineSeparators])
    if regex1.numberOfMatches(in: pwd, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, pwd.count)) == 0 {
        LYProgressHUD.showError("至少包含一个大写字母")
        return false
    }
    if regex2.numberOfMatches(in: pwd, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, pwd.count)) == 0{
        LYProgressHUD.showError("至少包含一个小写字母")
        return false
    }
    if regex3.numberOfMatches(in: pwd, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, pwd.count)) == 0{
        LYProgressHUD.showError("至少包含一个数字")
        return false
    }
    if regex.numberOfMatches(in: pwd, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, pwd.count)) != 1{
        LYProgressHUD.showError("密码格式不准确！")
        return false
    }
    
    var pass = true
    regex.enumerateMatches(in: pwd, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, pwd.count)) {
        match, flags, stop in
        if match != nil{
            if match!.range.length != pwd.count{
                LYProgressHUD.showError("密码不可包含特殊字符")
                pass = false
            }
        }
    }
    
    return pass
}

//环信注册
func esmobRegister(_ phone : String){
    EMClient.shared()?.register(withUsername: phone, password: "11")
//    HChatClient.shared().register(withUsername: phone, password: "11")
}

//环信登录
func esmobLogin(){
    DispatchQueue.global().async {
        let loginError = EMClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
        if loginError != nil{
            //注册环信
            EMClient.shared().register(withUsername: LocalData.getUserPhone(), password: "11")
            print("-------------------------------环信登录失败-------------------------------")
        }
        
//        let loginError = HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
//        if loginError != nil{
//            //注册环信
//            HChatClient.shared().register(withUsername: LocalData.getUserPhone(), password: "11")
//            print("-------------------------------环信登录失败-------------------------------")
//        }
    }
}

//环信退出
func esmobLogout(){
    DispatchQueue.global().async {
//        HChatClient.shared().logout(true)
    }
}

//发起聊天
func esmobChat(_ vc : UIViewController, _ to : String, _ type : Int, _ name : String="", _ icon : String=""){
    let chatVC = EaseMessageViewController.init(conversationChatter: to, conversationType: EMConversationType.init(0))
    chatVC?.title = name
    vc.navigationController?.pushViewController(chatVC!, animated: true)
    
    
//    if type == 1{
//        let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
//        vc.navigationController?.pushViewController(chatVC!, animated: true)
//    }else{
//        let chatVC = EaseMessageViewController.init(conversationChatter: to, conversationType: EMConversationType.init(0))
//        //保存聊天页面数据
//        LocalData.saveChatUserInfo(name: name, icon: icon, key: conversationId)
//        chatVC?.title = name
//        vc.navigationController?.pushViewController(chatVC!, animated: true)
//    }
}

class Macros: NSObject {
    
    
}
