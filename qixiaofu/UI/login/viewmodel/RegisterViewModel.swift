//
//  RegisterViewModel.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/20.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterViewModel: NSObject {
    
    class func getRegisterCode(params : [String:Any], block : @escaping ((_ json : JSON) -> Swift.Void)){
        NetTools.requestData(type: .post, urlString: VerificationCodeApi, parameters: params, succeed: { (resultDict, error) in
            block(resultDict)
        }) { (error) in
            print(error ?? "没有数据")
            LYProgressHUD.showError(error!)
        }
    }
    
    class func registerAction(params : [String:Any], block : @escaping((_ json : JSON) -> Swift.Void)){
        NetTools.requestData(type: .post, urlString: RegisterApi, parameters: params, succeed: { (resultDict, error) in
            block(resultDict)
            

            //注册加分
            self.addRedits(type:"1")
            
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
     class func addRedits(type:String) {
        //1:注册 2:实名认证 3:完成第一个订单加分
        var params : [String : Any] = [:]
        params["type"] = type
        NetTools.requestData(type: .post, urlString: AddReditsApi, parameters: params, succeed: { (json, msg) in
        }) { (error) in
        }
    }
}

/**
 {
 "listData" : {
 "code" : "3634"
 },
 "repMsg" : "验证码发送成功",
 "repCode" : "00"
 }
 
 
 {
 repCode = "00",
 repMsg = "注册成功",
 listData = 	{
 phone = "18612333016",
 userid = "ffb60a5ab266629a4bf9ac91ddb97fb9",
 tags = 	(
 ),
 store_id = 1,
 store_name = "",
 },
 }
 */
