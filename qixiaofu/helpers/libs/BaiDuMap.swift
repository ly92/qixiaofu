//
//  BaiDuUserLocation.swift
//  qixiaofu
//
//  Created by ly on 2018/6/8.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class BaiDuMap: NSObject {
    //单例
    static let `default` = BaiDuMap()
    
    //定位
    fileprivate var locationService = BMKLocationService()
    //记录当前位置
    fileprivate var location : BMKUserLocation?
    
    fileprivate var haveAlert = false
    
    func startLocation() {
        //初始化定位管理
        self.locationService.delegate = self
        self.locationService.startUserLocationService()
    }
    
    func getUserLocal() -> CLLocationCoordinate2D? {
        return self.location?.location.coordinate
    }
    
    func startTrace() {
        return
        
        //开始记录位置
        let sop = BTKServiceOption.init(ak: KBmapKey, mcode: "com.qixiaofu.7xf", serviceID: 201147, keepAlive: false)
        BTKAction.sharedInstance().initInfo(sop)
        let op = BTKStartServiceOption.init(entityName: LocalData.getUserPhone())
        BTKAction.sharedInstance().startService(op, delegate: self)
        BTKAction.sharedInstance().startGather(self)
    }
    
    func stopTrace() {
        return
            
        //结束记录位置
        BTKAction.sharedInstance().stopService(self)

    }
}


//MARK: - BMKLocationServiceDelegate
extension BaiDuMap : BMKLocationServiceDelegate{

    func didUpdate(_ userLocation: BMKUserLocation!) {
        //记录位置
        self.location = userLocation
        //停止定位
        self.locationService.stopUserLocationService()
    }
    
    func didFailToLocateUserWithError(_ error: Error!) {
        LYAlertView.show("提示", "请检查网络或者定位服务是否开启", "取消", "去设置", {
            //打开设置页面
            let url = URL(string:UIApplicationOpenSettingsURLString)
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.openURL(url!)
            }
        })
    }
 
}


extension BaiDuMap : BTKTraceDelegate{
    func onGet(_ message: BTKPushMessage!) {
        if message.type == 0x03{
            let content = message.content as! BTKPushMessageFenceAlarmContent
            if Int(content.actionType.rawValue) == 1{
                print(content.monitoredObject)
                print("进入")
                print(content.fenceName)
            }else if Int(content.actionType.rawValue) == 2{
                print(content.monitoredObject)
                print("离开")
                print(content.fenceName)
            }
        }else if message.type == 0x04{
            let content = message.content as! BTKPushMessageFenceAlarmContent
            if Int(content.actionType.rawValue) == 1{
                print(content.monitoredObject)
                print("进入")
                print(content.fenceName)
            }else if Int(content.actionType.rawValue) == 2{
                print(content.monitoredObject)
                print("离开")
                print(content.fenceName)
            }
        }
    }
    func onStartService(_ error: BTKServiceErrorCode) {
        print(error.hashValue)
    }
    func onStartGather(_ error: BTKGatherErrorCode) {
        print(error.hashValue)
        if error.hashValue == 4{
            if !self.haveAlert{
                DispatchQueue.main.async {
                    LYAlertView.show("提示", "请设置始终允许位置服务，否则无法获取后台定位服务！", "取消", "去设置", {
                        //打开设置页面
                        let url = URL(string:UIApplicationOpenSettingsURLString)
                        if UIApplication.shared.canOpenURL(url!){
                            UIApplication.shared.openURL(url!)
                        }
                        self.haveAlert = false
                    },{
                        self.haveAlert = false
                    })
                }
                self.haveAlert = true
            }
            
        }
    }
    func onStopGather(_ error: BTKGatherErrorCode) {
        print(error.hashValue)
    }
    func onStopService(_ error: BTKServiceErrorCode) {
        print(error.hashValue)
    }
    func onSetCacheMaxSize(_ error: BTKSetCacheMaxSizeErrorCode) {
        print(error.hashValue)
    }
}
