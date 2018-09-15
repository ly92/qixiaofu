////
////  ChatViewController.swift
////  qixiaofu
////
////  Created by ly on 2017/7/24.
////  Copyright © 2017年 qixiaofu. All rights reserved.
////
//
//import UIKit
//
//class ChatViewController: EaseMessageViewController {
//
//
//    init(conversationChatter:String, conversationName:String, conversationIcon:String) {
//        super.init(conversationChatter: conversationChatter, conversationType: .init(0))
//
//        self.navigationItem.title = conversationName
//        //保存聊天页面数据
//        LocalData.saveChatUserInfo(name: conversationName, icon: conversationIcon, key: self.conversation.conversationId)
//    }
//
//    override init(nibName nibNameorNil:String?, bundle nibBundleOrNil:Bundle?){
//        super.init(nibName:nibNameorNil,bundle:nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.showRefreshHeader = true
//        self.delegate = self
//        self.dataSource = self
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//}
//
//
//extension ChatViewController : EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource{
//
//    func messageViewController(_ viewController: EaseMessageViewController!, modelFor message: EMMessage!) -> IMessageModel! {
//        let model = EaseMessageModel.init(message: message)
//        model?.failImageName = "EaseUIResource.bundle/imageDownloadFail"
//        //是否是当前登录者发送的消息
//        let userDict = LocalData.getChatUserInfo(key: LocalData.getUserPhone())
//        model?.nickname = userDict["name"]
//        model?.avatarURLPath = userDict["icon"]
//
//        return model
//    }
//
//    func emotionFormessageViewController(_ viewController: EaseMessageViewController!) -> [Any]! {
//        var emotions = Array<EaseEmotion>()
//        for name in EaseEmoji.allEmoji(){
//            let emotion = EaseEmotion.init(name: "", emotionId: name as! String, emotionThumbnail: name as! String, emotionOriginal: name as! String, emotionOriginalURL: "", emotionType: .default)
//            emotions.append(emotion!)
//        }
//        let temp = emotions[0]
//        let managerDefault = EaseEmotionManager.init(type: .default, emotionRow: 3, emotionCol: 7, emotions: emotions, tagImage: UIImage(named:temp.emotionId))
//
//        return [managerDefault as Any]
//    }
//
//}
//
//
