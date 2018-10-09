//
//  AppDelegate.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/5/26.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import Foundation




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //单例
    class var sharedInstance : AppDelegate{
        guard let single = UIApplication.shared.delegate as? AppDelegate else{
            return AppDelegate()
        }
        return single
    }
    
    //底部tabbar
    var baseTabBar : LYTabBarController{
        get{
            return LYTabBarController()
        }
    }

    //底部tabbar
    var epTabBar : EnterpriseTabBarController{
        get{
            return EnterpriseTabBarController()
        }
    }
    
    //登录页面
    fileprivate lazy var loginNav : LYNavigationController = {
        let loginVC = ChooseLoginViewController.spwan()
        let loginNav = LYNavigationController(rootViewController: loginVC)
        return loginNav
    }()
    
    //引导页
    lazy var bgView : UIView = {
        let bgView = UIView(frame: UIScreen.main.bounds)
        bgView.backgroundColor = UIColor.black
        return bgView
    }()
    fileprivate lazy var scrollView: GuardScrollView = {
        let scrollView = GuardScrollView(frame: UIScreen.main.bounds)
        scrollView.backgroundColor = UIColor.white
        return scrollView
    }()
    
    //广告页
    fileprivate var adViewNav : LYNavigationController = {
        let adVC = AdViewController()
        let adViewNav = LYNavigationController(rootViewController: adVC)
        return adViewNav
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        
        //异常监测
        Bugly.start(withAppId: "42167a8f7c")
        
        LocalData.saveYesOrNotValue(value: "0", key: KIsLaunchInfoFromAppWebKey)
        
        //检测网络
        if !NetTools.checkNetType(){
            LYProgressHUD.showError("未连接网络，请检查网络设置")
        }
        
        //友盟分享设置
        DispatchQueue.global().async {
            self.confitUShareSettings()
        }
        
        //高德地图
//        AMapServices.shared().apiKey = KAmapKey
        //百度地图
        let mapManager = BMKMapManager()
        let ret = mapManager.start(KBmapKey, generalDelegate: self)
        if ret == false{
            print("百度地图启动失败！")
        }
        BaiDuMap.default.startLocation()
        
        //注册微信
        WXApi.registerApp(KWechatKey)
        
        //极光推送
        DispatchQueue.global().async {
            self.setupJpush(launchOptions)
        }
        
        //注册本地推送
        let setting = UIUserNotificationSettings.init(types: UIUserNotificationType(rawValue: UIUserNotificationType.RawValue(UInt8(UIUserNotificationType.alert.rawValue)|UInt8(UIUserNotificationType.sound.rawValue)|UInt8(UIUserNotificationType.badge.rawValue))), categories: nil)
        UIApplication.shared.registerUserNotificationSettings(setting)
        
        //注册环信
        self.configEasemob(application, launchOptions: launchOptions)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.enterHomeView(noti:)), name: NSNotification.Name(rawValue: KEnterAppNotification), object: nil)
        
        self.setupRootViewController()
        
        return true
    }
    
    //初始设置页面
    func setupRootViewController() {
        //如果个人账户登录了则进个人版，如果个人版没有登录但是企业版登录了则进企业版，如果都没有登录则展示登录页面
        if LocalData.getYesOrNotValue(key: IsLogin){
            LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
            self.window?.rootViewController = self.baseTabBar
            
            //未读消息数量
            self.loadSysMessage()
        }else if LocalData.getYesOrNotValue(key: IsEPLogin){
            LocalData.saveYesOrNotValue(value: "1", key: KEnterpriseVersion)
            self.window?.rootViewController = self.epTabBar
        }else{
            LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
            self.window?.rootViewController = self.loginNav
        }
        
        let isNotFirstOpen = LocalData.getYesOrNotValue(key: IsNotFirstOpen)
        if !isNotFirstOpen{
            self.showAppGuardView()
        }
    }
    
    
    //1、个人 2、企业 3、登录
    func resetRootViewController(_ type : Int) {
        DispatchQueue.main.async {
            if type == 1{
                LocalData.saveYesOrNotValue(value: "0", key: KEnterpriseVersion)
                //是否需要登录
                if !LocalData.getYesOrNotValue(key: IsLogin){
                    showLoginController()
                    return
                }
                if self.window?.rootViewController == self.baseTabBar{
                    return
                }
                LYProgressHUD.showEpLoading("打开个人版...")
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    DispatchQueue.main.async {
                        self.window?.rootViewController = self.baseTabBar
                        //加载个人信息
                        self.loadMineInfoData()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    LYProgressHUD.dismiss()
                }
            }else if type == 2{
                LocalData.saveYesOrNotValue(value: "1", key: KEnterpriseVersion)
                //是否需要登录
                if !LocalData.getYesOrNotValue(key: IsEPLogin){
                    showLoginController()
                    return
                }
                if self.window?.rootViewController == self.epTabBar{
                    return
                }
                LYProgressHUD.showEpLoading("打开企业版...")
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    DispatchQueue.main.async {
                        self.window?.rootViewController = self.epTabBar
                        //企业中心数据
                        self.loadEnterpriseData()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    LYProgressHUD.dismiss()
                }
            }else if type == 3{
                self.window?.rootViewController = self.loginNav
                UIApplication.shared.isStatusBarHidden = false
            }
        }
    }
    
    //从网页打开app时的跳转
    func goToLaunchDetailVC(){
        
        //判断是否记录从网页打开app时的跳转
        let launchInfo = LocalData.getLaunchTypeAndId()
        if launchInfo != nil{
            guard let tabbar = self.window?.rootViewController as? LYTabBarController else{
                return
            }
            guard let nav = tabbar.selectedViewController as? LYNavigationController else{
                return
            }

            if launchInfo!["type"] == LaunchDetailType.GoodsDetailType.rawValue{
                let detailVC = GoodsDetailViewController.spwan()
                detailVC.goodsId = launchInfo!["idStr"]!
                nav.viewControllers.first!.navigationController?.pushViewController(detailVC, animated: true)
            }else if launchInfo!["type"] == LaunchDetailType.ProjectDetailType.rawValue{
                let detailVC = TaskReceiveDetailViewController.spwan()
                detailVC.task_id = launchInfo!["idStr"]!
                nav.viewControllers.first!.navigationController?.pushViewController(detailVC, animated: true)
            }else if launchInfo!["type"] == LaunchDetailType.VideoDetailType.rawValue{
                let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
                videoPlayVC.videoId = launchInfo!["idStr"]!
                nav.viewControllers.first!.navigationController?.pushViewController(videoPlayVC, animated: true)
            }else if launchInfo!["type"] == LaunchDetailType.TestReportDetailType.rawValue{
                let testReportVC = TestReportDetailViewController.spwan()
                testReportVC.testId = launchInfo!["idStr"]!
                nav.viewControllers.first!.navigationController?.pushViewController(testReportVC, animated: true)
            }
        }
        LocalData.setLaunchTypeAndId(type: nil, idStr: nil)
    }
    
    //从广告详情打开商品跳转------逻辑需要整理
    func goToLaunchDetailVC2(){
        if window?.rootViewController == adViewNav{
            LocalData.saveYesOrNotValue(value: "0", key: KIsLaunchInfoFromAppWebKey)
            //判断是否记录从网页打开app时的跳转
            let launchInfo = LocalData.getLaunchTypeAndId()
            if launchInfo != nil{
                if launchInfo!["type"] == LaunchDetailType.GoodsDetailType.rawValue{
                    let detailVC = GoodsDetailViewController.spwan()
                    detailVC.goodsId = launchInfo!["idStr"]!
                    adViewNav.viewControllers.first!.navigationController?.pushViewController(detailVC, animated: true)
                }else if launchInfo!["type"] == LaunchDetailType.ProjectDetailType.rawValue{
                    let detailVC = TaskReceiveDetailViewController.spwan()
                    detailVC.task_id = launchInfo!["idStr"]!
                    adViewNav.viewControllers.first!.navigationController?.pushViewController(detailVC, animated: true)
                }else if launchInfo!["type"] == LaunchDetailType.VideoDetailType.rawValue{
                    let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
                    videoPlayVC.videoId = launchInfo!["idStr"]!
                    adViewNav.viewControllers.first!.navigationController?.pushViewController(videoPlayVC, animated: true)
                }
            }
            LocalData.setLaunchTypeAndId(type: nil, idStr: nil)
        }
    }
    
    //从网页打开app时的跳转
    func goToLaunchDetailVC3(){
        
        //判断是否记录从网页打开app时的跳转
        let launchInfo = LocalData.getLaunchTypeAndId()
        if launchInfo != nil{
            guard let tabbar = self.window?.rootViewController as? EnterpriseTabBarController else{
                return
            }
            guard let nav = tabbar.selectedViewController as? LYNavigationController else{
                return
            }
            
            if launchInfo!["type"] == LaunchDetailType.GoodsDetailType.rawValue{
                let detailVC = GoodsDetailViewController.spwan()
                detailVC.goodsId = launchInfo!["idStr"]!
                nav.viewControllers.first!.navigationController?.pushViewController(detailVC, animated: true)
            }
//            else if launchInfo!["type"] == LaunchDetailType.ProjectDetailType.rawValue{
//                let detailVC = TaskReceiveDetailViewController.spwan()
//                detailVC.task_id = launchInfo!["idStr"]!
//                nav.viewControllers.first!.navigationController?.pushViewController(detailVC, animated: true)
//            }else if launchInfo!["type"] == LaunchDetailType.VideoDetailType.rawValue{
//                let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
//                videoPlayVC.videoId = launchInfo!["idStr"]!
//                nav.viewControllers.first!.navigationController?.pushViewController(videoPlayVC, animated: true)
//            }
            else if launchInfo!["type"] == LaunchDetailType.TestReportDetailType.rawValue{
                let testReportVC = TestReportDetailViewController.spwan()
                testReportVC.testId = launchInfo!["idStr"]!
                nav.viewControllers.first!.navigationController?.pushViewController(testReportVC, animated: true)
            }
        }
        LocalData.setLaunchTypeAndId(type: nil, idStr: nil)
    }
    
    
    //当前根控制器是否为广告
    func isRootViewAdNav() -> Bool {
        return window?.rootViewController == adViewNav
    }
    
    //友盟分享设置
    func confitUShareSettings() {
        //打开调试日志
        UMSocialManager.default().openLog(true)
        //设置友盟appkey
        UMSocialManager.default().umSocialAppkey = KUMShareKey
        
        //设置微信的appKey和appSecret
        UMSocialManager.default().setPlaform(.wechatSession, appKey: KWechatKey, appSecret: KWechatSecretKey, redirectURL: nil)
        UMSocialManager.default().setPlaform(.wechatTimeLine, appKey: KWechatKey, appSecret: KWechatSecretKey, redirectURL: nil)
        
        //设置QQ
        UMSocialManager.default().setPlaform(.QQ, appKey: KTencentAppId, appSecret: KTencentAppKey, redirectURL: nil)
        UMSocialManager.default().setPlaform(.qzone, appKey: KTencentAppId, appSecret: KTencentAppKey, redirectURL: nil)
        
        //新浪
        UMSocialManager.default().setPlaform(.sina, appKey: KSinaAppKey, appSecret: KSinaAppSecret, redirectURL: "http://www.weibo.com")
        
        //email
        //        UMSocialManager.default().setPlaform(.email, appKey: <#T##String!#>, appSecret: <#T##String!#>, redirectURL: <#T##String!#>)
        
        //sms
    }
    
    //环信//注册环信
    func configEasemob(_ application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        //        let options = EMOptions.init(appkey: KEasemobKey)
        let options = HOptions()
        options.apnsCertName = KEasemobCertName
        options.tenantId = KEasemobId
        options.appkey = KEasemobKey
        let initError = HChatClient.shared().initializeSDK(with: options)
        if initError != nil{
            print("-------------------------------环信初始化失败----------------------------------")
        }
        
        //环信//登录环信
        esmobLogin()
    
    }
    
    
    
    //极光推送
    func setupJpush(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.alert.rawValue)|Int(JPAuthorizationOptions.badge.rawValue)|Int(JPAuthorizationOptions.sound.rawValue)
        DispatchQueue.main.async {
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        }
        
        
        let advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        if DeBug{
            JPUSHService.setup(withOption: launchOptions, appKey: KJpushKey, channel: "itms-apps://itunes.apple.com/cn/app/id1171281585?mt=8", apsForProduction: false, advertisingIdentifier : advertisingId)
        }else{
            JPUSHService.setup(withOption: launchOptions, appKey: KJpushKey, channel: "itms-apps://itunes.apple.com/cn/app/id1171281585?mt=8", apsForProduction: true, advertisingIdentifier : advertisingId)
        }
        
        JPUSHService.registrationIDCompletionHandler { (resCode, registrationID) in
            if resCode == 0{
                print("注册极光推送成功---" + registrationID!)
            }else{
                print("注册极光推送失败---" + String.init(format: "%d", resCode))
            }
        }
        
        //设置推送别名
        if LocalData.getUserPhone().isEmpty{
            //设置推送的通用标示
            JPUSHService.setAlias("000000", completion: { (isResCode, alias, seq) in
            }, seq:0)
        }else{
            JPUSHService.setAlias(LocalData.getUserPhone(), completion: { (isResCode, alias, seq) in
            }, seq:0)
        }
        
        
        //环信推送
        DispatchQueue.main.async {
            HChatClient.shared().add(self, delegateQueue: nil)
            EMClient.shared().chatManager.add(self, delegateQueue: nil)
        }
        
    }
    
    func registerJpush() {
        
    }
    
    //MARK: - 网页打开app
    //iOS 9以下的回调
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let urlStr = url.absoluteString
        //网页打开时跳转详情页
        self.openFromOther(urlStr, url)
        
        
        //微信支付
        if urlStr.hasPrefix(KWechatKey){
            return WXApi.handleOpen(url, delegate: self)
        }
        //支付宝
        //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDict) in
                //处理支付结果
                self.aliPayResult(resultDict)
            })
        }
        //支付宝
        //支付宝钱包快登授权返回authCode
        //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
        if url.host == "platformapi" {
            AlipaySDK.defaultService().processAuthResult(url, standbyCallback: { (resultDict) in
                //处理支付结果
                self.aliPayResult(resultDict)
            })
        }
        
        //处理友盟回调
        UMSocialManager.default().handleOpen(url, sourceApplication: sourceApplication, annotation: annotation)
        
        return true
    }
    //iOS 9以上的回调
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlStr = url.absoluteString
        
        //网页打开时跳转详情页
        self.openFromOther(urlStr, url)
        
        
        //微信支付
        if urlStr.hasPrefix(KWechatKey){
            return WXApi.handleOpen(url, delegate: self)
        }
        //支付宝
        //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDict) in
                //处理支付结果
                self.aliPayResult(resultDict)
            })
        }
        //支付宝
        //支付宝钱包快登授权返回authCode
        //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
        if url.host == "platformapi" {
            AlipaySDK.defaultService().processAuthResult(url, standbyCallback: { (resultDict) in
                //处理支付结果
                self.aliPayResult(resultDict)
            })
        }
        
        //处理友盟回调
        UMSocialManager.default().handleOpen(url, options: options)
        
        return true
    }
    
    //网页打开时跳转详情页
    func openFromOther(_ urlStr : String, _ url : URL) {
        if urlStr.hasPrefix("qixiaofu://"){
            if url.host == "goodsDetail"{
                //商品详情
                if url.query != nil{
                    let idStr = url.query!.components(separatedBy: "=").last
                    if idStr != nil{
                        LocalData.setLaunchTypeAndId(type: LaunchDetailType.GoodsDetailType, idStr: idStr)
                    }
                }
            }else if url.host == "projectDetail"{
                //任务单详情
                if url.query != nil{
                    let idStr = url.query!.components(separatedBy: "=").last
                    if idStr != nil{
                        LocalData.setLaunchTypeAndId(type: LaunchDetailType.ProjectDetailType, idStr: idStr)
                    }
                }
            }else if url.host == "videoDetail"{
                //任务单详情
                if url.query != nil{
                    let idStr = url.query!.components(separatedBy: "=").last
                    if idStr != nil{
                        LocalData.setLaunchTypeAndId(type: LaunchDetailType.VideoDetailType, idStr: idStr)
                    }
                }
            }else if url.host == "testreport"{
                //测报详情
                if url.query != nil{
                    let idStr = url.query!.components(separatedBy: "=").last
                    if idStr != nil{
                        LocalData.setLaunchTypeAndId(type: LaunchDetailType.TestReportDetailType, idStr: idStr)
                    }
                }
            }
            
            if self.window?.rootViewController != nil{
                if self.window!.rootViewController!.isKind(of: LYTabBarController.self){
                    //个人版
                    self.goToLaunchDetailVC()
                }else if LocalData.getYesOrNotValue(key: KIsLaunchInfoFromAppWebKey){
                    self.goToLaunchDetailVC2()
                }else if window!.rootViewController!.isKind(of: EnterpriseTabBarController.self){
                    //企业版
                    self.goToLaunchDetailVC3()
                }
            }
            
        }
        
        
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        //环信
        HChatClient.shared().applicationDidEnterBackground(application)
        EMClient.shared().applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        //检查app更新
        self.checkAppUpdate()
        
        //未读消息数量
        self.loadSysMessage()
        
        //百度地图
        let mapManager = BMKMapManager()
        let ret = mapManager.start(KBmapKey, generalDelegate: self)
        if ret == false{
            print("百度地图启动失败！")
        }
        BaiDuMap.default.startLocation()
        
        
        //环信
        HChatClient.shared().applicationWillEnterForeground(application)
        EMClient.shared().applicationWillEnterForeground(application)
        //环信//登录环信
        esmobLogin()
        
        //清理通知数量
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Required - 注册 DeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DispatchQueue.global().async {
            JPUSHService.registerDeviceToken(deviceToken)
            HChatClient.shared().bindDeviceToken(deviceToken)
            EMClient.shared().bindDeviceToken(deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
        //接到通知发送位置
        BaiDuMap.default.startLocation()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        //接到通知发送位置
        BaiDuMap.default.startLocation()
        completionHandler(UIBackgroundFetchResult.newData)
        guard let jump_type = userInfo["jump_type"] as? String else{
            return
        }
        if jump_type.trim == "73"{
            guard let jump_id = userInfo["jump_id"] as? String else{
                return
            }
            LocalData.setLaunchTypeAndId(type: LaunchDetailType.ProjectDetailType, idStr: jump_id)
        }
    }
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        //环信推送内容
        guard let tabbar = self.window?.rootViewController as? LYTabBarController else{
            return
        }
        guard let nav = tabbar.selectedViewController as? LYNavigationController else{
            return
        }
        //消息发送方的环信 ID
        guard let conversationId = notification.userInfo?["conversationId"] as? String else{
            return
        }
        var name = "对方"
        var icon = ""
        let dict = LocalData.getChatUserInfo(key: conversationId)
        name = dict["name"]!
        icon = dict["icon"]!
        //登录环信
        esmobLogin()
        if conversationId.hasPrefix("kefu"){
            let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
            nav.viewControllers.first!.navigationController?.pushViewController(chatVC!, animated: true)
        }else{
            let chatVC = EaseMessageViewController.init(conversationChatter: conversationId, conversationType: EMConversationType.init(0))
            //保存聊天页面数据
            LocalData.saveChatUserInfo(name: name, icon: icon, key: conversationId)
            chatVC?.title = name
            nav.viewControllers.first!.navigationController?.pushViewController(chatVC!, animated: true)
        }
    }
    
    
}


// MARK: - 引导页
extension AppDelegate{
    fileprivate func showAppGuardView() {
        self.window?.addSubview(bgView)
        bgView.addSubview(scrollView)
    }
    
    @objc func enterHomeView(noti: Notification) {
        // 获取通知传过来的按钮
        LocalData.saveYesOrNotValue(value: "1", key: IsNotFirstOpen)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(UInt64(1.5) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            UIView.animate(withDuration: 1.0, animations: {
                self.bgView.layer.transform = CATransform3DMakeScale(2, 2, 2)
                self.bgView.alpha = 0
            }, completion: { (completion) -> Void in
                UIApplication.shared.isStatusBarHidden = false
                self.bgView.removeFromSuperview()
            })
        }
    }
}

// MARK: - 登录页面
extension AppDelegate{
    
    //检查app更新
    func checkAppUpdate() {
        DispatchQueue.global().async {
            NetTools.requestData(type: .post, urlString: iOSVersionApi, succeed: { (result, error) in
                let localVersion = appVersion().replacingOccurrences(of: ".", with: "").intValue
                let netVersion = result["new_version_num"].stringValue.intValue
                let isForce = result["version_force"].stringValue.intValue
                var message = result["version_msg"].stringValue
                var url = result["version_url"].stringValue
                if message.trim.isEmpty{
                    message = "APP有新版本更新，为了您的使用体验，请到App Store下载更新"
                }
                if url.trim.isEmpty{
                    url = "itms-apps://itunes.apple.com/cn/app/id1171281585?mt=8"
                }
                if localVersion < netVersion{
                    if isForce == 1{
                        LYAlertView.show("提示", message,"去更新",{
                            let urlStr = url
                            if UIApplication.shared.canOpenURL(URL(string:urlStr)!){
                                UIApplication.shared.openURL(URL(string:urlStr)!)
                            }
                        })
                    }else{
                        LYAlertView.show("提示", message,"下次再说","去更新",{
                            let urlStr = url
                            if UIApplication.shared.canOpenURL(URL(string:urlStr)!){
                                UIApplication.shared.openURL(URL(string:urlStr)!)
                            }
                        })
                    }
                }
            }) { (error) in
            }
        }
    }

}

//MARK: - 支付
extension AppDelegate : WXApiDelegate{
    //微信支付结果
    func onResp(_ resp: BaseResp!) {
        
        if resp.isKind(of: PayResp.self){
            var dict = [String:String]()
            dict["code"] = "\(resp.errCode)"
            dict["error"] = resp.errStr
            //处理支付结果
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KWechatPayNotiName), object: nil, userInfo: dict)
        }else if resp.isKind(of: SendAuthResp.self){
            let authResp = resp as! SendAuthResp
            var dict = [String:String]()
            dict["errCode"] = "\(authResp.errCode)"
            dict["code"] = authResp.code
            dict["state"] = authResp.state
            dict["lang"] = authResp.lang
            dict["country"] = authResp.country
            //处理登录结果
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KWechatLoginNotiName), object: nil, userInfo: dict)
        }
    }
    
    //支付宝支付结果
    func aliPayResult(_ resultDict:[AnyHashable:Any]?) {
        guard let dict = resultDict as? [AnyHashable:String] else {
            return
        }
        if dict["resultStatus"] == "9000"{
            //支付成功
            LYProgressHUD.showInfo("支付宝支付成功！")
        }else if dict["resultStatus"] == "6001"{
            //支付取消
            LYProgressHUD.showInfo("用户取消了支付")
        }else{
            //支付失败
            LYProgressHUD.showInfo("支付失败！")
        }
    }
    
}

//MARK: - 获取用户信息
extension AppDelegate{
    // 获取用户信息
    func loadMineInfoData() {
        NetTools.requestData(type: .post, urlString: PersonalInfoApi, succeed: { (resultJson, msg) in
            //保存是否实名
            if resultJson["is_real"].stringValue == "1"{
                //已实名
                LocalData.saveYesOrNotValue(value: "1", key: IsTrueName)
            }else{
                //未实名
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
            }
            //保存姓名
            LocalData.saveUserName(userName: resultJson["member_nik_name"].stringValue)
            LocalData.saveTrueUserName(userName: resultJson["member_truename"].stringValue)
            
            //保存邀请码
            LocalData.saveUserInviteCode(phone: resultJson["iv_code"].stringValue)
            
            //保存服豆个数
            LocalData.saveBeanCount(bean: resultJson["member_fudou"].stringValue)
            
            //保存积分数
            LocalData.saveCreditsCount(bean: resultJson["jifen"].stringValue)
            
            //保存未加密用户ID
            LocalData.saveNotMd5UserId(userId: resultJson["member_id"].stringValue)
            
            //保存自己的聊天页面数据
            LocalData.saveChatUserInfo(name: resultJson["member_nik_name"].stringValue, icon: resultJson["member_avatar"].stringValue, key: LocalData.getUserPhone())
        }) { (error) in
        }
    }
    
    //企业中心数据
    func loadEnterpriseData() {
        NetTools.requestData(type: .post, urlString: EnterpriseCenterApi, succeed: { (resultJson, msg) in
            //实名认证
            if resultJson["is_real"].stringValue.intValue == 1{
                //已实名
                LocalData.saveYesOrNotValue(value: "1", key: IsTrueName)
            }else if resultJson["is_real"].stringValue.intValue == 2{
                //实名审核中
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
            }else{
                //未实名
                LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
            }
            //企业信息是否已审核
            if resultJson["audit_state"].stringValue.intValue == 1{
                LocalData.saveYesOrNotValue(value: "1", key: IsEPApproved)
            }else{
                LocalData.saveYesOrNotValue(value: "0", key: IsEPApproved)
            }
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取信息失败！")
        }
    }
    
    
    
    //系统消息
    func loadSysMessage() {
        let params : [String : Any] = [
            "op" : "message_sel",
            "act" : "member_index",
            "store_id" : "1"
        ]
        
        NetTools.requestData(type: .post, urlString: SysTermMessageApi, parameters: params, succeed: { (result, msg) in
            guard let tabbar = self.window?.rootViewController as? LYTabBarController else{
                return
            }
            var num = 0
            for sub in result.arrayValue{
                num += sub["unread_num"].stringValue.intValue
            }
            
            
            guard let conversations : Array<HConversation> = HChatClient.shared().chatManager.loadAllConversations() as? Array<HConversation> else {
                if num > 0 && !LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    tabbar.childViewControllers[2].tabBarItem.badgeValue = "\(num)"
                }else{
                    tabbar.childViewControllers[2].tabBarItem.badgeValue = nil
                }
                return
            }
            
            for converstion in conversations{
                let con = converstion
                num += Int(con.unreadMessagesCount)
            }
            
            if num > 0 && !LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                tabbar.childViewControllers[2].tabBarItem.badgeValue = "\(num)"
            }else{
                tabbar.childViewControllers[2].tabBarItem.badgeValue = nil
            }
        }) { (error) in
        }
    }
}


//MARK: - 环信和推送的代理
extension AppDelegate : HChatClientDelegate,EMChatManagerDelegate,JPUSHRegisterDelegate{
    
    
    //其他设备登录
    func userAccountDidLoginFromOtherDevice() {
        //重新登录
        showLoginController()
        LYAlertView.show("提示", "此账号已在其他设备登陆，如非本人操作，请修改密码","知道了")
    }
    
    func messagesDidReceive(_ aMessages: [Any]!) {
        if UIApplication.shared.applicationState == .active{
            //前台
        }else if UIApplication.shared.applicationState == .background{
            //后台
            if aMessages.count > 0{
                guard let message = aMessages[0] as? EMMessage else{
                    return
                }
                let localNotification = UILocalNotification()
                localNotification.alertBody = "您有新的未读消息！"
                localNotification.applicationIconBadgeNumber = 1
                localNotification.userInfo = ["conversationId":message.conversationId]
                localNotification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
        }else{
            //收到通知
        }
    }

    
    
    //jpush
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        //        let request = notification.request
        let userInfo = notification.request.content.userInfo
        let content = notification.request.content
        //
        let badge = content.badge
        //通知数量
        UIApplication.shared.applicationIconBadgeNumber = badge?.intValue ?? 0
        //        let body = content.body
        //        let subTitle = content.subtitle
        //        let title = content.title
        
        
        if notification.request.trigger != nil{
            if ((notification.request.trigger! as? UNPushNotificationTrigger) != nil){
                JPUSHService.handleRemoteNotification(userInfo)
            }
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue) | Int(UNNotificationPresentationOptions.badge.rawValue))
        
        guard let jump_type = userInfo["jump_type"] as? String else{
            return
        }
        let body = content.body.isEmpty ? "支付成功！" : content.body
        if jump_type.trim == "2018"{
            LYAlertView.show("提示", body, "知道了")
        }
    }
    
    //点击了推送的消息
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        print(response)
        if response.notification.request.trigger != nil{
            if ((response.notification.request.trigger! as? UNPushNotificationTrigger) != nil){
                JPUSHService.handleRemoteNotification(response.notification.request.content.userInfo)
            }
        }
        completionHandler()
        
        //        let request = notification.request
        let userInfo = response.notification.request.content.userInfo
        let content = response.notification.request.content
        let jump_type = userInfo["jump_type"] as? String
        if jump_type == nil{
            //环信推送内容或者无跳转的内容
            guard let tabbar = self.window?.rootViewController as? LYTabBarController else{
                return
            }
            guard let nav = tabbar.selectedViewController as? LYNavigationController else{
                return
            }
            //消息发送方的环信 ID
            guard let conversationId = userInfo["f"] as? String else{
                return
            }
            var name = "对方"
            var icon = ""
            let dict = LocalData.getChatUserInfo(key: conversationId)
            name = dict["name"]!
            icon = dict["icon"]!
            //登录环信
            esmobLogin()
            if conversationId.hasPrefix("kefu"){
                let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
                nav.viewControllers.first!.navigationController?.pushViewController(chatVC!, animated: true)
            }else{
                let chatVC = EaseMessageViewController.init(conversationChatter: conversationId, conversationType: EMConversationType.init(0))
                //保存聊天页面数据
                LocalData.saveChatUserInfo(name: name, icon: icon, key: conversationId)
                chatVC?.title = name
                nav.viewControllers.first!.navigationController?.pushViewController(chatVC!, animated: true)
            }
        }else{
            //极光推送内容
            let body = content.body.isEmpty ? "支付成功！" : content.body
            if jump_type!.trim == "2018"{
                LYAlertView.show("提示", body, "知道了")
            }else if jump_type!.trim == "73"{
                guard let jump_id = userInfo["jump_id"] as? String else{
                    return
                }
                let detailVC = TaskReceiveDetailViewController.spwan()
                detailVC.task_id = jump_id
                
                guard let tabbar = self.window?.rootViewController as? LYTabBarController else{
                    return
                }
                guard let nav = tabbar.selectedViewController as? LYNavigationController else{
                    return
                }
                nav.viewControllers.first!.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
        
        
        

    }
    
    /**
     <UNNotificationResponse: 0x1c0422ba0; actionIdentifier: com.apple.UNNotificationDefaultActionIdentifier, notification: <UNNotification: 0x1c0423460; date: 2017-11-29 05:27:23 +0000, request: <UNNotificationRequest: 0x1c422ecc0; identifier: 42784198229739337, content: <UNNotificationContent: 0x1c0112bd0; title: (null), subtitle: (null), body: 4, categoryIdentifier: , launchImageName: , peopleIdentifiers: (
     ), threadIdentifier: , attachments: (
     ), badge: 1, sound: <UNNotificationSound: 0x1c02a6d20>, hasDefaultAction: YES, defaultActionTitle: (null), shouldAddToNotificationsList: YES, shouldAlwaysAlertWhileAppIsForeground: NO, shouldLockDevice: NO, shouldPauseMedia: NO, isSnoozeable: NO, fromSnooze: NO, darwinNotificationName: (null), darwinSnoozedNotificationName: (null), trigger: <UNPushNotificationTrigger: 0x1c0011c70; contentAvailable: NO, mutableContent: NO>>>>
     
     some(<UNNotificationResponse: 0x10b1394a0; actionIdentifier: com.apple.UNNotificationDefaultActionIdentifier, notification: <UNNotification: 0x106177b80; date: 2018-09-07 08:19:17 +0000, request: <UNNotificationRequest: 0x1061a38d0; identifier: 58546796078880219, content: <UNNotificationContent: 0x10b1316d0; title: (null), subtitle: (null), body: test, categoryIdentifier: , launchImageName: , peopleIdentifiers: (
     ), threadIdentifier: , attachments: (
     ), badge: 1, sound: <UNNotificationSound: 0x10b1488d0>, hasDefaultAction: YES, defaultActionTitle: (null), shouldAddToNotificationsList: YES, shouldAlwaysAlertWhileAppIsForeground: NO, shouldLockDevice: NO, shouldPauseMedia: NO, isSnoozeable: NO, fromSnooze: NO, darwinNotificationName: (null), darwinSnoozedNotificationName: (null), trigger: <UNPushNotificationTrigger: 0x10a242aa0; contentAvailable: NO, mutableContent: NO>>>>)
     */
}

extension AppDelegate : BMKGeneralDelegate{
    
}
