//
//  NetTools.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/1.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum MethodType : String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

class NetTools: NSObject {
    //请求时间
    var elapsedTime: TimeInterval?
    
    //MARK: - 请求通用的manager
    static let defManager: SessionManager = {
        var defheaders = Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders
        let defConf = URLSessionConfiguration.default
        defConf.timeoutIntervalForRequest = 15
        defConf.httpAdditionalHeaders = defheaders
        return Alamofire.SessionManager(configuration: defConf)
    }()
    
    //MARK: - 后台请求用的manager
    static let backgroundManager: SessionManager = {
        let headers = Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders
        let backgroundConf = URLSessionConfiguration.background(withIdentifier: String(format:"%@.background",[Bundle.main.bundleIdentifier]))
        backgroundConf.httpAdditionalHeaders = headers
        return Alamofire.SessionManager(configuration: backgroundConf)
    }()
    
    //MARK: - 私有会话的manager
    static let ephemeralManager: SessionManager = {
        let headers = Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders
        let ephemeralConf = URLSessionConfiguration.ephemeral
        ephemeralConf.timeoutIntervalForRequest = 8
        ephemeralConf.httpAdditionalHeaders = headers
        return Alamofire.SessionManager(configuration: ephemeralConf)
    }()
    
    //检测网络
    class func checkNetType() -> Bool {
        guard let reachabilityManager = NetworkReachabilityManager.init(host: "www.7xiaofu.com")else{
            return false
        }
        return reachabilityManager.isReachable
    }
    class func checkNetTypeWiFi() -> Bool {
        guard let reachabilityManager = NetworkReachabilityManager.init(host: "www.7xiaofu.com")else{
            return false
        }
        return reachabilityManager.isReachableOnEthernetOrWiFi
    }
    class func checkNetTypeWWAN() -> Bool {
        guard let reachabilityManager = NetworkReachabilityManager.init(host: "www.7xiaofu.com")else{
            return false
        }
        return reachabilityManager.isReachableOnWWAN
    }
}

//通用请求方法
extension NetTools{
    
    /// 通用请求方法
    ///
    /// - Parameters:
    ///   - type: 请求方式
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - succeed: 请求成功时的回调
    ///   - failure: 请求失败时的回调
    static func registRequest(type: MethodType, urlString: String, parameters: [String : Any]? = nil, succeed: @escaping((_ result : Any?, _ error : Error?) -> Swift.Void), failure:@escaping((_ error : Error) -> Swift.Void)){
        //1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        
        let headers: HTTPHeaders = ["Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
                                    "Accept": "text/html",
                                    "application/x-www-form-urlencoded": "charset=utf-8",
                                    "Content-Type": "application/json",
                                    "Content-Length": "12130"
        ]
        
        let start = CACurrentMediaTime()
        //拼接url
        let URL = usedServer + urlString
        
        //2.发送网络请求encoding: URLEncoding.default,
        NetTools.defManager.request(URL, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            let end = CACurrentMediaTime()
            let elapsedTime = end - start
            debugPrint("请求时间 = \(elapsedTime)")
            
            //请求失败
            if response.result.isFailure{
                debugPrint(response.result.error ?? "请求失败，错误原因未知！！")
                failure(response.result.error!)
            }
            
            //请求成功
            if response.result.isSuccess{
                //3.获取结果
                guard let result = response.result.value else{
                    succeed(nil, response.result.error)
                    return
                }
                //4.将结果回调出去
                succeed(result,nil)
            }
        }
    }
    
    
    /// 通用获取数据请求
    ///
    /// - Parameters:
    ///   - type: 请求类型
    ///   - urlString: 请求地址
    ///   - parameters: 请求参数
    ///   - succeed: 请求成功时回调
    ///   - failure: 请求失败时回调
    static func requestData(type: MethodType, urlString: String, parameters: [String : Any]? = nil, succeed: @escaping((_ result: JSON, _ error: String?) -> Swift.Void), failure: @escaping((_ error: String?) -> Swift.Void)){
        
        let token_time = Date.phpTimestamp()
        var token = ("qixiaofu0ab3b4n55nca" + token_time)
        token = token.md5String()
        
        //1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        //2.设置请求头
        let headers : HTTPHeaders = [
            "osType": "android",
            "token": token
            //            "debug" : "1"
        ]
        
        //3.拼接默认参数
        var param : [String : Any]
        if parameters == nil{
            param = [String : Any]()
        }else{
            param = parameters!
        }
        param["token"] = token
        param["token_time"] = token_time
        if (urlString.trim != LoginApi && urlString.trim != VerificationCodeApi && urlString.trim != RegisterApi && urlString.trim != ForgetPwdApi && urlString.trim != EnterpriseRegisterApi && urlString.trim != EnterpriseVerificationCodeApi && urlString.trim != EnterpriseLoginApi && urlString.trim != EnterpriseVertifiForgetPwdApi && urlString.trim != ThirdLoginApi && urlString.trim != BinDingThirdAccountApi){
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                if !(LocalData.getEPUserId().isEmpty){
                    param["userid"] = LocalData.getEPUserId()
                }else{
                    //重新登录
                    showLoginController()
                    return
                }
            }else{
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    if !(LocalData.getEPUserId().isEmpty){
                        param["userid"] = LocalData.getEPUserId()
                    }else{
                        //重新登录
                        showLoginController()
                        return
                    }
                }else{
                    if !(LocalData.getUserId().isEmpty){
                        param["userid"] = LocalData.getUserId()
                    }else{
                        //重新登录
                        showLoginController()
                        return
                    }
                }
            }
            
        }
        
        //4.拼接url
        let URL = usedServer + urlString.trim
        
        #if DEBUG
        var strs : Array<String> = Array<String>()
        for key in param.keys {
            let value  = param[key]
            strs.append(key + "=" + "\(value ?? "")")
        }
        let str = strs.joined(separator: "&")
        debugPrint("-----------URL--------")
        if URL.contains("?"){
            debugPrint(URL + "&" + str)
        }else{
            debugPrint(URL + "?" + str)
        }
        #endif
        
        
        //5.获取网络请求
        NetTools.defManager.request(URL, method: method, parameters: param, encoding: URLEncoding.default, headers:headers).responseJSON { (respose) in
            //请求成功
            if respose.result.isSuccess{
                
                let json = JSON(respose.result.value ?? ["error":"未请求到数据"])
                #if DEBUG
                debugPrint("-----------返回数据--------")
                debugPrint(json)
                #endif
                if json["repCode"].stringValue == "01" && json["repMsg"].stringValue.hasPrefix("请登录"){
                    //登录页
                    showLoginController()
                    return
                }else if json["repCode"].stringValue == "01" && json["repMsg"].stringValue.hasPrefix("无此用户"){
                    //登录页
                    showLoginController()
                    return
                }else if json["repCode"].stringValue == "999" && json["repMsg"].stringValue == "系统维护中"{
                    if LocalData.getYesOrNotValue(key: IsSystemMaintaining){
                        LYProgressHUD.showError("系统维护中...")
                    }else{
                        LYProgressHUD.dismiss()
                        LocalData.saveYesOrNotValue(value: "1", key: IsSystemMaintaining)
                        guard let vc = (AppDelegate.sharedInstance.window?.rootViewController as? UITabBarController)?.selectedViewController?.childViewControllers.last else{
                            //没有获取到当前导航页面--直接展示登录页
                            showLoginController()
                            return
                        }
                        let sysMaintainVC = SystemMaintainingViewController.spwan()
                        let sysMaintainNav = LYNavigationController(rootViewController: sysMaintainVC)
                        vc.present(sysMaintainNav, animated: true, completion: {
                        })
                        return
                    }
                    return
                }else if json["repCode"].stringValue == "01" && json["repMsg"].stringValue == "用户名密码错误" && LocalData.getYesOrNotValue(key: IsSystemMaintaining){
                    LocalData.saveYesOrNotValue(value: "0", key: IsSystemMaintaining)
                    //登录
                    showLoginController()
                    LYProgressHUD.dismiss()
                    return
                }
                
                if json["repCode"].stringValue != "00"{
                    failure( json["repMsg"].stringValue)
                    return
                }
                
                //返回正确结果
                succeed(json["listData"],json["repMsg"].stringValue)
            }
            
            //请求失败
            if respose.result.isFailure{
                #if DEBUG
                debugPrint("-----------错误数据--------")
                debugPrint(respose.result.error ?? "请求失败！")
                #endif
                failure(respose.result.error as? String ?? "网络失去连接,请重试！")
            }
        }
    }
    
    
    static func upLoadImage(urlString: String, imgArray: Array<UIImage>,success : @escaping (_ response : String)->(), failture : @escaping (_ error : String)->()){
        let token_time = Date.phpTimestamp()
        var token = ("qixiaofu0ab3b4n55nca" + token_time)
        token = token.md5String()
        //2.设置请求头
        let headers : HTTPHeaders = [
            "osType": "android",
            "token": token,
            "Content-Type" : "multipart/form-data"
            //            "debug" : "1"
        ]
        let url = usedServer + urlString
        NetTools.defManager.upload(
            multipartFormData: { multipartFormData in
                for i in 0..<imgArray.count{
                    if let imageData = UIImageJPEGRepresentation(imgArray[i], 0.1) {
                        let fileName = "\(Date.timeIntervalBetween1970AndReferenceDate)\(Int(arc4random()%100)+1).png"
                        multipartFormData.append(imageData, withName: "img\(i + 1)", fileName: fileName, mimeType: "img/png")
                    }
                }
                if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                    multipartFormData.append(LocalData.getEPUserId().data(using: .utf8)!, withName: "userid")
                }else{
                    multipartFormData.append(LocalData.getUserId().data(using: .utf8)!, withName: "userid")
                }
        },
            to: url,
            method: HTTPMethod.post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) in
                        let json = JSON(response.result.value ?? ["error":"未请求到数据"])
                        debugPrint(json)
                        if json["repCode"] == "00"{
                            success(json["listData"]["img"].stringValue)
                        }else{
                            failture(json["repMsg"].stringValue)
                        }
                    })
                case .failure(let encodingError):
                    failture("\(encodingError)")
                    debugPrint(encodingError)
                }
        })
    }
    
    static func zipImage(currentImage: UIImage,scaleSize:CGFloat,percent: CGFloat) -> NSData{
        //压缩图片尺寸
        UIGraphicsBeginImageContext(CGSize.init(width: currentImage.size.width*scaleSize, height: currentImage.size.height*scaleSize))
        currentImage.draw(in: CGRect(x: 0, y: 0, width: currentImage.size.width*scaleSize, height:currentImage.size.height*scaleSize))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //高保真压缩图片质量
        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
        let imageData: NSData = UIImageJPEGRepresentation(newImage, percent)! as NSData
        return imageData
    }
    
    
    static func upLoadCustomImage(urlString: String,imgArray: Array<UIImage>, parameters: [String : String]? = nil,success : @escaping (_ response : String)->(), failture : @escaping (_ error : String)->()){
        let token_time = Date.phpTimestamp()
        var token = ("qixiaofu0ab3b4n55nca" + token_time)
        token = token.md5String()
        //2.设置请求头
        let headers : HTTPHeaders = [
            "osType": "android",
            "token": token
            //            "debug" : "1"
        ]
        //3.拼接默认参数
        var param : [String : String]
        if parameters == nil{
            param = [String : String]()
        }else{
            param = parameters!
        }
        param["token"] = token
        param["token_time"] = token_time
        
        let url = usedServer + urlString
        #if DEBUG
        var strs : Array<String> = Array<String>()
        for key in param.keys {
            let value  = param[key]
            strs.append(key + "=" + "\(value ?? "")")
        }
        let str = strs.joined(separator: "&")
        debugPrint("-----------URL--------")
        if url.contains("?"){
            debugPrint(url + "&" + str)
        }else{
            debugPrint(url + "?" + str)
        }
        #endif
        
        NetTools.defManager.upload(
            multipartFormData: { multipartFormData in
                //666多张图片上传
                for img in imgArray{
                    if let imageData = UIImageJPEGRepresentation(img, 0.5) {
                        let fileName = "\(Date.timeIntervalBetween1970AndReferenceDate).png"
                        multipartFormData.append(imageData, withName: "imgFile", fileName: fileName, mimeType: "img/png")
                    }
                    multipartFormData.append(LocalData.getUserId().data(using: .utf8)!, withName: "userid")
                    for key in param.keys{
                        multipartFormData.append(param[key]!.data(using: .utf8)!, withName: key)
                    }
                }
        },
            to: url,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) in
                        let json = JSON(response.result.value ?? ["error":"未请求到数据"])
                        debugPrint(json)
                        if json["repCode"] == "00"{
                            success(json["listData"]["avatar"].stringValue)
                        }else{
                            failture(json["repMsg"].stringValue)
                        }
                    })
                case .failure(let encodingError):
                    failture("\(encodingError)")
                    debugPrint(encodingError)
                }
        })
    }
    
    
    //外部接口调用
    static func requestCustomerApi(type: MethodType, urlString: String, parameters: [String : Any]? = nil, succeed: @escaping((_ result: JSON) -> Swift.Void), failure: @escaping((_ error: String?) -> Swift.Void)){
        //1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        //5.获取网络请求
        NetTools.defManager.request(urlString, method: method, parameters: parameters, encoding: URLEncoding.default).responseJSON { (respose) in
            //请求成功
            if respose.result.isSuccess{
                let json = JSON(respose.result.value ?? ["error":"未请求到数据"])
                #if DEBUG
                debugPrint("-----------返回数据--------")
                debugPrint(json)
                #endif
                //返回正确结果
                succeed(json)
            }
            //请求失败
            if respose.result.isFailure{
                #if DEBUG
                debugPrint("-----------错误数据--------")
                debugPrint(respose.result.error ?? "请求失败！")
                #endif
                failure(respose.result.error as? String ?? "请求失败！")
            }
        }
    }
    
    
    
}


extension NetTools{
    
    /*1.通过请求头告诉服务器，客户端的类型（可以通过修改，欺骗服务器）*/
    class func HeadRequest()
    {
        //(1）设置请求路径
        let url:NSURL = NSURL(string:"http://www.7xiaofu.com/api/index.php?act=login&op=index")!//不需要传递参数
        
        //(2) 创建请求对象
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL) //默认为get请求
        request.timeoutInterval = 5.0 //设置请求超时为5秒
        request.httpMethod = "POST"  //设置请求方法
        
        let token_time = String(format:"%0.f",Date().timeIntervalSince1970 * 1000)
        //                let token_time = Date.phpTimestamp()
        var token = ("qixiaofu0ab3b4n55nca" + token_time)
        token = token.md5String()
        
        //设置请求体
        let param:NSString = NSString(format:"username=18612334016&password=e3ceb5881a0a1fdaad01296d7554868d&client=ios&token=%@&token_time=%@",token,token_time)
        //把拼接后的字符串转换为data，设置请求体
        request.httpBody = param.data(using: String.Encoding.utf8.rawValue)
        
        //客户端类型，只能写英文
        request.setValue("android", forHTTPHeaderField:"osType")
        request.setValue(token, forHTTPHeaderField:"token")
        
        //(3) 发送请求
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue:OperationQueue()) { (res, data, error)in
            //服务器返回：请求方式 = POST，返回数据格式 = JSON，用户名 = 123，密码 = 123
            let  str = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
            debugPrint(str!)
        }
    }
    
    class func requestDataTest(urlString: String, parameters: [String : Any]? = nil, succeed: @escaping((_ result: JSON) -> Swift.Void), failure: @escaping((_ error: String?) -> Swift.Void))
    {
        
        let token_time = Date.phpTimestamp()
        var token = ("qixiaofu0ab3b4n55nca" + token_time)
        token = token.md5String()
        //3.拼接默认参数
        var param : [String : Any]
        if parameters == nil{
            param = [String : Any]()
        }else{
            param = parameters!
        }
        param["token"] = token
        param["token_time"] = token_time
        if (urlString != LoginApi && urlString != VerificationCodeApi && urlString != RegisterApi && urlString != ForgetPwdApi){
            if !(LocalData.getUserId().isEmpty){
                param["userid"] = LocalData.getUserId()
            }else{
                //重新登录
                showLoginController()
                return
            }
        }
        
        //4.拼接url
        let URL = usedServer + urlString
        
        var strs : Array<String> = Array<String>()
        for key in param.keys {
            let value  = param[key]
            strs.append(key + "=" + "\(value ?? "")")
        }
        let str = strs.joined(separator: "&")
        
        
        //(2) 创建请求对象
        let request:NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string:URL)! as URL) //默认为get请求
        request.timeoutInterval = 10.0 //设置请求超时为5秒
        request.httpMethod = "POST"  //设置请求方法
        
        
        //设置请求体
        let param222:NSString = NSString(format:str as NSString)
        //把拼接后的字符串转换为data，设置请求体
        request.httpBody = param222.data(using: String.Encoding.utf8.rawValue)
        
        //客户端类型，只能写英文
        request.setValue("android", forHTTPHeaderField:"osType")
        request.setValue(token, forHTTPHeaderField:"token")
        
        //(3) 发送请求
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue:OperationQueue()) { (res, data, error)in
            //服务器返回：请求方式 = POST，返回数据格式 = JSON，用户名 = 123，密码 = 123
            let  str = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
            debugPrint(str!)
        }
    }
    
}

extension NetTools{
    class func requestLYData(type: MethodType,urlString: String, parameters: [String : Any]? = nil, succeed: @escaping((_ result: JSON) -> Swift.Void), failure: @escaping((_ error: String?) -> Swift.Void))
    {
        let urlStr = "https://www.liyong.work/" + urlString
        //(2) 创建请求对象
        let request:NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string:urlStr)! as URL) //默认为get请求
        request.timeoutInterval = 10.0 //设置请求超时为5秒
        request.httpMethod = type == .get ? HTTPMethod.get.rawValue : HTTPMethod.post.rawValue  //设置请求方法
        
        if parameters != nil{
            var strs : Array<String> = Array<String>()
            for key in parameters!.keys {
                let value  = parameters![key]
                strs.append(key + "=" + "\(value ?? "")")
            }
            let str = strs.joined(separator: "&")
            //设置请求体
            let param222:NSString = NSString(format:str as NSString)
            //把拼接后的字符串转换为data，设置请求体
            request.httpBody = param222.data(using: String.Encoding.utf8.rawValue)
        }
        
        //(3) 发送请求
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue:OperationQueue()) { (res, data, error)in
            //服务器返回：请求方式 = POST，返回数据格式 = JSON，用户名 = 123，密码 = 123
            if data != nil{
                let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                succeed(JSON(json!))
            }else{
                failure("请求失败！")
            }
            
        }
    }
    
    //收集app的点击量
    /**
     type：
     0:测试
     1:发单
     2:接单列表
     3:首页下部分类的点击
     4:首页顶部banner点击
     5:广告点击
     6:商城banner点击
     7:商品详情点击
     8:附加软件
     9:代测点击
     10:培训详情
     11:视频详情
     12:知识库详情
     13:
     */
    class func qxfClickCount(_ type: String) {
        //        DispatchQueue.global().async {
        //            var params : [String : Any] = [:]
        //            params["click_man"] = LocalData.getUserPhone()
        //            params["click_type"] = type
        //            NetTools.requestLYData(type: .post, urlString: "qxf/click", parameters: params, succeed: { (result) in
        //            }) { (error) in
        //            }
        //        }
    }
    
    
}


//腾讯OCR
extension NetTools {
    /// 通用请求方法
    ///
    /// - Parameters:
    ///   - type: 请求方式
    ///   - urlString: 请求地址
    ///   - parameters: 参数
    ///   - succeed: 请求成功时的回调
    ///   - failure: 请求失败时的回调
    static func registOCRRequest(type: MethodType, parameters: [String : Any]? = nil, succeed: @escaping((_ result : Any?, _ error : Error?) -> Swift.Void), failure:@escaping((_ error : Error) -> Swift.Void)){
        //1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        
        let headers: HTTPHeaders = ["Authorization": "LzU5c47TbzCwtHT2RJBOp4TaGSo=",
                                    "Accept": "text/html",
                                    "application/x-www-form-urlencoded": "charset=utf-8",
                                    "Content-Type": "application/json",
                                    "Content-Length": "12130",
                                    "host": "recognition.image.myqcloud.com"
        ]
        
        let start = CACurrentMediaTime()
        //拼接url
        let URL = "https://recognition.image.myqcloud.com/ocr/general"
        
        //2.发送网络请求encoding: URLEncoding.default,
        NetTools.defManager.request(URL, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            let end = CACurrentMediaTime()
            let elapsedTime = end - start
            debugPrint("请求时间 = \(elapsedTime)")
            
            //请求失败
            if response.result.isFailure{
                debugPrint(response.result.error ?? "请求失败，错误原因未知！！")
                failure(response.result.error!)
            }
            
            //请求成功
            if response.result.isSuccess{
                //3.获取结果
                guard let result = response.result.value else{
                    succeed(nil, response.result.error)
                    return
                }
                //4.将结果回调出去
                succeed(result,nil)
            }
        }
    }
    
    
}
