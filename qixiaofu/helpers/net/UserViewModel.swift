//
//  UserViewModel.swift
//  qixiaofu
//
//  Created by ly on 2017/6/20.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//


import UIKit
import SwiftyJSON

class UserModelResult: NSObject {
    var listData : [String : NSObject]?{
        didSet{
            guard let listData = listData else  { return }
            userModel = UserModel(dict: listData)
        }
    }
    var userModel : UserModel!
    var repMsg : String!
    var repCode : String!
    init(dict : [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) { }
}

class UserModel: NSObject {
    var count_bill_integral : String!
    var working_time : String!
    var serviceSectorModels = [Service]()
    var service_sector : [[String : NSObject]]?{
        didSet{
            guard let service_sector = service_sector else { return }
            for dict in service_sector {
                serviceSectorModels.append(Service(dict: dict))
            }
        }
    }
    var count_integral : String!
    var service_brand : String!
    var member_avatar : String!
    var is_paypwd : String!
    var is_real : String!
    var member_nik_name : String!
    var iv_code : String!
    var count_bill : String!
    var member_level : String!
    var member_id : String!
    var cerImageModels = [CerImage]()
    var cer_images : [[String : NSObject]]?{
        didSet{
            guard let cer_images = cer_images else {return}
            for dict in cer_images {
                cerImageModels.append(CerImage(dict:dict))
            }
        }
    }
    init(dict : [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) { }
}

class Service: NSObject {
    var gc_id : String!
    var gc_name : String!
    
    init(dict : [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) { }
}

class CerImage: NSObject {
    var cer_image_name : String!
    var cer_image_type : String!
    //    var cer_id : NSNumber!
    var cer_image : String!
    
    init(dict : [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) { }
}


class UserViewModel: NSObject {
    
    class func loadUserInfo(userModelBlock: @escaping((_ userModel: JSON) -> Swift.Void)) {
        NetTools.requestData(type: .post, urlString: ShowMemberInfoApi, succeed: { (resultDict, error) in
            //            let userModel = UserModel.init(dict: resultDict as! Dictionary)
            
            userModelBlock(resultDict)
        }) { (error) in
            LYProgressHUD.showError( error!)
        }
    }
    
    
    //判断是否已实名认证
    class func haveTrueName(parentVC : UIViewController, _ block : @escaping (() -> Void)) {
        //判断是否实名
        if LocalData.getYesOrNotValue(key: IsTrueName){
            block()
        }else{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                NetTools.requestData(type: .post, urlString: EnterpriseCenterApi, succeed: { (resultJson, msg) in
                    LYProgressHUD.dismiss()
                    
                    if resultJson["is_real"].stringValue.intValue == 1{
                        LocalData.saveYesOrNotValue(value: "1", key: IsTrueName)
                        block()
                    }else if resultJson["is_real"].stringValue.intValue == 2{
                        LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
                        LYAlertView.show("提示", "实名信息审核中", "知道了",{
                        })
                    }else{
                        LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
                        LYAlertView.show("提示", "您尚未进行实名认证，请您先去认证", "取消","去认证",{
                            //实名认证
                            let idVC = IdentityViewController.spwan()
                            parentVC.navigationController?.pushViewController(idVC, animated: true)
                        })
                    }
                }) { (error) in
                    LYAlertView.show("提示", "您尚未进行实名认证，请您先去认证", "取消","去认证",{
                        //实名认证
                        let idVC = IdentityViewController.spwan()
                        parentVC.navigationController?.pushViewController(idVC, animated: true)
                    })
                }
            }else{
                NetTools.requestData(type: .post, urlString: PersonalInfoApi, succeed: { (resultJson, msg) in
                    //保存是否实名
                    if resultJson["is_real"].stringValue.intValue == 1{
                        //已实名
                        LocalData.saveYesOrNotValue(value: "1", key: IsTrueName)
                        block()
                    }else if resultJson["is_real"].stringValue.intValue == 2{
                        //已实名
                        LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
                        LYAlertView.show("提示", "实名信息审核中", "知道了",{
                        })
                    }else{
                        //未实名
                        LocalData.saveYesOrNotValue(value: "0", key: IsTrueName)
                        LYAlertView.show("提示", "您尚未进行实名认证，请您先去认证", "取消","去认证",{
                            //实名认证
                            let idVC = IdentityViewController.spwan()
                            parentVC.navigationController?.pushViewController(idVC, animated: true)
                        })
                    }
                }) { (error) in
                    LYAlertView.show("提示", "您尚未进行实名认证，请您先去认证", "取消","去认证",{
                        //实名认证
                        let idVC = IdentityViewController.spwan()
                        parentVC.navigationController?.pushViewController(idVC, animated: true)
                    })
                }
            }
        }
    }
    
    
    
    
    
    
}

/**
 {
 listData =     {
 "is_real" = 1;
 "store_id" = 1;
 "store_name" = "";
 tags =         (
 );
 userid = 84422938c32c2f8f5c83d825e2df17b3;
 username = 18612334016;
 };
 repCode = 00;
 repMsg = "\U767b\U5f55\U6210\U529f";
 }
 
 
 
 {
 "listData" : {
 "count_bill_integral" : "1",
 "working_time" : "1495841940",
 "service_sector" : [
 {
 "gc_id" : "4",
 "gc_name" : "X86服务器"
 },
 {
 "gc_id" : "7",
 "gc_name" : "监控设备"
 },
 {
 "gc_id" : "10",
 "gc_name" : "数据库"
 }
 ],
 "count_integral" : "0",
 "service_brand" : "",
 "member_avatar" : "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-06-06\/~UPLOAD~sys~2017-06-06@1496757625.jpg240",
 "is_paypwd" : "1",
 "is_real" : "1",
 "member_nik_name" : "16",
 "cer_images" : [
 {
 "cer_image_name" : "测试",
 "cer_image_type" : "10",
 "cer_id" : 1,
 "cer_image" : "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-06-20\/~UPLOAD~sys~2017-06-20@1497964445.png"
 }
 ],
 "iv_code" : "701005",
 "count_bill" : "4",
 "member_level" : "C",
 "member_id" : "1005"
 },
 "repMsg" : "",
 "repCode" : "00"
 }
 
 
 */
