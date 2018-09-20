//
//  MessageViewController.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MessageViewController: BaseTableViewController {
    
    //    class func spwan() -> MessageViewController{
    //        return self.loadFromStoryBoard(storyBoard: "Message") as! MessageViewController
    //    }
    
    fileprivate let systermIcons = [#imageLiteral(resourceName: "img_systemnesw"),#imageLiteral(resourceName: "wallet_message"),#imageLiteral(resourceName: "task_message")]
    fileprivate var systermJson : JSON = []
    
    fileprivate var chatArray : Array<HConversation> = Array<HConversation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "消息"
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.register(UINib.init(nibName: "SysMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "SysMessageCell")
        
        self.tableView.es.addPullToRefresh {
            //环信聊天消息列表
            self.esmobChatList()
            
            self.loadSysMessage()
            self.tableView.es.stopPullToRefresh()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //环信聊天消息列表
        self.esmobChatList()
        
        self.loadSysMessage()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //系统消息
    func loadSysMessage() {
        let params : [String : Any] = [
            "op" : "message_sel",
            "act" : "member_index",
            "store_id" : "1"
        ]
        NetTools.requestData(type: .post, urlString: SysTermMessageApi, parameters: params, succeed: { (result, msg) in
            self.systermJson = result
            self.tableView.reloadData()
            LYProgressHUD.dismiss()
            
            guard let tabbar = AppDelegate.sharedInstance.window?.rootViewController as? LYTabBarController else{
                return
            }
            var num = 0
            for sub in result.arrayValue{
                num += sub["unread_num"].stringValue.intValue
            }
            for converstion in self.chatArray{
                let con = converstion
                num += Int(con.unreadMessagesCount)
            }
            if num > 0 && !LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                tabbar.childViewControllers[2].tabBarItem.badgeValue = "\(num)"
            }else{
                tabbar.childViewControllers[2].tabBarItem.badgeValue = nil
            }
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //环信聊天消息列表
    func esmobChatList() {
        self.chatArray.removeAll()
//        if !HChatClient.shared().isLoggedInBefore{
        DispatchQueue.global().async {
            let loginError = HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
            if loginError != nil{
                print("-------------------------------环信登录失败-------------------------------")
            }
        }
//        }
        
        guard let conversations : Array<HConversation> = HChatClient.shared().chatManager.loadAllConversations() as? Array<HConversation> else {
            return
        }
        
        for converstion in conversations{
            let con = converstion
            let _ = LocalData.getChatUserInfo(key: con.conversationId)
            self.chatArray.append(con)
            self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .automatic)
        }
    }
    
}

extension MessageViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.systermJson.arrayValue.count
        }
        return self.chatArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SysMessageCell", for: indexPath) as! SysMessageCell
        if indexPath.section == 0{
            cell.iconImgV.image = self.systermIcons[indexPath.row]
            cell.timeLbl.isHidden = true
            cell.unReadNumLbl.isHidden = true
            cell.descLbl.text = ""
            
            if self.systermJson.arrayValue.count > indexPath.row{
                let subJson = self.systermJson.arrayValue[indexPath.row]
                cell.unReadNumLbl.text = subJson["unread_num"].stringValue
                cell.nameLbl.text = subJson["msg_title"].stringValue
                if subJson["unread_num"].stringValue.intValue > 0{
                    cell.descLbl.text = "有新消息来了"
                    cell.unReadNumLbl.isHidden = false
                }
            }
        }else{
            cell.timeLbl.isHidden = false
            cell.unReadNumLbl.isHidden = true
            if self.chatArray.count > indexPath.row{
                let model = self.chatArray[indexPath.row]
                let dict = LocalData.getChatUserInfo(key: model.conversationId)
                cell.nameLbl.text = dict["name"]
                cell.iconImgV.setHeadImageUrlStr(dict["icon"]!)
                
                //未读数量
                let unReadNum = Int(model.unreadMessagesCount)
                if unReadNum > 0{
                    cell.unReadNumLbl.isHidden = false
                    cell.unReadNumLbl.text = "\(model.unreadMessagesCount)"
                }
                
                
                var latestMessageTitle = ""
                if model.latestMessage != nil{
                    switch model.latestMessage.body.type {
                    case EMMessageBodyTypeImage:
                        latestMessageTitle = "图片"
                    case EMMessageBodyTypeText:
                        //表情映射
                        let didReceiveText = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons: (model.latestMessage.body as! EMTextMessageBody).text)
                        latestMessageTitle = didReceiveText!
                    case EMMessageBodyTypeVoice:
                        latestMessageTitle = "语音"
                    case EMMessageBodyTypeLocation:
                        latestMessageTitle = "位置"
                    case EMMessageBodyTypeVideo:
                        latestMessageTitle = "视频"
                    case EMMessageBodyTypeFile:
                        latestMessageTitle = "文件"
                    default:
                        latestMessageTitle = "[富文本]"
                    }
                    if latestMessageTitle.isEmpty{
                        latestMessageTitle = "[富文本]"
                    }
                    let attributedStr = NSAttributedString.init(string: latestMessageTitle)
                    cell.descLbl.attributedText = attributedStr
                    
                    cell.timeLbl.text = Date.dateStringFromDate(format: Date.dayFormatString(), timeStamps: "\(model.latestMessage.messageTime)")
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0{
            if self.systermJson.arrayValue.count > indexPath.row{
                let subJson = self.systermJson.arrayValue[indexPath.row]
                let messageVC = SystemMessageViewController()
                if subJson["msg_type"].stringValue.intValue == 1{
                    messageVC.messageType = .systemMessageType
                }else if subJson["msg_type"].stringValue.intValue == 2{
                    messageVC.messageType = .walletMessageType
                }else if subJson["msg_type"].stringValue.intValue == 3{
                    messageVC.messageType = .taskMessageType
                }
                self.navigationController?.pushViewController(messageVC, animated: true)
            }
        }else{
            if self.chatArray.count > indexPath.row{
                let model = self.chatArray[indexPath.row]
                var name = "对方"
                var icon = ""
                let dict = LocalData.getChatUserInfo(key: model.conversationId)
                name = dict["name"]!
                icon = dict["icon"]!
                DispatchQueue.global().async {
                    HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
                }
                
                //全部标为已读
                model.markAllMessages(asRead: nil)
                
                if model.conversationId.hasPrefix("kefu"){
                    let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
                    self.navigationController?.pushViewController(chatVC!, animated: true)
                }else{
                    let chatVC = EaseMessageViewController.init(conversationChatter: model.conversationId, conversationType: EMConversationType.init(0))
                    //保存聊天页面数据
                    LocalData.saveChatUserInfo(name: name, icon: icon, key: model.conversationId)
                    chatVC?.title = name
                    self.navigationController?.pushViewController(chatVC!, animated: true)
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 8
        }
        return 0.001
    }
    
}
/**
 {
 "listData" : [
 {
 "unread_num" : "0",
 "msg_title" : "系统消息",
 "msg_type" : "1"
 },
 {
 "unread_num" : "0",
 "msg_title" : "资金消息",
 "msg_type" : "2"
 },
 {
 "unread_num" : "0",
 "msg_title" : "接发单消息",
 "msg_type" : "3"
 }
 ],
 "repMsg" : "",
 "repCode" : "00"
 }
 */
