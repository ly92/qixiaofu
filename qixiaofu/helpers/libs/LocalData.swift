//
//  LocalData.swift
//  qixiaofu
//   _
//  | |      /\   /\
//  | |      \ \_/ /
//  | |       \_~_/
//  | |        / \
//  | |__/\    [ ]
//  |_|__,/    \_/
//
//  Created by 李勇 on 2017/5/30.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//
//  __________________________________________________
// |                    _                             |
// | /|,/ _   _ _      / ` /_  _ .  _ _/_ _ _   _    _|
// |/  / /_' / / /_/  /_, / / / / _\  /  / / / /_| _\ |
// |             _/                                   |
// |                 ~~** liwu19 **~~                 |
// |__________________________________________________|
//
//
//                       ___
//                    /`   `'.
//                   /   _..---;
//                   |  /__..._/  .--.-.
//                   |.'  e e | ___\_|/____
//                  (_)'--.o.--|    | |    |
//                 .-( `-' = `-|____| |____|
//                /  (         |____   ____|
//                |   (        |_   | |  __|
//                |    '-.--';/'/__ | | (  `|
//                |      '.   \    )"";--`\ /
//                \        ;   |--'    `;.-'
//                |`-.__ ..-'--'`;..--'`
//
// :*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*
//
import UIKit
import SwiftyJSON

enum LaunchDetailType : String {
    case ProjectDetailType = "1"
    case GoodsDetailType = "2"
    case VideoDetailType = "3"
    case TestReportDetailType = "4"
}


let KUserModelKey = "KUserModelKey" + appVersion()
let KUserIdKey = "KUserIdKey"
let KEPUserIdKey = "KEPUserIdKey"
let KUserIdNotMd5Key = "KUserIdNotMd5Key"
let KUserNameKey = "KUserNameKey" + appVersion()
let KUserTrueNameKey = "KUserTrueNameKey" + appVersion()
let KUserPhoneKey = "KUserPhoneKey"
let KUserResumeKey = "KUserResumeKey"
let KUserInviteCodeKey = "KUserInviteCodeKey" + appVersion()
let KSearchHistoryKey = "KSearchHistoryKey"
let KSendTaskKey = "KSendTaskKey" + LocalData.getUserPhone()
let KSupplyTaskKey = "KSupplyTaskKey" + LocalData.getUserPhone()
let KEaseMobListKey = "KEaseMobListKey"
let KEaseMobChatUserKey = "KEaseMobChatUserKey"
let KLaunchAppInfoKey = "KLaunchAppInfoKey"
let KIsLaunchInfoFromAppWebKey = "KIsLaunchInfoFromAppWebKey"
let KPayCoffeKey = "KPayCoffeKey" + LocalData.getUserPhone()
let KWalletMoneyKey = "KWalletMoneyKey" + LocalData.getUserPhone()
let KBeanCountKey = "KBeanCountKey" + LocalData.getUserPhone()
let KCreditsCountKey = "KCreditsCountKey" + LocalData.getUserPhone()
let KEnterpriseVersion = "KEnterpriseVersion"//企业版还是个人版

class LocalData: NSObject {

    // MARK: - UserDefaults
    
    // MARK: - base
    // 删除UserDefaults记录的所有数据
    class func removeAllLocalData(){
        guard let appDomain = Bundle.main.bundleIdentifier else {return}
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    //通过key删除数据
    class func removeLocalData(key: String){
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - 获取存储数据的bool值,1为Yes,0为No
    class func saveYesOrNotValue(value: String, key: String){
        //对记录登录特殊处理
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func getYesOrNotValue(key: String) -> Bool{
        let value = UserDefaults.standard.value(forKey:key)
        if (value == nil || value as! String == "0"){
            return false
        }else{
            return true
        }
    }
    
    //MARK: 搜索历史-最多存储12条
    class func saveSearchHistory(searchWord:String){
    var value = self.getSearchHistoryArray()
        if value.contains(searchWord) {
            value.remove(at: value.index(of: searchWord)!)
        }
        if value.count > 11{
            value.removeLast()
            UserDefaults.standard.setValue(value, forKey: KSearchHistoryKey)
            UserDefaults.standard.synchronize()
            self.saveSearchHistory(searchWord: searchWord)
            return
        }
        value.insert(searchWord, at: 0)
        UserDefaults.standard.setValue(value, forKey: KSearchHistoryKey)
        UserDefaults.standard.synchronize()
    }
    class func getSearchHistoryArray() ->Array<String>{
        let value = UserDefaults.standard.value(forKey:KSearchHistoryKey)
        if value != nil{
            let array = value as! Array<String>
            if array.count > 0{
                return array
            }
        }
        return Array()
    }
    class func removeSearchHistory(){
        var value = self.getSearchHistoryArray()
        value.removeAll()
        UserDefaults.standard.setValue(value, forKey: KSearchHistoryKey)
        UserDefaults.standard.synchronize()
    }

//    // MARK: - 获取UserModel
//    class func saveUserModelObject(model: UserModel){
//        UserDefaults.standard.setValue(model, forKey: KUserModelKey)
//        UserDefaults.standard.synchronize()
//    }
//    class func getUserModelObject() -> UserModel{
//        let userModel = UserDefaults.standard.value(forKey:KUserModelKey)
//        if (userModel == nil){
//            return UserModel(dict: ["userid" : ""])
//        }else{
//            return userModel as! UserModel
//        }
//    }
    
    // MARK: - 获取UserId
    class func saveUserId(userId: String){
        UserDefaults.standard.setValue(userId, forKey: KUserIdKey)
        UserDefaults.standard.synchronize()
    }
    class func getUserId() -> String{
        let userId = UserDefaults.standard.value(forKey:KUserIdKey)
        if (userId == nil){
            return ""
        }else{
            return userId as! String
        }
    }
    // MARK: - 获取企业购UserId
    class func saveEPUserId(userId: String){
        UserDefaults.standard.setValue(userId, forKey: KEPUserIdKey)
        UserDefaults.standard.synchronize()
    }
    class func getEPUserId() -> String{
        let userId = UserDefaults.standard.value(forKey:KEPUserIdKey)
        if (userId == nil){
            return ""
        }else{
            return userId as! String
        }
    }
    class func saveNotMd5UserId(userId: String){
        UserDefaults.standard.setValue(userId, forKey: KUserIdNotMd5Key)
        UserDefaults.standard.synchronize()
    }
    class func getNotMd5UserId() -> String{
        let userId = UserDefaults.standard.value(forKey:KUserIdNotMd5Key)
        if (userId == nil){
            return ""
        }else{
            return userId as! String
        }
    }
    
    // MARK: - 服豆个数
    class func saveBeanCount(bean: String){
        UserDefaults.standard.setValue(bean, forKey: KBeanCountKey)
        UserDefaults.standard.synchronize()
    }
    class func getBeanCount() -> String{
        let bean = UserDefaults.standard.value(forKey:KBeanCountKey)
        if (bean == nil){
            return ""
        }else{
            return bean as! String
        }
    }
    
    // MARK: - 积分数
    class func saveCreditsCount(bean: String){
        UserDefaults.standard.setValue(bean, forKey: KCreditsCountKey)
        UserDefaults.standard.synchronize()
    }
    class func getCreditsCount() -> String{
        let bean = UserDefaults.standard.value(forKey:KCreditsCountKey)
        if (bean == nil){
            return ""
        }else{
            return bean as! String
        }
    }
    
    // MARK: - 获取Username
    class func saveUserName(userName: String){
        UserDefaults.standard.setValue(userName, forKey: KUserNameKey)
        UserDefaults.standard.synchronize()
    }
    class func getUserName() -> String{
        let userName = UserDefaults.standard.value(forKey:KUserNameKey)
        if (userName == nil){
            return ""
        }else{
            return userName as! String
        }
    }
    
    class func saveTrueUserName(userName: String){
        UserDefaults.standard.setValue(userName, forKey: KUserTrueNameKey)
        UserDefaults.standard.synchronize()
    }
    class func getTrueUserName() -> String{
        let userName = UserDefaults.standard.value(forKey:KUserTrueNameKey)
        if (userName == nil){
            return ""
        }else{
            return userName as! String
        }
    }
    
    // MARK: - 获取User phone
    class func saveUserPhone(phone: String){
        //设置推送别名
        JPUSHService.setAlias(phone, completion: { (isResCode, alias, seq) in
        }, seq:0)
        UserDefaults.standard.setValue(phone, forKey: KUserPhoneKey)
        UserDefaults.standard.synchronize()
    }
    class func getUserPhone() -> String{
        let phone = UserDefaults.standard.value(forKey:KUserPhoneKey)
        if (phone == nil){
            return ""
        }else{
            return phone as! String
        }
    }
    // MARK: - 获取User resume
    class func saveUserResume(resume: String){
        UserDefaults.standard.setValue(resume, forKey: KUserResumeKey)
        UserDefaults.standard.synchronize()
    }
    class func getUserResume() -> String{
        let resume = UserDefaults.standard.value(forKey:KUserResumeKey)
        if (resume == nil){
            return ""
        }else{
            return resume as! String
        }
    }
    // MARK: - 获取User 邀请码
    class func saveUserInviteCode(phone: String){
        UserDefaults.standard.setValue(phone, forKey: KUserInviteCodeKey)
        UserDefaults.standard.synchronize()
    }
    class func getUserInviteCode() -> String{
        let phone = UserDefaults.standard.value(forKey:KUserInviteCodeKey)
        if (phone == nil){
            return ""
        }else{
            return phone as! String
        }
    }
    
    // MARK: - 获取发单的草稿记录
    class func saveSendTaskData(dict: [String : Any]){
        UserDefaults.standard.setValue(dict, forKey: KSendTaskKey)
        UserDefaults.standard.synchronize()
    }
    class func getSendTaskData() -> [String : Any]{
        let dict = UserDefaults.standard.value(forKey:KSendTaskKey)
        if (dict == nil){
            return [String : Any]()
        }else{
            return dict as! [String : Any]
        }
    }
    // MARK: - 获取补单的草稿记录
    class func saveSupplyTaskData(dict: [String : Any]){
        UserDefaults.standard.setValue(dict, forKey: KSupplyTaskKey)
        UserDefaults.standard.synchronize()
    }
    class func getSupplyTaskData() -> [String : Any]{
        let dict = UserDefaults.standard.value(forKey:KSupplyTaskKey)
        if (dict == nil){
            return [String : Any]()
        }else{
            return dict as! [String : Any]
        }
    }

    
    
    
    
    
    //MARK: - 归档
    //存储
    class func Archiver(object:Any, path:String){
        NSKeyedArchiver.archiveRootObject(object, toFile: path)
    }
    //读取
    class func UnArchiver(path: String) -> Any{
        return NSKeyedUnarchiver.unarchiveObject(withFile:path)!
    }
    
    
    
    //MARK: - 环信聊天数据保存
    //根据环信账号（手机号）保存icon和name
    class func saveChatUserInfo(name:String, icon:String, key:String){
        if key.hasPrefix("kefu"){
            let dict = ["name" : "客服", "icon" : "http://www.7xiaofu.com/img/logo.png"]
            UserDefaults.standard.setValue(dict, forKey: KEaseMobListKey+key)
            UserDefaults.standard.synchronize()
        }else{
            let dict = ["name" : name, "icon" : icon]
            UserDefaults.standard.setValue(dict, forKey: KEaseMobListKey+key)
            UserDefaults.standard.synchronize()
        }
    }
    class func getChatUserInfo(key:String) -> [String : String]{
        //客服
        if key.isEmpty{
            var dict2 : [String : String] = [String : String]()
            dict2["name"] = "未知"
            dict2["icon"] = ""
            return dict2
        }
        if key.hasPrefix("kefu"){
            var dict2 : [String : String] = [String : String]()
            dict2["name"] = "客服"
            dict2["icon"] = "http://www.7xiaofu.com/img/logo.png"
            return dict2
        }else{
            let dict = UserDefaults.standard.value(forKey:KEaseMobListKey+key)
            if (dict == nil){
                var dict3 : [String : String] = [String : String]()
                NetTools.requestData(type: .post, urlString: UserInfoApi, parameters: ["phone":key], succeed: { (result, msg) in
                    var name = result["member_nik_name"].stringValue
                    if name.isEmpty{
                        name = result["member_id"].stringValue
                    }
                    self.saveChatUserInfo(name: name, icon: result["touxiang"].stringValue, key: key)
                    dict3["name"] = name
                    dict3["icon"] = result["touxiang"].stringValue
                }, failure: { (error) in
                })
                
                if dict3.keys.count == 2{
                    return dict3
                }
                var dict2 : [String : String] = [String : String]()
                dict2["name"] = "未知"
                dict2["icon"] = ""
                return dict2
            }else{
                return dict as! [String : String]
            }
        }
    }
    
    //记录从网页打开app的时候传的值
    class func getLaunchTypeAndId() -> [String:String]?{
        let dict = UserDefaults.standard.value(forKey:KLaunchAppInfoKey)
        if (dict == nil){
            return nil
        }else{
            return dict as? [String : String]
        }
    }
    class func setLaunchTypeAndId(type:LaunchDetailType?, idStr:String?){
        if type == nil || idStr == nil{
            UserDefaults.standard.removeObject(forKey: KLaunchAppInfoKey)
        }else{
            let dict : [String:String] = ["type" : type!.rawValue, "idStr" : idStr!]
            UserDefaults.standard.setValue(dict, forKey: KLaunchAppInfoKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    //支付条形码支付金钱 1:零钱 2:服豆
    class func saveLocalPayType(type: String){
        UserDefaults.standard.setValue(type, forKey: KPayCoffeKey)
        UserDefaults.standard.synchronize()
    }
    class func getLocalPayType() -> String{
        let type = UserDefaults.standard.value(forKey:KPayCoffeKey)
        if (type == nil){
            return "1"
        }else{
            return type as! String
        }
    }
    
    //钱包零钱
    class func saveWalletMoney(money: String?){
        if money == nil{
            UserDefaults.standard.setValue("0", forKey: KWalletMoneyKey)
        }else{
            UserDefaults.standard.setValue(money, forKey: KWalletMoneyKey)
        }
        UserDefaults.standard.synchronize()
    }
    class func getWalletMoney() -> String{
        let money = UserDefaults.standard.value(forKey:KWalletMoneyKey)
        if (money == nil){
            return "0"
        }else{
            return money as! String
        }
    }
    
    
    //MARK: 红点记录
    class func savePointNum(num:Int){
        var value = self.getPointNumArray()
        if value.contains(num) {
            return
        }
        value.append(num)
        UserDefaults.standard.setValue(value, forKey: "KRedPointNumKey")
        UserDefaults.standard.synchronize()
    }
    class func getPointNumArray() ->Array<Int>{
        let value = UserDefaults.standard.value(forKey:"KRedPointNumKey")
        if value != nil{
            let array = value as! Array<Int>
            return array
        }
        return [7,11]
    }
    class func removePointNum(num:Int){
        var value = self.getPointNumArray()
        guard let index = value.index(of: num) else {
            return
        }
        if value.contains(num){
            value.remove(at: index)
        }
        UserDefaults.standard.setValue(value, forKey: "KRedPointNumKey")
        UserDefaults.standard.synchronize()
    }
    class func ContentPointNum(num:Int) ->Bool{
        let value = self.getPointNumArray()
        if value.contains(num){
            return true
        }
        return false
    }
    
    
    
//    //MARK: - userModel
//    class func archiverUserModel(object:UserModel){
//        NSKeyedArchiver.archiveRootObject(object, toFile: KUserModelKey)
//    }
//    //读取
//    class func unArchiverUserModel() -> UserModel{
//        return NSKeyedUnarchiver.unarchiveObject(withFile:KUserModelKey)! as! UserModel
//    }
//    
    
}
